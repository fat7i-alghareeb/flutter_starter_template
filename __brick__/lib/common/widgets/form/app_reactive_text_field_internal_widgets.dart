part of 'app_reactive_text_field.dart';

/// Internal, small UI widgets used by [AppReactiveTextField].
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

/// Clickable wrapper for prefix/suffix widgets.
///
/// Uses a `GestureDetector` with opaque hit testing to make taps easy.
class _PrefixSuffixSlot extends StatelessWidget {
  const _PrefixSuffixSlot({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

/// Default suffix icon for obscured password state.
class _DefaultPasswordHidden extends StatelessWidget {
  const _DefaultPasswordHidden();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.visibility_off, size: 20.sp, color: context.grey);
  }
}

/// Default suffix icon for revealed password state.
class _DefaultPasswordShown extends StatelessWidget {
  const _DefaultPasswordShown();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.visibility, size: 20.sp, color: context.grey);
  }
}
