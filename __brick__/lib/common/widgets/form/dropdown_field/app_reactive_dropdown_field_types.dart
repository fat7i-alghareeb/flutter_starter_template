part of 'app_reactive_dropdown_field.dart';

/// Called after a successful selection where the control value is written.
///
/// The selected option is always passed even if you later reject the selection
/// using [AppReactiveDropdownSelectReturnCallback].
typedef AppReactiveDropdownSelectedCallback<T> =
    void Function(AppDropdownOption<T> selected);

/// Called when the user selects an option.
///
/// Return `null` to accept the selection.
///
/// Return a non-null string to reject it:
/// - the dropdown will keep showing the selected option text,
/// - but the bound form control value will be set to `null`,
/// - and a custom validation error message will be shown.
typedef AppReactiveDropdownSelectReturnCallback<T> =
    String? Function(AppDropdownOption<T> selected);

/// Defines how the dropdown options are presented.
enum AppReactiveDropdownPresentation { menu, dialog, bottomSheet }

/// A base option entity used by [AppReactiveDropdownField].
///
/// This class is designed to be extended:
///
/// ```dart
/// class CountryOption extends AppDropdownOption<int> {
///   const CountryOption({required super.id, required super.name, this.code});
///   final String? code;
/// }
/// ```
///
/// Notes:
/// - [id] is the value written into the reactive form control.
/// - [name] is the displayed text.
/// - [enable] disables the option in the UI if set to `false`.
class AppDropdownOption<T> {
  const AppDropdownOption({
    required this.id,
    required this.name,
    this.enable = true,
  });

  final T id;
  final String name;
  final bool enable;
}
