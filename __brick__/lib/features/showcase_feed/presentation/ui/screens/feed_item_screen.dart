import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../common/widgets/app_bottom_sheet.dart';
import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../common/widgets/failed_state_widget.dart';
import '../../../../../common/widgets/scroll_reveal.dart';
import '../../../../../core/injection/injectable.dart';
import '../../../../../core/router/app_links.dart';
import '../../../../../core/services/session/pending_action.dart';
import '../../../../../core/utils/bloc_status.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/helpers/app_formats.dart';
import '../../../../../utils/helpers/app_strings.dart';
import '../../../../auth/presentation/ui/widgets/auth_gate_sheet.dart';
import '../../../domain/feed_entities.dart';
import '../../states/feed_item_bloc.dart';
import '../widgets/feed_cards.dart';

/// One item of the feed — an inner screen, pushed over the tabs, so the
/// floating navigation bar is gone and the action capsule takes its place.
///
/// ```text
/// ┌──────────────────────────────┐
/// │ (←)                     (⋮)  │
/// │      [picture, Hero]         │
/// │  ╭────────── ▬ ─────────────╮│
/// │  │ [Category] · 4 min read   ││
/// │  │ Title                     ││
/// │  │ Author · date             ││
/// │  │ body …                    ││
/// │  │ More like this  (rail)    ││
/// │  ╰──────────────────────────╯│
/// │   ╭ 🔖 Save      [ Share ] ╮  │  tucks away on scroll
/// └──────────────────────────────┘
/// ```
///
/// A failure is told apart from an item that is GONE (the server said 404):
/// retrying a deleted item is pointless, so a gone item offers only the way
/// back.
class FeedItemScreen extends StatelessWidget {
  const FeedItemScreen({super.key, required this.itemId});

  final String itemId;

  static const String pageName = 'FeedItemScreen';

  /// Relative: the page is nested under the root route (`AppPage.feedItem`).
  static const String pagePath = 'items/:id';
  static const String idParam = 'id';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeedItemBloc>(
      create: (_) => getIt<FeedItemBloc>()..add(FeedItemEvent.started(itemId)),
      child: const Scaffold(body: _FeedItemBody()),
    );
  }
}

