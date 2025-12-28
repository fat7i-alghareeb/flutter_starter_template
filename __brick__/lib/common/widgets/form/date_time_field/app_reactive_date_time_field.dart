import 'dart:ui' as ui;
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../common/widgets/app_affixes.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../utils/constants/design_constants.dart';
import '../../../../utils/extensions/context_extensions.dart';
import '../../../../utils/extensions/date_time_extensions.dart';
import '../../../../utils/extensions/string_extensions.dart';
import '../../../../utils/extensions/theme_extensions.dart';
import '../../../../utils/helpers/app_strings.dart';
import '../app_reactive_text_field.dart';
import '../app_reactive_validation_messages.dart';

part 'app_reactive_date_time_field_variants.dart';
part 'app_reactive_date_time_field_internal_widgets.dart';
part 'app_reactive_date_time_field_pickers_mixin.dart';
part 'app_reactive_date_time_field_value_mixin.dart';
part 'app_reactive_date_time_field_state.dart';

/// A high-performance, reactive date/time picker field built on top of
/// `reactive_forms`.
///
/// This widget is designed to match the architecture and UI approach of
/// [AppReactiveTextField] while keeping the input logic abstract and the UI
/// highly customizable.
///
/// ## Storage type (important)
/// This field detects the target control type at runtime and supports only:
/// - `FormControl<DateTime>`: the selected [DateTime] is stored as-is.
/// - `FormControl<String>`: the selected value is stored as an ISO-8601 string
///   via `DateTime.toIso8601String()`.
///
/// ### Example: store as DateTime
/// ```dart
/// final form = FormGroup({
///   'startAt': FormControl<DateTime>(),
/// });
///
/// AppReactiveDateTimeField.dateTime(
///   formControlName: 'startAt',
///   title: AppStrings.selectDateTime,
/// );
/// ```
///
/// ### Example: store as ISO string
/// ```dart
/// final form = FormGroup({
///   'startAtIso': FormControl<String>(),
/// });
///
/// AppReactiveDateTimeField.dateTime(
///   formControlName: 'startAtIso',
///   title: AppStrings.selectDateTime,
/// );
/// ```
///
/// ## Formatting
/// - The display text is generated using a shared [AppDateTimeFormatter]
///   signature (same used by `DateTime` / ISO-string extensions).
/// - Each factory constructor provides a sensible default formatter.
/// - You can override formatting by passing a custom [formatter] with the same
///   signature.
///
/// Example override:
/// ```dart
/// AppReactiveDateTimeField.date(
///   formControlName: 'birthDate',
///   formatter: (dt, {locale = 'en_US'}) => dt.formatDateTime('dd/MM/yyyy', locale: locale),
/// );
/// ```
class AppReactiveDateTimeField extends StatefulWidget {
  const AppReactiveDateTimeField._({
    super.key,
    required this.formControlName,
    this.formGroup,
    this.title,
    this.isRequired = false,
    this.titleSpacing = AppSpacing.sm,
    this.layout = const AppFieldLayout(),
    this.enabled = true,
    this.hintText,
    this.decoration = const AppTextFieldDecoration(),
    this.style = const AppTextFieldStyle(),
    this.validation = const AppTextFieldValidation(),
    this.affixes = const AppAffixes(),
    this.allowClear = true,
    this.formatter,
    this.rangeTextBuilder,
    this.onSelected,
    this.pickerOverride,
    this.acceptSameDay = true,
    required AppReactiveDateTimeFieldType type,
  }) : _type = type;

