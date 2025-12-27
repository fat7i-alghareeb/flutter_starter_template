part of 'app_reactive_date_time_field.dart';

typedef AppReactiveDateTimeFieldPicker =
    Future<DateTime?> Function(BuildContext context, DateTime initialDate);

typedef AppReactiveDateTimeFieldRangeTextBuilder =
    String Function(DateTime from, DateTime to, {String locale});

typedef AppReactiveDateTimeFieldSelectedCallback =
    void Function(AppReactiveDateTimeFieldSelection selection);

/// Defines which kind of selection UI this field uses.
enum AppReactiveDateTimeFieldType {
  /// Select year, month, day, and time.
  dateTime,

  /// Select year, month, and day.
  date,

  /// Select year and month (day is fixed to 1 internally).
  yearMonth,

  /// Select year only (month/day are fixed to 1 internally).
  year,

  /// Select month and day in the current year.
  monthDay,

  /// Select month in the current year (day is fixed to 1 internally).
  month,

  /// Select day in the current month (year/month come from now).
  day,

  /// Select time only (year/month/day come from now).
  time,

  /// Select a date range (from–to).
  dateRange,
}

/// The unified selection payload returned by [AppReactiveDateTimeField].
class AppReactiveDateTimeFieldSelection {
  const AppReactiveDateTimeFieldSelection({
    required this.dateTime,
    required this.isoString,
    required this.displayText,
    required this.type,
    this.from,
    this.to,
    this.fromIsoString,
    this.toIsoString,
    this.range,
  });

  /// For single-value modes, this is the selected date/time.
  ///
  /// For date-range mode, this is the start value (same as [from]).
  final DateTime dateTime;

  /// For single-value modes, this is `dateTime.toIso8601String()`.
  ///
  /// For date-range mode, this is a JSON string with ISO values:
  /// `{"from":"...","to":"..."}`.
  final String isoString;

  /// For date-range mode, the start date.
  final DateTime? from;

  /// For date-range mode, the end date.
  final DateTime? to;

  /// For date-range mode, `from.toIso8601String()`.
  final String? fromIsoString;

  /// For date-range mode, `to.toIso8601String()`.
  final String? toIsoString;

  /// For date-range mode, the full range.
  final DateTimeRange? range;

  final String displayText;
  final AppReactiveDateTimeFieldType type;
}
