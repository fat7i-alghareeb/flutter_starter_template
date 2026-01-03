import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../common/widgets/app_icon_source.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../utils/extensions/theme_extensions.dart';
import '../../../../../../utils/extensions/context_extensions.dart';
import 'navigation_controller.dart';

/// A single item in [BottomNavBar].
///
/// Items are intentionally implemented as builders so the caller can supply
/// *any* widget as a tab, while still receiving a unified state
/// ([BottomNavItemState]) describing whether the item is active and what
/// color/size it should use.
class BottomNavItem {
  const BottomNavItem._({required this.builder});

  /// Creates an item from an [IconSource].
  ///
  /// Notes on sizing:
  /// - The `size` we pass into [IconSource.build] is a logical size.
  /// - The concrete [IconSource] implementations in this template apply
  ///   `.sp` internally (see `app_icon_source.dart`), so we intentionally do
  ///   not apply `.sp` again here.
  factory BottomNavItem.icon({
    required IconSource icon,
    String? semanticLabel,
    String? label,
  }) {
    return BottomNavItem._(
      builder: (context, state) {
        final effectiveLabel = (label != null && label.trim().isNotEmpty)
            ? label.trim()
            : null;

        final iconWidget = icon.build(
          context,
          color: state.color,
          size: state.iconSize,
        );

        final child = effectiveLabel == null
            ? iconWidget
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  4.verticalSpace,
                  Text(
                    effectiveLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.s11w500.copyWith(color: state.color),
                  ),
                ],
              );

        // Semantics adds accessibility metadata for screen readers.
        //
        // Here we provide:
        // - `label`: the spoken name of the tab.
        // - `selected`: whether this tab is currently active.
        //
        // This makes the custom bottom bar behave more like the stock
        // Material bottom navigation in accessibility tools.
        return Semantics(
          label: semanticLabel ?? effectiveLabel,
          selected: state.isActive,
          child: child,
        );
      },
    );
  }

  /// Creates an item from a custom builder.
  ///
  /// This is the most flexible option and allows you to build any widget
  /// (icon, icon+label, animated widget, etc.) while still receiving
  /// [BottomNavItemState] from the bar.
  factory BottomNavItem.builder({
    required Widget Function(BuildContext context, BottomNavItemState state)
    builder,
  }) {
    return BottomNavItem._(builder: builder);
  }

  /// Builds the tab widget.
  ///
  /// This is called for each tab on every relevant change (current index,
  /// colors, etc.). Keep the builder lightweight.
  final Widget Function(BuildContext context, BottomNavItemState state) builder;
}

/// State object passed into [BottomNavItem.builder].
///
/// This keeps the item builder decoupled from the bar implementation while
/// still enabling consistent active/inactive visuals.
class BottomNavItemState {
  const BottomNavItemState({
    required this.index,
    required this.isActive,
    required this.color,
    required this.iconSize,
  });

  final int index;
  final bool isActive;
  final Color color;
  final double iconSize;
}

