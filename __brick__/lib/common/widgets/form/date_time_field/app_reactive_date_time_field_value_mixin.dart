part of 'app_reactive_date_time_field.dart';

mixin _AppReactiveDateTimeFieldValueMixin on State<AppReactiveDateTimeField> {
  // Returns: (resolved DateTime?, hasValue)
  (DateTime?, bool) _resolveControlDateTime(AbstractControl<dynamic> control) {
    // Detect the control type using runtime type checks.
    if (control is FormControl<DateTime>) {
      final dt = control.value;
      return (dt, dt != null);
    }

    if (control is FormControl<String>) {
      final raw = control.value;
      final dt = raw.isNullOrBlank ? null : raw!.toLocalDateTimeOrNull();
      return (dt, dt != null);
    }

    // Unsupported control type.
    return (null, false);
  }

  // Returns: (resolved DateTimeRange?, hasValue)
  (DateTimeRange?, bool) _resolveControlDateRange(
    AbstractControl<dynamic> control,
  ) {
    if (control is FormControl<DateTimeRange>) {
      final range = control.value;
      return (range, range != null);
    }

    if (control is FormControl<String>) {
      final raw = control.value;
      final range = raw.isNullOrBlank ? null : _tryParseIsoRangeJson(raw!);
      return (range, range != null);
    }

    return (null, false);
  }

  (bool, String) _resolveDisplayText(
    AbstractControl<dynamic> control, {
    required String locale,
  }) {
    if (widget._type == AppReactiveDateTimeFieldType.dateRange) {
      final (range, hasValue) = _resolveControlDateRange(control);
      if (!hasValue || range == null) return (false, '');

      final from = range.start;
      final to = range.end;
      final builder = widget.rangeTextBuilder ?? _defaultDateRangeTextBuilder;
      return (true, builder(from, to, locale: locale));
    }

    final (dt, hasValue) = _resolveControlDateTime(control);
    if (!hasValue || dt == null) return (false, '');

    // If the caller didn't provide a formatter, we fall back to the DateTime
    // extension directly (widgets should not depend on AppDateTimeFormatters).
    final formatter =
        widget.formatter ?? (d, {locale = 'en_US'}) => d.toYmd(locale: locale);
    return (true, formatter(dt, locale: locale));
  }

  String _defaultDateRangeTextBuilder(
    DateTime from,
    DateTime to, {
    String locale = 'en_US',
  }) {
    final fromLabel = AppStrings.from.toLowerCase();
    final toLabel = AppStrings.to.toLowerCase();
    return '$fromLabel ( ${from.toYmd(locale: locale)} ) '
        '$toLabel ( ${to.toYmd(locale: locale)} )';
  }

  void _writeValue(AbstractControl<dynamic> control, DateTime picked) {
    // Only two supported storage types:
    // - DateTime control -> store DateTime
    // - String control -> store ISO string
    if (control is FormControl<DateTime>) {
      control.updateValue(picked);
      return;
    }

    if (control is FormControl<String>) {
      control.updateValue(picked.toIso8601String());
      return;
    }
  }

  void _writeRangeValue(AbstractControl<dynamic> control, DateTimeRange range) {
    if (control is FormControl<DateTimeRange>) {
      control.updateValue(range);
      return;
    }

    if (control is FormControl<String>) {
      control.updateValue(
        jsonEncode(<String, String>{
          'from': range.start.toIso8601String(),
          'to': range.end.toIso8601String(),
        }),
      );
      return;
    }
  }

  void _clear(AbstractControl<dynamic> control) {
    // Clear should set the reactive control value to null.
    if (control is FormControl<DateTime>) {
      control.updateValue(null);
      control.markAsDirty();
      control.markAsTouched();
      return;
    }

    if (control is FormControl<DateTimeRange>) {
      control.updateValue(null);
      control.markAsDirty();
      control.markAsTouched();
      return;
    }

    if (control is FormControl<String>) {
      control.updateValue(null);
      control.markAsDirty();
      control.markAsTouched();
      return;
    }
  }

  DateTimeRange? _tryParseIsoRangeJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final fromRaw = decoded['from'];
      final toRaw = decoded['to'];
      if (fromRaw is! String || toRaw is! String) return null;

      final from = fromRaw.toLocalDateTimeOrNull();
      final to = toRaw.toLocalDateTimeOrNull();
      if (from == null || to == null) return null;

      return DateTimeRange(start: from, end: to);
    } catch (_) {
      return null;
    }
  }
}
