import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../common/widgets/app_icon_source.dart';
import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../common/widgets/empty_state_widget.dart';
import '../../../../../common/widgets/failed_state_widget.dart';
import '../../../../../common/widgets/scroll_reveal.dart';
import '../../../../../core/services/storage/last_visit.dart';
import '../../../../../core/utils/bloc_status.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/helpers/app_formats.dart';
import '../../../../../utils/helpers/app_strings.dart';
import '../../../../root/presentation/ui/widgets/nav_bar/app_bottom_nav.dart';
import '../../../../root/presentation/ui/widgets/nav_bar/navigation_controller.dart';
import '../../../../root/presentation/ui/widgets/nav_bar/navigation_scope.dart';
import '../../../domain/feed_entities.dart';
import '../../states/feed_bloc.dart';
import 'feed_cards.dart';
import 'feed_header.dart';
import 'feed_navigation.dart';

/// The feed page: a header over one lazy scroll view of independent
/// sections and a paged list.
///
/// ```text
/// ┌─ header        greeting · settings          (opening choreography)
/// │               [ search … rotating hint ]    hides on scroll down
/// │               recent searches
/// ├─ highlights    peek carousel                AppLazySection
/// ├─ picks         rail + «2 new» + count-up    AppLazySection
/// ├─ latest        paged list, reveal on scroll, SkeletonMore at the end
/// └─ back-to-top · pull to refresh · reselect the tab to go to the top
/// ```
///
/// The sections live in a `CustomScrollView` with a 400dp cache extent, so a
/// section is built — and therefore asks for its data — only when it is
/// about to scroll into view.
class FeedBody extends StatefulWidget {
  const FeedBody({super.key});

  /// How far ahead of the viewport a section is built, and so requested.
  static const double sectionCacheExtent = 400;

  /// The next page is asked for this far from the end of the list.
  static const double loadMoreThreshold = 600;

  /// The widest the column gets on a tablet or a landscape phone.
  static const double maxContentWidth = 640;

  @override
  State<FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<FeedBody>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final LastVisit _lastVisit = LastVisit('feed');

