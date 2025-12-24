part of 'app_reactive_text_field.dart';

typedef AppReactiveTextFieldValueCallback =
    void Function(String value, bool isValid);

/// High-performance, highly customizable form field widgets built on top of
/// `reactive_forms`.
///
/// This file defines the public API for [AppReactiveTextField] and related
/// supporting types. The implementation is split into smaller `part` files to
/// keep maintenance easy.
///
/// ## Key design decisions
/// - **Reactive source of truth**: the bound `FormControl` is the source of
///   truth. UI reads and writes through the control.
/// - **Phone storage**: phone values are stored as a **String in E.164 format**
///   (e.g. `+201234567890`) in the `FormControl<String>`.
/// - **Validation UI**: title is always above the field, and the first
///   validation message is shown below (configurable by [AppReactiveShowErrorsMode]).
///
/// See the widget DartDoc on [AppReactiveTextField] for usage examples.
enum _AppReactiveTextFieldType {
  text,
  email,
  password,
  phone,
  decimal,
  integer,
  stringOnly,
}

/// Controls *when* validation errors should be shown.
///
/// The widget itself always passes `showErrors: (_) => false` to the underlying
/// reactive widget and computes the error visibility here.
enum AppReactiveShowErrorsMode { touched, dirty }

/// Controls the text direction for the input content.
///
/// - [locale] uses your app's current locale direction.
/// - [ltr] forces left-to-right.
/// - [rtl] forces right-to-left.
enum AppFieldTextDirectionMode { locale, ltr, rtl }

/// Layout configuration for [AppReactiveTextField].
///
/// This is intentionally small and stable so it can be reused across many
/// fields without rebuilding lots of objects.
class AppFieldLayout {
  const AppFieldLayout({
    this.width,
    this.height,
    this.percentageWidth,
    this.percentageHeight,
    this.borderRadius,
    this.contentPadding,
  });

  final double? width;
  final double? height;

  final double? percentageWidth;
  final double? percentageHeight;

  final double? borderRadius;

  final EdgeInsetsGeometry? contentPadding;
}

/// Border colors for different field states.
///
/// If a color is `null`, a theme-based default will be used.
class AppFieldBorderColors {
  const AppFieldBorderColors({
    this.enabled,
    this.focused,
    this.disabled,
    this.error,
  });

  final Color? enabled;
  final Color? focused;
  final Color? disabled;
  final Color? error;
}

class AppTextFieldDecoration {
  const AppTextFieldDecoration({
    this.fillColor = Colors.transparent,
    this.noShadow = true,
    this.shadows,
    this.borderEnabled = true,
    this.borderWidth = 1,
    this.borderColors,
  });

  final Color fillColor;
  final bool noShadow;
  final List<BoxShadow>? shadows;
  final bool borderEnabled;
  final double borderWidth;
  final AppFieldBorderColors? borderColors;
}

class AppTextFieldStyle {
  const AppTextFieldStyle({
    this.titleTextStyle,
    this.textStyle,
    this.validationTextStyle,
  });

  final TextStyle? titleTextStyle;
  final TextStyle? textStyle;
  final TextStyle? validationTextStyle;
}

class AppTextFieldAffixes {
  const AppTextFieldAffixes({
    this.prefixIcon,
    this.suffixIcon,
    this.onPrefixTap,
    this.onSuffixTap,
  });

  final IconSource? prefixIcon;
  final IconSource? suffixIcon;
  final VoidCallback? onPrefixTap;
  final VoidCallback? onSuffixTap;
}

class AppTextFieldValidation {
  const AppTextFieldValidation({
    this.enabled = true,
    this.showErrorsMode = AppReactiveShowErrorsMode.dirty,
    this.hideErrorText = false,
    this.deferErrorsUntilFirstDebounce = true,
    this.messages,
  });

  final bool enabled;
  final AppReactiveShowErrorsMode showErrorsMode;
  final bool hideErrorText;
  final bool deferErrorsUntilFirstDebounce;
  final Map<String, ValidationMessageFunction>? messages;
}

class _ResolvedOuterFieldConfig {
  const _ResolvedOuterFieldConfig({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.contentPadding,
    required this.baseTextStyle,
    required this.hintStyle,
    required this.validationMessages,
    required this.direction,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final TextStyle baseTextStyle;
  final TextStyle? hintStyle;
  final Map<String, ValidationMessageFunction> validationMessages;
  final TextDirection direction;
}
