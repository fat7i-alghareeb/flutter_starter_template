import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/utils/helpers/app_formats.dart';

import '../helpers/test_app.dart';

/// Every number in the app prints in LATIN digits — in the Arabic UI too.
///
/// Arabic-Indic digits are one switch away (`AppFormats`), but whichever
/// is chosen, the numbers all come out of ONE system, so a price, a clock
/// and a version never show two kinds of digit side by side. It shipped mixed once — CLDR's plain `ar`
/// gave Latin while `AppStrings` templates carried Arabic-Indic — and no test
/// looked at a glyph.
///
/// ⚠️ ONE `testWidgets` in this file — `pumpLocalizedApp` cannot be called
/// twice in a process (`test/README.md`), and the Arabic locale is the whole
/// point here.
void main() {
  setUpAll(initTestLocalization);

  testWidgets('every number the Arabic UI shows is in Latin digits', (
    tester,
  ) async {
    final latin = RegExp('[0-9]');
    // The Eastern digits, and the Arabic grouping and decimal separators.
    final arabicIndic = RegExp('[٠-٩٫٬]');

    final formatted = <String, String>{};

    await pumpLocalizedApp(
      tester,
      Builder(
        builder: (context) {
          formatted['price'] = AppFormats.price(context, 4500000);
          formatted['number'] = AppFormats.number(context, 118);
          formatted['rating'] = AppFormats.number(context, 4.4);
          formatted['time'] = AppFormats.time(
            context,
            DateTime(2026, 9, 20, 23, 30),
          );
          formatted['fullDate'] = AppFormats.fullDate(
            context,
            DateTime(2026, 5, 28),
          );
          formatted['dayMonth'] = AppFormats.dayMonth(
            context,
            DateTime(2026, 5, 28),
          );
          // A version is a STRING of digits, so it walks straight past
          // `number` — it must still come out in the same digits.
          formatted['version'] = AppFormats.version(context, '1.0');
          return const SizedBox.shrink();
        },
      ),
    );

    expect(formatted, isNotEmpty);

    formatted.forEach((name, value) {
      expect(
        latin.hasMatch(value),
        isTrue,
        reason: '$name has no Latin digit: "$value"',
      );
      expect(
        arabicIndic.hasMatch(value),
        isFalse,
        reason: '$name still carries an Arabic-Indic digit: "$value"',
      );
    });

    // Grouped with a Latin comma — the same system as the digits.
    expect(formatted['price'], startsWith('4,500,000'));
    expect(formatted['version'], '1.0');
  });

  group('AppFormats.line — parts of one line, in either direction', () {
    test('each part is isolated, joined by « · », and an empty part dropped',
        () {
      expect(
        AppFormats.line(<String>['لجنة الإغاثة', '', '5h ago']),
        '\u2068لجنة الإغاثة\u2069 · \u20685h ago\u2069',
      );
    });

    test('an isolate is a pair of invisible marks around the text, nothing '
        'more', () {
      final isolated = AppFormats.isolate('شارع المدارس');
      expect(isolated.replaceAll(RegExp('[\u2068\u2069]'), ''), 'شارع المدارس');
      expect(isolated.codeUnitAt(0), 0x2068);
      expect(isolated.codeUnitAt(isolated.length - 1), 0x2069);
    });
  });
}
