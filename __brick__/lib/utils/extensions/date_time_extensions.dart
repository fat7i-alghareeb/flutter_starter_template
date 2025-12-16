import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formatting utilities for [DateTime] values.
///
/// These helpers focus on converting [DateTime] instances into
/// human-readable strings using common patterns.
extension DateTimeFormattingExtensions on DateTime {
  /// Formats this date/time using a custom ICU [pattern] and [locale].
  ///
  /// Example:
  /// `now.formatDateTime('yyyy-MM-dd HH:mm', locale: 'en_US');`
  String formatDateTime(String pattern, {String locale = 'en_US'}) {
    return DateFormat(pattern, locale).format(this);
  }

  /// Format as `yyyy-MM-dd`.
  ///
  /// Example: `DateTime(2025, 9, 22).toYmd()` → `'2025-09-22'`.
  String toYmd({String locale = 'en_US'}) =>
      formatDateTime('yyyy-MM-dd', locale: locale);

  /// Format as `EEE d, MMM yyyy` (e.g. `Mon 22, Sep 2025`).
  String toWeekdayDayMonthYear({String locale = 'en_US'}) =>
      formatDateTime('EEE d, MMM yyyy', locale: locale);

  /// Format as `d-M-yyyy` (e.g. `22-9-2025`).
  String toDayMonthYearDash({String locale = 'en_US'}) =>
      formatDateTime('d-M-yyyy', locale: locale);

  /// 24-hour time `HH:mm`.
  String toTime24({String locale = 'en_US'}) =>
      formatDateTime('HH:mm', locale: locale);

  /// 12-hour time `hh:mm a`.
  String toTime12({String locale = 'en_US'}) =>
      formatDateTime('hh:mm a', locale: locale);

  /// Smart date/time similar to the old `timeWithSmartDate` helper.
  ///
  /// If the year matches `DateTime.now().year`, uses
  /// `MMM d, h:mm a`, otherwise `MMM d, y, h:mm a`. Output is
  /// lowercased for a chat-style look.
  String toSmartDateTime({String locale = 'en_US'}) {
    final now = DateTime.now();
    final sameYear = year == now.year;
    final pattern = sameYear ? 'MMM d, h:mm a' : 'MMM d, y, h:mm a';
    return formatDateTime(pattern, locale: locale).toLowerCase();
  }

  /// Formats a time range between this and [endTime].
  ///
  /// If [isLtr] is `true`, returns `"start - end"`, otherwise
  /// `"end - start"`.
  String formatTimeRange(
    DateTime endTime, {
    bool isLtr = true,
    bool is24 = false,
    String locale = 'en_US',
  }) {
    final format = is24 ? DateFormat('HH:mm', locale) : DateFormat.jm(locale);
    final startStr = format.format(this);
    final endStr = format.format(endTime);
    return isLtr ? '$startStr - $endStr' : '$endStr - $startStr';
  }
}

/// Calendar utilities for [DateTime] values.
///
/// These helpers focus on comparing and adjusting dates, without
/// producing ISO strings.
extension DateTimeCalendarExtensions on DateTime {
  /// Returns `true` if this and [other] fall on the same calendar day.
  ///
  /// Example:
  /// `DateTime(2025, 9, 22).isSameDay(DateTime(2025, 9, 22, 23))` → `true`.
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// `true` if this date is on the same day as `DateTime.now()`.
  bool get isToday => isSameDay(DateTime.now());

  /// `true` if this date is exactly one day before `DateTime.now()`.
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// `true` if this date is exactly one day after `DateTime.now()`.
  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));

  /// Midnight at the start of the same calendar day.
  /// Example: `2025-09-22 10:37` → `2025-09-22 00:00`.
  DateTime get startOfDay => DateTime(year, month, day);

  /// Last millisecond of the same calendar day.
  /// Example: `2025-09-22 10:37` → `2025-09-22 23:59:59.999`.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns a copy of this [DateTime] with selected fields replaced.
  ///
  /// Example:
  /// `now.copyWith(hour: 0, minute: 0)`.
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  /// Adds [days] to this [DateTime].
  /// Example: `now.addDays(7)`.
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtracts [days] from this [DateTime].
  /// Example: `now.subtractDays(1)`.
  DateTime subtractDays(int days) => subtract(Duration(days: days));
}

/// Safe parsing helpers for ISO-8601 date-time strings.
extension DateTimeParsingExtensions on String {
  /// Parses this ISO‑8601 string into a [DateTime], or returns `null`
  /// if parsing fails.
  ///
  /// Example:
  /// `'2025-09-22T07:37:39.849Z'.toDateTimeOrNull()`.
  DateTime? toDateTimeOrNull() {
    try {
      return DateTime.parse(this);
    } catch (_) {
      return null;
    }
  }

