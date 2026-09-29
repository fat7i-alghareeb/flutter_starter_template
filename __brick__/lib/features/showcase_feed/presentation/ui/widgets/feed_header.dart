import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../core/injection/injectable.dart';
import '../../../../../core/services/session/auth_state_notifier.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/extensions/theme_extensions.dart';
import '../../../../../utils/helpers/app_strings.dart';
import '../../states/feed_bloc.dart';
import 'feed_navigation.dart';

/// The feed's header: a greeting and a settings button, then a search field
/// that slides away on scroll down and comes straight back on scroll up.
///
/// ```text
///  ┌──────────────────────────────────────────┐
///  │ Good morning                        (⚙) │
///  │ Demo                                     │
///  │ ╭──────────────────────────────────────╮ │
///  │ │ 🔍 Search for news…  (word rotates)  │ │  ← hides on scroll down
///  │ ╰──────────────────────────────────────╯ │
///  │ [recent] [searches]                      │
///  └──────────────────────────────────────────┘
/// ```
///
/// A hairline and a soft shadow appear once the list is under it.
class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key, required this.isScrolled, this.intro});

  final bool isScrolled;

  /// The opening choreography (`AppIntro`): 0 → 1 once per app run. Null:
  /// shown as it is.
  final Animation<double>? intro;

  static const double barHeight = 64;

  /// The clock the greeting reads — replaced in golden tests, where «Good
  /// morning» must not turn into «Good evening» with the time of day.
  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final intro = this.intro ?? kAlwaysCompleteAnimation;
    final isSearchVisible = context.select<FeedBloc, bool>(
      (bloc) => bloc.state.isSearchVisible,
    );

    // At least [barHeight]; taller when a large system font needs it.
    final bar = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: barHeight),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: AppSpacing.screenMargin,
          end: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            const Expanded(child: _Greeting()),
            AppBarAction(
              icon: AppIcons.settings,
              label: AppStrings.settingsTitle,
              onTap: () => FeedNavigation.openSettings(context),
            ),
          ],
        ),
      ),
    );

    final search = ClipRect(
      child: AnimatedAlign(
        alignment: AlignmentDirectional.topCenter,
        heightFactor: isSearchVisible ? 1 : 0,
        duration: isSearchVisible
            ? const Duration(milliseconds: 180)
            : const Duration(milliseconds: 200),
        curve: isSearchVisible ? AppCurves.enter : AppCurves.press,
        child: AnimatedOpacity(
          opacity: isSearchVisible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.screenMargin,
              AppSpacing.xs,
              AppSpacing.screenMargin,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[_FeedSearch(), _RecentSearches()],
            ),
          ),
        ),
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isScrolled
                ? colors.outline
                : colors.outline.withValues(alpha: 0),
          ),
        ),
        boxShadow: isScrolled && !context.isDarkTheme
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0F141510),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIntroSlot(animation: intro, end: 0.45, dy: -10, child: bar),
            AppIntroSlot(
              animation: intro,
              start: 0.12,
              end: 0.6,
              dy: -6,
              scale: 0.97,
              child: search,
            ),
          ],
        ),
      ),
    );
  }
}

/// «Good morning» over the reader's first name, the words fading in one
/// after another the first time. A guest is simply welcomed.
class _Greeting extends StatefulWidget {
  const _Greeting();

  @override
  State<_Greeting> createState() => _GreetingState();
}

class _GreetingState extends State<_Greeting>
    with SingleTickerProviderStateMixin {
  late final AnimationController _words = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  /// Once per app run: coming back to the tab does not replay it.
  static bool _played = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_words.isAnimating || _words.isCompleted) return;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_played || reduced) {
      _words.value = 1;
    } else {
      _played = true;
      _words.forward();
    }
  }

  @override
  void dispose() {
    _words.dispose();
    super.dispose();
  }

  static String timeOfDay() {
    final hour = FeedHeader.clock().hour;
    return hour >= 4 && hour < 12
        ? AppStrings.feedGoodMorning
        : AppStrings.feedGoodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final authState = getIt.isRegistered<AuthStateNotifier>()
        ? getIt<AuthStateNotifier>()
        : null;

    return ListenableBuilder(
      listenable: authState ?? const AlwaysStoppedAnimation<int>(0),
      builder: (context, _) {
        final name = authState?.user?.name?.trim();
        final guest = name == null || name.isEmpty;
        final small = timeOfDay();
        final large = guest ? AppStrings.feedWelcome : name.split(' ').first;

        Widget word(String text, TextStyle? style, int slot) {
          final t = CurvedAnimation(
            parent: _words,
            curve: Interval(
              slot * 0.22,
              0.55 + slot * 0.22,
              curve: AppCurves.enter,
            ),
          );
          return AnimatedBuilder(
            animation: t,
            builder: (context, child) => Opacity(
              opacity: t.value,
              child: Transform.translate(
                offset: Offset(0, (1 - t.value) * 6),
                child: child,
              ),
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          );
        }

        return Semantics(
          header: true,
          label: <String>[small, large].join(AppStrings.a11ySeparator),
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              word(
                small,
                theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                0,
              ),
              word(
                large,
                theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
                1,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The search field. While it is empty and not focused, its hint rotates —
/// «Search for *news*…», then *events*, *places* — to teach what search
/// covers.
class _FeedSearch extends StatefulWidget {
  const _FeedSearch();

  @override
  State<_FeedSearch> createState() => _FeedSearchState();
}

class _FeedSearchState extends State<_FeedSearch> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _focus.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String query) {
    _focus.unfocus();
    context.read<FeedBloc>().add(FeedEvent.querySubmitted(query.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // A search started elsewhere (a recent chip, another tab) shows its
    // words in the field; «clear» empties both.
    return BlocListener<FeedBloc, FeedState>(
      listenWhen: (previous, current) => previous.query != current.query,
      listener: (context, state) {
        if (_controller.text != state.query) _controller.text = state.query;
      },
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[
          AppSearchField(
            controller: _controller,
            focusNode: _focus,
            // The rotating hint below stands in for the field's own.
            hintText: '',
            onSubmitted: _submit,
            onChanged: (value) {
              if (value.isEmpty) _submit('');
            },
          ),
          if (_controller.text.isEmpty && !_focus.hasFocus)
            PositionedDirectional(
              start: 40 + AppSpacing.md,
              end: AppSpacing.lg,
              child: IgnorePointer(
                child: AppRotatingHint(
                  prefix: AppStrings.feedSearchFor,
                  words: AppStrings.feedSearchWords
                      .split('|')
                      .where((w) => w.trim().isNotEmpty)
                      .toList(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The last few searches as chips under the field — one tap runs it again.
class _RecentSearches extends StatelessWidget {
  const _RecentSearches();

  @override
  Widget build(BuildContext context) {
    final recent = context.select<FeedBloc, List<String>>(
      (bloc) => bloc.state.recentSearches,
    );
    if (recent.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
      child: Semantics(
        label: AppStrings.feedRecentSearches,
        container: true,
        child: SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recent.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) => AppChip(
              label: recent[index],
              onTap: () => context.read<FeedBloc>().add(
                FeedEvent.querySubmitted(recent[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
