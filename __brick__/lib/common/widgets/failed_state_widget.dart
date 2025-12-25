import '../imports/imports.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// FailedStateWidget
/// ---------------
///
/// A full-height failure state widget.
///
/// Features:
/// - Centered content
/// - Customizable [icon] via [IconSource]
/// - Optional pull-to-refresh (wraps content with [RefreshIndicator])
/// - Optional retry button (primary gradient) using [AppButton]
/// - Optional `details` text for debugging (kept visually subtle)
///
/// Usage:
/// ```dart
/// FailedStateWidget(
///   message: errorMessage,
///   onRetrying: () => cubit.load(),
/// )
///
/// // With details for debugging:
/// FailedStateWidget(
///   message: AppStrings.somethingWentWrong,
///   details: exception.toString(),
///   onRetrying: () => cubit.load(),
/// )
/// ```
class FailedStateWidget extends StatelessWidget {
  const FailedStateWidget({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.details,
    this.onRefresh,
    this.onRetrying,
    this.retryLabel,
    this.retryIcon,
    this.iconSize = 86,
    this.padding,
    this.maxWidth,
    this.titleStyle,
    this.messageStyle,
    this.detailsStyle,
    this.iconColor,
  });

  final IconSource? icon;

  final String? title;
  final String? message;
  final String? details;

  final Future<void> Function()? onRefresh;
  final VoidCallback? onRetrying;

  final String? retryLabel;
  final IconSource? retryIcon;

  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final TextStyle? detailsStyle;

  final Color? iconColor;

  Widget _buildBody(BuildContext context) {
    final colors = context.colorScheme;

    final effectiveIcon =
        icon ?? IconSource.icon(Icons.error_outline_rounded, size: iconSize);

    final effectiveTitle = title?.trim().isNotEmpty == true
        ? title!
        : AppStrings.somethingWentWrong;

    final effectiveMessage = message?.trim().isNotEmpty == true
        ? message!
        : AppStrings.unknownError;

    final effectiveIconColor =
        iconColor ?? colors.onSurface.withValues(alpha: 0.55);

    // Enable pull-to-refresh even when the error UI doesn't overflow.
    final physics = onRefresh != null
        ? const AlwaysScrollableScrollPhysics()
        : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

    final content = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: physics,
          child: ConstrainedBox(
            // Keeps the state vertically centered by filling the viewport.
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: (maxWidth ?? 560).w),
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
                      AppSpacing.lg.verticalSpacing,
                      Text(
                        effectiveTitle,
                        textAlign: TextAlign.center,
                        style:
                            titleStyle ??
                            AppTextStyles.s20w700.copyWith(
                              color: colors.onSurface,
                            ),
                      ),
                      AppSpacing.sm.verticalSpacing,
                      Text(
                        effectiveMessage,
                        textAlign: TextAlign.center,
                        style:
                            messageStyle ??
                            AppTextStyles.s16w400.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.82),
                            ),
                      ),
                      if (details?.trim().isNotEmpty == true) ...[
                        AppSpacing.md.verticalSpacing,
                        Text(
                          details!,
                          textAlign: TextAlign.center,
                          style:
                              detailsStyle ??
                              AppTextStyles.s12w400.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.55),
                              ),
                        ),
                      ],
                      if (onRetrying != null) ...[
                        AppSpacing.xl.verticalSpacing,
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
