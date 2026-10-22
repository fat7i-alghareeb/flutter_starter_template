import 'package:flutter/material.dart';

import '../../../core/platform/app_platform.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../utils/extensions/theme_extensions.dart';
import '../../../utils/constants/design_constants.dart';

abstract class AppFormFieldDefaults {
  static const double borderWidth = 1;

  static double borderRadiusValue() {
    return AppRadii.sm;
  }

  static EdgeInsetsGeometry contentPadding() {
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  }

  /// A single-line field's height: 44 under a finger, 40 under a mouse. A tall
  /// field is mostly empty padding, and a form of them reads as a long strip.
  static double get height => AppPlatform.hasDesktopWindow ? 40 : 44;

  static TextStyle titleTextStyle(BuildContext context) {
    return AppTextStyles.s14w600.copyWith(
      color: context.onSurface.withValues(alpha: 0.85),
    );
  }

  static TextStyle errorTextStyle(BuildContext context) {
    return AppTextStyles.s12w500.copyWith(color: AppColors.error);
  }

  static Color iconColor(BuildContext context) {
    return context.colorScheme.onSurfaceVariant;
  }

  /// Placeholder text. `onSurfaceVariant` — 4.5:1 or better on a card in both
  /// themes; the old tint of the border grey was close to invisible.
  static Color hintColor(BuildContext context) {
    return context.colorScheme.onSurfaceVariant;
  }

  /// The plate of a field: the card colour, so a field reads as a field on the
  /// grey page and keeps its border as the edge. A disabled one steps back to
  /// the quiet plate.
  static Color fillColor(BuildContext context, {bool enabled = true}) {
    return enabled
        ? context.colorScheme.surface
        : context.colorScheme.surfaceContainerHighest;
  }

  static List<BoxShadow> shadows(BuildContext context) {
    return context.shadows.grey;
  }

  static Color borderColorEnabled(BuildContext context) {
    return context.grey;
  }

  static Color borderColorFocused(BuildContext context) {
    return context.primary;
  }

  static Color borderColorDisabled(BuildContext context) {
    return context.colorScheme.outline;
  }

  static Color borderColorError(BuildContext context) {
    return AppColors.error;
  }
}
