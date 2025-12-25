import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'
    show REdgeInsets, SizeExtension;
import '../../utils/constants/design_constants.dart';

/// Layout helpers for widgets referenced by a [GlobalKey].
///
/// Example:
/// ```dart
/// final key = GlobalKey();
/// // inside build:
/// Size? size = key.size;
/// Offset? pos = key.globalPosition;
/// ```
extension GlobalKeyLayoutExtensions on GlobalKey {
  RenderBox? get renderBox {
    final context = currentContext;
    if (context == null) return null;
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      return renderObject;
    }
    return null;
  }

  Size? get size => renderBox?.size;

  double? get width => size?.width;

  double? get height => size?.height;

  Offset? get globalPosition => renderBox?.localToGlobal(Offset.zero);
}

extension WidgetX on Widget {
  Widget get standardHorizontalPadding =>
      Padding(padding: AppSpacing.horizontal, child: this);
  Widget get standardVerticalPadding =>
      Padding(padding: AppSpacing.vertical, child: this);
  Widget get standardPadding =>
      Padding(padding: AppSpacing.standardPadding, child: this);
  Widget paddingAll(double v) =>
      Padding(padding: REdgeInsets.all(v), child: this);
  Widget symmetricPadding({double? v, double? h}) => Padding(
    padding: REdgeInsets.symmetric(horizontal: h ?? 0, vertical: v ?? 0),
    child: this,
  );
  Widget center() => Center(child: this);
}

extension WidgetGestureX on Widget {
  Widget onTap(VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: this);
}

extension WidgetBoxX on Widget {
  Widget sized({double? w, double? h}) =>
      SizedBox(width: w?.w, height: h?.h, child: this);
}

extension NumSpacingX on num {
  Widget get verticalSpacing => SizedBox(height: h);
  Widget get horizontalSpacing => SizedBox(width: w);

  // Backward-compatible alias for the common misspelling.
  Widget get horizantleSpasing => horizontalSpacing;
}
