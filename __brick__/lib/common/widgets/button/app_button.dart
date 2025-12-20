import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/constants/design_constants.dart';
import '../../../utils/extensions/context_extensions.dart';
import 'package:vibration/vibration.dart';

import 'app_button_child.dart';
import 'app_button_loading_dots.dart';
import 'app_button_variants.dart';

class AppButton extends StatefulWidget {
  const AppButton._({
    super.key,
    required this.child,
    required this.onTap,
    required this.variant,
    required this.fill,
    this.layout = const AppButtonLayout(),
    this.isActive = true,
    this.isLoading = false,
    this.noShadow = false,
  });

  factory AppButton.variant({
    Key? key,
    required AppButtonVariant variant,
    required AppButtonFill fill,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton._(
      key: key,
      child: child,
      onTap: onTap,
      variant: variant,
      fill: fill,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  factory AppButton.primary({
    Key? key,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton._(
      key: key,
      child: child,
      onTap: onTap,
      variant: AppButtonVariant.primary,
      fill: AppButtonFill.solid,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  factory AppButton.grey({
    Key? key,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton.variant(
      key: key,
      variant: AppButtonVariant.grey,
      fill: AppButtonFill.solid,
      child: child,
      onTap: onTap,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  factory AppButton.greyGradient({
    Key? key,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton.variant(
      key: key,
      variant: AppButtonVariant.grey,
      fill: AppButtonFill.gradient,
      child: child,
      onTap: onTap,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  factory AppButton.primaryGradient({
    Key? key,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton._(
      key: key,
      child: child,
      onTap: onTap,
      variant: AppButtonVariant.primary,
      fill: AppButtonFill.gradient,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  factory AppButton.success({
    Key? key,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton._(
      key: key,
      child: child,
      onTap: onTap,
      variant: AppButtonVariant.success,
      fill: AppButtonFill.solid,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  factory AppButton.successGradient({
    Key? key,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton._(
      key: key,
      child: child,
      onTap: onTap,
      variant: AppButtonVariant.success,
      fill: AppButtonFill.gradient,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  factory AppButton.error({
    Key? key,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton._(
      key: key,
      child: child,
      onTap: onTap,
      variant: AppButtonVariant.error,
      fill: AppButtonFill.solid,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  factory AppButton.errorGradient({
    Key? key,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton._(
      key: key,
      child: child,
      onTap: onTap,
      variant: AppButtonVariant.error,
      fill: AppButtonFill.gradient,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  factory AppButton.warning({
    Key? key,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton._(
      key: key,
      child: child,
      onTap: onTap,
      variant: AppButtonVariant.warning,
      fill: AppButtonFill.solid,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  factory AppButton.warningGradient({
    Key? key,
    required AppButtonChild child,
    required VoidCallback? onTap,
    AppButtonLayout layout = const AppButtonLayout(),
    bool isActive = true,
    bool isLoading = false,
    bool noShadow = false,
  }) {
    return AppButton._(
      key: key,
      child: child,
      onTap: onTap,
      variant: AppButtonVariant.warning,
      fill: AppButtonFill.gradient,
      layout: layout,
      isActive: isActive,
      isLoading: isLoading,
      noShadow: noShadow,
    );
  }

  final AppButtonChild child;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final AppButtonFill fill;
  final AppButtonLayout layout;
  final bool isActive;
  final bool isLoading;
  final bool noShadow;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  bool _pressed = false;

  bool get _isEnabled =>
      widget.onTap != null && widget.isActive && !widget.isLoading;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
      reverseDuration: AppDurations.fast,
    );

    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    if (widget.isLoading) {
      _setPressed(true);
    }
  }

  @override
  void didUpdateWidget(covariant AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isLoading != widget.isLoading) {
      if (widget.isLoading) {
        _setPressed(true);
      } else {
        _setPressed(false);
      }
    }

    if (!widget.isLoading && (widget.onTap == null || !widget.isActive)) {
      _setPressed(false);
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    _pressed = value;

    if (_pressed) {
      _pressController.forward();
    } else {
      _pressController.reverse();
    }
  }

  void _vibratePress() {
    unawaited(() async {
      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator != true) return;
        await Vibration.vibrate(duration: 10, amplitude: 40);
      } catch (_) {}
    }());
  }

  void _vibrateTap() {
    unawaited(() async {
      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator != true) return;
        await Vibration.vibrate(duration: 15, amplitude: 70);
      } catch (_) {}
    }());
  }

  @override
  Widget build(BuildContext context) {
    final style = AppButtonStyleResolver.resolve(
      context,
      variant: widget.variant,
      fill: widget.fill,
      isActive: widget.isActive,
      noShadow: widget.noShadow,
    );

    final width = widget.layout.percentageWidth != null
        ? context.screenWidth * widget.layout.percentageWidth!
        : widget.layout.width?.w;

    var height = widget.layout.percentageHeight != null
        ? context.screenHeight * widget.layout.percentageHeight!
        : widget.layout.height.h;

    final isCircle = widget.layout.shape == AppButtonShape.circle;

    final borderRadiusValue = switch (widget.layout.shape) {
      AppButtonShape.circle => height / 2,
      AppButtonShape.pill => 999,
      AppButtonShape.rounded => widget.layout.borderRadius ?? AppRadii.sm,
    };

    final borderRadius = BorderRadius.circular(borderRadiusValue.r);

    final padding =
        widget.layout.contentPadding ?? widget.child.defaultPadding(context);

    final content = widget.isLoading
        ? AppButtonLoadingDots(color: style.foreground)
        : widget.child.build(context, foreground: style.foreground);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _isEnabled
          ? (_) {
              _setPressed(true);
              _vibratePress();
            }
          : null,
      onTapCancel: _isEnabled
          ? () {
              if (!widget.isLoading) _setPressed(false);
            }
          : null,
      onTapUp: _isEnabled
          ? (_) {
              if (!widget.isLoading) _setPressed(false);
            }
          : null,
      onTap: _isEnabled
          ? () {
              _vibrateTap();
              widget.onTap?.call();
            }
          : null,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: AppDurations.normal,
          curve: AppCurves.theme,
          width: isCircle ? height : width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: style.color,
            gradient: style.gradient,
            borderRadius: borderRadius,
            boxShadow: style.shadows,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}
