import '../helpers/app_strings.dart';

/// Localization helpers for [int] values that represent calendar parts.
extension AppIntMonthNameExtensions on int {
  /// Returns the localized short month name for the month index (1..12).
  ///
  /// Example: `9.monthNameShort` -> `AppStrings.sep`.
  String get monthNameShort {
    return switch (this) {
      DateTime.january => AppStrings.jan,
      DateTime.february => AppStrings.feb,
      3 => AppStrings.mar,
      4 => AppStrings.apr,
      5 => AppStrings.may,
      6 => AppStrings.jun,
      7 => AppStrings.jul,
      8 => AppStrings.aug,
      9 => AppStrings.sep,
      10 => AppStrings.oct,
      11 => AppStrings.nov,
      12 => AppStrings.dec,
      _ => '',
    };
  }

  /// Returns the localized full month name for the month index (1..12).
  ///
  /// Example: `12.monthNameFull` -> `AppStrings.december`.
  String get monthNameFull {
    return switch (this) {
      DateTime.january => AppStrings.january,
      2 => AppStrings.february,
      3 => AppStrings.march,
      4 => AppStrings.april,
      5 => AppStrings.may,
      6 => AppStrings.june,
      7 => AppStrings.july,
      8 => AppStrings.august,
      9 => AppStrings.september,
      10 => AppStrings.october,
      11 => AppStrings.november,
      12 => AppStrings.december,
      _ => '',
    };
  }
}

extension AppIntWeekdayNameExtensions on int {
  /// Returns the localized short weekday name for the weekday index.
  ///
  /// Supports [DateTime.weekday] (1..7 where 1 is Monday).
  /// Example: `DateTime.now().weekday.weekdayNameShort` -> `AppStrings.mon`.
  String get weekdayNameShort {
    return switch (this) {
      DateTime.monday => AppStrings.mon,
      DateTime.tuesday => AppStrings.tue,
      DateTime.wednesday => AppStrings.wed,
      DateTime.thursday => AppStrings.thu,
      DateTime.friday => AppStrings.fri,
      DateTime.saturday => AppStrings.sat,
      7 => AppStrings.sun,
      _ => '',
    };
  }

  /// Returns the localized full weekday name for the weekday index.
  ///
  /// Supports [DateTime.weekday] (1..7 where 1 is Monday).
  /// Example: `1.weekdayNameFull` -> `AppStrings.monday`.
  String get weekdayNameFull {
    return switch (this) {
      DateTime.monday => AppStrings.monday,
      2 => AppStrings.tuesday,
      3 => AppStrings.wednesday,
      4 => AppStrings.thursday,
      5 => AppStrings.friday,
      6 => AppStrings.saturday,
      7 => AppStrings.sunday,
      _ => '',
    };
  }
}
