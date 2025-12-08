import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utilities for building a [SystemUiOverlayStyle] that matches the
/// active [ThemeData] of the application.
///
/// This allows the system status bar and navigation bar colors and icon
/// brightness to adapt automatically when the app theme changes.
class AppSystemUiOverlay {
  AppSystemUiOverlay._();

  /// Builds a [SystemUiOverlayStyle] for the given [theme].
  ///
  /// - Uses [ColorScheme.surface] as the base color for both the
  ///   status bar and the navigation bar.
  /// - Chooses icon brightness based on the estimated brightness of the
  ///   surface color to ensure good contrast.
  static SystemUiOverlayStyle forTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;

    // Estimate how light or dark the surface color is so we can pick
    // icon colors that remain legible.
    final surfaceBrightness = ThemeData.estimateBrightnessForColor(surface);

    // On Android, [statusBarIconBrightness] and
    // [systemNavigationBarIconBrightness] control the icon color. We want
    // icons to be the opposite of the background brightness.
    final iconBrightness = surfaceBrightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return SystemUiOverlayStyle(
      // Background color for the status bar (Android). On iOS this is
      // combined with [statusBarBrightness].
      statusBarColor: surface,
      // On iOS, [statusBarBrightness] describes the background brightness
      // of the status bar itself.
      statusBarBrightness: surfaceBrightness,
      // On Android, this controls the actual icon brightness.
      statusBarIconBrightness: iconBrightness,
      // Navigation bar styling (Android).
      systemNavigationBarColor: surface,
      systemNavigationBarIconBrightness: iconBrightness,
      systemNavigationBarDividerColor: surface,
    );
  }
}
