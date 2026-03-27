import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../utils/extensions/theme_extensions.dart';
import '../../../utils/constants/design_constants.dart';

abstract class AppFormFieldDefaults {
  static const double borderWidth = 1;

  static double borderRadiusValue() {
    return AppRadii.sm;
  }

  static EdgeInsetsGeometry contentPadding() {
    return REdgeInsets.symmetric(horizontal: 12, vertical: 12);
  }

  static TextStyle titleTextStyle(BuildContext context) {
    return AppTextStyles.s14w600.copyWith(
      color: context.onSurface.withValues(alpha: 0.85),
    );
  }

  static TextStyle errorTextStyle(BuildContext context) {
    return AppTextStyles.s12w500.copyWith(color: AppColors.error);
  }

  static Color iconColor(BuildContext context) {
    return context.onSurface.withValues(alpha: 0.45);
  }

  static Color fillColor(BuildContext context) {
    return context.primary.withValues(alpha: 0.05);
  }

  static List<BoxShadow> shadows(BuildContext context) {
    return context.shadows.grey;
  }

  static Color borderColorEnabled(BuildContext context) {
    return context.grey;
  }

  static Color borderColorFocused(BuildContext context) {
    return context.primary;
  }

  static Color borderColorDisabled(BuildContext context) {
    return context.grey.withValues(alpha: 0.6);
  }

  static Color borderColorError(BuildContext context) {
    return AppColors.error;
  }
}
