import '../imports/imports.dart';

/// AppBottomSheet
/// -------------
///
/// Standardized bottom sheet layout used across the app.
///
/// Usage:
/// ```dart
/// await AppBottomSheet.show(
///   context,
///   sheet: AppBottomSheet.basic(
///     title: 'Filter',
///     child: FilterForm(),
///   ),
/// );
/// ```
///
/// This widget focuses on presentation. Showing it is done via the
/// [AppBottomSheet.show] helper.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet._({
    super.key,
    required this.child,
    this.title,
    this.titleStyle,
    this.header,
    this.actions,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 16,
    this.showDragHandle = true,
    this.unfocusOnTapOutside = true,
    this.scrollable = true,
  });

  /// A simple, common bottom sheet layout.
  factory AppBottomSheet.basic({
    Key? key,
    required Widget child,
    String? title,
    TextStyle? titleStyle,
    Widget? header,
    List<Widget>? actions,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double borderRadius = 16,
    bool showDragHandle = true,
    bool unfocusOnTapOutside = true,
    bool scrollable = true,
  }) {
    return AppBottomSheet._(
      key: key,
      title: title,
      titleStyle: titleStyle,
      header: header,
      actions: actions,
      padding: padding,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      showDragHandle: showDragHandle,
      unfocusOnTapOutside: unfocusOnTapOutside,
      scrollable: scrollable,
      child: child,
    );
  }

  /// Shows a modal bottom sheet using a consistent chrome.
  ///
  /// [useRootNavigator] pushes the sheet above nested navigators (e.g.
  /// go_router ShellRoute / nested Navigator) so it behaves consistently.
  static Future<T?> show<T>(
    BuildContext context, {
    required AppBottomSheet sheet,
    bool useRootNavigator = true,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool isDismissible = true,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      barrierColor: barrierColor,
      backgroundColor: Colors.transparent,
      builder: (context) => sheet,
    );
  }

  final Widget child;
  final String? title;
  final TextStyle? titleStyle;
  final Widget? header;
  final List<Widget>? actions;

  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;

  final bool showDragHandle;
  final bool unfocusOnTapOutside;
  final bool scrollable;

  Widget _dragHandle(BuildContext context) {
    final handleColor = context.onSurface.withValues(alpha: 0.14);

    return Container(
      width: 120.w,
      height: 4.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: handleColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(borderRadius.r),
      topRight: Radius.circular(borderRadius.r),
    );

    final body = Material(
      color: backgroundColor ?? context.colorScheme.surface,
      borderRadius: radius,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Padding(
          padding: padding ?? AppSpacing.standardPadding,
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showDragHandle) _dragHandle(context),
                if (header != null) ...[AppSpacing.md.verticalSpace, header!],
                if (title?.trim().isNotEmpty == true) ...[
                  AppSpacing.md.verticalSpace,
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style:
                        titleStyle ??
                        AppTextStyles.s16w400.copyWith(
                          color: context.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
                if (title?.trim().isNotEmpty == true || header != null)
                  AppSpacing.lg.verticalSpace,

                // `scrollable` allows large content (forms) without overflow.
                if (scrollable)
                  Flexible(child: SingleChildScrollView(child: child))
                else
                  child,

                if (actions != null && actions!.isNotEmpty) ...[
                  AppSpacing.lg.verticalSpace,
                  ...actions!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Tap outside content to dismiss keyboard (common in forms).
    final maybeUnfocus = unfocusOnTapOutside
        ? GestureDetector(onTap: context.unfocus, child: body)
        : body;

    return SafeArea(child: maybeUnfocus);
  }
}
