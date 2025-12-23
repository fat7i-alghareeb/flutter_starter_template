part of 'app_reactive_text_field.dart';

/// Phone-specific logic for [AppReactiveTextField].
///
/// Implementation notes:
/// - Uses `intl_phone_number_input` for parsing/formatting/validation.
/// - Writes the phone value back to the bound `FormControl<String>`.
/// - Stores the value as E.164 (e.g. `+201234567890`).
/// - When invalid, adds a custom reactive_forms error key: `invalidPhone`.
extension _AppReactiveTextFieldPhone on _AppReactiveTextFieldState {
  /// Picks the initial ISO country code.
  ///
  /// Priority:
  /// 1) [AppReactiveTextField.phoneDefaultIsoCode] if provided.
  /// 2) Locale countryCode (if available).
  /// 3) Fallback to `US`.
  String _defaultIsoCode(BuildContext context) {
    if (widget.phoneDefaultIsoCode != null &&
        widget.phoneDefaultIsoCode!.trim().isNotEmpty) {
      return widget.phoneDefaultIsoCode!.trim().toUpperCase();
    }

    try {
      final locale = Localizations.localeOf(context);
      final cc = locale.countryCode;
      if (cc != null && cc.trim().length == 2) {
        return cc.trim().toUpperCase();
      }
    } catch (_) {}

    return 'US';
  }

  /// Syncs the internal controller from the reactive control value.
  ///
  /// This prevents cursor jumps and avoids rebuilding the entire phone widget
  /// tree on every keystroke.
  void _syncPhoneControllerFromControl(String? value) {
    final v = value ?? '';
    if (phoneController.text == v) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (phoneController.text == v) return;
      phoneController.value = TextEditingValue(
        text: v,
        selection: TextSelection.collapsed(offset: v.length),
      );
    });
  }

  /// Builds the phone field using `InternationalPhoneNumberInput`.
  ///
  /// Validation:
  /// - When the package reports invalid input, we set `invalidPhone` on the
  ///   reactive control (without overriding other errors like `required`).
  Widget _buildPhoneField(
    BuildContext context, {
    required TextStyle textStyle,
    required String invalidPhoneText,
  }) {
    final isoCode = _defaultIsoCode(context);

    return ReactiveValueListenableBuilder<String>(
      formControlName: widget.formControlName,
      builder: (context, control, child) {
        final value = control.value;
        _syncPhoneControllerFromControl(value);

        final initial = PhoneNumber(isoCode: isoCode, phoneNumber: value);

        return InternationalPhoneNumberInput(
          key: ValueKey<String>(isoCode),
          isEnabled: widget.enabled,
          textFieldController: phoneController,
          focusNode: _focusNode,
          textStyle: textStyle,
          selectorConfig: SelectorConfig(useEmoji: widget.phoneUseEmojiFlags),
          countries: widget.phoneCountries,
          initialValue: initial,
          onInputValidated: (isValid) {
            final AbstractControl<Object>? inherited = ReactiveForm.of(
              context,
              listen: false,
            );
            final FormGroup? form =
                widget.formGroup ??
                (inherited is FormGroup
                    ? inherited
                    : inherited?.parent as FormGroup?);

            if (form == null) return;

            final AbstractControl<dynamic> raw = form.control(
              widget.formControlName,
            );
            if (raw is! FormControl<String>) return;
            final c = raw;

            final currentValue = (c.value ?? '').trim();
            if (currentValue.isEmpty) {
              if (c.hasError(AppReactiveValidationMessages.invalidPhoneKey)) {
                c.removeError(AppReactiveValidationMessages.invalidPhoneKey);
                c.updateValueAndValidity();
              }
              return;
            }

            if (isValid) {
              if (c.hasError(AppReactiveValidationMessages.invalidPhoneKey)) {
                c.removeError(AppReactiveValidationMessages.invalidPhoneKey);
                c.updateValueAndValidity();
              }
            } else {
              if (!c.hasError(AppReactiveValidationMessages.invalidPhoneKey)) {
                final current = Map<String, dynamic>.from(c.errors);
                current[AppReactiveValidationMessages.invalidPhoneKey] = true;
                c.setErrors(current);
                c.updateValueAndValidity();
              }
            }
          },
          inputDecoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          hintText: widget.hintText.isNullOrBlank ? null : widget.hintText,
          errorMessage: invalidPhoneText,
          onInputChanged: (number) {
            final phone = number.phoneNumber;
            final AbstractControl<Object>? inherited = ReactiveForm.of(
              context,
              listen: false,
            );
            final FormGroup? form =
                widget.formGroup ??
                (inherited is FormGroup
                    ? inherited
                    : inherited?.parent as FormGroup?);

            if (form == null) return;

            final AbstractControl<dynamic> raw = form.control(
              widget.formControlName,
            );
            if (raw is! FormControl<String>) return;
            final c = raw;

            if (c.value != phone) {
              c.updateValue(phone);
            }

            widget.onChanged?.call(phone ?? '');
            scheduleDebounced(phone ?? '');
          },
          onFieldSubmitted: (_) {
            widget.onSubmitted?.call(phoneController.text);
          },
        );
      },
    );
  }
}
