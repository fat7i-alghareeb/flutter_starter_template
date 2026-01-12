part of 'app_reactive_date_time_field.dart';

class _AppReactiveDateTimeFieldState extends State<AppReactiveDateTimeField>
    with
        _AppReactiveDateTimeFieldPickersMixin,
        _AppReactiveDateTimeFieldValueMixin {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        if (!mounted) return;
        setState(() {});
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inner = _buildWithEffectiveGroup(context);
    if (widget.formGroup == null) return inner;

    // Match AppReactiveTextField behavior: if a formGroup is provided, the field
    // wraps itself with a ReactiveForm.
    return ReactiveForm(formGroup: widget.formGroup!, child: inner);
  }

  Widget _buildWithEffectiveGroup(BuildContext context) {
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

    final direction = Directionality.of(context);
    final resolvedPadding = contentPadding.resolve(direction);

    final locale = context.locale.toString();

    final fontSize = baseTextStyle.fontSize ?? 14;
    final lineHeightMultiplier = baseTextStyle.height ?? 1.2;
    final minOuterHeight =
        (fontSize * lineHeightMultiplier) + resolvedPadding.vertical;

    final defaultHeight = 48.h;
    final heightCandidate = heightFromLayout ?? defaultHeight;
    final effectiveHeight = heightCandidate < minOuterHeight
        ? minOuterHeight
        : heightCandidate;

    return SizedBox(
      width: width,
      child: ReactiveStatusListenableBuilder(
        formControlName: widget.formControlName,
        builder: (context, control, child) {
          // If the widget is disabled, we also disable validation UI.
          final showValidation = widget.enabled && widget.validation.enabled;

          // Match AppReactiveTextField visibility logic.
          final shouldShowError =
              showValidation &&
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
                  messages: validationMessages,
                )
              : null;

          final borderColor = _resolveBorderColor(
            context,
            shouldShowError: shouldShowError,
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
            borderRadius: borderRadius,
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

          // Compute the display string based on the control value.
          //
          // For single-value modes we format a single DateTime.
          // For range mode we format a (from,to) range.
          final (hasValue, displayText) = _resolveDisplayText(
            control,
            locale: locale,
          );

          // Clear button is only shown when a value exists.
          final showClear = widget.enabled && widget.allowClear && hasValue;

          final suffixWidget = showClear
              ? _TapArea(
                  onTap: () => _clear(control),
                  child: const _ClearIcon(),
                )
              : (widget.affixes.suffixIcon != null
                    ? _TapArea(
                        onTap: widget.affixes.onSuffixTap,
                        child: widget.affixes.suffixIcon!.build(
                          context,
                          color: inputTextColor,
                          size: 20,
                        ),
                      )
                    : null);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              titleWidget,
              if (!widget.title.isNullOrBlank)
                widget.titleSpacing.verticalSpace,
              Focus(
                focusNode: _focusNode,
                child: Container(
                  height: effectiveHeight,
                  decoration: decoration,
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: contentPadding,
                    child: _buildFieldRow(
                      context,
                      control: control,
                      valueText: displayText,
                      hintText: widget.hintText,
                      textStyle: baseTextStyle.copyWith(color: inputTextColor),
                      hintStyle: hintStyle,
                      suffix: suffixWidget,
                    ),
                  ),
                ),
              ),
              if (shouldShowErrorText &&
                  errorText != null &&
                  errorText.trim().isNotEmpty) ...[
                AppSpacing.xs.verticalSpace,
                Text(
                  errorText,
                  style:
                      (widget.style.validationTextStyle ??
                              AppTextStyles.s11w500)
                          .copyWith(color: AppColors.error),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Color? _resolveBorderColor(
    BuildContext context, {
    required bool shouldShowError,
  }) {
    if (!widget.decoration.borderEnabled) return null;

    final colors = widget.decoration.borderColors;

    // If there's a validation error, force the error border.
    if (shouldShowError) {
      return colors?.error ?? AppColors.error;
    }

    // If disabled, render a muted border.
    if (!widget.enabled) {
      return colors?.disabled ?? context.grey.withValues(alpha: 0.6);
    }

    // If focused, show a focused border.
    if (_focusNode.hasFocus) {
      return colors?.focused ?? context.primary;
    }

    // Default border.
    return colors?.enabled ?? context.grey;
  }

  Widget _buildFieldRow(
    BuildContext context, {
    required AbstractControl<dynamic> control,
    required String valueText,
    required String? hintText,
    required TextStyle textStyle,
    required TextStyle? hintStyle,
    required Widget? suffix,
  }) {
    final textAlign = Directionality.of(context) == ui.TextDirection.rtl
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Row(
      children: <Widget>[
        if (widget.affixes.prefixIcon != null)
          _TapArea(
            onTap: widget.affixes.onPrefixTap,
            child: widget.affixes.prefixIcon!.build(
              context,
              color: textStyle.color ?? context.onSurface,
              size: 20,
            ),
          ),
        if (widget.affixes.prefixIcon != null) AppSpacing.sm.horizontalSpace,
        Expanded(
          child: _TapArea(
            onTap: widget.enabled ? () => _onTap(context, control) : null,
            child: Align(
              alignment: textAlign,
              child: _DateTimeFieldValueText(
                text: valueText,
                hintText: hintText,
                textStyle: textStyle,
                hintStyle: hintStyle,
              ),
            ),
          ),
        ),
        if (suffix != null) ...[AppSpacing.sm.horizontalSpace, suffix],
      ],
    );
  }

  Future<void> _onTap(
    BuildContext context,
    AbstractControl<dynamic> control,
  ) async {
    if (widget._type == AppReactiveDateTimeFieldType.dateRange) {
      return _onTapDateRange(control);
    }

    // Request focus so the UI can show the focused border while the picker is open.
    _focusNode.requestFocus();

    // Mark as touched so validation can show after the user interacts.
    control.markAsTouched();

    // Resolve an initial date for the picker UI.
    final (current, hasValue) = _resolveControlDateTime(control);
    final now = DateTime.now();
    final initial = hasValue ? current! : now;

    // Capture any context-derived values before awaiting.
    final locale = context.locale.toString();

    // If a custom picker is provided, use it and skip built-in logic.
    final pickerOverride = widget.pickerOverride;
    final Future<DateTime?> pickFuture = pickerOverride != null
        ? pickerOverride.call(context, initial)
        : _pickDefault(initial);

    final DateTime? picked = await pickFuture;

    if (!mounted) return;

    // If the user cancelled the picker, do nothing.
    if (picked == null) {
      // Keep the UX clean: remove focus when the interaction is cancelled.
      _focusNode.unfocus();
      return;
    }

    // Mark dirty because the user changed the value via the picker.
    control.markAsDirty();

    // Update the control value depending on the declared control type.
    _writeValue(control, picked);

    // Emit the selection payload.
    final iso = picked.toIso8601String();
    final formatter =
        widget.formatter ?? (d, {locale = 'en_US'}) => d.toYmd(locale: locale);
    final display = formatter(picked, locale: locale);
    widget.onSelected?.call(
      AppReactiveDateTimeFieldSelection(
        displayText: display,
        type: widget._type,
        dateTime: picked,
        isoString: iso,
      ),
    );

    // Selection finished successfully.
    _focusNode.unfocus();
  }

  Future<void> _onTapDateRange(AbstractControl<dynamic> control) async {
    _focusNode.requestFocus();
    control.markAsTouched();

    final now = DateTime.now();
    final (existingRange, hasValue) = _resolveControlDateRange(control);
    final initial = hasValue && existingRange != null
        ? existingRange
        : DateTimeRange(start: now, end: now);

    final picked = await _pickDateRange(initial);
    if (!mounted) return;

    if (picked == null) {
      _focusNode.unfocus();
      return;
    }

    if (!widget.acceptSameDay && picked.start.isSameDay(picked.end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date range of at least 2 days.'),
        ),
      );
      _focusNode.unfocus();
      return;
    }

    control.markAsDirty();
    _writeRangeValue(control, picked);

    final locale = context.locale.toString();
    final display = (widget.rangeTextBuilder ?? _defaultDateRangeTextBuilder)
        .call(picked.start, picked.end, locale: locale);

    final fromIso = picked.start.toIso8601String();
    final toIso = picked.end.toIso8601String();
    final isoJson = jsonEncode(<String, String>{'from': fromIso, 'to': toIso});

    widget.onSelected?.call(
      AppReactiveDateTimeFieldSelection(
        dateTime: picked.start,
        displayText: display,
        type: widget._type,
        from: picked.start,
        to: picked.end,
        fromIsoString: fromIso,
        toIsoString: toIso,
        isoString: isoJson,
        range: picked,
      ),
    );

    _focusNode.unfocus();
  }
}
