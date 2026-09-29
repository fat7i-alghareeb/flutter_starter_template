import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_key_value_table.dart';

import '../../../helpers/test_app.dart';

void main() {
  const rows = <AppKeyValue>[
    AppKeyValue('المكان', 'قرب شارع المدارس'),
    AppKeyValue('تاريخ الفقدان', '22 مايو 2026'),
    AppKeyValue('وصف مميّز', 'ميدالية زرقاء'),
  ];

  group('AppKeyValueTable', () {
    testWidgets('renders every label and value', (tester) async {
      await pumpApp(tester, const AppKeyValueTable(rows: rows));
      for (final row in rows) {
        expect(find.text(row.label), findsOneWidget);
        expect(find.text(row.value), findsOneWidget);
      }
    });

    testWidgets('renders NOTHING when empty — not an empty box', (
      tester,
    ) async {
      // An empty table must not leave a titled, blank block on the screen.
      await pumpApp(
        tester,
        const AppKeyValueTable(rows: <AppKeyValue>[], title: 'التفاصيل'),
      );
      expect(find.text('التفاصيل'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('draws a divider between rows but not after the last', (
      tester,
    ) async {
      await pumpApp(tester, const AppKeyValueTable(rows: rows));

      final decorated = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration)
          .map((c) => (c.decoration! as BoxDecoration).border)
          .toList();

      // Three rows → two dividers.
      expect(decorated.where((b) => b != null).length, 2);
    });

    testWidgets('each row is one semantic sentence', (tester) async {
      // "المكان: قرب شارع المدارس" reads correctly; a label and value announced
      // as two unrelated fragments does not.
      await pumpApp(tester, const AppKeyValueTable(rows: rows));
      expect(find.bySemanticsLabel('المكان: قرب شارع المدارس'), findsOneWidget);
    });

    testWidgets('a long value wraps instead of overflowing', (tester) async {
      await pumpApp(
        tester,
        const SizedBox(
          width: 300,
          child: AppKeyValueTable(
            rows: <AppKeyValue>[
              AppKeyValue(
                'وصف',
                'قيمة طويلة جدًا جدًا تتجاوز عرض السطر الواحد بكثير',
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
