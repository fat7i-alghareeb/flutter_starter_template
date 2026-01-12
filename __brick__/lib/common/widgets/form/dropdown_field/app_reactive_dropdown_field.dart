import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../common/widgets/app_affixes.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../utils/constants/design_constants.dart';
import '../../../../utils/extensions/context_extensions.dart';
import '../../../../utils/extensions/string_extensions.dart';
import '../../../../utils/extensions/theme_extensions.dart';
import '../../../../utils/helpers/app_strings.dart';
import '../../app_bottom_sheet.dart';
import '../../app_dialog.dart';
import '../app_reactive_text_field.dart';
import '../app_reactive_validation_messages.dart';

part 'app_reactive_dropdown_field_types.dart';
part 'app_reactive_dropdown_field_internal_widgets.dart';
part 'app_reactive_dropdown_field_state.dart';

/// A reusable, generic reactive dropdown field built on top of `reactive_forms`.
///
/// This widget follows the same architecture/UI conventions used by
/// [AppReactiveTextField] and [AppReactiveDateTimeField]:
/// - Optional title above the field
/// - Decorated container (border/shadow/fill)
/// - Validation text using [AppReactiveValidationMessages]
/// - Works inside an existing [ReactiveForm] or can wrap itself when
///   [formGroup] is provided.
///
/// ## Storage type (important)
/// The bound form control value **must** match `T`.
/// - If `T` is `int`, the control should be `FormControl<int>`.
/// - If `T` is `String`, the control should be `FormControl<String>`.
///
/// ## Options model
/// The dropdown options are a list of [AppDropdownOption].
///
/// - [AppDropdownOption.id] is the value written to the control.
/// - [AppDropdownOption.name] is the displayed text.
/// - [AppDropdownOption.enable] disables an item when `false`.
///
/// ### Example
/// ```dart
/// final form = FormGroup({
///   'countryId': FormControl<int>(validators: [Validators.required]),
/// });
///
/// final options = <AppDropdownOption<int>>[
///   AppDropdownOption(id: 1, name: 'Egypt'),
///   AppDropdownOption(id: 2, name: 'Saudi Arabia'),
/// ];
///
/// ReactiveForm(
///   formGroup: form,
///   child: AppReactiveDropdownField<int>.menu(
///     formControlName: 'countryId',
///     title: 'Country',
///     options: options,
///   ),
/// );
/// ```
///
/// ## Presentation
/// Use one of the factory constructors:
/// - [AppReactiveDropdownField.menu] (overlay anchored to the field)
/// - [AppReactiveDropdownField.dialog]
/// - [AppReactiveDropdownField.bottomSheet]
///
/// You can enable search in any presentation by passing `enableSearch: true`.
///
/// ## Conditional selection (advanced)
/// Use [onSelectReturn] to validate the chosen option *at selection time*.
///
/// - Return `null` to accept.
/// - Return a non-null string to reject the selection.
///
/// When rejected:
/// - the selected option stays displayed,
/// - the control value is set to `null`,
/// - and a validation error message is shown.
///
/// ```dart
/// AppReactiveDropdownField<int>.menu(
///   formControlName: 'countryId',
///   options: options,
///   onSelectReturn: (selected) {
///     if (selected.id == 2) return 'This country is not allowed';
///     return null;
///   },
/// );
/// ```
class AppReactiveDropdownField<T> extends StatefulWidget {
  /// A fully-configurable dropdown field.
  ///
  /// Prefer using one of the factory constructors (e.g. [menu], [dialog],
  /// [bottomSheet]) for consistent presets.
  const AppReactiveDropdownField._({
    super.key,
    required this.formControlName,
    this.formGroup,
    required this.options,
    this.title,
    this.isRequired = false,
    this.titleSpacing = AppSpacing.sm,
    this.layout = const AppFieldLayout(),
    this.enabled = true,
    this.isLoading = false,
    this.hintText,
    this.decoration = const AppTextFieldDecoration(),
    this.style = const AppTextFieldStyle(),
    this.validation = const AppTextFieldValidation(),
    this.affixes = const AppAffixes(),
    this.allowClear = true,
    this.enableSearch = false,
    this.dialogBarrierDismissible = true,
    this.presentation = AppReactiveDropdownPresentation.menu,
    this.optionsTextStyle,
    this.missingOptionNameBuilder,
    this.onSelected,
    this.onSelectUnEnabledItem,
    this.onSelectReturn,
  });

