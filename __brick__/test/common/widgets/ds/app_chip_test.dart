import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_chip.dart';

import '../../../helpers/test_app.dart';

void main() {
  group('AppChip', () {
    testWidgets('an active chip differs by WEIGHT as well as colour', (
      tester,
    ) async {
      // `DESIGN_SYSTEM.md` → Accessibility: the active state is never carried by colour
      // alone. Someone who cannot separate olive from grey still sees the bold.
      await pumpApp(tester, const AppChip(label: 'الكل', selected: true));
      final active = tester.widget<Text>(find.text('الكل')).style!;

      await pumpApp(tester, const AppChip(label: 'الكل'));
      final inactive = tester.widget<Text>(find.text('الكل')).style!;

      expect(active.fontWeight, FontWeight.w700);
      expect(inactive.fontWeight, isNot(FontWeight.w700));
      expect(active.color, isNot(inactive.color));
    });

    testWidgets('a count is appended to the label', (tester) async {
      await pumpApp(tester, const AppChip(label: 'مفقود', count: '7'));
      // « · » between the label and its count.
      expect(find.text('مفقود · 7'), findsOneWidget);
    });

    testWidgets('the count is printed exactly as it was handed over', (
      tester,
    ) async {
      // The chip takes a FORMATTED string, never a number: with an `int`
      // the label built `'$label · $count'` and printed Latin digits inside
      // an Arabic word, which no golden holds and `pumpApp`'s locale-less
      // tree could never show. The caller formats
      // through `AppFormats.number`; this fails if the chip ever starts
      // formatting on its own.
      await pumpApp(tester, const AppChip(label: 'الكل', count: '1,200'));
      // Exactly as handed over — grouped by the caller, not re-formatted.
      expect(find.text('الكل · 1,200'), findsOneWidget);
      expect(find.text('الكل · 1200'), findsNothing);
    });

    testWidgets('the count is hidden when null', (tester) async {
      await pumpApp(tester, const AppChip(label: 'مفقود'));
      expect(find.text('مفقود'), findsOneWidget);
    });

    testWidgets('reports its selected state to a screen reader', (
      tester,
    ) async {
      await pumpApp(tester, const AppChip(label: 'مفقود', selected: true));
      final node = tester.getSemantics(find.byType(AppChip));
      expect(node, isSemantics(isSelected: true));
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await pumpApp(tester, AppChip(label: 'الكل', onTap: () => taps++));
      await tester.tap(find.byType(AppChip));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });

  group('AppChip in a Wrap', () {
    testWidgets('takes the width of its word, not of the screen', (
      tester,
    ) async {
      // A `Container` with an `alignment` expands to fill BOUNDED
      // constraints. Inside a rail the constraints are unbounded and the
      // chip was fine; inside the `Wrap` of «جرّب تصنيفًا آخر» every chip
      // stretched to the full width of the screen, on the stores' empty
      // list, the marketplace's, and search's — until a device showed it.
      await pumpApp(
        tester,
        const SizedBox(
          width: 358,
          child: Wrap(
            children: <Widget>[
              AppChip(label: 'منزل'),
              AppChip(label: 'إلكترونيات'),
            ],
          ),
        ),
      );

      final first = tester.getSize(find.byType(AppChip).first);
      final second = tester.getSize(find.byType(AppChip).last);
      expect(first.width, lessThan(150));
      expect(second.width, lessThan(200));
      expect(
        tester.getTopLeft(find.byType(AppChip).first).dy,
        tester.getTopLeft(find.byType(AppChip).last).dy,
        reason: 'two short chips share one line',
      );
    });
  });

  group('AppChipRail', () {
    testWidgets('renders nothing at all when empty', (tester) async {
      // An empty rail must not leave a 32dp gap where chips would have been —
      // a content section with no statuses simply has no filter row.
      await pumpApp(tester, const AppChipRail(children: <Widget>[]));
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('lays chips out horizontally', (tester) async {
      await pumpApp(
        tester,
        const AppChipRail(
          children: <Widget>[
            AppChip(label: 'الكل', selected: true),
            AppChip(label: 'مفقود'),
            AppChip(label: 'موجود'),
          ],
        ),
      );
      expect(find.byType(AppChip), findsNWidgets(3));
    });

    testWidgets('vertical padding is ADDED to the chips, never taken from '
        'them', (tester) async {
      // The notifications row passes 8dp above and below; inside a rail
      // fixed at 32 would crush every chip to 16.
      await pumpApp(
        tester,
        const AppChipRail(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: <Widget>[AppChip(label: 'الكل', selected: true)],
        ),
      );
      expect(tester.getSize(find.byType(AppChip)).height, 32);
    });
  });

  group('AppSectionHeader', () {
    testWidgets('shows the title and hides the action when there is none', (
      tester,
    ) async {
      await pumpApp(tester, const AppSectionHeader(title: 'أحدث الأخبار'));
      expect(find.text('أحدث الأخبار'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('the «الكل» pill carries the count', (
      tester,
    ) async {
      await pumpApp(
        tester,
        AppSectionHeader(
          title: 'عروض اليوم',
          actionLabel: 'عرض الكل',
          count: 24,
          onActionTap: () {},
        ),
        settle: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('24'), findsOneWidget);
    });

    testWidgets('shows the action when given one', (tester) async {
      var taps = 0;
      await pumpApp(
        tester,
        AppSectionHeader(
          title: 'أحدث الأخبار',
          actionLabel: 'عرض الكل',
          onActionTap: () => taps++,
        ),
      );
      await tester.tap(find.text('عرض الكل'));
      expect(taps, 1);
    });

    // «عرض الكل ‹» sat in the middle of the row with nothing at the end
    // edge: title and action split the width in two halves, and the action
    // started where the title's half ended (reported on device, 2026-09-26).
    for (final direction in TextDirection.values) {
      testWidgets('the action sits against the end edge (${direction.name})', (
        tester,
      ) async {
        await pumpApp(
          tester,
          Directionality(
            textDirection: direction,
            child: AppSectionHeader(
              title: 'عروض اليوم',
              actionLabel: 'عرض الكل',
              onActionTap: () {},
            ),
          ),
        );

        final header = tester.getRect(find.byType(AppSectionHeader));
        final action = tester.getRect(find.byType(InkWell));
        if (direction == TextDirection.rtl) {
          expect(action.left, header.left);
        } else {
          expect(action.right, header.right);
        }
      });
    }

    testWidgets('a long title takes what the action leaves, not half', (
      tester,
    ) async {
      const title = 'منتجات مختارة لك من محلات المخيم وأسواقه';
      await pumpApp(
        tester,
        AppSectionHeader(
          title: title,
          actionLabel: 'عرض الكل',
          onActionTap: () {},
        ),
      );

      final paragraph = tester.renderObject<RenderParagraph>(find.text(title));
      final header = tester.getRect(find.byType(AppSectionHeader));
      expect(paragraph.size.width, greaterThan(header.width / 2));
    });

    testWidgets('a long action at 320dp and 2x text does not overflow', (
      tester,
    ) async {
      await pumpApp(
        tester,
        AppSectionHeader(
          title: 'المنيو',
          actionLabel: 'المنيو كامل',
          onActionTap: () {},
        ),
        surfaceSize: TestDevices.small,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
