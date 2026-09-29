import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../helpers/test_app.dart';

/// A template whose `{}` never receives its value.
///
/// «{} new» rendering as « new» drops the one thing the sentence exists
/// for. The placeholder-count check in the generator compares the
/// languages with each other, so a sentence that is wrong in BOTH passes it;
/// this renders each template for real.
///
/// One `pumpLocalizedApp` per FILE — `EasyLocalization` keeps process-level
/// state (`test/README.md`).
void main() {
  setUpAll(initTestLocalization);

  testWidgets('every argument reaches the sentence it belongs to', (
    tester,
  ) async {
    final rendered = <String, String>{};

    await pumpLocalizedApp(
      tester,
      Builder(
        builder: (context) {
          rendered['positionOf'] = AppStrings.a11yPositionOf('2', '5');
          rendered['switchedTo'] = AppStrings.navSwitchedTo('الرئيسية');
          rendered['slideOf'] = AppStrings.onboardingSlideOf('1', '3');
          rendered['newSince'] = AppStrings.feedNewSince('4');
          rendered['noResultsFor'] = AppStrings.feedNoResultsFor('حديقة');
          rendered['resultsFor'] = AppStrings.feedResultsFor('حديقة');
          rendered['offlineCached'] = AppStrings.stateOfflineCached('منذ ساعة');
          return const SizedBox.shrink();
        },
      ),
    );

    rendered.forEach((name, value) {
      expect(
        value.contains('{}'),
        isFalse,
        reason: '$name kept its placeholder: "$value"',
      );
    });

    expect(rendered['positionOf'], allOf(contains('2'), contains('5')));
    expect(rendered['switchedTo'], contains('الرئيسية'));
    expect(rendered['slideOf'], allOf(contains('1'), contains('3')));
    expect(
      rendered['newSince'],
      contains('4'),
      reason: 'the number the sentence exists for must be IN it',
    );
    expect(rendered['noResultsFor'], contains('حديقة'));
    expect(rendered['resultsFor'], contains('حديقة'));
    expect(rendered['offlineCached'], contains('منذ ساعة'));
  });
}
