import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../utils/constants/design_constants.dart';
import '../../../utils/extensions/context_extensions.dart';
import '../../../utils/extensions/string_extensions.dart';
import '../../../utils/extensions/theme_extensions.dart';
import '../../../utils/helpers/input_formatters.dart';
import '../../../utils/helpers/app_strings.dart';
import '../../../utils/helpers/colored_print.dart';
import '../app_icon_source.dart';
import 'app_reactive_validation_messages.dart';

part 'app_reactive_text_field_types.dart';
part 'app_reactive_text_field_mixins.dart';
part 'app_reactive_text_field_state.dart';
part 'app_reactive_text_field_phone.dart';
part 'app_reactive_text_field_internal_widgets.dart';

/// A reusable reactive text field with a consistent app-specific UI.
///
/// This widget provides:
/// - A title above the field (optional)
/// - A decorated container (border/shadow/fill)
/// - Prefix/suffix widgets or icons
/// - Built-in variants: text/email/password/phone/decimal/integer/stringOnly
/// - Localized validation messages with override support
/// - Debounced `onChanged` callback
///
/// ## Usage
/// The field can be used in either of these modes:
///
/// ### 1) Inside a parent [ReactiveForm]
/// ```dart
/// final form = FormGroup({
///   'email': FormControl<String>(validators: [Validators.required, Validators.email]),
/// });
///
/// ReactiveForm(
///   formGroup: form,
///   child: AppReactiveTextField.email(
///     formControlName: 'email',
///     title: 'Email',
///   ),
/// );
/// ```
///
/// ### 2) Standalone (wraps itself with [ReactiveForm])
/// ```dart
/// AppReactiveTextField.email(
///   formGroup: form,
///   formControlName: 'email',
/// );
/// ```
///
/// ## Phone behavior
/// When using [AppReactiveTextField.phone], the widget uses
/// `intl_phone_number_input`.
///
/// - The bound control must be `FormControl<String>`.
/// - The value stored in the control is expected to be E.164.
/// - When the package reports an invalid phone, the widget sets a custom
///   reactive_forms error key: `invalidPhone`.
class AppReactiveTextField extends StatefulWidget {
  const AppReactiveTextField._({
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
    this.affixes = const AppTextFieldAffixes(),
    this.textDirectionMode = AppFieldTextDirectionMode.locale,
    this.maxLines,
    this.minLines,
    this.textInputAction,
    this.onChanged,
    this.onChangedDebounced,
    this.onChangedDebounceDuration = const Duration(milliseconds: 400),
    this.onSubmitted,
    this.allowNegative = false,
    this.removeTrailingDotZero = false,
    this.passwordObscureText = true,
    this.passwordEnableToggle = true,
    this.passwordObscuredWidget,
    this.passwordRevealedWidget,
    this.phoneCountries,
    this.phoneUseEmojiFlags = true,
    this.phoneDefaultIsoCode,
    required _AppReactiveTextFieldType type,
  }) : _type = type;