/// Custom bottom navigation bar for the Root feature.
///
/// Key goals:
/// - Fully customizable items (via [BottomNavItem]).
/// - Minimal rebuild surface (only listens to [NavigationController]).
/// - Responsive sizing driven by available width (via [LayoutBuilder]).
/// - Smooth indicator movement and item animations (via `flutter_animate`).
///
/// Height rules:
/// - If [height] is `null`, a default is chosen.
/// - If `height <= 0`, the default is used.
/// - If `0 < height <= 1`, it is treated as a fraction of screen height.
///   Example: `height: 0.1` -> 10% of the screen height.
/// - If `height > 1`, it is treated as absolute logical pixels.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.controller,
    required this.items,
    this.height,
    this.backgroundColor,
    this.padding,
    this.indicatorColor,
    this.indicatorHeight = 3,
    this.indicatorRadius = 999,
    this.indicatorWidthFactor = 0.42,
    this.iconSize = 24,
    this.activeIconSizeDelta = 2,
    this.activeColor,
    this.inactiveColor,
    this.animationDuration = const Duration(milliseconds: 220),
    this.animationCurve = Curves.easeOutCubic,
  });

  final NavigationController controller;
  final List<BottomNavItem> items;

  /// Height of the bar.
  ///
  /// - `null`: default height.
  /// - `<= 0`: fallback to default height.
  /// - `0..1`: screen height percentage.
  /// - `> 1`: absolute logical pixels.
  final double? height;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  /// Indicator color.
  ///
  /// If `null`, defaults to [activeColor].
  final Color? indicatorColor;

  /// Indicator thickness in logical pixels.
  final double indicatorHeight;

  /// Corner radius for the indicator.
  ///
  /// This is passed through `.r` (ScreenUtil) so it scales consistently with
  /// radii across the app.
  final double indicatorRadius;

  /// Width of the indicator relative to the tab slot width.
  ///
  /// Example: `0.42` means indicator width is ~42% of the tab slot.
  final double indicatorWidthFactor;

  /// Base icon size passed into [IconSource.build].
  ///
  /// `IconSource` implementations already apply `.sp` internally, so keep this
  /// value as a logical size.
  final double iconSize;

  /// Additional size applied to the active icon.
  final double activeIconSizeDelta;

  /// Active tab color.
  ///
  /// Defaults to `context.primary`.
  final Color? activeColor;

  /// Inactive tab color.
  ///
  /// Defaults to `context.grey`.
  final Color? inactiveColor;

  /// Duration used for item emphasis + indicator movement.
  final Duration animationDuration;

  /// Curve used for item emphasis + indicator movement.
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Number of tabs.
        final count = items.length;

        // Resolve the height based on the rules documented above.
        final defaultHeight = context.isTablet ? 76.0.h : 68.0.h;
        final effectiveHeight = height == null
            ? defaultHeight
            : (height! <= 0
                  ? defaultHeight
                  : (height! <= 1.0
                        ? context.screenHeight * height!
                        : height!.h));

        final effectiveBackground = backgroundColor ?? context.surface;

        if (count == 0) {
          return Material(
            color: effectiveBackground,
            child: SafeArea(
              top: false,
              child: SizedBox(height: effectiveHeight),
            ),
          );
        }

        // Ensure the index is always valid (guards against runtime errors
        // if items length changes during hot reload / dev).
        final currentIndex = controller.currentIndex
            .clamp(0, count - 1)
            .toInt();

        final effectiveActiveColor = activeColor ?? context.primary;
        final effectiveInactiveColor = inactiveColor ?? context.grey;
        final effectiveIndicatorColor = indicatorColor ?? effectiveActiveColor;

        return Material(
          color: effectiveBackground,
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Width is resolved from constraints so the layout adapts to
                // tablets / rotations without relying on `.w`.
                final maxWidth = constraints.maxWidth;
                final direction = Directionality.of(context);
                final resolvedPadding = (padding ?? EdgeInsets.zero).resolve(
                  direction,
                );

                final innerWidth = math.max(
                  0.0,
                  maxWidth - resolvedPadding.horizontal,
                );
                final itemWidth = innerWidth / count;

                // Indicator width is a fraction of each item slot.
                final indicatorWidth = math.max(
                  12.0,
                  math.min(itemWidth * indicatorWidthFactor, itemWidth),
                );

                final indicatorStart =
                    (currentIndex * itemWidth) +
                    ((itemWidth - indicatorWidth) / 2.0);

                return Container(
                  height: effectiveHeight,
                  decoration: BoxDecoration(
                    color: context.background,
                    boxShadow: context.shadows.grey,
                  ),
                  child: Padding(
                    padding: padding ?? EdgeInsets.zero,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Row(
                          children: List.generate(count, (index) {
                            final isActive = index == currentIndex;
                            final state = BottomNavItemState(
                              index: index,
                              isActive: isActive,
                              color: isActive
                                  ? effectiveActiveColor
                                  : effectiveInactiveColor,
                              iconSize: isActive
                                  ? (iconSize + activeIconSizeDelta)
                                  : iconSize,
                            );

                            final child = items[index].builder(context, state);

                            return Expanded(
                              child: _BottomNavTap(
                                isActive: isActive,
                                duration: animationDuration,
                                curve: animationCurve,
                                onTap: () => controller.setIndex(index),
                                index: index,
                                child: child,
                              ),
                            );
                          }),
                        ),
                        _BottomNavIndicator(
                          duration: animationDuration,
                          curve: animationCurve,
                          color: effectiveIndicatorColor,
                          height: indicatorHeight,
                          radius: indicatorRadius,
                          width: indicatorWidth,
                          start: indicatorStart,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Tap wrapper for a single tab slot.
///
/// This is separated to keep the public widget focused and to keep rebuild
/// logic localized.
class _BottomNavTap extends StatelessWidget {
  const _BottomNavTap({
    required this.child,
    required this.index,
    required this.isActive,
    required this.onTap,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final int index;
  final bool isActive;
  final VoidCallback onTap;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    // We keep this as a simple GestureDetector because:
    // - The caller may wrap their own Material/Ink effects.
    // - We want to avoid forcing ripple behavior.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        // Animate item emphasis when it becomes active.
        child: child
            .animate(target: isActive ? 1.0 : 0.0)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.08, 1.08),
              duration: duration,
              curve: curve,
            )
            .fade(begin: 0.78, end: 1, duration: duration, curve: curve),
      ),
    );
  }
}

/// Animated indicator that moves between tabs.
///
/// Uses [AnimatedAlign] so we don't need to compute pixel-perfect offsets.
class _BottomNavIndicator extends StatelessWidget {
  const _BottomNavIndicator({
    required this.duration,
    required this.curve,
    required this.color,
    required this.height,
    required this.radius,
    required this.width,
    required this.start,
  });

  final Duration duration;
  final Curve curve;
  final Color color;
  final double height;
  final double radius;
  final double width;
  final double start;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositionedDirectional(
      duration: duration,
      curve: curve,
      start: start,
      top: 0,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius.r),
          ),
        ),
      ),
    );
  }
}
