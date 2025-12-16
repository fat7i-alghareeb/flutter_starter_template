import 'package:flutter/material.dart';
import 'package:testNameToDelete/core/theme/app_colors.dart' show AppColors;

/// Defines a set of optional seed colors for constructing a [ColorScheme].
///
/// Any field left `null` will fall back to the value generated from
/// `ColorScheme.fromSeed`, while non-null fields will override it. This
/// allows you to:
///
/// - Customize only a subset of the palette.
/// - Provide completely different colors for light and dark themes.
class AppColorSeedSet {
  /// Creates an immutable set of color seeds used to build a [ColorScheme].
  const AppColorSeedSet({
    this.primary,
    this.onPrimary,
    this.primaryContainer,
    this.onPrimaryContainer,
    this.secondary,
    this.onSecondary,
    this.secondaryContainer,
    this.onSecondaryContainer,
    this.tertiary,
    this.onTertiary,
    this.tertiaryContainer,
    this.onTertiaryContainer,
    this.error,
    this.onError,
    this.errorContainer,
    this.onErrorContainer,
    this.background,
    this.onBackground,
    this.surface,
    this.onSurface,
    this.surfaceVariant,
    this.onSurfaceVariant,
    this.outline,
    this.outlineVariant,
    this.shadow,
    this.scrim,
    this.inverseSurface,
    this.onInverseSurface,
    this.inversePrimary,
    this.surfaceTint,
  });

  /// Primary brand color.
  final Color? primary;

  /// Text/icon color appearing on top of [primary].
  final Color? onPrimary;

  /// Container color derived from [primary].
  final Color? primaryContainer;

  /// Text/icon color appearing on top of [primaryContainer].
  final Color? onPrimaryContainer;

  /// Secondary accent color.
  final Color? secondary;

  /// Text/icon color appearing on top of [secondary].
  final Color? onSecondary;

  /// Container color derived from [secondary].
  final Color? secondaryContainer;

  /// Text/icon color appearing on top of [secondaryContainer].
  final Color? onSecondaryContainer;

  /// Tertiary accent color.
  final Color? tertiary;

  /// Text/icon color appearing on top of [tertiary].
  final Color? onTertiary;

  /// Container color derived from [tertiary].
  final Color? tertiaryContainer;

  /// Text/icon color appearing on top of [tertiaryContainer].
  final Color? onTertiaryContainer;

  /// Error color.
  final Color? error;

  /// Text/icon color appearing on top of [error].
  final Color? onError;

  /// Container color derived from [error].
  final Color? errorContainer;

  /// Text/icon color appearing on top of [errorContainer].
  final Color? onErrorContainer;

  /// Background color for large surfaces.
  final Color? background;

  /// Text/icon color appearing on top of [background].
  final Color? onBackground;

  /// Default surface color for components.
  final Color? surface;

  /// Text/icon color appearing on top of [surface].
  final Color? onSurface;

  /// Variant of [surface] used for differentiation (e.g. cards).
  final Color? surfaceVariant;

  /// Text/icon color appearing on top of [surfaceVariant].
  final Color? onSurfaceVariant;

  /// Outline color for borders and dividers.
  final Color? outline;

  /// Softer outline variant.
  final Color? outlineVariant;

  /// Shadow color.
  final Color? shadow;

  /// Scrim color used for overlays.
  final Color? scrim;

  /// Inverse surface color used in contrasting areas.
  final Color? inverseSurface;

  /// Text/icon color appearing on top of [inverseSurface].
  final Color? onInverseSurface;

  /// Primary color used in inverse contexts.
  final Color? inversePrimary;

  /// Surface tint applied to emphasize elevation.
  final Color? surfaceTint;
}

/// Theme-specific color seeds for the application.
///
/// You can provide different colors for light and dark themes here. Any
/// field left `null` will be derived automatically from a Material 3
/// seed-based [ColorScheme].
class AppColorSeeds {
  AppColorSeeds._();

  /// Seed colors for the light theme.
  static const AppColorSeedSet light = AppColorSeedSet(
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    secondary: AppColors.secondaryLight,
    background: Color(0xFFF9FAFB),
    surface: Colors.white,
  );

