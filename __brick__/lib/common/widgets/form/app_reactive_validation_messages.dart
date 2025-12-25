import 'package:reactive_forms/reactive_forms.dart';

import '../../../utils/helpers/app_strings.dart';

/// Default reactive_forms validation messages used by [AppReactiveTextField].
///
/// ## Override a built-in message
/// Provide `AppTextFieldValidation(messages: ...)` to the field:
///
/// ```dart
/// AppReactiveTextField.email(
///   formControlName: 'email',
///   validation: AppTextFieldValidation(
///     messages: {
///       ValidationMessage.required: (_) => 'Required (custom)',
///     },
///   ),
/// );
/// ```
///
/// ## Add a custom validation key
/// 1) Create a validator that returns your key in the error map:
///
/// ```dart
/// Map<String, dynamic>? noAdmin(AbstractControl<dynamic> c) {
///   final v = (c.value ?? '').toString();
///   return v.contains('admin') ? {'noAdmin': true} : null;
/// }
/// ```
///
/// 2) Provide a message resolver for the same key:
///
/// ```dart
/// AppReactiveTextField.text(
///   formControlName: 'username',
///   validation: AppTextFieldValidation(messages: {
///     'noAdmin': (_) => 'Not allowed',
///   }),
/// );
/// ```
class AppReactiveValidationMessages {
  const AppReactiveValidationMessages._();

  static const String invalidPhoneKey = 'invalidPhone';
  static const String customMessageKey = 'customMessage';
  static const String unknownKey = 'unknown';

  static Map<String, ValidationMessageFunction> defaults() {
    return <String, ValidationMessageFunction>{
      ValidationMessage.required: (_) => AppStrings.validationRequired,
      ValidationMessage.requiredTrue: (_) => AppStrings.validationRequiredTrue,
      ValidationMessage.email: (_) => AppStrings.validationEmail,
      ValidationMessage.number: (_) => AppStrings.validationNumber,
      ValidationMessage.min: (_) => AppStrings.validationMin,
      ValidationMessage.max: (_) => AppStrings.validationMax,
      ValidationMessage.minLength: (_) => AppStrings.validationMinLength,
      ValidationMessage.maxLength: (_) => AppStrings.validationMaxLength,
      ValidationMessage.pattern: (_) => AppStrings.validationPattern,
      ValidationMessage.creditCard: (_) => AppStrings.validationCreditCard,
      ValidationMessage.equals: (_) => AppStrings.validationEquals,
      ValidationMessage.mustMatch: (_) => AppStrings.validationMustMatch,
      ValidationMessage.compare: (_) => AppStrings.validationCompare,
      ValidationMessage.contains: (_) => AppStrings.validationContains,
      ValidationMessage.oneOf: (_) => AppStrings.validationOneOf,
      ValidationMessage.any: (_) => AppStrings.validationAny,
      invalidPhoneKey: (_) => AppStrings.validationInvalidPhone,
      customMessageKey: (value) {
        if (value is String && value.trim().isNotEmpty) return value;
        return AppStrings.validationUnknown;
      },
      unknownKey: (_) => AppStrings.validationUnknown,
    };
  }

  static Map<String, ValidationMessageFunction> merge(
    Map<String, ValidationMessageFunction> base,
    Map<String, ValidationMessageFunction>? override,
  ) {
    if (override == null || override.isEmpty) return base;
    return <String, ValidationMessageFunction>{...base, ...override};
  }

  static String? firstErrorText(
    AbstractControl<dynamic> control, {
    required Map<String, ValidationMessageFunction> messages,
  }) {
    if (control.errors.isEmpty) return null;

    for (final entry in control.errors.entries) {
      final key = entry.key;
      final resolver = messages[key] ?? messages[unknownKey];
      if (resolver == null) continue;
      return resolver(entry.value);
    }

    return null;
  }

  static String? latestErrorText(
    AbstractControl<dynamic> control, {
    required Map<String, ValidationMessageFunction> messages,
  }) {
    if (control.errors.isEmpty) return null;

    String? last;
    for (final entry in control.errors.entries) {
      final key = entry.key;
      final resolver = messages[key] ?? messages[unknownKey];
      if (resolver == null) continue;
      last = resolver(entry.value);
    }

    return last;
  }
}
