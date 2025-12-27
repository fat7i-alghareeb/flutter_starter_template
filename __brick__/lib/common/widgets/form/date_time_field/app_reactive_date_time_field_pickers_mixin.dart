part of 'app_reactive_date_time_field.dart';

mixin _AppReactiveDateTimeFieldPickersMixin on State<AppReactiveDateTimeField> {
  // NOTE:
  // All picker UI logic is isolated in this mixin to keep the main state file
  // focused on building the widget tree, validation UI, and control wiring.

  Future<DateTime?> _pickDefault(DateTime initial) {
    return switch (widget._type) {
      AppReactiveDateTimeFieldType.dateTime => _pickDateTime(initial),
      AppReactiveDateTimeFieldType.date => _pickDate(initial),
      AppReactiveDateTimeFieldType.yearMonth => _pickYearMonth(initial),
      AppReactiveDateTimeFieldType.year => _pickYear(initial),
      AppReactiveDateTimeFieldType.monthDay => _pickMonthDayCurrentYear(
        initial,
      ),
      AppReactiveDateTimeFieldType.month => _pickMonthCurrentYear(initial),
      AppReactiveDateTimeFieldType.day => _pickDayCurrentMonth(initial),
      AppReactiveDateTimeFieldType.time => _pickTime(initial),
      AppReactiveDateTimeFieldType.dateRange => throw StateError(
        'Use _pickDateRange for AppReactiveDateTimeFieldType.dateRange',
      ),
    };
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    // Select year/month/day.
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    // Step 1: pick date.
    final date = await _pickDate(initial);
    if (date == null) return null;

    // Step 2: pick time.
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;

    // Combine date + time into a single DateTime.
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<DateTime?> _pickTime(DateTime initial) async {
    // Select time (hour/minute). Date part is filled from today's date.
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  Future<DateTime?> _pickMonthDayCurrentYear(DateTime initial) {
    // Select month/day in the current year by restricting the allowed range.
    final year = DateTime.now().year;
    final safeDay = _clampDay(
      year: year,
      month: initial.month,
      day: initial.day,
    );

    return showDatePicker(
      context: context,
      initialDate: DateTime(year, initial.month, safeDay),
      firstDate: DateTime(year),
      lastDate: DateTime(year, 12, 31),
    );
  }

  Future<DateTime?> _pickDayCurrentMonth(DateTime initial) {
    // Select day in the current month by restricting the allowed range.
    final now = DateTime.now();
    final first = DateTime(now.year, now.month);
    final last = DateTime(now.year, now.month + 1, 0);

    // Clamp day so the initial date always falls within the current month.
    final safeDay = _clampDay(
      year: now.year,
      month: now.month,
      day: initial.day,
    );
    final initialInMonth = DateTime(now.year, now.month, safeDay);

    return showDatePicker(
      context: context,
      initialDate: initialInMonth,
      firstDate: first,
      lastDate: last,
    );
  }

  int _clampDay({required int year, required int month, required int day}) {
    // Last day in [month] is computed by using day=0 of the next month.
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    if (day < 1) return 1;
    if (day > lastDayOfMonth) return lastDayOfMonth;
    return day;
  }

  Future<DateTime?> _pickYear(DateTime initial) async {
    // Custom year picker dialog.
    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        final nowYear = DateTime.now().year;
        final start = nowYear - 100;
        final end = nowYear + 20;

        return AlertDialog(
          title: Text(AppStrings.selectYear),
          content: SizedBox(
            width: 320,
            height: 320,
            child: YearPicker(
              firstDate: DateTime(start),
              lastDate: DateTime(end),
              selectedDate: DateTime(initial.year),
              onChanged: (date) => Navigator.of(context).pop(date.year),
            ),
          ),
        );
      },
    );

    if (selected == null) return null;

    // Month/day fixed to 1.
    return DateTime(selected);
  }

  Future<DateTime?> _pickYearMonth(DateTime initial) async {
    // Custom year+month picker dialog.
    final selected = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        int selectedYear = initial.year;
        int selectedMonth = initial.month;

        return StatefulBuilder(
          builder: (context, setState) {
            final nowYear = DateTime.now().year;
            final start = nowYear - 100;
            final end = nowYear + 20;

            return AlertDialog(
              title: Text(AppStrings.selectMonth),
              content: SizedBox(
                width: 340,
                height: 380,
                child: Column(
                  children: <Widget>[
                    // Year selection.
                    SizedBox(
                      height: 200,
                      child: YearPicker(
                        firstDate: DateTime(start),
                        lastDate: DateTime(end),
                        selectedDate: DateTime(selectedYear),
                        onChanged: (date) {
                          setState(() {
                            selectedYear = date.year;
                          });
                        },
                      ),
                    ),
                    AppSpacing.md.verticalSpace,
                    // Month selection.
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 2.4,
                            ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = month == selectedMonth;
                          final label = DateTime(
                            selectedYear,
                            month,
                          ).toMonthFull();

                          return _TapArea(
                            onTap: () {
                              setState(() {
                                selectedMonth = month;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.xs.r,
                                ),
                                color: isSelected
                                    ? context.primary.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? context.primary
                                      : context.grey.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppStrings.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(DateTime(selectedYear, selectedMonth));
                  },
                  child: Text(AppStrings.done),
                ),
              ],
            );
          },
        );
      },
    );

    return selected;
  }

  Future<DateTime?> _pickMonthCurrentYear(DateTime initial) async {
    // Custom month picker (current year).
    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        int selectedMonth = initial.month;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppStrings.selectMonth),
              content: SizedBox(
                width: 340,
                height: 220,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final isSelected = month == selectedMonth;
                    final label = DateTime(
                      DateTime.now().year,
                      month,
                    ).toMonthFull();

                    return _TapArea(
                      onTap: () {
                        setState(() {
                          selectedMonth = month;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.xs.r),
                          color: isSelected
                              ? context.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? context.primary
                                : context.grey.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppStrings.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(selectedMonth),
                  child: Text(AppStrings.done),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected == null) return null;
    return DateTime(DateTime.now().year, selected);
  }

  Future<DateTimeRange?> _pickDateRange(DateTimeRange initial) {
    return showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDateRange: initial,
    );
  }
}