  /// Seed colors for the dark theme.
  static const AppColorSeedSet dark = AppColorSeedSet(
    primary: AppColors.primaryDark,
    onPrimary: Color(0xFF0D47A1),
    secondary: AppColors.secondaryDark,
    background: Color(0xFF111827),
    surface: Color(0xFF111827),
    surfaceVariant: Color(0xFF333333),
    onSurfaceVariant: Color(0xFFFFFFFF),
    outline: Color(0xFFFFFFFF),
    outlineVariant: Color(0xFF666666),
    shadow: Color(0xFFFFFFFF),
    scrim: Color(0xFFFFFFFF),
    inverseSurface: Color(0xFFFFFFFF),
    onInverseSurface: Color(0xFF333333),
    inversePrimary: Color(0xFF90CAF9),
    surfaceTint: Color(0xFF90CAF9),
  );
}

/// Predefined light and dark [ColorScheme]s for the app.
///
/// These are built explicitly for each theme using [AppColorSeedSet]
/// overrides on top of a baseline `ColorScheme.fromSeed` result.
class AppColorSchemes {
  AppColorSchemes._();

  /// Fully configured light [ColorScheme] for the app.
  static final ColorScheme light = _buildColorScheme(
    brightness: Brightness.light,
    seeds: AppColorSeeds.light,
  );

  /// Fully configured dark [ColorScheme] for the app.
  static final ColorScheme dark = _buildColorScheme(
    brightness: Brightness.dark,
    seeds: AppColorSeeds.dark,
  );

  /// Builds a [ColorScheme] by merging seed overrides with a baseline
  /// `ColorScheme.fromSeed` result.
  static ColorScheme _buildColorScheme({
    required Brightness brightness,
    required AppColorSeedSet seeds,
  }) {
    // Use primary as the seed when provided, otherwise fall back to a
    // sensible blue-based default.
    final Color seedColor = seeds.primary ?? const Color(0xFF1565C0);

    final base = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ColorScheme(
      brightness: brightness,
      primary: seeds.primary ?? base.primary,
      onPrimary: seeds.onPrimary ?? base.onPrimary,
      primaryContainer: seeds.primaryContainer ?? base.primaryContainer,
      onPrimaryContainer: seeds.onPrimaryContainer ?? base.onPrimaryContainer,
      secondary: seeds.secondary ?? base.secondary,
      onSecondary: seeds.onSecondary ?? base.onSecondary,
      secondaryContainer: seeds.secondaryContainer ?? base.secondaryContainer,
      onSecondaryContainer:
          seeds.onSecondaryContainer ?? base.onSecondaryContainer,
      tertiary: seeds.tertiary ?? base.tertiary,
      onTertiary: seeds.onTertiary ?? base.onTertiary,
      tertiaryContainer: seeds.tertiaryContainer ?? base.tertiaryContainer,
      onTertiaryContainer:
          seeds.onTertiaryContainer ?? base.onTertiaryContainer,
      error: seeds.error ?? base.error,
      onError: seeds.onError ?? base.onError,
      errorContainer: seeds.errorContainer ?? base.errorContainer,
      onErrorContainer: seeds.onErrorContainer ?? base.onErrorContainer,
      surface: seeds.surface ?? base.surface,
      onSurface: seeds.onSurface ?? base.onSurface,
      surfaceContainerHighest:
          seeds.surfaceVariant ?? base.surfaceContainerHighest,
      onSurfaceVariant: seeds.onSurfaceVariant ?? base.onSurfaceVariant,
      outline: seeds.outline ?? base.outline,
      outlineVariant: seeds.outlineVariant ?? base.outlineVariant,
      shadow: seeds.shadow ?? base.shadow,
      scrim: seeds.scrim ?? base.scrim,
      inverseSurface: seeds.inverseSurface ?? base.inverseSurface,
      onInverseSurface: seeds.onInverseSurface ?? base.onInverseSurface,
      inversePrimary: seeds.inversePrimary ?? base.inversePrimary,
      surfaceTint: seeds.surfaceTint ?? base.surfaceTint,
    );
  }
}
