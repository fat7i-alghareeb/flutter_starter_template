# AppReactiveDateTimeField

This folder contains `AppReactiveDateTimeField`, a high-performance reactive form field for selecting date/time values.

## Storage types (important)

`AppReactiveDateTimeField` infers the **control value type** from the `formControlName` at runtime.

Supported storage:

- `FormControl<DateTime>`
  - Stores the selected `DateTime` object.

- `FormControl<String>`
  - Stores the selected value as ISO-8601 string via `DateTime.toIso8601String()`.

- `FormControl<DateTimeRange>` (date-range mode only)
  - Stores a `DateTimeRange(start: from, end: to)`.

- `FormControl<String>` (date-range mode only)
  - Stores a JSON string:

    ```json
    {"from":"<iso>","to":"<iso>"}
    ```

If you use a different control type, the field will not be able to read/write values.

## Available modes

### 1) Date + Time

```dart
AppReactiveDateTimeField.dateTime(
  formControlName: 'startAt',
  title: AppStrings.selectDateTime,
);
```

Default display:

`(10:37AM) 2025-09-22`

### 2) Date

```dart
AppReactiveDateTimeField.date(
  formControlName: 'birthDate',
  title: AppStrings.selectDate,
);
```

Default display:

`2025-09-22`

### 3) Year + Month

```dart
AppReactiveDateTimeField.yearMonth(
  formControlName: 'billingMonth',
  title: AppStrings.selectMonth,
);
```

Default display:

`Sep 2025`

### 4) Year only

```dart
AppReactiveDateTimeField.year(
  formControlName: 'graduationYear',
  title: AppStrings.selectYear,
);
```

Default display:

`2025`

### 5) Month + Day (current year)

```dart
AppReactiveDateTimeField.monthDay(
  formControlName: 'anniversary',
  title: AppStrings.selectDay,
);
```

Default display:

`December 21`

### 6) Month only (current year)

```dart
AppReactiveDateTimeField.month(
  formControlName: 'startMonth',
  title: AppStrings.selectMonth,
);
```

Default display:

`December`

### 7) Day only (current month)

```dart
AppReactiveDateTimeField.day(
  formControlName: 'dayInMonth',
  title: AppStrings.selectDay,
);
```

Default display:

`Mon 22`

### 8) Time only

```dart
AppReactiveDateTimeField.time(
  formControlName: 'startTime',
  title: AppStrings.selectTime,
);
```

Default display:

`10:37AM`

### 9) Date range (from–to)

```dart
AppReactiveDateTimeField.dateRange(
  formControlName: 'range',
  title: AppStrings.selectDate,
);
```

Default display:

`from 2025-09-22 to 2025-09-30`

## Selection callback payload

Use `onSelected` to receive a unified payload:

- `selection.dateTime`
  - Single modes: selected `DateTime`
  - Range mode: `from` (start)

- `selection.isoString`
  - Single modes: `dateTime.toIso8601String()`
  - Range mode: JSON `{from,to}`

For range mode you also get:

- `selection.from`, `selection.to`
- `selection.fromIsoString`, `selection.toIsoString`
- `selection.range`

## Formatting

### Override the formatter inline

All single-value modes accept `formatter`:

```dart
AppReactiveDateTimeField.date(
  formControlName: 'birthDate',
  formatter: (dt, {locale = 'en_US'}) => dt.formatDateTime('dd/MM/yyyy', locale: locale),
);
```

### Use existing DateTime extensions

The project already provides a set of formatting extensions in:

- `lib/utils/extensions/date_time_extensions.dart`

Examples:

- `dt.toYmd(locale: locale)`
- `dt.toTime12Compact(locale: locale)`
- `dt.toMonthYearShort(locale: locale)`

### Adding a new formatter

You have 2 options:

1) **Inline** (recommended for one-off cases)

```dart
formatter: (dt, {locale = 'en_US'}) => dt.formatDateTime('EEE, dd MMM', locale: locale)
```

1) **Add a new DateTime extension** (recommended if reused)

Add a method to `DateTimeFormattingExtensions` in `date_time_extensions.dart` and call it from your field `formatter`.

## Notes

- Range mode uses `showDateRangePicker`.
- The widget uses the current app locale via `context.locale` when building display text.