class _FeedItemBody extends StatelessWidget {
  const _FeedItemBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedItemBloc, FeedItemState>(
      listenWhen: (previous, current) =>
          previous.saveToggles != current.saveToggles,
      listener: _onSaveToggled,
      buildWhen: (previous, current) =>
          previous.detailState != current.detailState ||
          previous.relatedState != current.relatedState ||
          previous.isSaved != current.isSaved,
      builder: (context, state) {
        if (state.detailState.isFailed) {
          final message = state.detailState.errorMessage;
          final gone = message == AppStrings.clientNotFound;
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: FailedStateWidget(
                    title: gone ? AppStrings.feedItemGone : null,
                    message: gone ? null : message,
                    onRetrying: gone
                        ? null
                        : () => context.read<FeedItemBloc>().add(
                            const FeedItemEvent.retried(),
                          ),
                    retryLabel: AppStrings.retry,
                  ),
                ),
                // A shared link may point at an item that is gone for good:
                // retrying is never the only way out.
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(AppStrings.actionBack),
                  ),
                ),
              ],
            ),
          );
        }

        final item = state.detailState.getDataWhenSuccess;
        return AppHeroDetailLayout(
          title: item?.title,
          image: item == null
              ? const SkeletonScope(
                  isLoading: true,
                  child: SkeletonBox(radius: 0, child: SizedBox.expand()),
                )
              : item.hasImage
              ? Hero(
                  tag: FeedHeroTags.image(item.id),
                  child: AppKenBurns(
                    child: AppThumbnail(
                      imageUrl: item.imageUrl,
                      iconKey: item.category,
                      iconSize: 48,
                    ),
                  ),
                )
              : null,
          menu: item == null ? null : () => _openMenu(context, item),
          actions: item == null
              ? null
              : (controller) => _ItemActions(
                  item: item,
                  isSaved: state.isSaved,
                  controller: controller,
                ),
          body: _ItemContent(
            item: item,
            related: state.relatedState,
          ),
        );
      },
    );
  }

  /// A state the reader can undo says so in the same breath.
  static void _onSaveToggled(BuildContext context, FeedItemState state) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppSnackContent(
            state.isSaved ? AppStrings.feedSaved : AppStrings.feedUnsaved,
          ),
          duration: AppDurations.snackBar,
          action: SnackBarAction(
            label: AppStrings.actionUndo,
            onPressed: () => context.read<FeedItemBloc>().add(
              const FeedItemEvent.saveToggled(),
            ),
          ),
        ),
      );
  }

  static Future<void> _openMenu(BuildContext context, FeedItemEntity item) {
    return AppBottomSheet.show<void>(
      context,
      sheet: AppBottomSheet.basic(
        title: item.title,
        titleIcon: AppIcons.more,
        scrollable: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const AppIcon(AppIcons.link),
              title: Text(AppStrings.actionCopyLink),
              onTap: () {
                Navigator.of(context).pop();
                _copyLink(context, item);
              },
            ),
            ListTile(
              leading: const AppIcon(AppIcons.report),
              title: Text(AppStrings.actionReport),
              onTap: () {
                Navigator.of(context).pop();
                AuthGate.run(context, ProtectedAction.report, () async {
                  if (!context.mounted) return;
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: AppSnackContent(AppStrings.reportSent)),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _copyLink(BuildContext context, FeedItemEntity item) {
    Clipboard.setData(ClipboardData(text: AppLinks.shareUrlOf(item.id)));
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: AppSnackContent(AppStrings.feedLinkCopied)),
      );
  }
}

/// Badge, title, meta and body — each a `.loading()` twin of itself until the
/// item lands — then «More like this».
class _ItemContent extends StatelessWidget {
  const _ItemContent({required this.item, required this.related});

  final FeedItemEntity? item;
  final BlocStatus<List<FeedItemEntity>> related;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final data = item;
    final relatedItems = related.getDataWhenSuccess;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: AppSpacing.lg,
        bottom: AppActionCapsule.clearanceOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SkeletonScope(
            isLoading: data == null,
            child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.screenMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (data == null)
                      const AppBadge.skeleton()
                    else
                      AppBadge.primary(data.categoryName),
                    if (data?.readMinutes != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        AppStrings.feedReadMinutes(
                          data!.readMinutes!,
                          AppFormats.number(context, data.readMinutes!),
                        ),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SkeletonText(
                  data?.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.xs),
                SkeletonText(
                  data == null
                      ? null
                      : AppFormats.line(<String>[
                          data.author,
                          AppFormats.fullDate(context, data.publishedAt),
                        ]),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  loadingWidthFactor: 0.5,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (data == null)
                  SkeletonText(
                    null,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    maxLines: 6,
                  )
                else
                  SelectableText(
                    data.body,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
              ],
            ),
          ),
          ),
          if (relatedItems == null || relatedItems.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            ScrollReveal(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.screenMargin,
                ),
                child: AppSectionHeader(title: AppStrings.feedMoreLikeThis),
              ),
            ),
            AppRail(
              children: <Widget>[
                if (relatedItems == null) ...const <Widget>[
                  FeedPickCard.loading(),
                  FeedPickCard.loading(),
                ] else
                  for (final r in relatedItems)
                    FeedPickCard.success(key: ValueKey(r.id), item: r),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Save and share, in the floating capsule. Saving asks a guest to sign in
/// first (`AuthMode.guestFirst`) and then runs on its own.
class _ItemActions extends StatelessWidget {
  const _ItemActions({
    required this.item,
    required this.isSaved,
    required this.controller,
  });

  final FeedItemEntity item;
  final bool isSaved;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppActionCapsule(
      controller: controller,
      maxWidth: 640,
      child: Row(
        children: <Widget>[
          Semantics(
            toggled: isSaved,
            child: TextButton.icon(
              onPressed: () => AuthGate.run(
                context,
                ProtectedAction.save,
                () async => context.read<FeedItemBloc>().add(
                  const FeedItemEvent.saveToggled(),
                ),
              ),
              icon: AppIcon(
                AppIcons.bookmark,
                color: isSaved ? colors.primary : colors.onSurfaceVariant,
              ),
              label: Text(
                isSaved ? AppStrings.actionSaved : AppStrings.actionSave,
              ),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _FeedItemBody._copyLink(context, item),
            icon: AppIcon(AppIcons.share, color: colors.onPrimary),
            label: Text(AppStrings.actionShare),
          ),
        ],
      ),
    );
  }
}