  /// A fully-configurable dropdown field.
  ///
  /// This is provided as a convenience factory to keep the API consistent with
  /// other form widgets (e.g. [AppReactiveTextField]) that expose multiple
  /// presets.
  ///
  /// Prefer using the preset factories like [menu], [dialog], or [bottomSheet]
  /// unless you need full control.
  factory AppReactiveDropdownField({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    required List<AppDropdownOption<T>> options,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    bool isLoading = false,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    bool enableSearch = false,
    bool dialogBarrierDismissible = true,
    AppReactiveDropdownPresentation presentation =
        AppReactiveDropdownPresentation.menu,
    TextStyle? optionsTextStyle,
    String Function(T id)? missingOptionNameBuilder,
    AppReactiveDropdownSelectedCallback<T>? onSelected,
    AppReactiveDropdownUnEnabledItemCallback<T>? onSelectUnEnabledItem,
    AppReactiveDropdownSelectReturnCallback<T>? onSelectReturn,
  }) {
    return AppReactiveDropdownField<T>._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      options: options,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      isLoading: isLoading,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      enableSearch: enableSearch,
      dialogBarrierDismissible: dialogBarrierDismissible,
      presentation: presentation,
      optionsTextStyle: optionsTextStyle,
      missingOptionNameBuilder: missingOptionNameBuilder,
      onSelected: onSelected,
      onSelectUnEnabledItem: onSelectUnEnabledItem,
      onSelectReturn: onSelectReturn,
    );
  }

  /// Overlay dropdown anchored to the field.
  factory AppReactiveDropdownField.menu({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    required List<AppDropdownOption<T>> options,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    bool isLoading = false,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    bool enableSearch = false,
    bool dialogBarrierDismissible = true,
    TextStyle? optionsTextStyle,
    String Function(T id)? missingOptionNameBuilder,
    AppReactiveDropdownSelectedCallback<T>? onSelected,
    AppReactiveDropdownUnEnabledItemCallback<T>? onSelectUnEnabledItem,
    AppReactiveDropdownSelectReturnCallback<T>? onSelectReturn,
  }) {
    return AppReactiveDropdownField<T>._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      options: options,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      isLoading: isLoading,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      enableSearch: enableSearch,
      dialogBarrierDismissible: dialogBarrierDismissible,
      optionsTextStyle: optionsTextStyle,
      missingOptionNameBuilder: missingOptionNameBuilder,
      onSelected: onSelected,
      onSelectUnEnabledItem: onSelectUnEnabledItem,
      onSelectReturn: onSelectReturn,
    );
  }

  /// Dialog-based dropdown.
  factory AppReactiveDropdownField.dialog({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    required List<AppDropdownOption<T>> options,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    bool isLoading = false,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    bool enableSearch = false,
    bool dialogBarrierDismissible = true,
    TextStyle? optionsTextStyle,
    String Function(T id)? missingOptionNameBuilder,
    AppReactiveDropdownSelectedCallback<T>? onSelected,
    AppReactiveDropdownUnEnabledItemCallback<T>? onSelectUnEnabledItem,
    AppReactiveDropdownSelectReturnCallback<T>? onSelectReturn,
  }) {
    return AppReactiveDropdownField<T>._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      options: options,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      isLoading: isLoading,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      enableSearch: enableSearch,
      dialogBarrierDismissible: dialogBarrierDismissible,
      presentation: AppReactiveDropdownPresentation.dialog,
      optionsTextStyle: optionsTextStyle,
      missingOptionNameBuilder: missingOptionNameBuilder,
      onSelected: onSelected,
      onSelectUnEnabledItem: onSelectUnEnabledItem,
      onSelectReturn: onSelectReturn,
    );
  }

  /// Bottom-sheet dropdown.
  factory AppReactiveDropdownField.bottomSheet({
    Key? key,
    required String formControlName,
    FormGroup? formGroup,
    required List<AppDropdownOption<T>> options,
    String? title,
    bool isRequired = false,
    double titleSpacing = AppSpacing.sm,
    AppFieldLayout layout = const AppFieldLayout(),
    bool enabled = true,
    bool isLoading = false,
    String? hintText,
    AppTextFieldDecoration decoration = const AppTextFieldDecoration(),
    AppTextFieldStyle style = const AppTextFieldStyle(),
    AppTextFieldValidation validation = const AppTextFieldValidation(),
    AppAffixes affixes = const AppAffixes(),
    bool allowClear = true,
    bool enableSearch = false,
    bool dialogBarrierDismissible = true,
    TextStyle? optionsTextStyle,
    String Function(T id)? missingOptionNameBuilder,
    AppReactiveDropdownSelectedCallback<T>? onSelected,
    AppReactiveDropdownUnEnabledItemCallback<T>? onSelectUnEnabledItem,
    AppReactiveDropdownSelectReturnCallback<T>? onSelectReturn,
  }) {
    return AppReactiveDropdownField<T>._(
      key: key,
      formControlName: formControlName,
      formGroup: formGroup,
      options: options,
      title: title,
      isRequired: isRequired,
      titleSpacing: titleSpacing,
      layout: layout,
      enabled: enabled,
      isLoading: isLoading,
      hintText: hintText,
      decoration: decoration,
      style: style,
      validation: validation,
      affixes: affixes,
      allowClear: allowClear,
      enableSearch: enableSearch,
      dialogBarrierDismissible: dialogBarrierDismissible,
      presentation: AppReactiveDropdownPresentation.bottomSheet,
      optionsTextStyle: optionsTextStyle,
      missingOptionNameBuilder: missingOptionNameBuilder,
      onSelected: onSelected,
      onSelectUnEnabledItem: onSelectUnEnabledItem,
      onSelectReturn: onSelectReturn,
    );
  }

  /// The name of the control inside the parent [FormGroup].
  final String formControlName;

  /// Optional form group. When provided, the widget wraps itself with
  /// [ReactiveForm] (same pattern used by other form fields in this project).
  final FormGroup? formGroup;

  /// The available dropdown options.
  final List<AppDropdownOption<T>> options;

  /// Optional title shown above the field.
  final String? title;

  /// Shows a red `*` next to [title] when `true`.
  final bool isRequired;

  /// Vertical spacing between [title] and the field.
  final double titleSpacing;

  /// Layout configuration (width/height/padding/borderRadius).
  final AppFieldLayout layout;

  /// Enables/disables the entire field.
  final bool enabled;

  /// When `true`, the field shows a loading indicator and prevents opening the
  /// picker until options are ready.
  final bool isLoading;

  /// Hint text shown when no option is selected.
  final String? hintText;

  /// Field decoration config (borders/shadows/fill).
  final AppTextFieldDecoration decoration;

  /// Field text styles.
  final AppTextFieldStyle style;

  /// Validation behavior (show errors mode/messages).
  final AppTextFieldValidation validation;

  /// Prefix/suffix icon configuration.
  final AppAffixes affixes;

  /// Show/hide the clear button.
  final bool allowClear;

  /// Enables search field inside the options picker.
  final bool enableSearch;

  final bool dialogBarrierDismissible;

  /// How the options are displayed (menu/dialog/bottom sheet).
  final AppReactiveDropdownPresentation presentation;

  /// Text style used for option items.
  final TextStyle? optionsTextStyle;

  /// When the control already has an `id` that is not in [options], this builder
  /// is used to create a display name for the injected option.
  final String Function(T id)? missingOptionNameBuilder;

  /// Called after a successful selection where the control value is written.
  final AppReactiveDropdownSelectedCallback<T>? onSelected;

  /// Called when the user taps a disabled option (`enable: false`).
  ///
  /// The widget will not update the form control value.
  final AppReactiveDropdownUnEnabledItemCallback<T>? onSelectUnEnabledItem;

  /// Called during selection to accept/reject the chosen option.
  final AppReactiveDropdownSelectReturnCallback<T>? onSelectReturn;

  @override
  State<AppReactiveDropdownField<T>> createState() =>
      _AppReactiveDropdownFieldState<T>();
}
