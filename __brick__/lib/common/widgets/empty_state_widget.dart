import '../imports/imports.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// EmptyStateWidget
/// --------------
///
/// A simple full-height empty state widget.
///
/// Features:
/// - Centered content
/// - Customizable [icon] via [IconSource]
/// - Optional pull-to-refresh (wraps content with [RefreshIndicator])
/// - Optional retry button (primary gradient) using [AppButton]
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   text: AppStrings.emptyStateNoData,
///   onRefresh: () async => cubit.load(),
///   onRetrying: () => cubit.load(),
/// )
///
/// // With a network image icon:
/// EmptyStateWidget(
///   icon: IconSource.imageNetwork("https://..."),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.icon,
    this.text,
    this.onRefresh,
    this.onRetrying,
    this.retryLabel,
    this.retryIcon,
    this.iconSize = 86,
    this.padding,
    this.maxWidth,
    this.textStyle,
    this.iconColor,
  });

  final IconSource? icon;
  final String? text;

  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetrying;

  final String? retryLabel;
  final IconSource? retryIcon;

  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final TextStyle? textStyle;
  final Color? iconColor;

  Widget _buildBody(BuildContext context) {
    final colors = context.colorScheme;

    final effectiveIcon =
        icon ?? IconSource.icon(Icons.inbox_outlined, size: iconSize);

    final effectiveText = text?.trim().isNotEmpty == true
        ? text!
        : AppStrings.emptyStateNoData;

    final effectiveIconColor =
        iconColor ?? colors.onSurface.withValues(alpha: 0.55);

    // For pull-to-refresh to work even when the content doesn't fill the
    // viewport, the scroll view must always be scrollable.
    final physics = onRefresh != null
        ? const AlwaysScrollableScrollPhysics()
        : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

    final content = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: physics,
          child: ConstrainedBox(
            // Forces the column to take at least the full height so the
            // centered layout stays centered on tall screens.
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: (maxWidth ?? 520).w),
                child: Padding(
                  padding: padding ?? AppSpacing.standardPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      effectiveIcon.build(
                        context,
                        color: effectiveIconColor,
                        size: iconSize,
                      ),
                      AppSpacing.lg.verticalSpace,
                      Text(
                        effectiveText,
                        textAlign: TextAlign.center,
                        style:
                            textStyle ??
                            AppTextStyles.s16w400.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.82),
                            ),
                      ),
                      if (onRetrying != null) ...[
                        AppSpacing.xl.verticalSpace,
                        AppButton.primaryGradient(
                          onTap: onRetrying,
                          child: AppButtonChild.labelIcon(
                            label: retryLabel ?? AppStrings.retry,
                            icon:
                                retryIcon ??
                                IconSource.icon(Icons.refresh_rounded),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (onRefresh == null) return content;

    // Wrap with RefreshIndicator only when refresh is enabled.
    return RefreshIndicator(onRefresh: onRefresh!, child: content);
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context)
        .animate()
        .fadeIn(duration: 200.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.04, end: 0, duration: 240.ms, curve: Curves.easeOut);
  }
}
