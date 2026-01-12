import 'package:flutter/material.dart';

import 'app_typography.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _withWeight(TextStyle? base, FontWeight weight) {
    final b = base!;
    // IMPORTANT:
    // `TextStyle.copyWith(color: null)` does NOT clear the color; it keeps the
    // original color. To make the style inherit the active theme's color, we
    // must rebuild the style without carrying over `color/foreground/background`.
    return TextStyle(
      fontFamily: b.fontFamily,
      fontFamilyFallback: b.fontFamilyFallback,
      fontSize: b.fontSize,
      fontWeight: weight,
      fontStyle: b.fontStyle,
      letterSpacing: b.letterSpacing,
      wordSpacing: b.wordSpacing,
      textBaseline: b.textBaseline,
      height: b.height,
      leadingDistribution: b.leadingDistribution,
      locale: b.locale,
      // Intentionally omit: color, backgroundColor, foreground, background.
      decoration: b.decoration,
      decorationColor: b.decorationColor,
      decorationStyle: b.decorationStyle,
      decorationThickness: b.decorationThickness,
      debugLabel: b.debugLabel,
      shadows: b.shadows,
      overflow: b.overflow,
    );
  }

  static TextStyle get s40w700 {
    final base = AppTypography.textTheme?.displayLarge;
    return _withWeight(base, FontWeight.w700);
  }

  static TextStyle get s34w700 {
    final base = AppTypography.textTheme?.displayMedium;
    return _withWeight(base, FontWeight.w700);
  }

  static TextStyle get s28w700 {
    final base = AppTypography.textTheme?.displaySmall;
    return _withWeight(base, FontWeight.w700);
  }

  static TextStyle get s24w700 {
    final base = AppTypography.textTheme?.headlineLarge;
    return _withWeight(base, FontWeight.w700);
  }

  static TextStyle get s22w700 {
    final base = AppTypography.textTheme?.headlineMedium;
    return _withWeight(base, FontWeight.w700);
  }

  static TextStyle get s20w700 {
    final base = AppTypography.textTheme?.headlineSmall;
    return _withWeight(base, FontWeight.w700);
  }

  static TextStyle get s18w600 {
    final base = AppTypography.textTheme?.titleLarge;
    return _withWeight(base, FontWeight.w600);
  }

  static TextStyle get s16w600 {
    final base = AppTypography.textTheme?.titleMedium;
    return _withWeight(base, FontWeight.w600);
  }

  static TextStyle get s14w600 {
    final base = AppTypography.textTheme?.titleSmall;
    return _withWeight(base, FontWeight.w600);
  }

  static TextStyle get s16w400 {
    final base = AppTypography.textTheme?.bodyLarge;
    return _withWeight(base, FontWeight.w400);
  }

  static TextStyle get s14w400 {
    final base = AppTypography.textTheme?.bodyMedium;
    return _withWeight(base, FontWeight.w400);
  }

  static TextStyle get s12w400 {
    final base = AppTypography.textTheme?.bodySmall;
    return _withWeight(base, FontWeight.w400);
  }

  static TextStyle get s14w500 {
    final base = AppTypography.textTheme?.labelLarge;
    return _withWeight(base, FontWeight.w500);
  }

  static TextStyle get s12w500 {
    final base = AppTypography.textTheme?.labelMedium;
    return _withWeight(base, FontWeight.w500);
  }

  static TextStyle get s11w500 {
    final base = AppTypography.textTheme?.labelSmall;
    return _withWeight(base, FontWeight.w500);
  }
}
