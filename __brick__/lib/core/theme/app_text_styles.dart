import 'package:flutter/material.dart';

import 'app_typography.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle? get s40w700 {
    final base = AppTypography.textTheme?.displayLarge;
    return base?.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle? get s34w700 {
    final base = AppTypography.textTheme?.displayMedium;
    return base?.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle? get s28w700 {
    final base = AppTypography.textTheme?.displaySmall;
    return base?.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle? get s24w700 {
    final base = AppTypography.textTheme?.headlineLarge;
    return base?.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle? get s22w700 {
    final base = AppTypography.textTheme?.headlineMedium;
    return base?.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle? get s20w700 {
    final base = AppTypography.textTheme?.headlineSmall;
    return base?.copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle? get s18w600 {
    final base = AppTypography.textTheme?.titleLarge;
    return base?.copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle? get s16w600 {
    final base = AppTypography.textTheme?.titleMedium;
    return base?.copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle? get s14w600 {
    final base = AppTypography.textTheme?.titleSmall;
    return base?.copyWith(fontWeight: FontWeight.w600);
  }

  static TextStyle? get s16w400 {
    final base = AppTypography.textTheme?.bodyLarge;
    return base?.copyWith(fontWeight: FontWeight.w400);
  }

  static TextStyle? get s14w400 {
    final base = AppTypography.textTheme?.bodyMedium;
    return base?.copyWith(fontWeight: FontWeight.w400);
  }

  static TextStyle? get s12w400 {
    final base = AppTypography.textTheme?.bodySmall;
    return base?.copyWith(fontWeight: FontWeight.w400);
  }

  static TextStyle? get s14w500 {
    final base = AppTypography.textTheme?.labelLarge;
    return base?.copyWith(fontWeight: FontWeight.w500);
  }

  static TextStyle? get s12w500 {
    final base = AppTypography.textTheme?.labelMedium;
    return base?.copyWith(fontWeight: FontWeight.w500);
  }

  static TextStyle? get s11w500 {
    final base = AppTypography.textTheme?.labelSmall;
    return base?.copyWith(fontWeight: FontWeight.w500);
  }
}
