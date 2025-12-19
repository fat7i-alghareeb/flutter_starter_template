import 'package:flutter/material.dart';

/// Theme-agnostic static colors used across the app.
///
/// Use these for semantic feedback (success, warning, etc.) that do not
/// change between light and dark themes.
class AppColors {
  AppColors._();

  /// primary Color
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF90CAF9);

  /// Secondary Color
  static const Color secondaryLight = Color(0xFF00BFA5);
  static const Color secondaryDark = Color(0xFF64FFDA);

  static const Color greyLight = Color(0xFFD1D5DB);
  static const Color greyDark = Color(0xFF374151);

  /// Color used for success/toast states.
  static const Color success = Color(0xFF2E7D32);

  /// Color used for warning states.
  static const Color warning = Color(0xFFF9A825);

  /// Color used for error states beyond the core [ColorScheme.error].
  static const Color error = Color(0xFFD32F2F);

  /// Color used for informational highlights.
  static const Color info = Color(0xFF0288D1);
}
