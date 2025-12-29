part of 'app_reactive_text_field.dart';

/// Implementation for [AppReactiveTextField].
///
/// This state is responsible for:
/// - Rendering the field container + title + validation message
/// - Selecting the correct field implementation (text vs phone)
/// - Applying input formatters depending on the selected factory
/// - Debouncing `onChangedDebounced`
class _AppReactiveTextFieldState extends State<AppReactiveTextField>
    with _AppReactiveTextFieldDebounceMixin, _AppReactiveTextFieldHelpersMixin {
  // Tracks focus to update UI (border color) and to mark some controls as touched on blur.
  late final FocusNode _focusNode;

  // Timer used to arm deferred validation after the first debounce pause.
  Timer? _deferValidationDebounce;

  // Whether deferred validation has been armed (errors can be shown after this becomes true).
  bool _deferValidationArmed = false;

  // Phone input controller (national digits only). Only used for phone field type.
  TextEditingController? _phoneController;

  // Currently selected country ISO (e.g. "US") for the phone picker.
  String? _phoneIsoCode;

  // Last phone number object received from intl_phone_number_input.
  PhoneNumber? _phoneLastNumber;

  // Latest validity reported by intl_phone_number_input.
  bool _phoneIsValid = false;

  // Last emitted valid E.164 string to dedupe callbacks.
  String? _phoneLastEmittedE164;

  // Debug: last computed error visibility to avoid spamming logs.
  bool? _debugLastShouldShowError;

  // Debug: last resolved error text to avoid spamming logs.
  String? _debugLastErrorText;

  // Debug: last defer gate state to avoid spamming logs.
  bool? _debugLastDeferGate;

  // Password visibility state.
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);

    if (widget._type == _AppReactiveTextFieldType.password) {
      _obscure = widget.passwordObscureText;
    }
  }

  @override
  void didUpdateWidget(AppReactiveTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the control changes (or the deferral behavior changes), reset the
    // deferred-validation state so we don't show stale errors.
    if (oldWidget.formControlName != widget.formControlName ||
        oldWidget.validation.deferErrorsUntilFirstDebounce !=
            widget.validation.deferErrorsUntilFirstDebounce) {
      _deferValidationDebounce?.cancel();
      _deferValidationArmed = false;
    }

    if (oldWidget._type != widget._type) {
      // If we leave the phone field, clean up phone-specific cached state.
      if (oldWidget._type == _AppReactiveTextFieldType.phone &&
          widget._type != _AppReactiveTextFieldType.phone) {
        _phoneController?.dispose();
        _phoneController = null;

        _phoneIsoCode = null;
        _phoneLastNumber = null;
        _phoneIsValid = false;
        _phoneLastEmittedE164 = null;
      }
    }

    if (oldWidget._type != widget._type &&
        widget._type == _AppReactiveTextFieldType.password) {
      _obscure = widget.passwordObscureText;
    }

    if (widget._type == _AppReactiveTextFieldType.password &&
        oldWidget.passwordObscureText != widget.passwordObscureText) {
      _obscure = widget.passwordObscureText;
    }
  }

  @override
  void dispose() {
    disposeDebounce();
    _deferValidationDebounce?.cancel();
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _phoneController?.dispose();
    super.dispose();
  }

  void _armDeferredValidation() {
    if (!widget.validation.deferErrorsUntilFirstDebounce) return;
    if (_deferValidationArmed) return;
    _deferValidationDebounce?.cancel();
    printC(
      '[AppReactiveTextField] arm deferred validation: ${widget.formControlName}',
    );
    _deferValidationDebounce = Timer(widget.onChangedDebounceDuration, () {
      if (!mounted) return;
      setState(() {
        _deferValidationArmed = true;
      });
      printC(
        '[AppReactiveTextField] deferred validation armed: ${widget.formControlName}',
      );
    });
  }

  void _debugLogErrorDecision({
    required AbstractControl<dynamic> control,
    required bool deferGate,
    required bool shouldShowError,
    required String? errorText,
  }) {
    if (_debugLastDeferGate != deferGate ||
        _debugLastShouldShowError != shouldShowError ||
        _debugLastErrorText != errorText) {
      _debugLastDeferGate = deferGate;
      _debugLastShouldShowError = shouldShowError;
      _debugLastErrorText = errorText;
      printY(
        '[AppReactiveTextField] ${widget.formControlName} \n '
        'deferGate=$deferGate \n'
        'invalid=${control.invalid} \n'
        'dirty=${control.dirty} \n'
        'touched=${control.touched} \n'
        'shouldShowError=$shouldShowError \n'
        'errorText=${errorText ?? "<null>"} \n'
        'errors=${control.errors.keys.toList()}\n',
      );
    }
  }

  TextEditingController get phoneController =>
      _phoneController ??= TextEditingController();

  void _onFocusChanged() {
    if (!mounted) return;

    if (!_focusNode.hasFocus &&
        widget._type == _AppReactiveTextFieldType.phone) {
      final AbstractControl<Object>? inherited = ReactiveForm.of(
        context,
        listen: false,
      );
      final FormGroup? form =
          widget.formGroup ??
          (inherited is FormGroup
              ? inherited
              : inherited?.parent as FormGroup?);

      final AbstractControl<dynamic>? raw = form?.control(
        widget.formControlName,
      );
      if (raw is FormControl<String>) {
        raw.markAsTouched();
      }
    }

    setState(() {});
  }

  _ResolvedOuterFieldConfig _resolveOuter(BuildContext context) {
    final width = widget.layout.percentageWidth != null
        ? context.screenWidth * widget.layout.percentageWidth!
        : widget.layout.width?.w;

    final heightFromLayout = widget.layout.percentageHeight != null
        ? context.screenHeight * widget.layout.percentageHeight!
        : widget.layout.height?.h;

    final borderRadiusValue = widget.layout.borderRadius ?? AppRadii.sm;
    final borderRadius = BorderRadius.circular(borderRadiusValue.r);

    final contentPadding =
        widget.layout.contentPadding ??
        REdgeInsets.symmetric(horizontal: 12, vertical: 12);

    final baseTextStyle = widget.style.textStyle ?? AppTextStyles.s14w400;

    final hintStyle = widget.hintText.isNullOrBlank
        ? null
        : baseTextStyle.copyWith(color: context.grey.withValues(alpha: 0.8));

    final validationMessages = AppReactiveValidationMessages.merge(
      AppReactiveValidationMessages.defaults(),
      widget.validation.messages,
    );

    final direction = effectiveTextDirection(context);

    final resolvedPadding = contentPadding.resolve(direction);
    final fontSize = baseTextStyle.fontSize ?? 14;
    final lineHeightMultiplier = baseTextStyle.height ?? 1.2;
    final minOuterHeight =
        (fontSize * lineHeightMultiplier) + resolvedPadding.vertical;

    final isMultiline =
        (widget.maxLines != null && widget.maxLines! > 1) ||
        (widget.minLines != null && widget.minLines! > 1);

    final defaultHeight = isMultiline ? null : 48.h;
    final heightCandidate = heightFromLayout ?? defaultHeight;

    final effectiveHeight = heightCandidate == null
        ? null
        : math.max(heightCandidate, minOuterHeight);

    return _ResolvedOuterFieldConfig(
      width: width,
      height: effectiveHeight,
      borderRadius: borderRadius,
      contentPadding: contentPadding,
      baseTextStyle: baseTextStyle,
      hintStyle: hintStyle,
      validationMessages: validationMessages,
      direction: direction,
    );
  }

  Color? _resolveBorderColor(
    BuildContext context, {
    required bool shouldShowError,
    required bool isFocused,
  }) {
    if (!widget.decoration.borderEnabled) return null;

    final colors = widget.decoration.borderColors;

    if (shouldShowError) {
      return colors?.error ?? AppColors.error;
    }

    if (!widget.enabled) {
      return colors?.disabled ?? context.grey.withValues(alpha: 0.6);
    }

    if (isFocused) {
      return colors?.focused ?? context.primary;
    }

    return colors?.enabled ?? context.grey;
  }

  @override
  Widget build(BuildContext context) {
    final inner = _buildWithEffectiveGroup(context);
    if (widget.formGroup == null) return inner;

    return ReactiveForm(formGroup: widget.formGroup!, child: inner);
  }

  Widget _buildWithEffectiveGroup(BuildContext context) {
    final outer = _resolveOuter(context);

    return SizedBox(
      width: outer.width,
      child: ReactiveStatusListenableBuilder(
        formControlName: widget.formControlName,
        builder: (context, control, child) {
          final resolvedPadding = outer.contentPadding.resolve(outer.direction);

          // The outer container has padding. This computes the remaining space
          // that can be used by the inner input widget.
          final double? availableFieldHeight = outer.height == null
              ? null
              : outer.height! - resolvedPadding.vertical;
          final double? effectiveFieldHeight =
              (availableFieldHeight != null && availableFieldHeight < 0)
              ? 0
              : availableFieldHeight;

          // If the widget is disabled, we also disable validation UI.
          final showValidation = widget.enabled && widget.validation.enabled;

          // When deferral is enabled, we don't show errors until the first
          // debounce pause after the user starts interacting with the field.
          final deferGate =
              !widget.validation.deferErrorsUntilFirstDebounce ||
              _deferValidationArmed ||
              control.touched ||
              control.dirty;

          // Error visibility is controlled here (not inside ReactiveTextField)
          // to keep UI consistent for both text and phone implementations.
          // In touched-mode, we still show errors after the user starts typing
          // (dirty) so "invalidPhone" can appear without requiring blur.
          final shouldShowError =
              showValidation &&
              deferGate &&
              control.invalid &&
              switch (widget.validation.showErrorsMode) {
                AppReactiveShowErrorsMode.touched =>
                  control.touched || control.dirty,
                AppReactiveShowErrorsMode.dirty => control.dirty,
              };

          final shouldShowErrorText =
              shouldShowError && !widget.validation.hideErrorText;

          final errorText = shouldShowErrorText
              ? AppReactiveValidationMessages.latestErrorText(
                  control,
                  messages: outer.validationMessages,
                )
              : null;

          _debugLogErrorDecision(
            control: control,
            deferGate: deferGate,
            shouldShowError: shouldShowError,
            errorText: errorText,
          );

          final isFocused = _focusNode.hasFocus;

          final borderColor = _resolveBorderColor(
            context,
            shouldShowError: shouldShowError,
            isFocused: isFocused,
          );

          final boxShadow = widget.decoration.noShadow
              ? const <BoxShadow>[]
              : (widget.decoration.shadows ?? context.shadows.grey);

          final inputTextColor = shouldShowError
              ? AppColors.error
              : context.onSurface;

          final titleColor = shouldShowError
              ? AppColors.error
              : context.onSurface;

          final decoration = BoxDecoration(
            color: widget.decoration.fillColor,
            borderRadius: outer.borderRadius,
            border: widget.decoration.borderEnabled && borderColor != null
                ? Border.all(
                    color: borderColor,
                    width: widget.decoration.borderWidth,
                  )
                : null,
            boxShadow: boxShadow,
          );

          final titleWidget = widget.title.isNullOrBlank
              ? const SizedBox.shrink()
              : _FieldTitle(
                  title: widget.title!.trim(),
                  isRequired: widget.isRequired,
                  style: (widget.style.titleTextStyle ?? AppTextStyles.s12w500)
                      .copyWith(color: titleColor),
                );
          final fieldChild = switch (widget._type) {
            _AppReactiveTextFieldType.phone => _buildPhoneField(
              context,
              textStyle: outer.baseTextStyle.copyWith(color: inputTextColor),
              invalidPhoneText: AppStrings.validationInvalidPhone,
              fieldHeight: effectiveFieldHeight,
            ),
            _ => _buildReactiveTextField(
              context,
              textStyle: outer.baseTextStyle.copyWith(color: inputTextColor),
              hintStyle: outer.hintStyle,
              direction: outer.direction,
              messages: outer.validationMessages,
              fieldHeight: effectiveFieldHeight,
            ),
          };

          final validationStyleBase =
              widget.style.validationTextStyle ?? AppTextStyles.s11w500;
          final validationStyle = validationStyleBase.copyWith(
            color: AppColors.error,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              titleWidget,
              if (!widget.title.isNullOrBlank)
                widget.titleSpacing.verticalSpace,
              Container(
                height: outer.height,
                decoration: decoration,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: outer.contentPadding,
                  child: fieldChild,
                ),
              ),
              if (shouldShowErrorText &&
                  errorText != null &&
                  errorText.trim().isNotEmpty) ...[
                AppSpacing.xs.verticalSpace,
                Text(errorText, style: validationStyle),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildReactiveTextField(
    BuildContext context, {
    required TextStyle textStyle,
    required TextStyle? hintStyle,
    required TextDirection direction,
    required Map<String, ValidationMessageFunction> messages,
    required double? fieldHeight,
  }) {
    final inputDecoration = InputDecoration(
      isDense: true,
      hintText: widget.hintText.isNullOrBlank ? null : widget.hintText,
      hintStyle: hintStyle,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    );

    final suffixWidget = _effectiveSuffix();

    final isObscured = widget._type == _AppReactiveTextFieldType.password
        ? _obscure
        : false;
    final isSingleLine = isObscured ? true : (widget.maxLines ?? 1) == 1;
    final shouldExpand = fieldHeight != null && isSingleLine && !isObscured;

    return Directionality(
      textDirection: direction,
      child: Row(
        children: <Widget>[
          if (widget.affixes.prefixIcon != null)
            _PrefixSuffixSlot(
              onTap: widget.affixes.onPrefixTap,
              child: widget.affixes.prefixIcon!.build(
                context,
                color: textStyle.color ?? context.onSurface,
                size: 20,
              ),
            ),
          if (widget.affixes.prefixIcon != null) AppSpacing.sm.horizontalSpace,
          Expanded(
            child: ReactiveTextField<String>(
              formControlName: widget.formControlName,
              focusNode: _focusNode,
              keyboardType: keyboardType(widget._type),
              textInputAction: widget.textInputAction,
              obscureText: isObscured,
              style: textStyle,
              maxLines: isObscured
                  ? 1
                  : (shouldExpand ? null : widget.maxLines),
              minLines: isObscured
                  ? 1
                  : (shouldExpand ? null : widget.minLines),
              expands: shouldExpand,
              textAlignVertical: TextAlignVertical.center,

              // reactive_forms doesn't accept `enabled:` like Flutter's
              // TextField. `readOnly` keeps the field non-editable without
              // breaking layout.
              readOnly: !widget.enabled,
              showCursor: widget.enabled,
              inputFormatters: inputFormatters(widget._type),
              decoration: inputDecoration,
              validationMessages: messages,
              showErrors: (control) => false,
              onChanged: (control) {
                final value = (control.value ?? '').toString();
                final isValid = control.valid;
                _armDeferredValidation();
                widget.onChanged?.call(value, isValid);
                scheduleDebounced(value, isValid);
              },
              onSubmitted: (control) {
                final v = (control.value ?? '').toString();
                final normalized = normalizeNumericText(widget._type, v);
                if (normalized != v) {
                  control.updateValue(normalized);
                }
                final isValid = control.valid;
                widget.onSubmitted?.call(normalized, isValid);
              },
            ),
          ),
          if (suffixWidget != null || widget.affixes.suffixIcon != null) ...[
            AppSpacing.sm.horizontalSpace,
            _PrefixSuffixSlot(
              onTap:
                  widget._type == _AppReactiveTextFieldType.password &&
                      widget.passwordObscureText &&
                      widget.passwordEnableToggle
                  ? _togglePassword
                  : widget.affixes.onSuffixTap,
              child:
                  suffixWidget ??
                  widget.affixes.suffixIcon!.build(
                    context,
                    color: textStyle.color ?? context.onSurface,
                    size: 20,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _effectiveSuffix() {
    if (widget._type != _AppReactiveTextFieldType.password) return null;
    if (!widget.passwordObscureText) return null;
    if (!widget.passwordEnableToggle) return null;

    final obscured = widget.passwordObscuredWidget;
    final revealed = widget.passwordRevealedWidget;

    final child = _obscure
        ? (obscured ?? const _DefaultPasswordHidden())
        : (revealed ?? const _DefaultPasswordShown());

    return AnimatedSwitcher(
      duration: AppDurations.fast,
      child: KeyedSubtree(key: ValueKey<bool>(_obscure), child: child),
    );
  }

  void _togglePassword() {
    if (widget._type != _AppReactiveTextFieldType.password) return;
    if (!widget.passwordObscureText) return;
    if (!widget.passwordEnableToggle) return;
    setState(() {
      _obscure = !_obscure;
    });
  }
}