  factory AppReactiveTextField.text({
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
    AppTextFieldAffixes affixes = const AppTextFieldAffixes(),
    AppFieldTextDirectionMode textDirectionMode =
        AppFieldTextDirectionMode.locale,
    int? maxLines,
    int? minLines,
    TextInputAction? textInputAction,
    AppReactiveTextFieldValueCallback? onChanged,
    AppReactiveTextFieldValueCallback? onChangedDebounced,
    Duration onChangedDebounceDuration = const Duration(milliseconds: 400),
    AppReactiveTextFieldValueCallback? onSubmitted,
  }) {
    return AppReactiveTextField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      textDirectionMode: textDirectionMode,
      maxLines: maxLines,
      minLines: minLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onChangedDebounced: onChangedDebounced,
      onChangedDebounceDuration: onChangedDebounceDuration,
      onSubmitted: onSubmitted,
      type: _AppReactiveTextFieldType.text,
    );
  }

  factory AppReactiveTextField.email({
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
    AppTextFieldAffixes affixes = const AppTextFieldAffixes(),
    AppFieldTextDirectionMode textDirectionMode =
        AppFieldTextDirectionMode.locale,
    int? maxLines,
    int? minLines,
    TextInputAction? textInputAction,
    AppReactiveTextFieldValueCallback? onChanged,
    AppReactiveTextFieldValueCallback? onChangedDebounced,
    Duration onChangedDebounceDuration = const Duration(milliseconds: 400),
    AppReactiveTextFieldValueCallback? onSubmitted,
  }) {
    return AppReactiveTextField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      textDirectionMode: textDirectionMode,
      maxLines: maxLines,
      minLines: minLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onChangedDebounced: onChangedDebounced,
      onChangedDebounceDuration: onChangedDebounceDuration,
      onSubmitted: onSubmitted,
      type: _AppReactiveTextFieldType.email,
    );
  }

  factory AppReactiveTextField.password({
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
    AppTextFieldAffixes affixes = const AppTextFieldAffixes(),
    AppFieldTextDirectionMode textDirectionMode =
        AppFieldTextDirectionMode.locale,
    AppReactiveTextFieldValueCallback? onChanged,
    AppReactiveTextFieldValueCallback? onChangedDebounced,
    Duration onChangedDebounceDuration = const Duration(milliseconds: 400),
    AppReactiveTextFieldValueCallback? onSubmitted,
    bool passwordObscureText = true,
    bool passwordEnableToggle = true,
    Widget? passwordObscuredWidget,
    Widget? passwordRevealedWidget,
  }) {
    return AppReactiveTextField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      textDirectionMode: textDirectionMode,
      onChanged: onChanged,
      onChangedDebounced: onChangedDebounced,
      onChangedDebounceDuration: onChangedDebounceDuration,
      onSubmitted: onSubmitted,
      passwordObscureText: passwordObscureText,
      passwordEnableToggle: passwordEnableToggle,
      passwordObscuredWidget: passwordObscuredWidget,
      passwordRevealedWidget: passwordRevealedWidget,
      maxLines: 1,
      minLines: 1,
      type: _AppReactiveTextFieldType.password,
    );
  }

  factory AppReactiveTextField.phone({
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
    AppTextFieldAffixes affixes = const AppTextFieldAffixes(),
    AppFieldTextDirectionMode textDirectionMode = AppFieldTextDirectionMode.ltr,
    AppReactiveTextFieldValueCallback? onChanged,
    AppReactiveTextFieldValueCallback? onChangedDebounced,
    Duration onChangedDebounceDuration = const Duration(milliseconds: 400),
    AppReactiveTextFieldValueCallback? onSubmitted,
    List<String>? phoneCountries,
    bool phoneUseEmojiFlags = false,
    String? phoneDefaultIsoCode,
  }) {
    return AppReactiveTextField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      textDirectionMode: textDirectionMode,
      onChanged: onChanged,
      onChangedDebounced: onChangedDebounced,
      onChangedDebounceDuration: onChangedDebounceDuration,
      onSubmitted: onSubmitted,
      phoneCountries: phoneCountries,
      phoneUseEmojiFlags: phoneUseEmojiFlags,
      phoneDefaultIsoCode: phoneDefaultIsoCode,
      type: _AppReactiveTextFieldType.phone,
    );
  }

  factory AppReactiveTextField.decimal({
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
    AppTextFieldAffixes affixes = const AppTextFieldAffixes(),
    AppFieldTextDirectionMode textDirectionMode =
        AppFieldTextDirectionMode.locale,
    AppReactiveTextFieldValueCallback? onChanged,
    AppReactiveTextFieldValueCallback? onChangedDebounced,
    Duration onChangedDebounceDuration = const Duration(milliseconds: 400),
    AppReactiveTextFieldValueCallback? onSubmitted,
    bool allowNegative = false,
    bool removeTrailingDotZero = false,
  }) {
    return AppReactiveTextField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      textDirectionMode: textDirectionMode,
      onChanged: onChanged,
      onChangedDebounced: onChangedDebounced,
      onChangedDebounceDuration: onChangedDebounceDuration,
      onSubmitted: onSubmitted,
      allowNegative: allowNegative,
      removeTrailingDotZero: removeTrailingDotZero,
      type: _AppReactiveTextFieldType.decimal,
    );
  }

  factory AppReactiveTextField.integer({
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
    AppTextFieldAffixes affixes = const AppTextFieldAffixes(),
    AppFieldTextDirectionMode textDirectionMode =
        AppFieldTextDirectionMode.locale,
    AppReactiveTextFieldValueCallback? onChanged,
    AppReactiveTextFieldValueCallback? onChangedDebounced,
    Duration onChangedDebounceDuration = const Duration(milliseconds: 400),
    AppReactiveTextFieldValueCallback? onSubmitted,
    bool allowNegative = false,
  }) {
    return AppReactiveTextField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      textDirectionMode: textDirectionMode,
      onChanged: onChanged,
      onChangedDebounced: onChangedDebounced,
      onChangedDebounceDuration: onChangedDebounceDuration,
      onSubmitted: onSubmitted,
      allowNegative: allowNegative,
      type: _AppReactiveTextFieldType.integer,
    );
  }

  factory AppReactiveTextField.stringOnly({
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
    AppTextFieldAffixes affixes = const AppTextFieldAffixes(),
    AppFieldTextDirectionMode textDirectionMode =
        AppFieldTextDirectionMode.locale,
    AppReactiveTextFieldValueCallback? onChanged,
    AppReactiveTextFieldValueCallback? onChangedDebounced,
    Duration onChangedDebounceDuration = const Duration(milliseconds: 400),
    AppReactiveTextFieldValueCallback? onSubmitted,
  }) {
    return AppReactiveTextField._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      textDirectionMode: textDirectionMode,
      onChanged: onChanged,
      onChangedDebounced: onChangedDebounced,
      onChangedDebounceDuration: onChangedDebounceDuration,
      onSubmitted: onSubmitted,
      type: _AppReactiveTextFieldType.stringOnly,
    );
  }

  /// The name of the control in the parent [FormGroup].
  ///
  /// This is required in all cases.
  final String formControlName;

  /// Optional form group.
  ///
  /// - If provided, this widget wraps itself with a [ReactiveForm].
  /// - If `null`, you must place the widget under an ancestor [ReactiveForm]
  ///   (recommended for most apps).
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
  final AppTextFieldAffixes affixes;

  final AppFieldTextDirectionMode textDirectionMode;

  final int? maxLines;
  final int? minLines;

  final TextInputAction? textInputAction;

  final AppReactiveTextFieldValueCallback? onChanged;

  /// Debounced value change callback.
  ///
  /// Useful for “search as you type” without doing work on every keystroke.
  final AppReactiveTextFieldValueCallback? onChangedDebounced;
  final Duration onChangedDebounceDuration;
  final AppReactiveTextFieldValueCallback? onSubmitted;

  final bool allowNegative;
  final bool removeTrailingDotZero;

  final bool passwordObscureText;
  final bool passwordEnableToggle;

  final Widget? passwordObscuredWidget;
  final Widget? passwordRevealedWidget;

  final List<String>? phoneCountries;
  final bool phoneUseEmojiFlags;

  /// Optional default ISO code for the phone selector.
  ///
  /// If not provided, the widget tries to use `Localizations.localeOf(context)`
  /// country code, and falls back to `US`.
  final String? phoneDefaultIsoCode;

  final _AppReactiveTextFieldType _type;

  @override
  State<AppReactiveTextField> createState() => _AppReactiveTextFieldState();
}
