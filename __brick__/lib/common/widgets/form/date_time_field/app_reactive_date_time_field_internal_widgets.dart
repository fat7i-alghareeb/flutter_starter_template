part of 'app_reactive_date_time_field.dart';

/// Internal, small UI widgets used by [AppReactiveDateTimeField].
///
/// Kept as private widgets to:
/// - avoid expanding your public API surface
/// - keep rebuilds small and predictable
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
        if (isRequired) ...[
          AppSpacing.xs.horizontalSpace,
          Text('*', style: style.copyWith(color: AppColors.error)),
        ],
      ],
    );
  }
}

class _DateTimeFieldValueText extends StatelessWidget {
  const _DateTimeFieldValueText({
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
    final isEmpty = text.trim().isEmpty;

    // If the value is empty, we render the hint so the field remains readable
    // while still behaving like a read-only picker.
    return Text(
      isEmpty ? (hintText ?? '') : text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: isEmpty ? (hintStyle ?? textStyle) : textStyle,
    );
  }
}

class _ClearIcon extends StatelessWidget {
  const _ClearIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.clear, size: 20.sp, color: context.grey);
  }
}

class _TapArea extends StatelessWidget {
  const _TapArea({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;

    // Use a GestureDetector with opaque hit-testing to make taps easier and
    // to avoid needing an InkWell (which depends on Material ancestors).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}
