import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../utils/constants/design_constants.dart';

import 'app_button_icon_source.dart';

abstract class AppButtonChild {
  const AppButtonChild();

  Widget build(BuildContext context, {required Color foreground});

  EdgeInsetsGeometry defaultPadding(BuildContext context);

  factory AppButtonChild.label(
    String label, {
    TextAlign textAlign = TextAlign.center,
    int? maxLines,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return _LabelButtonChild(
      label,
      textAlign: textAlign,
      maxLines: maxLines,
      textStyle: textStyle,
      padding: padding,
    );
  }

  factory AppButtonChild.icon(
    AppButtonIconSource icon, {
    double size = 20,
    EdgeInsetsGeometry? padding,
  }) {
    return _IconOnlyButtonChild(icon, size: size, padding: padding);
  }

  factory AppButtonChild.labelIcon({
    required String label,
    required AppButtonIconSource icon,
    AppButtonIconPosition position = AppButtonIconPosition.leading,
    double iconSize = 18,
    double spacing = AppSpacing.sm,
    TextAlign textAlign = TextAlign.center,
    int? maxLines,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return _LabelIconButtonChild(
      label: label,
      icon: icon,
      position: position,
      iconSize: iconSize,
      spacing: spacing,
      textAlign: textAlign,
      maxLines: maxLines,
      textStyle: textStyle,
      padding: padding,
    );
  }
}

enum AppButtonIconPosition { leading, trailing }

class _LabelButtonChild extends AppButtonChild {
  const _LabelButtonChild(
    this.label, {
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.textStyle,
    this.padding,
  });

  final String label;
  final TextAlign textAlign;
  final int? maxLines;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, {required Color foreground}) {
    final base = textStyle ?? AppTextStyles.s12w400;

    return Text(
      label,
      maxLines: maxLines ?? 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: base.copyWith(color: foreground),
    );
  }

  @override
  EdgeInsetsGeometry defaultPadding(BuildContext context) {
    return padding ??
        REdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 12);
  }
}

class _IconOnlyButtonChild extends AppButtonChild {
  const _IconOnlyButtonChild(this.icon, {this.size = 20, this.padding});

  final AppButtonIconSource icon;
  final double size;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, {required Color foreground}) {
    return icon.build(context, color: foreground, size: size);
  }

  @override
  EdgeInsetsGeometry defaultPadding(BuildContext context) {
    return padding ?? REdgeInsets.all(12);
  }
}

class _LabelIconButtonChild extends AppButtonChild {
  const _LabelIconButtonChild({
    required this.label,
    required this.icon,
    this.position = AppButtonIconPosition.leading,
    this.iconSize = 18,
    this.spacing = AppSpacing.sm,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.textStyle,
    this.padding,
  });

  final String label;
  final AppButtonIconSource icon;
  final AppButtonIconPosition position;
  final double iconSize;
  final double spacing;
  final TextAlign textAlign;
  final int? maxLines;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, {required Color foreground}) {
    final iconWidget = icon.build(context, color: foreground, size: iconSize);
    final base = (textStyle ?? AppTextStyles.s12w400).copyWith(
      color: foreground,
    );

    final textWidget = Text(
      label,
      maxLines: maxLines ?? 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: base,
    );

    final children = <Widget>[
      if (position == AppButtonIconPosition.leading) ...[
        iconWidget,
        SizedBox(width: spacing.w),
        Flexible(child: textWidget),
      ] else ...[
        Flexible(child: textWidget),
        SizedBox(width: spacing.w),
        iconWidget,
      ],
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  @override
  EdgeInsetsGeometry defaultPadding(BuildContext context) {
    return padding ??
        REdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12);
  }
}
