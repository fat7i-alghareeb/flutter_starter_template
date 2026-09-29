import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_badge.dart';
import 'package:{{project_name}}/core/theme/app_colors.dart';

import '../../../helpers/test_app.dart';

BoxDecoration _decorationOf(WidgetTester tester, String label) =>
    tester
            .widget<Container>(
              find
                  .ancestor(of: find.text(label), matching: find.byType(Container))
                  .first,
            )
            .decoration!
        as BoxDecoration;

void main() {
  group('AppBadge', () {
    testWidgets('always renders its text', (tester) async {
      await pumpApp(tester, const AppBadge.urgent('Urgent'));
      expect(find.text('Urgent'), findsOneWidget);
    });

    testWidgets('carries text even when given an icon', (tester) async {
      // There is no colour-only or icon-only badge: a reader who cannot tell
      // two tones apart must still get the word.
      await pumpApp(
        tester,
        const AppBadge.urgent('Urgent', icon: Icons.priority_high),
      );
      expect(find.text('Urgent'), findsOneWidget);
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
    });

    testWidgets('the urgent tone uses the semantic urgent colour', (
      tester,
    ) async {
      await pumpApp(tester, const AppBadge.urgent('Urgent'));
      expect(
        _decorationOf(tester, 'Urgent').color,
        AppSemanticColors.light.urgent,
      );
    });

    testWidgets('the neutral tone has a border, the primary one does not', (
      tester,
    ) async {
      await pumpApp(tester, const AppBadge('Used'));
      expect(_decorationOf(tester, 'Used').border, isNotNull);

      await pumpApp(tester, const AppBadge.primary('Official'));
      expect(_decorationOf(tester, 'Official').border, isNull);
    });

    testWidgets('the dashed badge paints an outline on no fill', (
      tester,
    ) async {
      // Sponsored or promoted content must be visibly marked; the dash is
      // what sets it apart from an ordinary neutral badge.
      await pumpApp(tester, const AppBadge.dashed('Sponsored'));
      final decoration = _decorationOf(tester, 'Sponsored');
      expect(decoration.color, Colors.transparent);
      expect(decoration.border, isNotNull);
    });

    testWidgets('survives a long label without overflowing', (tester) async {
      await pumpApp(
        tester,
        const SizedBox(
          width: 80,
          child: AppBadge('A very long tag that must not break the layout'),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    forEachBrightness('renders every tone in both themes', (
      tester,
      brightness,
    ) async {
      await pumpApp(
        tester,
        const Wrap(
          spacing: 8,
          children: <Widget>[
            AppBadge('Neutral'),
            AppBadge.primary('Primary'),
            AppBadge.urgent('Urgent'),
            AppBadge.subtle('Subtle'),
            AppBadge.positive('Positive'),
            AppBadge.dashed('Dashed'),
          ],
        ),
        brightness: brightness,
      );
      expect(find.text('Subtle'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
