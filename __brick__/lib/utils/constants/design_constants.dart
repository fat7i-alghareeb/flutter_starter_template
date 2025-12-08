import 'package:flutter/animation.dart';

/// Global design constants used across the app.
///
/// Central place for spacing, radii, animation durations and base
/// design size for ScreenUtil.
class AppSpacing {
  AppSpacing._();

  /// 4
  static const double xs = 4;

  /// 8
  static const double sm = 8;

  /// 12
  static const double md = 12;

  /// 16
  static const double lg = 16;

  /// 24
  static const double xl = 24;

  /// 32
  static const double xxl = 32;
}

/// Common corner radii used for shapes.
class AppRadii {
  AppRadii._();

  /// 4
  static const double xs = 4;

  /// 8
  static const double sm = 8;

  /// 12
  static const double md = 12;

  /// 16
  static const double lg = 16;
}

/// Global animation durations used throughout the app.
class AppDurations {
  AppDurations._();

  /// Duration for theme transitions.
  static const Duration themeAnimation = Duration(milliseconds: 300);

  /// Fast UI feedback (e.g. tap effects).
  static const Duration fast = Duration(milliseconds: 150);

  /// Default animation duration for most UI transitions.
  static const Duration normal = Duration(milliseconds: 250);

  /// Longer transitions (e.g. page transitions, dialogs).
  static const Duration slow = Duration(milliseconds: 350);
}

/// Curves used for animations.
class AppCurves {
  AppCurves._();

  /// Default curve for theme and major UI transitions.
  static const Curve theme = Curves.easeInOut;
}

/// Design size used by ScreenUtil.
///
/// Update this if your base design (Figma / XD) uses a different
/// logical resolution.
class AppDesign {
  AppDesign._();

  static const Size designSize = Size(390, 844); // iPhone 13 / common base
}
