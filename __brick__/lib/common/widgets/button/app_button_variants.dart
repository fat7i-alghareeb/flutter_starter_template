import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/extensions/theme_extensions.dart';

/// Shared types and style resolution for [AppButton].
enum AppButtonFill { solid, gradient }

/// Shadow style used by [AppButtonStyleResolver].
///
/// Defaults to [AppButtonShadowVariant.grey] unless overridden.
enum AppButtonShadowVariant { primary, success, error, warning, grey }

/// Shape used by [AppButtonLayout] to compute border radius and sizing.
enum AppButtonShape { rounded, pill, circle }

/// Layout configuration for [AppButton].
///
/// Notes:
/// - If [height] is null, the button wraps content + padding.
/// - If [percentageHeight] is set, it overrides [height].
class AppButtonLayout {
  const AppButtonLayout({
    this.width,
    this.height,
    this.percentageWidth,
    this.percentageHeight,
    this.borderRadius,
    this.shape = AppButtonShape.rounded,
    this.contentPadding,
  });

  final double? width;
  final double? height;

  final double? percentageWidth;
  final double? percentageHeight;

  final double? borderRadius;
  final AppButtonShape shape;

  final EdgeInsetsGeometry? contentPadding;
}

abstract class AppButtonVariant {
  const AppButtonVariant();

  Color solidColor(BuildContext context);

  LinearGradient gradient(BuildContext context);

  Color foreground(BuildContext context);

  static const AppButtonVariant primary = _PrimaryButtonVariant();
  static const AppButtonVariant success = _SuccessButtonVariant();
  static const AppButtonVariant error = _ErrorButtonVariant();
  static const AppButtonVariant warning = _WarningButtonVariant();
  static const AppButtonVariant grey = _GreyButtonVariant();
}

class AppButtonResolvedStyle {
  const AppButtonResolvedStyle({
    required this.fill,
    required this.color,
    required this.gradient,
    required this.foreground,
    required this.shadows,
  });

  final AppButtonFill fill;
  final Color? color;
  final LinearGradient? gradient;
  final Color foreground;
  final List<BoxShadow> shadows;
}

class AppButtonStyleResolver {
  AppButtonStyleResolver._();

  static AppButtonResolvedStyle resolve(
    BuildContext context, {
    required AppButtonVariant variant,
    required AppButtonFill fill,
    required bool isActive,
    required bool noShadow,
    AppButtonShadowVariant? shadowVariant,
    List<BoxShadow>? customShadows,
  }) {
    final effectiveVariant = isActive ? variant : AppButtonVariant.grey;

    final color = fill == AppButtonFill.solid
        ? effectiveVariant.solidColor(context)
        : null;

    final gradient = fill == AppButtonFill.gradient
        ? effectiveVariant.gradient(context)
        : null;

    final foreground = isActive
        ? effectiveVariant.foreground(context)
        : context.colorScheme.onSurface;

    final shadows = noShadow
        ? const <BoxShadow>[]
        : (customShadows ??
              _resolveShadows(
                context,
                shadowVariant ?? AppButtonShadowVariant.grey,
              ));

    return AppButtonResolvedStyle(
      fill: fill,
      color: color,
      gradient: gradient,
      foreground: foreground,
      shadows: shadows,
    );
  }

  static Color foregroundForColor(Color background) {
    final b = ThemeData.estimateBrightnessForColor(background);
    return b == Brightness.dark ? Colors.white : Colors.black;
  }

  static List<BoxShadow> _resolveShadows(
    BuildContext context,
    AppButtonShadowVariant variant,
  ) {
    return switch (variant) {
      AppButtonShadowVariant.primary => context.shadows.primary,
      AppButtonShadowVariant.success => context.shadows.success,
      AppButtonShadowVariant.error => context.shadows.error,
      AppButtonShadowVariant.warning => context.shadows.warning,
      AppButtonShadowVariant.grey => context.shadows.grey,
    };
  }
}

class _PrimaryButtonVariant extends AppButtonVariant {
  const _PrimaryButtonVariant();

  @override
  Color solidColor(BuildContext context) => context.colorScheme.primary;

  @override
  LinearGradient gradient(BuildContext context) => context.gradients.primary;

  @override
  Color foreground(BuildContext context) => context.colorScheme.onPrimary;
}

class _SuccessButtonVariant extends AppButtonVariant {
  const _SuccessButtonVariant();

  @override
  Color solidColor(BuildContext context) => AppColors.success;

  @override
  LinearGradient gradient(BuildContext context) => context.gradients.success;

  @override
  Color foreground(BuildContext context) =>
      AppButtonStyleResolver.foregroundForColor(AppColors.success);
}

class _ErrorButtonVariant extends AppButtonVariant {
  const _ErrorButtonVariant();

  @override
  Color solidColor(BuildContext context) => AppColors.error;

  @override
  LinearGradient gradient(BuildContext context) => context.gradients.error;

  @override
  Color foreground(BuildContext context) =>
      AppButtonStyleResolver.foregroundForColor(AppColors.error);
}

class _WarningButtonVariant extends AppButtonVariant {
  const _WarningButtonVariant();

  @override
  Color solidColor(BuildContext context) => AppColors.warning;

  @override
  LinearGradient gradient(BuildContext context) => context.gradients.warning;

  @override
  Color foreground(BuildContext context) =>
      AppButtonStyleResolver.foregroundForColor(AppColors.warning);
}

class _GreyButtonVariant extends AppButtonVariant {
  const _GreyButtonVariant();

  @override
  Color solidColor(BuildContext context) => context.grey;

  @override
  LinearGradient gradient(BuildContext context) => context.gradients.grey;

  @override
  Color foreground(BuildContext context) => context.colorScheme.onSurface;
}

class CustomButtonVariant extends AppButtonVariant {
  final Color? color;
  final LinearGradient? gradientColor;
  const CustomButtonVariant({this.color, this.gradientColor});

  @override
  Color solidColor(BuildContext context) => color ?? context.grey;

  @override
  LinearGradient gradient(BuildContext context) =>
      gradientColor ?? context.gradients.grey;

  @override
  Color foreground(BuildContext context) => context.colorScheme.onSurface;
}
