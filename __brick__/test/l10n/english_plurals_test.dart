import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../helpers/test_app.dart';

/// English needs its «one» too: «1 mins read» is as wrong as a missing
/// Arabic dual.
///
/// One `pumpLocalizedApp` per FILE (`test/README.md`).
void main() {
  setUpAll(initTestLocalization);

  testWidgets('one and many read right in English', (tester) async {
    final said = <String, String>{};

    await pumpLocalizedApp(
      tester,
      Builder(
        builder: (context) {
          said['r1'] = AppStrings.feedReadMinutes(1, '1');
          said['r5'] = AppStrings.feedReadMinutes(5, '5');
          said['m1'] = AppStrings.timeMinutesAgo(1, '1');
          said['h2'] = AppStrings.timeHoursAgo(2, '2');
          said['d3'] = AppStrings.timeDaysAgo(3, '3');
          return const SizedBox.shrink();
        },
      ),
      locale: const Locale('en'),
    );

    expect(said['r1'], '1 min read');
    expect(said['r5'], '5 min read');
    expect(said['m1'], '1 min ago');
    expect(said['h2'], '2h ago');
    expect(said['d3'], '3d ago');
  });
}
