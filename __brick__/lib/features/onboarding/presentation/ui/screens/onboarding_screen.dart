import 'package:flutter/material.dart';

import '../../../../../common/widgets/custom_scaffold/app_scaffold.dart'
    show AppScaffold, AppScaffoldConfig;
import '../../../../../common/widgets/ds/app_icons.dart';
import '../../../../../core/injection/injectable.dart';
import '../../../../../core/services/onboarding/onboarding_service.dart';
import '../../../../../core/services/session/auth_manager.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../utils/constants/app_flow_constants.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/helpers/app_strings.dart';
import '../widgets/onboarding_collage.dart';
import '../widgets/onboarding_slide.dart';

/// Three slides, shown once — after the splash on the first launch after
/// install, then never again.
///
/// The top of the screen is a collage of every word the three slides cover;
/// each slide lights up its own and dims the rest. The bottom is a fixed
/// sheet: the headline, the dots and one button. The sheet never moves, so
/// the button stays under the thumb for all three slides.
///
/// «Skip» sits on every slide, including the last: onboarding a reader cannot
/// escape is a wall, and a wall on first launch is how an app gets deleted
/// before it is understood. A swipe moves in reading order and never
/// finishes — leaving takes a deliberate tap.
///
/// Replace [slides] with your own story (strings in `assets/l10n`, icons from
/// `AppIcons`).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String pagePath = '/onboarding';
  static const String pageName = 'OnboardingScreen';

  /// Exposed so a test can assert the count without duplicating the list.
  ///
  /// A getter, not a `const` list: the strings come from `AppStrings`, which
  /// resolves against the active locale at call time.
  static List<OnboardingSlideData> get slides => <OnboardingSlideData>[
    OnboardingSlideData(
      icon: AppIcons.home,
      headline: AppStrings.onboardingSlide1,
      supports: <OnboardingSupport>[
        OnboardingSupport(icon: AppIcons.news, label: AppStrings.onboardingTopicNews),
        OnboardingSupport(icon: AppIcons.calendar, label: AppStrings.onboardingTopicEvents),
        OnboardingSupport(
          icon: AppIcons.alert,
          label: AppStrings.onboardingTopicAlerts,
          isUrgent: true,
        ),
      ],
    ),
    OnboardingSlideData(
      icon: AppIcons.search,
      headline: AppStrings.onboardingSlide2,
      supports: <OnboardingSupport>[
        OnboardingSupport(icon: AppIcons.search, label: AppStrings.onboardingTopicSearch),
        OnboardingSupport(icon: AppIcons.tag, label: AppStrings.onboardingTopicOffers),
        OnboardingSupport(icon: AppIcons.pin, label: AppStrings.onboardingTopicPlaces),
      ],
    ),
    OnboardingSlideData(
      icon: AppIcons.bookmark,
      headline: AppStrings.onboardingSlide3,
      supports: <OnboardingSupport>[
        OnboardingSupport(icon: AppIcons.bookmark, label: AppStrings.onboardingTopicSaved),
        OnboardingSupport(icon: AppIcons.heart, label: AppStrings.onboardingTopicFavorites),
      ],
    ),
  ];

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<OnboardingSlideData> _slides = OnboardingScreen.slides;
  int _index = 0;
  bool _finishing = false;

  bool get _isLast => _index == _slides.length - 1;

  /// Marks onboarding done. The router is listening and moves on by itself,
  /// so there is no navigation here: one place decides where the user goes.
  ///
  /// In guest-first mode the reader becomes a guest FIRST: «neither a guest
  /// nor signed in» is the pair the guard reads as «send to the login wall»,
  /// and the other order would leave a frame of exactly that pair. A reader
  /// who is somehow already signed in stays signed in.
  Future<void> _finish() async {
    // A double tap on «Start» must not finish twice.
    if (_finishing) return;
    _finishing = true;
    if (AppFlowConfig.authMode == AuthMode.guestFirst &&
        getIt.isRegistered<AuthManager>()) {
      final auth = getIt<AuthManager>();
      if (!auth.isAuthenticated) await auth.continueAsGuest();
    }
    await getIt<OnboardingService>().setOnboardingFinished();
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    setState(() => _index++);
  }

  void _previous() {
    if (_index == 0) return;
    setState(() => _index--);
  }

  /// A swipe moves in reading order: towards the start edge is forward, so
  /// in Arabic a finger dragged to the right advances. A swipe never
  /// finishes — leaving takes a deliberate tap.
  void _onSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 200) return;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final forward = isRtl ? velocity > 0 : velocity < 0;
    if (!forward) {
      _previous();
    } else if (!_isLast) {
      _next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    return AppScaffold.body(
      scaffoldConfig: AppScaffoldConfig(backgroundColor: semantic.background),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: _onSwipe,
        child: Column(
          children: <Widget>[
            // `تخطّي` on EVERY slide, the last one included.
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(AppStrings.onboardingSkip),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.sm,
                  AppSpacing.screenMargin,
                  AppSpacing.xl,
                ),
                child: OnboardingCollage(slides: _slides, index: _index),
              ),
            ),

            // The sheet: fixed, so the button never moves under the thumb.
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.xxl,
                  AppSpacing.screenMargin,
                  AppSpacing.xl + MediaQuery.viewPaddingOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    OnboardingHeadline(text: _slides[_index].headline),
                    const SizedBox(height: AppSpacing.xl),
                    OnboardingDots(count: _slides.length, index: _index),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: _next,
                      child: Text(
                        // One primary button per screen. On the last slide
                        // it says «Start», not «Next» — the label has to tell
                        // the reader they are about to leave, not advance.
                        _isLast
                            ? AppStrings.onboardingStart
                            : AppStrings.onboardingNext,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
