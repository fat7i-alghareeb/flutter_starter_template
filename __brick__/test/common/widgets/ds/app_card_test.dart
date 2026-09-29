import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_card.dart';
import 'package:{{project_name}}/utils/constants/design_constants.dart';

import '../../../helpers/test_app.dart';

void main() {
  group('AppCard', () {
    testWidgets('the WHOLE card is tappable, not just its text', (
      tester,
    ) async {
      // `DESIGN_SYSTEM.md` → Accessibility. Tapping the padding is the common case on a
      // phone, and a card that only reacts to its title feels broken.
      var taps = 0;
      await pumpApp(
        tester,
        AppCard(onTap: () => taps++, child: const Text('بطاقة')),
      );

      // Deliberately NOT on the text — this lands in the padding, which a card
      // that only wired up its title would ignore.
      //
      // Vertically centred on purpose: 4dp in from the TOP-LEFT would fall
      // inside the 18dp corner radius, which the card clips away, and the miss
      // would look like a bug in the widget rather than in the test.
      final rect = tester.getRect(find.byType(AppCard));
      await tester.tapAt(Offset(rect.left + 4, rect.center.dy));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('carries a shadow in light mode and no border', (tester) async {
      await pumpApp(tester, const AppCard(child: Text('بطاقة')));

      final decoration =
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration;

      // Never a shadow AND a border on the same element.
      expect(decoration.boxShadow, isNotEmpty);
      expect(decoration.border, isNull);
    });

    testWidgets('swaps the shadow for a border in dark mode', (tester) async {
      await pumpApp(
        tester,
        const AppCard(child: Text('بطاقة')),
        brightness: Brightness.dark,
      );

      final decoration =
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration;

      // A shadow is invisible on a dark ground, so it is replaced, not added to.
      expect(decoration.boxShadow, isEmpty);
      expect(decoration.border, isNotNull);
    });

    testWidgets('uses the card radius from the scale', (tester) async {
      await pumpApp(tester, const AppCard(child: Text('بطاقة')));

      final decoration =
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(AppRadii.lg));
    });

    testWidgets('a semantic label collapses the card into one node', (
      tester,
    ) async {
      // A card read out as five separate fragments is unusable with a screen
      // reader; the whole card should be one sentence.
      await pumpApp(
        tester,
        const AppCard(
          semanticLabel: 'خبر: انقطاع المياه، منذ ساعتين',
          child: Column(
            children: <Widget>[Text('انقطاع المياه'), Text('منذ ساعتين')],
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('خبر: انقطاع المياه، منذ ساعتين'),
        findsOneWidget,
      );
    });

    testWidgets('a card with no onTap has no InkWell', (tester) async {
      await pumpApp(tester, const AppCard(child: Text('بطاقة')));
      expect(find.byType(InkWell), findsNothing);
    });
  });
}