  /// The opening choreography: header, then search, then the first section.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: AppIntro.duration,
  );

  NavigationController? _navigation;
  int _lastReselectToken = 0;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    unawaited(_lastVisit.load());
    FeedNavigation.searchIntent.pending.addListener(_onSearchIntent);
    // Another tab may have asked for a search before this one was built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onSearchIntent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppIntro.play(context, _intro, id: 'feed');
    final navigation = NavigationScope.maybeOf(context);
    if (identical(navigation, _navigation)) return;
    _navigation?.removeListener(_onNavigationChanged);
    _navigation = navigation;
    _lastReselectToken = navigation?.reselectToken ?? 0;
    navigation?.addListener(_onNavigationChanged);
  }

  @override
  void dispose() {
    FeedNavigation.searchIntent.pending.removeListener(_onSearchIntent);
    _navigation?.removeListener(_onNavigationChanged);
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _intro.dispose();
    super.dispose();
  }

  void _onSearchIntent() {
    if (!mounted) return;
    final query = FeedNavigation.searchIntent.take();
    if (query == null) return;
    context.read<FeedBloc>().add(FeedEvent.querySubmitted(query));
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final bloc = context.read<FeedBloc>();
    bloc.add(FeedEvent.scrolled(position.pixels));

    if (position.maxScrollExtent - position.pixels <
        FeedBody.loadMoreThreshold) {
      bloc.add(const FeedEvent.loadMore());
    }

    final scrolled = position.pixels > 0;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  /// A tap on the active tab brings the list back to the top.
  void _onNavigationChanged() {
    final navigation = _navigation;
    if (navigation == null) return;
    if (navigation.reselectToken == _lastReselectToken) return;
    _lastReselectToken = navigation.reselectToken;
    if (navigation.currentIndex != FeedNavigation.tabIndex ||
        !_scroll.hasClients) {
      return;
    }
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: AppCurves.enter,
    );
  }

  Future<void> _refresh() async {
    final bloc = context.read<FeedBloc>()..add(const FeedEvent.refreshed());
    // The indicator stays until the list has answered; the sections follow
    // on their own and each swaps its skeleton out as it lands.
    await bloc.stream
        .firstWhere((s) => !s.listState.isLoading)
        .timeout(const Duration(seconds: 10), onTimeout: () => bloc.state);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = AppBottomNav.listBottomPadding(context);
    return Column(
      children: <Widget>[
        FeedHeader(isScrolled: _isScrolled, intro: _intro),
        Expanded(
          child: Stack(
            children: <Widget>[
              AppRefresh(
                onRefresh: _refresh,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: FeedBody.maxContentWidth,
                    ),
                    child: CustomScrollView(
                      controller: _scroll,
                      // Always draggable, or pull-to-refresh dies the moment
                      // a search leaves fewer rows than fill the screen.
                      physics: const AlwaysScrollableScrollPhysics(),
                      scrollCacheExtent: const ScrollCacheExtent.pixels(
                        FeedBody.sectionCacheExtent,
                      ),
                      slivers: <Widget>[
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.sm),
                        ),
                        _Sections(intro: _intro, lastVisit: _lastVisit),
                        const _LatestList(),
                        SliverToBoxAdapter(child: SizedBox(height: bottom)),
                      ],
                    ),
                  ),
                ),
              ),
              AppBackToTop(
                controller: _scroll,
                label: AppStrings.commonBackToTop,
                bottom: bottom - AppSpacing.lg,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The two lazy sections — hidden while a search is showing.
class _Sections extends StatelessWidget {
  const _Sections({required this.intro, required this.lastVisit});

  final Animation<double> intro;
  final LastVisit lastVisit;

  @override
  Widget build(BuildContext context) {
    final searching = context.select<FeedBloc, bool>(
      (bloc) => bloc.state.query.isNotEmpty,
    );
    if (searching) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverList.list(
      children: <Widget>[
        // Part of the opening: it grows in after the header and search.
        AppIntroSlot(
          animation: intro,
          start: 0.25,
          scale: 0.94,
          curve: AppCurves.reveal,
          child: BlocSelector<FeedBloc, FeedState, BlocStatus<List<FeedItemEntity>>>(
            selector: (state) => state.highlightsState,
            builder: (context, status) => AppLazySection<FeedItemEntity>(
              status: status,
              onRequested: () => context.read<FeedBloc>().add(
                const FeedEvent.sectionRequested(FeedSection.highlights),
              ),
              onRetry: () => context.read<FeedBloc>().add(
                const FeedEvent.sectionRetried(FeedSection.highlights),
              ),
              loading: (_) => const AppPeekCarousel<FeedItemEntity>.loading(),
              builder: (context, data) => AppPeekCarousel<FeedItemEntity>(
                items: data,
                semanticLabelOf: (item) => item.title,
                itemBuilder: (context, item, isActive) =>
                    FeedHighlightSlide(item: item, isActive: isActive),
              ),
            ),
          ),
        ),
        BlocSelector<FeedBloc, FeedState, BlocStatus<List<FeedItemEntity>>>(
          selector: (state) => state.picksState,
          builder: (context, status) => ValueListenableBuilder<DateTime?>(
            // The previous visit arrives from storage a moment after the
            // page opens; the «new» dot follows it.
            valueListenable: lastVisit.previous,
            builder: (context, _, _) {
              final data = status.getDataWhenSuccess;
              final fresh = data == null
                  ? 0
                  : lastVisit.countNewer(data.map((i) => i.publishedAt));
              return AppLazySection<FeedItemEntity>(
                status: status,
                title: AppStrings.feedPicks,
                count: data?.length,
                newLabel: fresh > 0
                    ? AppStrings.feedNewSince(AppFormats.number(context, fresh))
                    : null,
                onRequested: () => context.read<FeedBloc>().add(
                  const FeedEvent.sectionRequested(FeedSection.picks),
                ),
                onRetry: () => context.read<FeedBloc>().add(
                  const FeedEvent.sectionRetried(FeedSection.picks),
                ),
                loading: (_) => const AppRail(
                  // Two cards read as a rail; a screenful of placeholders
                  // suggests more is coming than usually does.
                  children: <Widget>[
                    FeedPickCard.loading(),
                    FeedPickCard.loading(),
                  ],
                ),
                builder: (context, data) => AppRail(
                  // The first rail of the page slides once per app run to
                  // show it scrolls sideways.
                  nudgeId: 'feed.picks',
                  children: <Widget>[
                    for (final item in data)
                      FeedPickCard.success(key: ValueKey(item.id), item: item),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// The paged list: skeleton rows → rows rising in as they scroll into view →
/// two skeleton rows while the next page loads → «That's everything».
class _LatestList extends StatelessWidget {
  const _LatestList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: (previous, current) =>
          previous.listState != current.listState ||
          previous.loadMoreState != current.loadMoreState ||
          previous.hasMore != current.hasMore ||
          previous.query != current.query ||
          previous.total != current.total,
      builder: (context, state) {
        final bloc = context.read<FeedBloc>();
        final list = state.listState;

        if (list.isFailed) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 380,
              child: FailedStateWidget(
                message: list.errorMessage,
                onRetrying: () => bloc.add(const FeedEvent.listRetried()),
              ),
            ),
          );
        }

        final items = list.getDataWhenSuccess;
        if (items != null && items.isEmpty) {
          // Specific, never generic: say what was looked for.
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 380,
              child: EmptyStateWidget(
                icon: IconSource.svg(AppIcons.search),
                text: state.query.isEmpty
                    ? AppStrings.feedEmpty
                    : AppStrings.feedNoResultsFor(state.query),
                description: AppStrings.feedEmptyHint,
                onRetrying: state.query.isEmpty
                    ? null
                    : () => bloc.add(const FeedEvent.querySubmitted('')),
                retryLabel: AppStrings.actionClearSearch,
              ),
            ),
          );
        }

        final isLoading = items == null;
        return SliverMainAxisGroup(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.screenMargin,
              ),
              sliver: SliverToBoxAdapter(
                child: ScrollReveal(
                  child: AppSectionHeader(
                    title: state.query.isEmpty
                        ? AppStrings.feedLatest
                        : AppStrings.feedResultsFor(state.query),
                    count: isLoading ? null : state.total,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.screenMargin,
              ),
              sliver: SliverList.separated(
                itemCount: isLoading ? 5 : items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.cardGap),
                itemBuilder: (context, index) {
                  if (isLoading) return const FeedCard.loading();
                  final item = items[index];
                  // The rise plays as each row scrolls in, not when it is
                  // built off screen in the cache extent.
                  return FeedCard.success(
                    item: item,
                  ).revealOnScroll(id: item.id);
                },
              ),
            ),
            SliverToBoxAdapter(child: _ListFooter(state: state)),
          ],
        );
      },
    );
  }
}

/// The end of the list: the next page arriving, a retry, or the sentence
/// that says there is no next page.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final FeedState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.lg),
      child: Center(
        child: switch (state) {
          _ when state.loadMoreState.isLoading => SkeletonMore(
            itemBuilder: (_) => const FeedCard.loading(),
          ),
          _ when state.loadMoreState.isFailed => TextButton(
            onPressed: () =>
                context.read<FeedBloc>().add(const FeedEvent.loadMore()),
            child: Text(AppStrings.retry),
          ),
          _ when state.hasMore || !state.listState.isSuccess =>
            const SizedBox.shrink(),
          _ => Text(
            AppStrings.feedNoMore,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        },
      ),
    );
  }
}
