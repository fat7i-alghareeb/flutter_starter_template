import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central typography configuration for the app.
///
/// All text styles should come from this configuration so that updating
/// fonts or sizes happens in a single place.
class AppTypography {
  AppTypography._();

  /// Base font family used across the app.
  ///
  /// To swap fonts, change this to another [GoogleFonts] family and adjust
  /// weights in this method as needed.
  static TextTheme baseTextTheme(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GoogleFonts.poppinsTextTheme(textTheme);
  }

  static TextTheme? _cachedTextTheme;

  static TextTheme? get textTheme => _cachedTextTheme;

  /// Builds a [TextTheme] with responsive font sizes using [ScreenUtil].
  ///
  /// All base sizes are specified in logical pixels and converted to `.sp`
  /// so that the global [ScreenUtilInit.fontSizeResolver] controls the
  /// final scaling behavior.
  static TextTheme buildTextTheme(BuildContext context) {
    final base = baseTextTheme(context);

    double s(double size) => size.sp;

    final themed = base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: s(40)),
      displayMedium: base.displayMedium?.copyWith(fontSize: s(34)),
      displaySmall: base.displaySmall?.copyWith(fontSize: s(28)),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: s(24)),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: s(22)),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: s(20)),
      titleLarge: base.titleLarge?.copyWith(fontSize: s(18)),
      titleMedium: base.titleMedium?.copyWith(fontSize: s(16)),
      titleSmall: base.titleSmall?.copyWith(fontSize: s(14)),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: s(16)),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: s(14)),
      bodySmall: base.bodySmall?.copyWith(fontSize: s(12)),
      labelLarge: base.labelLarge?.copyWith(fontSize: s(14)),
      labelMedium: base.labelMedium?.copyWith(fontSize: s(12)),
      labelSmall: base.labelSmall?.copyWith(fontSize: s(11)),
    );

    _cachedTextTheme = themed;
    return themed;
  }
}
