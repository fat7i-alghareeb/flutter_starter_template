import 'package:flutter/material.dart';

/// Theme-agnostic static colors used across the app.
///
/// Use these for semantic feedback (success, warning, etc.) that do not
/// change between light and dark themes.
class AppColors {
  AppColors._();

  /// Color used for success/toast states.
  static const Color success = Color(0xFF2E7D32);

  /// Color used for warning states.
  static const Color warning = Color(0xFFF9A825);

  /// Color used for error states beyond the core [ColorScheme.error].
  static const Color error = Color(0xFFD32F2F);

  /// Color used for informational highlights.
  static const Color info = Color(0xFF0288D1);
}