  factory AppReactiveDateTimeField.dateTime({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    AppDateTimeFormatter? formatter,
    AppReactiveDateTimeFieldSelectedCallback? onSelected,
    AppReactiveDateTimeFieldPicker? pickerOverride,
  }) {
    return AppReactiveDateTimeField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText ?? AppStrings.selectDateTime,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      formatter:
          formatter ??
          (dt, {locale = 'en_US'}) => dt.toFullDateTime(locale: locale),
      onSelected: onSelected,
      pickerOverride: pickerOverride,
      type: AppReactiveDateTimeFieldType.dateTime,
    );
  }

  factory AppReactiveDateTimeField.date({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    AppDateTimeFormatter? formatter,
    AppReactiveDateTimeFieldSelectedCallback? onSelected,
    AppReactiveDateTimeFieldPicker? pickerOverride,
  }) {
    return AppReactiveDateTimeField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText ?? AppStrings.selectDate,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      formatter:
          formatter ?? (dt, {locale = 'en_US'}) => dt.toYmd(locale: locale),
      onSelected: onSelected,
      pickerOverride: pickerOverride,
      type: AppReactiveDateTimeFieldType.date,
    );
  }

  factory AppReactiveDateTimeField.yearMonth({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    AppDateTimeFormatter? formatter,
    AppReactiveDateTimeFieldSelectedCallback? onSelected,
    AppReactiveDateTimeFieldPicker? pickerOverride,
  }) {
    return AppReactiveDateTimeField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText ?? AppStrings.selectMonth,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      formatter:
          formatter ??
          (dt, {locale = 'en_US'}) => dt.toMonthYearShort(locale: locale),
      onSelected: onSelected,
      pickerOverride: pickerOverride,
      type: AppReactiveDateTimeFieldType.yearMonth,
    );
  }

  factory AppReactiveDateTimeField.year({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    AppDateTimeFormatter? formatter,
    AppReactiveDateTimeFieldSelectedCallback? onSelected,
    AppReactiveDateTimeFieldPicker? pickerOverride,
  }) {
    return AppReactiveDateTimeField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText ?? AppStrings.selectYear,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      formatter:
          formatter ??
          (dt, {locale = 'en_US'}) => dt.toYearOnly(locale: locale),
      onSelected: onSelected,
      pickerOverride: pickerOverride,
      type: AppReactiveDateTimeFieldType.year,
    );
  }

  factory AppReactiveDateTimeField.monthDay({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    AppDateTimeFormatter? formatter,
    AppReactiveDateTimeFieldSelectedCallback? onSelected,
    AppReactiveDateTimeFieldPicker? pickerOverride,
  }) {
    return AppReactiveDateTimeField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText ?? AppStrings.selectDay,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      formatter:
          formatter ??
          (dt, {locale = 'en_US'}) => dt.toMonthDayFull(locale: locale),
      onSelected: onSelected,
      pickerOverride: pickerOverride,
      type: AppReactiveDateTimeFieldType.monthDay,
    );
  }

  factory AppReactiveDateTimeField.month({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    AppDateTimeFormatter? formatter,
    AppReactiveDateTimeFieldSelectedCallback? onSelected,
    AppReactiveDateTimeFieldPicker? pickerOverride,
  }) {
    return AppReactiveDateTimeField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText ?? AppStrings.selectMonth,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      formatter:
          formatter ??
          (dt, {locale = 'en_US'}) => dt.toMonthFull(locale: locale),
      onSelected: onSelected,
      pickerOverride: pickerOverride,
      type: AppReactiveDateTimeFieldType.month,
    );
  }

  factory AppReactiveDateTimeField.day({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    AppDateTimeFormatter? formatter,
    AppReactiveDateTimeFieldSelectedCallback? onSelected,
    AppReactiveDateTimeFieldPicker? pickerOverride,
  }) {
    return AppReactiveDateTimeField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText ?? AppStrings.selectDay,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      formatter:
          formatter ??
          (dt, {locale = 'en_US'}) => dt.toWeekdayDayShort(locale: locale),
      onSelected: onSelected,
      pickerOverride: pickerOverride,
      type: AppReactiveDateTimeFieldType.day,
    );
  }

  factory AppReactiveDateTimeField.time({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    AppDateTimeFormatter? formatter,
    AppReactiveDateTimeFieldSelectedCallback? onSelected,
    AppReactiveDateTimeFieldPicker? pickerOverride,
  }) {
    return AppReactiveDateTimeField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText ?? AppStrings.selectTime,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      formatter:
          formatter ??
          (dt, {locale = 'en_US'}) => dt.toTime12Compact(locale: locale),
      onSelected: onSelected,
      pickerOverride: pickerOverride,
      type: AppReactiveDateTimeFieldType.time,
    );
  }

  factory AppReactiveDateTimeField.dateRange({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    bool acceptSameDay = true,
    AppReactiveDateTimeFieldRangeTextBuilder? rangeTextBuilder,
    AppReactiveDateTimeFieldSelectedCallback? onSelected,
  }) {
    return AppReactiveDateTimeField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText ?? AppStrings.selectDate,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      acceptSameDay: acceptSameDay,
      rangeTextBuilder: rangeTextBuilder,
      onSelected: onSelected,
      type: AppReactiveDateTimeFieldType.dateRange,
    );
  }

  /// The name of the control in the parent [FormGroup].
  ///
  /// This is required in all cases.
  final String formControlName;

  /// Optional form group.
  ///
  /// - If provided, this widget wraps itself with a [ReactiveForm].
  /// - If `null`, you must place the widget under an ancestor [ReactiveForm].
  final FormGroup? formGroup;

  final String? title;
  final bool isRequired;
  final double titleSpacing;

  final AppFieldLayout layout;

  final bool enabled;

  final String? hintText;
  final AppTextFieldDecoration decoration;
  final AppTextFieldStyle style;
  final AppTextFieldValidation validation;
  final AppAffixes affixes;

  /// Whether to show a clear button when the field has a value.
  ///
  /// When pressed, the control is set to `null`.
  final bool allowClear;

  /// Display formatter for the selected [DateTime].
  ///
  /// If `null`, a default formatter is selected based on the factory used.
  final AppDateTimeFormatter? formatter;

  /// Display builder used for the date-range mode.
  ///
  /// If `null`, a default builder is used:
  /// `from <yyyy-MM-dd> to <yyyy-MM-dd>`.
  final AppReactiveDateTimeFieldRangeTextBuilder? rangeTextBuilder;

  /// Whether date-range mode should allow selecting a range where start and end
  /// fall on the same calendar day.
  ///
  /// Only applies when [_type] is [AppReactiveDateTimeFieldType.dateRange].
  final bool acceptSameDay;

  /// Called after a successful selection.
  ///
  /// The callback provides:
  /// - The selected [DateTime]
  /// - The ISO string (`dateTime.toIso8601String()`)
  /// - The formatted display text (based on [formatter])
  final AppReactiveDateTimeFieldSelectedCallback? onSelected;

  /// Optional picker override to fully customize the selection UI.
  ///
  /// If provided, the field will call this picker instead of the built-in one.
  final AppReactiveDateTimeFieldPicker? pickerOverride;

  final AppReactiveDateTimeFieldType _type;

  @override
  State<AppReactiveDateTimeField> createState() =>
      _AppReactiveDateTimeFieldState();
}
