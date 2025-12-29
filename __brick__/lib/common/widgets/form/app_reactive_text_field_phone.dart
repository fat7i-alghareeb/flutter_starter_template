part of 'app_reactive_text_field.dart';

/// Phone-specific logic for [AppReactiveTextField].
///
/// Implementation notes:
/// - Uses `intl_phone_number_input` for parsing/formatting/validation.
/// - Writes the phone value back to the bound `FormControl<String>`.
/// - Stores the value as E.164 (e.g. `+201234567890`).
/// - When invalid, adds a custom reactive_forms error key: `invalidPhone`.
extension _AppReactiveTextFieldPhone on _AppReactiveTextFieldState {
  bool _looksLikeE164(String value) {
    final v = value.trim();
    if (!v.startsWith('+')) return false;
    final digits = v.substring(1);
    if (digits.isEmpty) return false;
    if (digits.length < 6 || digits.length > 15) return false;
    return RegExp(r'^\d+$').hasMatch(digits);
  }

  bool _looksLikeNationalDigits(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    if (v.length < 7 || v.length > 15) return false;
    return RegExp(r'^\d+$').hasMatch(v);
  }

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
  void _syncPhoneControllerFromControl(
    String? value, {
    required String isoCode,
  }) {
    if (_focusNode.hasFocus) return;

    // If the user has typed something and the current input is not valid,
    // do NOT overwrite the controller from the control value (which may still
    // contain the last valid E.164). This prevents reverting to the last valid
    // value on blur.
    if (!_phoneIsValid && phoneController.text.trim().isNotEmpty) {
      return;
    }

    final e164 = (value ?? '').trim();

    if (e164.isEmpty) {
      // When the control is empty but the user has typed digits (invalid / not
      // yet validated), keep the controller text.
      if (phoneController.text.trim().isNotEmpty) return;
      return;
    }

    // Only attempt to sync when the control contains a proper E.164.
    // This avoids feeding malformed strings into intl_phone_number_input
    // (which can crash with NumberParseException).
    if (_looksLikeE164(e164)) {
      PhoneNumber.getRegionInfoFromPhoneNumber(e164, isoCode)
          .then((pn) {
            final text = pn.parseNumber();
            if (phoneController.text == text) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (phoneController.text == text) return;
              phoneController.value = TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            });
          })
          .catchError((_) {
            // Ignore parsing errors.
          });
      return;
    }

    // In some flows you might store national digits (legacy / migration).
    // If that happens, show them, but do NOT attempt to parse.
    if (_looksLikeNationalDigits(e164)) {
      if (phoneController.text == e164) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (phoneController.text == e164) return;
        phoneController.value = TextEditingValue(
          text: e164,
          selection: TextSelection.collapsed(offset: e164.length),
        );
      });
    }
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
    required double? fieldHeight,
  }) {
    final isoCode = _phoneIsoCode ??= _defaultIsoCode(context);

    return ReactiveValueListenableBuilder<String>(
      formControlName: widget.formControlName,
      builder: (context, control, child) {
        final value = control.value;

        final isReset =
            (value == null || value.trim().isEmpty) &&
            !control.dirty &&
            !control.touched;
        if (isReset && phoneController.text.trim().isNotEmpty) {
          _phoneLastNumber = null;
          _phoneIsValid = false;
          _phoneLastEmittedE164 = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (phoneController.text.trim().isEmpty) return;
            phoneController.clear();
          });
        }

        _syncPhoneControllerFromControl(value, isoCode: isoCode);

        final e164 = (value ?? '').trim();
        final initial = _looksLikeE164(e164)
            ? PhoneNumber(isoCode: isoCode, phoneNumber: e164)
            : PhoneNumber(isoCode: isoCode);

        return SizedBox(
          height: fieldHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: InternationalPhoneNumberInput(
              key: ValueKey<String>(widget.formControlName),
              isEnabled: widget.enabled,
              textFieldController: phoneController,
              focusNode: _focusNode,
              textStyle: textStyle,
              selectorTextStyle: textStyle,
              ignoreBlank: true,
              formatInput: false,
              keyboardType: TextInputType.number,
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                useBottomSheetSafeArea: true,
                setSelectorButtonAsPrefixIcon: true,
                useEmoji: widget.phoneUseEmojiFlags,
                leadingPadding: 0,
                trailingSpace: false,
              ),
              autoFocusSearch: true,
              searchBoxDecoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: AppStrings.search,
              ),
              spaceBetweenSelectorAndTextField: 0,
              selectorButtonOnErrorPadding: 0,
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

                final currentText = phoneController.text.trim();
                final shouldStartValidation =
                    currentText.isNotEmpty ||
                    (c.value ?? '').isNotEmpty ||
                    c.dirty ||
                    c.touched;

                if (shouldStartValidation) {
                  c.markAsDirty();
                  _armDeferredValidation();
                }

                final wasValid = _phoneIsValid;
                _phoneIsValid = isValid;

                if (wasValid != isValid) {
                  if (isValid) {
                    printG(
                      '[PhoneField] ${widget.formControlName} validated=true '
                      'text="${phoneController.text.trim()}" '
                      'control="${(c.value ?? "").toString()}" '
                      'errors=${c.errors.keys.toList()}',
                    );
                  } else {
                    printR(
                      '[PhoneField] ${widget.formControlName} validated=false '
                      'text="${phoneController.text.trim()}" '
                      'control="${(c.value ?? "").toString()}" '
                      'errors=${c.errors.keys.toList()}',
                    );
                  }
                }

                if (wasValid && !isValid) {
                  if ((c.value ?? '').isNotEmpty) {
                    c.updateValue('');
                  }
                  final current = Map<String, dynamic>.from(c.errors);
                  current[AppReactiveValidationMessages.invalidPhoneKey] = true;
                  c.setErrors(current);
                  printR(
                    '[PhoneField] ${widget.formControlName} set invalidPhone '
                    'control="${(c.value ?? "").toString()}" '
                    'errors=${c.errors.keys.toList()}',
                  );
                  _phoneLastEmittedE164 = null;
                  return;
                }
                if (currentText.isEmpty) {
                  if (c.hasError(
                    AppReactiveValidationMessages.invalidPhoneKey,
                  )) {
                    c.removeError(
                      AppReactiveValidationMessages.invalidPhoneKey,
                    );
                  }
                  if ((c.value ?? '').isNotEmpty) {
                    c.updateValue('');
                  } else {
                    c.updateValueAndValidity();
                  }
                  return;
                }

                if (isValid) {
                  if (c.hasError(
                    AppReactiveValidationMessages.invalidPhoneKey,
                  )) {
                    c.removeError(
                      AppReactiveValidationMessages.invalidPhoneKey,
                    );
                  }

                  final e164 = _phoneLastNumber?.phoneNumber ?? '';
                  if (_looksLikeE164(e164) && c.value != e164) {
                    c.updateValue(e164);
                  } else {
                    c.updateValueAndValidity();
                  }

                  if (_phoneLastEmittedE164 != e164) {
                    _phoneLastEmittedE164 = e164;
                    widget.onChanged?.call(e164, true);
                    scheduleDebounced(e164, true);
                  }
                } else {
                  final current = Map<String, dynamic>.from(c.errors);
                  current[AppReactiveValidationMessages.invalidPhoneKey] = true;
                  c.setErrors(current);
                  printR(
                    '[PhoneField] ${widget.formControlName} set invalidPhone '
                    'control="${(c.value ?? "").toString()}" '
                    'errors=${c.errors.keys.toList()}',
                  );
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
              // We render errors in AppReactiveTextField (below the container).
              errorMessage: '',
              onInputChanged: (number) {
                _phoneLastNumber = number;
                if (number.isoCode != null &&
                    number.isoCode!.trim().isNotEmpty) {
                  _phoneIsoCode = number.isoCode!.trim().toUpperCase();
                }

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

                final currentText = phoneController.text.trim();
                final shouldStartValidation =
                    currentText.isNotEmpty ||
                    (c.value ?? '').isNotEmpty ||
                    c.dirty ||
                    c.touched;

                if (shouldStartValidation) {
                  c.markAsDirty();
                  _armDeferredValidation();
                }

                if (!_phoneIsValid && phoneController.text.trim().isNotEmpty) {
                  printY(
                    '[PhoneField] ${widget.formControlName} typing invalid '
                    'text="${phoneController.text.trim()}" '
                    'control="${(c.value ?? "").toString()}" '
                    'errors=${c.errors.keys.toList()}',
                  );
                }

                final nextValue = phone ?? '';

                if (currentText.isEmpty) {
                  _phoneLastEmittedE164 = null;
                  if ((c.value ?? '').isNotEmpty) {
                    c.updateValue('');
                  }
                  if (c.hasError(
                    AppReactiveValidationMessages.invalidPhoneKey,
                  )) {
                    c.removeError(
                      AppReactiveValidationMessages.invalidPhoneKey,
                    );
                    c.updateValueAndValidity();
                  }
                  return;
                }

                // Gate: until the package confirms validity, we don't update
                // the stored value (keep the last valid E.164 in the control)
                // and we don't fire callbacks.
                if (!_phoneIsValid) {
                  return;
                }

                if (_looksLikeE164(nextValue) && c.value != nextValue) {
                  c.updateValue(nextValue);
                }
              },
              onFieldSubmitted: (_) {
                if (!_phoneIsValid) return;
                final phone = (control.value ?? '').toString();
                if (!_looksLikeE164(phone)) return;
                widget.onSubmitted?.call(phone, control.valid);
              },
            ),
          ),
        );
      },
    );
  }
}
