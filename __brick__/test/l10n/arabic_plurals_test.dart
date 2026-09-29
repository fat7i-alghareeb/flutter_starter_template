import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/utils/helpers/app_formats.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../helpers/test_app.dart';

/// What a count READS like in Arabic — the sentences themselves.
///
/// One fixed template per count prints «منذ 2 ساعات» (it is «منذ ساعتين»)
/// and «قراءة 1 دقائق». A widget test sees only keys, so the Arabic is
/// pinned here, once, with the real translations and the real plural rules —
/// the ones `bootstrap` turns on (`ignorePluralRules: false`).
///
/// One `pumpLocalizedApp` per FILE (`test/README.md`).
void main() {
  setUpAll(initTestLocalization);

  testWidgets('each count takes the form Arabic gives it', (tester) async {
    final said = <String, String>{};
    final now = DateTime.now();

    await pumpLocalizedApp(
      tester,
      Builder(
        builder: (context) {
          String ago(Duration d) =>
              AppFormats.relativeTime(context, now.subtract(d));
          String read(int n) =>
              AppStrings.feedReadMinutes(n, AppFormats.number(context, n));

          said['1m'] = ago(const Duration(minutes: 1, seconds: 5));
          said['2m'] = ago(const Duration(minutes: 2, seconds: 5));
          said['5m'] = ago(const Duration(minutes: 5, seconds: 5));
          said['11m'] = ago(const Duration(minutes: 11, seconds: 5));
          said['1h'] = ago(const Duration(hours: 1, minutes: 1));
          said['2h'] = ago(const Duration(hours: 2, minutes: 1));
          said['3h'] = ago(const Duration(hours: 3, minutes: 1));
          said['11h'] = ago(const Duration(hours: 11, minutes: 1));
          said['2d'] = ago(const Duration(days: 2, hours: 1));
          said['5d'] = ago(const Duration(days: 5, hours: 1));

          said['read1'] = read(1);
          said['read2'] = read(2);
          said['read3'] = read(3);
          said['read11'] = read(11);
          return const SizedBox.shrink();
        },
      ),
    );

    expect(said['1m'], 'منذ دقيقة');
    expect(said['2m'], 'منذ دقيقتين');
    expect(said['5m'], 'منذ 5 دقائق');
    expect(said['11m'], 'منذ 11 دقيقة');
    expect(said['1h'], 'منذ ساعة');
    expect(said['2h'], 'منذ ساعتين', reason: 'not «منذ 2 ساعات»');
    expect(said['3h'], 'منذ 3 ساعات');
    expect(said['11h'], 'منذ 11 ساعة');
    expect(said['2d'], 'منذ يومين');
    expect(said['5d'], 'منذ 5 أيام');

    expect(said['read1'], 'قراءة دقيقة', reason: 'not «قراءة 1 دقائق»');
    expect(said['read2'], 'قراءة دقيقتين');
    expect(said['read3'], 'قراءة 3 دقائق');
    expect(said['read11'], 'قراءة 11 دقيقة');

    for (final entry in said.entries) {
      expect(entry.value, isNot(contains('{')), reason: entry.key);
    }
  });
}
