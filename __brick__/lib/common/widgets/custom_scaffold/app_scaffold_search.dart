part of 'app_scaffold.dart';

/// Configuration for the search section.
///
/// This is a thin wrapper around [AppReactiveTextField.text] so pages can
/// control search behavior without mixing text field parameters into the
/// scaffold API.
final class AppScaffoldSearchConfig {
  const AppScaffoldSearchConfig({
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
    this.textDirectionMode = AppFieldTextDirectionMode.locale,
    this.textInputAction,
    this.onChanged,
    this.onChangedDebounced,
    this.onChangedDebounceDuration = const Duration(milliseconds: 400),
    this.onSubmitted,
  });

  /// Name of the reactive_forms control.
  final String formControlName;

  /// Optional form group.
  ///
  /// If provided, [AppReactiveTextField] can wrap itself with a [ReactiveForm].
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
  final AppFieldTextDirectionMode textDirectionMode;
  final TextInputAction? textInputAction;

  final AppReactiveTextFieldValueCallback? onChanged;

  /// Debounced value callback.
  ///
  /// Useful for “search as you type” without doing work on every keystroke.
  final AppReactiveTextFieldValueCallback? onChangedDebounced;
  final Duration onChangedDebounceDuration;

  /// Called when the user submits the field.
  final AppReactiveTextFieldValueCallback? onSubmitted;
}

/// Small wrapper for a minimal set of Scaffold configuration.
///
/// Keeping this in a separate config object allows the scaffold API to scale
/// without adding dozens of parameters to [AppScaffold].
final class AppScaffoldConfig {
  const AppScaffoldConfig({
    this.backgroundColor,
    this.resizeToAvoidBottomInset = false,
  });

  /// Background color passed to [Scaffold].
  final Color? backgroundColor;

  /// Passed to [Scaffold.resizeToAvoidBottomInset].
  final bool resizeToAvoidBottomInset;
}

/// Internal search section used by [AppScaffold].
///
/// This indirection keeps the main scaffold build method small and ensures the
/// search field is not built unless [ScaffoldFeature.search] is enabled.
class _AppScaffoldSearchField extends StatelessWidget {
  const _AppScaffoldSearchField({required this.config});

  final AppScaffoldSearchConfig config;

  @override
  Widget build(BuildContext context) {
    return AppReactiveTextField.text(
      formControlName: config.formControlName,
      formGroup: config.formGroup,
      title: config.title,
      isRequired: config.isRequired,
      titleSpacing: config.titleSpacing,
      layout: config.layout,
      enabled: config.enabled,
      hintText: config.hintText,
      decoration: config.decoration,
      style: config.style,
      validation: config.validation,
      affixes: config.affixes,
      textDirectionMode: config.textDirectionMode,
      textInputAction: config.textInputAction,
      onChanged: config.onChanged,
      onChangedDebounced: config.onChangedDebounced,
      onChangedDebounceDuration: config.onChangedDebounceDuration,
      onSubmitted: config.onSubmitted,
    );
  }
}
