import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// AppShimmer
/// ---------
///
/// A thin wrapper around the `shimmer` package that provides:
/// - A consistent default color palette based on the current theme.
/// - Convenient factories for common skeleton shapes.
///
/// Usage:
/// ```dart
/// AppShimmer.box(width: 120, height: 16);
/// AppShimmer.circle(size: 42);
///
/// AppShimmer(
///   child: Container(height: 120, width: double.infinity),
/// );
/// ```
class AppShimmer extends StatelessWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.animate = true,
    this.enableHighlight = true,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1400),
    this.direction = ShimmerDirection.ltr,
  });

  final Widget child;

  final bool enabled;

  final bool animate;

  final bool enableHighlight;

  final Color? baseColor;

  final Color? highlightColor;

  final Duration period;

  final ShimmerDirection direction;

  factory AppShimmer.box({
    Key? key,
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
    double borderRadius = 12,
    Color? color,
    bool enabled = true,
    bool animate = true,
    bool enableHighlight = true,
    Color? baseColor,
    Color? highlightColor,
    Duration period = const Duration(milliseconds: 1400),
    ShimmerDirection direction = ShimmerDirection.ltr,
  }) {
    return AppShimmer(
      key: key,
      enabled: enabled,
      animate: animate,
      enableHighlight: enableHighlight,
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: period,
      direction: direction,
      child: Container(
        width: width?.w,
        height: height?.h,
        margin: margin,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }

  factory AppShimmer.circle({
    Key? key,
    double size = 42,
    EdgeInsetsGeometry? margin,
    Color? color,
    bool enabled = true,
    bool animate = true,
    bool enableHighlight = true,
    Color? baseColor,
    Color? highlightColor,
    Duration period = const Duration(milliseconds: 1400),
    ShimmerDirection direction = ShimmerDirection.ltr,
  }) {
    return AppShimmer(
      key: key,
      enabled: enabled,
      animate: animate,
      enableHighlight: enableHighlight,
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: period,
      direction: direction,
      child: Container(
        width: size.r,
        height: size.r,
        margin: margin,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // `enabled` disables the shimmer wrapper completely (returns child).
    // `animate` keeps the shimmer colors but pauses the animation.
    if (!enabled) return child;

    final theme = Theme.of(context);

    final base =
        baseColor ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9);

    final highlight = enableHighlight
        ? (highlightColor ?? theme.colorScheme.surface)
        : base;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: period,
      direction: direction,
      enabled: animate,
      child: child,
    );
  }
}
