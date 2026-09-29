import 'package:flutter/material.dart';

import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/helpers/app_formats.dart';
import '../../../../../utils/helpers/app_strings.dart';

/// One word a slide covers, drawn as a tile in the collage.
@immutable
class OnboardingSupport {
  const OnboardingSupport({
    required this.icon,
    required this.label,
    this.isUrgent = false,
  });

  /// A constant from `AppIcons`.
  final String icon;

  /// Already translated — it comes from `AppStrings`, and reuses a word the
  /// reader will meet inside the app.
  final String label;

  /// A tile that should stand out (alerts, for instance) wears the urgent
  /// colour, as it does in the app.
  final bool isUrgent;
}

/// The content of one onboarding slide.
@immutable
class OnboardingSlideData {
  const OnboardingSlideData({
    required this.icon,
    required this.headline,
    required this.supports,
  });

  /// A constant from `AppIcons` — the slide's own subject.
  final String icon;

  /// The headline, already translated — it comes from `AppStrings`.
  final String headline;

  /// Two or three words naming what this slide covers. They are the collage
  /// tiles this slide lights up.
  ///
  /// Concrete words beat an abstract promise: «News · Events · Alerts»
  /// tells a reader what is actually inside, which a headline alone does
  /// not.
  final List<OnboardingSupport> supports;
}

/// The headline in the bottom sheet — the only text that changes there.
///
/// It fades and rises into place when the slide changes, so the sheet itself
/// never moves: the collage above carries the motion.
class OnboardingHeadline extends StatelessWidget {
  const OnboardingHeadline({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedSwitcher(
      duration: reduceMotion
          ? AppDurations.reducedMotion
          : AppDurations.routeIn,
      switchInCurve: AppCurves.enter,
      switchOutCurve: AppCurves.exit,
      transitionBuilder: (child, animation) {
        final fade = FadeTransition(opacity: animation, child: child);
        if (reduceMotion) return fade;
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          ).animate(animation),
          child: fade,
        );
      },
      // Only the incoming headline takes space; the outgoing one fades on
      // top of it rather than stacking a second line of height.
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          for (final child in previous) ExcludeSemantics(child: child),
          ?current,
        ],
      ),
      child: Semantics(
        key: ValueKey<String>(text),
        liveRegion: true,
        header: true,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// The page indicator.
///
/// The active dot stretches into a bar rather than only changing colour —
/// position is then readable without relying on colour alone, which is the same
/// rule the navigation bar follows.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      // Through `AppFormats`: the numerals a screen reader speaks follow the
      // locale like every other number in the app.
      label: AppStrings.onboardingSlideOf(
        AppFormats.number(context, index + 1),
        AppFormats.number(context, count),
      ),
      container: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppDurations.toggle,
              curve: AppCurves.toggle,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == index ? colors.primary : colors.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadii.full),
              ),
            ),
        ],
      ),
    );
  }
}
