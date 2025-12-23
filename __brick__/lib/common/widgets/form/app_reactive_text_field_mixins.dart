part of 'app_reactive_text_field.dart';

mixin _AppReactiveTextFieldDebounceMixin on State<AppReactiveTextField> {
  Timer? _debounce;

  void scheduleDebounced(String value) {
    if (widget.onChangedDebounced == null) return;
    _debounce?.cancel();
    _debounce = Timer(widget.onChangedDebounceDuration, () {
      widget.onChangedDebounced?.call(value);
    });
  }

  @mustCallSuper
  void disposeDebounce() {
    _debounce?.cancel();
  }
}

mixin _AppReactiveTextFieldHelpersMixin on State<AppReactiveTextField> {
  TextDirection effectiveTextDirection(BuildContext context) {
    return switch (widget.textDirectionMode) {
      AppFieldTextDirectionMode.locale =>
        context.isRtl ? TextDirection.rtl : TextDirection.ltr,
      AppFieldTextDirectionMode.ltr => TextDirection.ltr,
      AppFieldTextDirectionMode.rtl => TextDirection.rtl,
    };
  }

  TextInputType? keyboardType(_AppReactiveTextFieldType type) {
    return switch (type) {
      _AppReactiveTextFieldType.email => TextInputType.emailAddress,
      _AppReactiveTextFieldType.password => TextInputType.visiblePassword,
      _AppReactiveTextFieldType.decimal =>
        const TextInputType.numberWithOptions(decimal: true, signed: true),
      _AppReactiveTextFieldType.integer =>
        const TextInputType.numberWithOptions(signed: true),
      _AppReactiveTextFieldType.phone => TextInputType.phone,
      _ => TextInputType.text,
    };
  }

  List<TextInputFormatter>? inputFormatters(_AppReactiveTextFieldType type) {
    return switch (type) {
      _AppReactiveTextFieldType.decimal => <TextInputFormatter>[
        AppNumericTextFormatter(
          allowDecimal: true,
          allowNegative: widget.allowNegative,
        ),
      ],
      _AppReactiveTextFieldType.integer => <TextInputFormatter>[
        AppNumericTextFormatter(allowNegative: widget.allowNegative),
      ],
      _AppReactiveTextFieldType.stringOnly => const <TextInputFormatter>[
        AppStringOnlyFormatter(),
      ],
      _ => null,
    };
  }

  String normalizeNumericText(_AppReactiveTextFieldType type, String input) {
    if (!widget.removeTrailingDotZero) return input;
    if (type != _AppReactiveTextFieldType.decimal) return input;
    if (input.endsWith('.0')) {
      return input.substring(0, input.length - 2);
    }
    return input;
  }
}
