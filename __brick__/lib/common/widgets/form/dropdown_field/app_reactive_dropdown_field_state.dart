part of 'app_reactive_dropdown_field.dart';

/// State class for [AppReactiveDropdownField].
///
/// This class handles the internal state and behavior of the dropdown field,
/// including focus management, overlay positioning, and validation.
class _AppReactiveDropdownFieldState<T>
    extends State<AppReactiveDropdownField<T>> {
  /// Error key used when [AppReactiveDropdownField.onSelectReturn] rejects a
  /// selection by returning a non-null message.
  ///
  /// This key is resolved through [AppReactiveValidationMessages.defaults].
  static const String _errorKey =
      AppReactiveValidationMessages.customMessageKey;

  /// Focus is used only for styling purposes (focused border) and to emulate the
  /// UX of other form widgets where the field becomes “active” after tapping.
  late final FocusNode _focusNode;

  /// Used to locate the field's render box for overlay positioning in
  /// [AppReactiveDropdownPresentation.menu].
  final GlobalKey _fieldKey = GlobalKey();

  /// Overlay entry used only for `menu` presentation.
  OverlayEntry? _overlay;

  /// Effective options list.
  ///
  /// This is copied from [widget.options] so we can inject a missing option when
  /// the control contains a value that is not present in the list.
  late List<AppDropdownOption<T>> _options;

  /// Currently selected option (used for display).
  AppDropdownOption<T>? _selected;

  /// When `true`, the UI keeps displaying [_selected] even if the form control
  /// value becomes `null`.
  ///
  /// This is required for the `onSelectReturn` behavior:
  /// - user selects an option
  /// - callback rejects it
  /// - control is set to null (validation)
  /// - but we still show the choice the user made
  bool _keepDisplayWhileControlNull = false;

  /// Search query used when [widget.enableSearch] is enabled.
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Keep the same focus-driven visual behavior used by other form fields.
    _focusNode = FocusNode()
      ..addListener(() {
        if (!mounted) return;
        setState(() {});
      });

    // Copy the incoming list so we can safely mutate it when injecting a
    // missing option.
    _options = List<AppDropdownOption<T>>.from(widget.options);
  }

  @override
  void didUpdateWidget(covariant AppReactiveDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If options list changes, refresh the effective list.
    if (oldWidget.options != widget.options) {
      _options = List<AppDropdownOption<T>>.from(widget.options);
    }
  }

  @override
  void dispose() {
    // Always remove the overlay entry to avoid memory leaks.
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    // Idempotent: safe to call even if the overlay was already removed.
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final inner = _buildWithEffectiveGroup(context);

    // Same pattern used by other form widgets:
    // - when [formGroup] is provided we self-wrap in a [ReactiveForm]
    // - otherwise assume there is a parent [ReactiveForm]
    if (widget.formGroup == null) return inner;
    return ReactiveForm(formGroup: widget.formGroup!, child: inner);
  }

  Widget _buildWithEffectiveGroup(BuildContext context) {
    // Resolve target width/height from layout configuration.
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

    // Merge default validation messages with the field overrides.
    final validationMessages = AppReactiveValidationMessages.merge(
      AppReactiveValidationMessages.defaults(),
      widget.validation.messages,
    );

    final direction = Directionality.of(context);
    final resolvedPadding = contentPadding.resolve(direction);

    // Ensure the field has a minimum height that can fit the resolved padding
    // and the text line height.
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
          // Sync internal display state from the reactive form control.
          _syncFromControl(control);

          // Validation UX is disabled if the field is disabled.
          final showValidation = widget.enabled && widget.validation.enabled;

          // Determine if we should show an error state.
          // This follows the same pattern used by other form widgets.
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

          // Colors change when the field is invalid to match the global form
          // widgets styling (red border/text).
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

          // Display text always comes from the selected option name.
          final valueText = _selected?.name ?? '';
          final hasDisplayedValue = _selected != null;

          final suffixWidget = _buildSuffix(
            control,
            hasDisplayedValue: hasDisplayedValue,
            iconColor: inputTextColor,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              titleWidget,
              if (!widget.title.isNullOrBlank)
                widget.titleSpacing.verticalSpace,
              Container(
                key: _fieldKey,
                height: effectiveHeight,
                decoration: decoration,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: contentPadding,
                  child: Row(
                    children: <Widget>[
                      if (widget.affixes.prefixIcon != null)
                        _TapArea(
                          onTap: widget.affixes.onPrefixTap,
                          child: widget.affixes.prefixIcon!.build(
                            context,
                            color: inputTextColor,
                            size: 20,
                          ),
                        ),
                      if (widget.affixes.prefixIcon != null)
                        AppSpacing.sm.horizontalSpace,
                      Expanded(
                        child: _TapArea(
                          onTap: widget.enabled ? () => _open(control) : null,
                          child: Align(
                            alignment: context.isRtl
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: _DropdownValueText(
                              text: valueText,
                              hintText:
                                  widget.hintText ?? AppStrings.selectOption,
                              textStyle: baseTextStyle.copyWith(
                                color: inputTextColor,
                              ),
                              hintStyle: hintStyle,
                            ),
                          ),
                        ),
                      ),
                      if (suffixWidget != null) ...[
                        AppSpacing.sm.horizontalSpace,
                        suffixWidget,
                      ],
                    ],
                  ),
                ),
              ),
              // Error text is shown only when:
              // - validation is enabled
              // - the control is invalid
              // - the configured showErrorsMode is satisfied
              // - and the resolved error text is non-empty.
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
    // If borders are disabled entirely, we return null so no border is painted.
    if (!widget.decoration.borderEnabled) return null;

    final colors = widget.decoration.borderColors;

    // Error state has the highest priority.
    if (shouldShowError) {
      return colors?.error ?? AppColors.error;
    }

    // Disabled state has the next priority.
    if (!widget.enabled) {
      return colors?.disabled ?? context.grey.withValues(alpha: 0.6);
    }

    // Focused state gives the “active” border.
    if (_focusNode.hasFocus) {
      return colors?.focused ?? context.primary;
    }

    // Default enabled border.
    return colors?.enabled ?? context.grey;
  }

  void _syncFromControl(AbstractControl<dynamic> control) {
    // The dropdown control value is expected to be of type `T`.
    // We keep `_selected` in sync so the UI always reflects the latest value.
    final dynamic raw = control.value;

    // If the control is null we clear the displayed selection unless we are
    // intentionally keeping it (see `_keepDisplayWhileControlNull`).
    if (raw == null) {
      if (!_keepDisplayWhileControlNull) {
        _selected = null;
      }
      return;
    }

    // Safety: if the control value isn't of type T, we can't match it against
    // the option IDs. Treat it as no-value rather than crashing on `as T`.
    if (raw is! T) {
      if (!_keepDisplayWhileControlNull) {
        _selected = null;
      }
      return;
    }

    _keepDisplayWhileControlNull = false;

    final T id = raw;

    // Try to find a matching option by id.
    final existingIndex = _options.indexWhere((o) => o.id == id);
    if (existingIndex == -1) {
      // If the form control already contains a value not present in the list,
      // inject it so:
      // - the user sees a meaningful label
      // - the field does not look empty
      final name = widget.missingOptionNameBuilder?.call(id) ?? id.toString();
      final injected = AppDropdownOption<T>(id: id, name: name);
      _options = <AppDropdownOption<T>>[..._options, injected];
      _selected = injected;
      return;
    }

    // Normal case: the value exists in the provided options.
    _selected = _options[existingIndex];
  }

  Widget? _buildSuffix(
    AbstractControl<dynamic> control, {
    required bool hasDisplayedValue,
    required Color iconColor,
  }) {
    // Clear button is shown only when:
    // - field is enabled
    // - allowClear is enabled
    // - and there is a displayed value.
    final showClear = widget.enabled && widget.allowClear && hasDisplayedValue;

    // When clear is shown we clear the value.
    // Otherwise, tapping the arrow opens the picker.
    final child = showClear
        ? _TapArea(onTap: () => _clear(control), child: const _ClearIcon())
        : _TapArea(onTap: () => _open(control), child: const _ArrowIcon());

    return AnimatedSwitcher(
      duration: AppDurations.fast,
      child: KeyedSubtree(key: ValueKey<bool>(showClear), child: child),
    );
  }

  void _clear(AbstractControl<dynamic> control) {
    // When the user clears manually, we also stop the special
    // “keep displaying selection while control is null” behavior.
    _keepDisplayWhileControlNull = false;
    _selected = null;
    _searchQuery = '';

    // If the field had a custom message from onSelectReturn, remove it.
    if (control.hasError(_errorKey)) {
      control.removeError(_errorKey);
    }

    // Clear the control value and mark it as interacted with.
    control.updateValue(null);
    control.markAsDirty();
    control.markAsTouched();
    control.updateValueAndValidity();

    setState(() {});
  }

  Future<void> _open(AbstractControl<dynamic> control) async {
    // Trigger focus to show focused border and match other field UX.
    _focusNode.requestFocus();
    // Mark as touched so validation showErrorsMode.touched can take effect.
    control.markAsTouched();

    // Route the presentation based on the preset.
    return switch (widget.presentation) {
      AppReactiveDropdownPresentation.menu => _openMenu(control),
      AppReactiveDropdownPresentation.dialog => _openDialog(control),
      AppReactiveDropdownPresentation.bottomSheet => _openBottomSheet(control),
    };
  }

  List<AppDropdownOption<T>> _filteredOptions() {
    // Filter is case-insensitive and based on option name.
    final q = _searchQuery.trim().toLowerCase();
    // If search is disabled or query is empty, return all options.
    if (!widget.enableSearch || q.isEmpty) return _options;
    return _options
        .where((o) => o.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  Future<void> _openDialog(AbstractControl<dynamic> control) async {
    // Reset search every time the picker is opened.
    _searchQuery = '';

    await AppDialog.show<void>(
      context,
      dialog: AppDialog.basic(
        title: widget.title ?? AppStrings.selectOption,
        secondaryAction: AppDialogAction.secondary(
          label: AppStrings.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        child: _buildPickerBody(control, inDialog: true),
      ),
    );

    // Ensure the field no longer appears focused after closing.
    _focusNode.unfocus();
  }

  Future<void> _openBottomSheet(AbstractControl<dynamic> control) async {
    // Reset search every time the picker is opened.
    _searchQuery = '';

    await AppBottomSheet.show<void>(
      context,
      sheet: AppBottomSheet.basic(
        title: widget.title ?? AppStrings.selectOption,
        child: _buildPickerBody(control, inDialog: false),
      ),
    );

    // Ensure the field no longer appears focused after closing.
    _focusNode.unfocus();
  }

  Future<void> _openMenu(AbstractControl<dynamic> control) async {
    // Only one overlay at a time.
    if (_overlay != null) return;
    // Reset search for each open.
    _searchQuery = '';

    // We locate the field and overlay render boxes to position the menu.
    final renderObject = _fieldKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;

    final overlayBox = Overlay.of(context).context.findRenderObject();
    if (overlayBox is! RenderBox) return;

    final fieldOffset = renderObject.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final fieldSize = renderObject.size;

    final media = MediaQuery.of(context);
    final screen = overlayBox.size;

    // Basic positioning rules:
    // - cap menu height
    // - try to show below the field when there is enough space
    final maxHeight = (screen.height * 0.5).clamp(240.0, 420.0);
    final availableBelow = screen.height - (fieldOffset.dy + fieldSize.height);
    final showBelow = availableBelow >= 220;

    // If not enough space below, show above.
    final double top = showBelow
        ? fieldOffset.dy + fieldSize.height
        : (fieldOffset.dy - maxHeight).clamp(0.0, screen.height - maxHeight);

    final double left = fieldOffset.dx;
    final double width = fieldSize.width;

    _overlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Tap outside closes the menu.
                  _removeOverlay();
                  _focusNode.unfocus();
                  setState(() {});
                },
                child: const SizedBox.shrink(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: width,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadii.sm.r),
                      border: Border.all(
                        color: context.grey.withValues(alpha: 0.35),
                      ),
                      boxShadow: context.shadows.grey,
                    ),
                    padding: EdgeInsets.all(AppSpacing.sm.r),
                    child: _buildPickerBody(control, inDialog: false),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    // Insert overlay into the app overlay.
    Overlay.of(context).insert(_overlay!);
    setState(() {});

    // Keep the pattern consistent with other fields where unawaited async tasks
    // might be scheduled after opening.
    unawaited(
      Future<void>.delayed(
        media.accessibleNavigation ? const Duration() : const Duration(),
      ),
    );
  }

  Widget _buildPickerBody(
    AbstractControl<dynamic> control, {
    required bool inDialog,
  }) {
    // Effective list after applying search filtering.
    final options = _filteredOptions();

    // Search widget is optional and only shown when enableSearch is true.
    final searchField = widget.enableSearch
        ? Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
            child: TextField(
              onChanged: (v) {
                // Update query and re-filter in real time.
                setState(() {
                  _searchQuery = v;
                });
              },
              decoration: InputDecoration(
                isDense: true,
                hintText: AppStrings.search,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w,
                  vertical: AppSpacing.sm.h,
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.enableSearch) searchField,
        Flexible(
          child: options.isEmpty
              // Empty state when search yields no results (or options list is empty).
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg.h),
                  child: Text(
                    AppStrings.noResultsFound,
                    style: AppTextStyles.s14w400.copyWith(
                      color: context.grey.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: AppSpacing.xs.h),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    // Selection is determined by matching ids.
                    final isSelected = _selected?.id == option.id;
                    return _buildOptionTile(
                      control,
                      option: option,
                      isSelected: isSelected,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    AbstractControl<dynamic> control, {
    required AppDropdownOption<T> option,
    required bool isSelected,
  }) {
    // Disabled options are not selectable and appear grey.
    final enabled = option.enable;

    // Selected option gets a subtle background + primary colored border.
    final bg = isSelected
        ? context.primary.withValues(alpha: 0.12)
        : Colors.transparent;

    final borderColor = isSelected
        ? context.primary
        : context.grey.withValues(alpha: 0.25);

    // Text color changes based on state.
    final color = !enabled
        ? context.grey.withValues(alpha: 0.7)
        : (isSelected ? context.primary : context.onSurface);

    final textStyle = (widget.optionsTextStyle ?? AppTextStyles.s14w400)
        .copyWith(color: color);

    return _TapArea(
      onTap: enabled
          ? () async {
              // Only handle selection when the option is enabled.
              await _handleSelect(control, option);
            }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm.w,
          vertical: AppSpacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.sm.r),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          option.name,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _handleSelect(
    AbstractControl<dynamic> control,
    AppDropdownOption<T> option,
  ) async {
    // Always update UI selection immediately.
    // If onSelectReturn rejects, we still keep this displayed.
    _selected = option;

    // Notify consumer of the tapped option.
    widget.onSelected?.call(option);

    // Allow consumer to reject the selection (advanced conditional validation).
    final errorText = widget.onSelectReturn?.call(option);

    if (errorText != null) {
      // Reject case:
      // - keep the displayed option
      // - but set control value to null
      // - and set a custom validation error message.
      _keepDisplayWhileControlNull = true;

      // Merge with existing errors map so we don't clobber other validators.
      final current = Map<String, dynamic>.from(control.errors);
      current[_errorKey] = errorText;
      control.setErrors(current);

      // Null out the control value (the selection is not accepted).
      control.updateValue(null);
      control.markAsDirty();
      control.markAsTouched();
      control.updateValueAndValidity();

      _removeOverlay();
      // Only close route-based pickers.
      // The menu overlay is not a route, and popping would pop the page.
      if (widget.presentation != AppReactiveDropdownPresentation.menu &&
          Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      setState(() {});
      return;
    }

    // Accept case: user selection is valid.
    _keepDisplayWhileControlNull = false;

    // Clear previously set custom message (if any).
    if (control.hasError(_errorKey)) {
      control.removeError(_errorKey);
    }

    // Persist selection into the reactive form control.
    control.updateValue(option.id);
    control.markAsDirty();
    control.markAsTouched();
    control.updateValueAndValidity();

    _removeOverlay();
    // Close route-based pickers only.
    if (widget.presentation != AppReactiveDropdownPresentation.menu &&
        Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    setState(() {});
  }
}
