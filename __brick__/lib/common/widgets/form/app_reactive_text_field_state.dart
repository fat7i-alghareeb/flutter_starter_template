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
  late final FocusNode _focusNode;

  TextEditingController? _phoneController;

  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);

    if (widget._type == _AppReactiveTextFieldType.phone) {
      _phoneController = TextEditingController();
    }

    if (widget._type == _AppReactiveTextFieldType.password) {
      _obscure = widget.passwordObscureText;
    }
  }

  @override
  void didUpdateWidget(AppReactiveTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget._type != widget._type) {
      if (widget._type == _AppReactiveTextFieldType.phone &&
          _phoneController == null) {
        _phoneController = TextEditingController();
      }

      if (oldWidget._type == _AppReactiveTextFieldType.phone &&
          widget._type != _AppReactiveTextFieldType.phone) {
        _phoneController?.dispose();
        _phoneController = null;
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
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _phoneController?.dispose();
    super.dispose();
  }

  TextEditingController get phoneController =>
      _phoneController ??= TextEditingController();

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  _ResolvedOuterFieldConfig _resolveOuter(BuildContext context) {
    final width = widget.layout.percentageWidth != null
        ? context.screenWidth * widget.layout.percentageWidth!
        : widget.layout.width?.w;

    final height = widget.layout.percentageHeight != null
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

    return _ResolvedOuterFieldConfig(
      width: width,
      height: height,
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
      height: outer.height,
      child: ReactiveStatusListenableBuilder(
        formControlName: widget.formControlName,
        builder: (context, control, child) {
          final showValidation = widget.validation.enabled;

          // Error visibility is controlled here (not inside ReactiveTextField)
          // to keep UI consistent for both text and phone implementations.
          final shouldShowError =
              showValidation &&
              control.invalid &&
              switch (widget.validation.showErrorsMode) {
                AppReactiveShowErrorsMode.touched => control.touched,
                AppReactiveShowErrorsMode.dirty => control.dirty,
              };

          final errorText = shouldShowError
              ? AppReactiveValidationMessages.firstErrorText(
                  control,
                  messages: outer.validationMessages,
                )
              : null;

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
            ),
            _ => _buildReactiveTextField(
              context,
              textStyle: outer.baseTextStyle.copyWith(color: inputTextColor),
              hintStyle: outer.hintStyle,
              direction: outer.direction,
              messages: outer.validationMessages,
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
                decoration: decoration,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: outer.contentPadding,
                  child: fieldChild,
                ),
              ),
              if (shouldShowError &&
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
              obscureText: widget._type == _AppReactiveTextFieldType.password
                  ? _obscure
                  : false,
              style: textStyle,
              maxLines: widget._type == _AppReactiveTextFieldType.password
                  ? 1
                  : widget.maxLines,
              minLines: widget._type == _AppReactiveTextFieldType.password
                  ? 1
                  : widget.minLines,

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
                widget.onChanged?.call(value);
                scheduleDebounced(value);
              },
              onSubmitted: (control) {
                final v = (control.value ?? '').toString();
                final normalized = normalizeNumericText(widget._type, v);
                if (normalized != v) {
                  control.updateValue(normalized);
                }
                widget.onSubmitted?.call(normalized);
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
