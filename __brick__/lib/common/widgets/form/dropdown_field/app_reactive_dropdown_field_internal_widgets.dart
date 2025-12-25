part of 'app_reactive_dropdown_field.dart';

/// Internal title widget used by [AppReactiveDropdownField].
///
/// Kept private to keep the public API small and consistent with other form
/// widgets.
class _FieldTitle extends StatelessWidget {
  const _FieldTitle({
    required this.title,
    required this.isRequired,
    required this.style,
  });

  final String title;
  final bool isRequired;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            title,
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Required indicator is shown next to the title.
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text('*', style: style.copyWith(color: AppColors.error)),
        ],
      ],
    );
  }
}

/// A small hit-target wrapper used for the dropdown tap areas.
///
/// This mimics the pattern used by other form widgets in the project.
class _TapArea extends StatelessWidget {
  const _TapArea({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Using GestureDetector with opaque behavior makes the whole area tappable
    // (including empty padding).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

/// The clear icon shown when there is a selected value and allowClear is true.
class _ClearIcon extends StatelessWidget {
  const _ClearIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.close, size: 20.sp, color: context.grey);
  }
}

/// The default arrow icon shown when there is no selected value.
class _ArrowIcon extends StatelessWidget {
  const _ArrowIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.keyboard_arrow_down, size: 24.sp, color: context.grey);
  }
}

/// Displays either the selected value text or the hint text.
class _DropdownValueText extends StatelessWidget {
  const _DropdownValueText({
    required this.text,
    required this.hintText,
    required this.textStyle,
    required this.hintStyle,
  });

  final String text;
  final String? hintText;
  final TextStyle textStyle;
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) {
    // Treat whitespace as empty.
    final hasText = text.trim().isNotEmpty;
    return Text(
      hasText ? text : (hintText ?? ''),
      style: hasText ? textStyle : (hintStyle ?? textStyle),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