  /// Parses this string and converts it to UTC, or returns `null` if
  /// parsing fails.
  ///
  /// Example:
  /// `'2025-09-22T10:37:00'.toUtcDateTimeOrNull()`.
  DateTime? toUtcDateTimeOrNull() => toDateTimeOrNull()?.toUtc();

  /// Parses this string and converts it to local time, or returns
  /// `null` if parsing fails.
  ///
  /// Example:
  /// `'2025-09-22T07:37:39.849Z'.toLocalDateTimeOrNull()`.
  DateTime? toLocalDateTimeOrNull() => toDateTimeOrNull()?.toLocal();
}

/// Convenience helpers for [DateTimeRange].
extension DateTimeRangeExtensions on DateTimeRange {
  /// `true` if [start] and [end] lie on the same calendar day.
  ///
  /// Example:
  /// `DateTimeRange(start: d1, end: d1.add(Duration(hours: 2))).isSingleDay`.
  bool get isSingleDay => start.isSameDay(end);

  /// Formats the range as `yyyy-MM-dd{separator}yyyy-MM-dd` using
  /// [DateTimeFormattingExtensions.toYmd].
  ///
  /// Example:
  /// ```dart
  /// final range = DateTimeRange(
  ///   start: DateTime(2025, 9, 22),
  ///   end: DateTime(2025, 9, 25),
  /// );
  /// range.formatYmdRange();          // '2025-09-22 / 2025-09-25'
  /// range.formatYmdRange(separator: ' - ');
  /// // '2025-09-22 - 2025-09-25'
  /// ```
  String formatYmdRange({String separator = ' / '}) {
    return '${start.toYmd()}$separator${end.toYmd()}';
  }
}

/// Human-friendly formatting helpers for ISO-8601 date/time [String] values.
extension IsoDateStringFormatting on String {
  DateTime? _parseIsoToLocal() => toLocalDateTimeOrNull();

  /// Formats this ISO string using a custom ICU [pattern].
  ///
  /// Example:
  /// `'2025-09-22T07:37:39.849Z'.isoFormat('EEE d, MMM yyyy')`.
  String isoFormat(String pattern, {String locale = 'en_US'}) {
    final dt = _parseIsoToLocal();
    if (dt == null) return this;
    return DateFormat(pattern, locale).format(dt);
  }

  /// Equivalent of the old `fullDate` helper.
  ///
  /// Example input (UTC+3):
  /// `'2025-09-22T07:37:39.849Z'.isoFullDate()`
  /// → `'(10:37AM) 2025-09-22'`.
  String isoFullDate({String locale = 'en_US'}) {
    final dt = _parseIsoToLocal();
    if (dt == null) return this;
    final date = DateFormat('yyyy-MM-dd', locale).format(dt);
    final time = DateFormat('hh:mm', locale).format(dt);
    final status = DateFormat('a', locale).format(dt);
    return '($time$status) $date';
  }

  /// Short date like `Mon 22, Sep 2025`.
  String isoDatePretty({String locale = 'en_US'}) {
    final dt = _parseIsoToLocal();
    if (dt == null) return this;
    return DateFormat('EEE d, MMM yyyy', locale).format(dt);
  }

  /// 24-hour time `HH:mm`.
  String isoTime24({String locale = 'en_US'}) {
    final dt = _parseIsoToLocal();
    if (dt == null) return this;
    return DateFormat('HH:mm', locale).format(dt);
  }

  /// Smart date/time similar to the old `timeWithSmartDate`.
  ///
  /// Example outputs:
  /// - `'sep 22, 10:37 am'`
  /// - `'sep 22, 2024, 10:37 am'`
  String isoSmartDateTime({String locale = 'en_US'}) {
    final dt = _parseIsoToLocal();
    if (dt == null) return this;
    final now = DateTime.now();
    final sameYear = dt.year == now.year;
    final pattern = sameYear ? 'MMM d, h:mm a' : 'MMM d, y, h:mm a';
    return DateFormat(pattern, locale).format(dt).toLowerCase();
  }

  /// Day-month-year with dashes, e.g. `'22-9-2025'`.
  String isoDayMonthYearDash({String locale = 'en_US'}) {
    final dt = _parseIsoToLocal();
    if (dt == null) return this;
    return DateFormat('d-M-yyyy', locale).format(dt);
  }
}
