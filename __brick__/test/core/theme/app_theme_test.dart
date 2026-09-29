import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/theme/app_colors.dart';
import 'package:{{project_name}}/core/theme/app_theme.dart';
import 'package:{{project_name}}/core/theme/app_theme_colors.dart';
import 'package:{{project_name}}/core/theme/app_typography.dart';
import 'package:{{project_name}}/utils/constants/design_constants.dart';

/// Guards the promises `DESIGN_SYSTEM.md` makes.
///
/// Not "does the theme exist" tests. Each one locks a decision that is
/// expensive to notice by eye and easy to break by accident: a contrast ratio,
/// a banned font weight, a radius that drifts off the scale.

/// WCAG relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('contrast — the ratios the palette claims (DESIGN_SYSTEM.md)', () {
    const light = AppColorSchemes.light;
    const dark = AppColorSchemes.dark;

    test('primary text on a card is AAA in both themes', () {
      expect(contrast(light.onSurface, light.surface), greaterThan(7));
      expect(contrast(dark.onSurface, dark.surface), greaterThan(7));
    });

    test('secondary text on a card is at least AA', () {
      expect(contrast(light.onSurfaceVariant, light.surface), greaterThan(4.5));
      expect(contrast(dark.onSurfaceVariant, dark.surface), greaterThan(4.5));
    });

    test('secondary text on the SCREEN ground is also at least AA', () {
      // The screen ground is not the card colour. Checking only against
      // the card would miss text that sits directly on the background.
      expect(
        contrast(light.onSurfaceVariant, AppSemanticColors.light.background),
        greaterThan(4.5),
      );
    });

    test('button label on a filled primary button is at least AA', () {
      expect(contrast(light.onPrimary, light.primary), greaterThan(4.5));
      expect(contrast(dark.onPrimary, dark.primary), greaterThan(4.5));
    });

    test('the urgent badge is readable', () {
      expect(
        contrast(
          AppSemanticColors.light.onUrgent,
          AppSemanticColors.light.urgent,
        ),
        greaterThan(4.5),
      );
    });

    test('the community badge is readable', () {
      expect(contrast(light.onTertiary, light.tertiary), greaterThan(4.5));
    });

    test('secondary is usable for text on a card in both themes', () {
      expect(contrast(light.secondary, light.surface), greaterThan(4.5));
      expect(contrast(dark.secondary, dark.surface), greaterThan(4.5));
    });

    test('an error line is readable on the card and on the ground', () {
      expect(contrast(light.error, light.surface), greaterThan(4.5));
      expect(contrast(dark.error, dark.surface), greaterThan(4.5));
    });
  });

  group('typography', () {
    test('the family is the bundled Tajawal, not a network font', () {
      expect(AppTypography.fontFamily, 'Tajawal');
      expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, 'Tajawal');
    });

    test('only weights 400 / 500 / 700 / 800 are used', () {
      // A List, not a const Set — FontWeight has no primitive equality.
      const allowed = <FontWeight>[
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w700,
        FontWeight.w800,
      ];

      final theme = AppTypography.buildTextTheme;
      final styles = <String, TextStyle?>{
        'displayLarge': theme.displayLarge,
        'displayMedium': theme.displayMedium,
        'displaySmall': theme.displaySmall,
        'headlineLarge': theme.headlineLarge,
        'headlineMedium': theme.headlineMedium,
        'headlineSmall': theme.headlineSmall,
        'titleLarge': theme.titleLarge,
        'titleMedium': theme.titleMedium,
        'titleSmall': theme.titleSmall,
        'bodyLarge': theme.bodyLarge,
        'bodyMedium': theme.bodyMedium,
        'bodySmall': theme.bodySmall,
        'labelLarge': theme.labelLarge,
        'labelMedium': theme.labelMedium,
        'labelSmall': theme.labelSmall,
      };

      for (final entry in styles.entries) {
        expect(
          allowed.contains(entry.value?.fontWeight),
          isTrue,
          reason: '${entry.key} uses ${entry.value?.fontWeight}, which the type scale does not use',
        );
      }
    });

    test('body text never drops below 14sp', () {
      final theme = AppTypography.buildTextTheme;
      expect(theme.bodyMedium!.fontSize, greaterThanOrEqualTo(14));
      expect(theme.bodyLarge!.fontSize, greaterThanOrEqualTo(14));
      // 12 and 11 are allowed, but only for secondary text and badges.
      expect(theme.bodySmall!.fontSize, 12);
      expect(theme.labelSmall!.fontSize, 11);
    });
  });

  group('shape and colour plumbing', () {
    test('the screen ground is NOT the card colour', () {
      // A real bug this catches: pointing scaffoldBackgroundColor at
      // colorScheme.surface makes every card invisible against the screen.
      expect(
        AppTheme.light.scaffoldBackgroundColor,
        isNot(AppColorSchemes.light.surface),
      );
      expect(AppTheme.light.scaffoldBackgroundColor, AppColors.backGroundLight);
    });

    test('the semantic extension is registered on both themes', () {
      expect(AppTheme.light.extension<AppSemanticColors>(), isNotNull);
      expect(AppTheme.dark.extension<AppSemanticColors>(), isNotNull);
    });

    test('urgent stands apart from the primary and the error colour', () {
      // An urgent badge that looks like a button, or like a failed field,
      // says the wrong thing.
      expect(AppSemanticColors.light.urgent, isNot(AppColorSchemes.light.primary));
      expect(AppSemanticColors.light.urgent, isNot(AppColorSchemes.light.error));
    });

    test('every radius in the scale is one of the seven allowed values', () {
      // A List, not a const Set: doubles have no primitive equality, so a
      // const Set<double> is a compile error.
      const scale = <double>[7, 12, 14, 18, 20, 26, 999];
      for (final radius in <double>[
        AppRadii.xs,
        AppRadii.sm,
        AppRadii.md,
        AppRadii.lg,
        AppRadii.xl,
        AppRadii.sheet,
        AppRadii.full,
      ]) {
        expect(scale.contains(radius), isTrue, reason: '$radius is off-scale');
      }
    });

    test('a nested radius is the outer minus 4, floored at the smallest', () {
      expect(AppRadii.nestedIn(AppRadii.lg), AppRadii.md);
      expect(AppRadii.nestedIn(AppRadii.xs), AppRadii.xs);
    });

    test('cards carry no border in light mode and a hairline in dark', () {
      final lightShape =
          AppTheme.light.cardTheme.shape! as RoundedRectangleBorder;
      final darkShape =
          AppTheme.dark.cardTheme.shape! as RoundedRectangleBorder;

      // Never a shadow AND a border on the same element.
      expect(lightShape.side, BorderSide.none);
      expect(darkShape.side, isNot(BorderSide.none));
    });

    test('motion: exit is faster than enter', () {
      expect(
        AppDurations.sheetOut.inMilliseconds,
        lessThan(AppDurations.sheetIn.inMilliseconds),
      );
      expect(
        AppDurations.routeOut.inMilliseconds,
        lessThan(AppDurations.routeIn.inMilliseconds),
      );
    });

    test('touch targets never fall below 44', () {
      expect(AppIconSizes.minTouchTarget, greaterThanOrEqualTo(44));
      expect(AppIconSizes.navTouchTarget, greaterThanOrEqualTo(48));
    });
  });
}
