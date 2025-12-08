import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

import '../../utils/constants/design_constants.dart';
import 'app_theme_colors.dart';

/// Builds light and dark [ThemeData] instances for the app using
/// Material 3 and shared configuration.
class AppTheme {
  AppTheme._();

  /// Light theme based on [AppColorSchemes.light].
  static ThemeData light(BuildContext context, TextTheme textTheme) {
    return _buildTheme(
      colorScheme: AppColorSchemes.light,
      textTheme: textTheme,
      useMaterial3: true,
    );
  }

  /// Dark theme based on [AppColorSchemes.dark].
  static ThemeData dark(BuildContext context, TextTheme textTheme) {
    return _buildTheme(
      colorScheme: AppColorSchemes.dark,
      textTheme: textTheme,
      useMaterial3: true,
    );
  }

  /// Shared ThemeData configuration for both light and dark themes.
  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool useMaterial3,
  }) {
    final base = ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
    );
  }
}
