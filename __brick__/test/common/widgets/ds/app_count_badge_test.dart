import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_bar_action.dart';
import 'package:{{project_name}}/common/widgets/ds/app_count_badge.dart';
import 'package:{{project_name}}/common/widgets/ds/app_icons.dart';

import '../../../helpers/test_app.dart';

/// A count is a circle for one digit and a pill beyond it — never a stripe,
/// never an oval, at any text size, in a row, in a stack, in either direction.
void main() {
  Finder badgeBox() => find.byType(AppCountBadge);

  Future<Size> sizeOf(
    WidgetTester tester,
    int count, {
    double textScale = 1,
    TextDirection direction = TextDirection.rtl,
    Widget Function(Widget badge)? around,
  }) async {
    final badge = AppCountBadge(
      count: count,
      color: Colors.red,
      onColor: Colors.white,
    );
    await pumpApp(
      tester,
      around == null ? badge : around(badge),
      textScale: textScale,
      textDirection: direction,
    );
    return tester.getSize(badgeBox());
  }

  for (final direction in TextDirection.values) {
    for (final scale in <double>[1, 1.3, 1.5]) {
      testWidgets('one digit is a circle (${direction.name}, ×$scale)', (
        tester,
      ) async {
        for (final count in <int>[1, 3, 7, 9]) {
          final size = await sizeOf(
            tester,
            count,
            textScale: scale,
            direction: direction,
          );
          expect(size.width, size.height, reason: 'count $count');
          expect(size.width, closeTo(20 * scale, 0.5), reason: 'count $count');
        }
      });
    }
  }

  testWidgets('two digits are a pill as tall as the circle', (tester) async {
    final one = await sizeOf(tester, 1);
    final two = await sizeOf(tester, 12);
    expect(two.height, one.height);
    expect(two.width, greaterThan(two.height));
  });

  testWidgets('past 99 it reads 99+', (tester) async {
    await sizeOf(tester, 250);
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('zero draws nothing', (tester) async {
    final size = await sizeOf(tester, 0);
    expect(size, Size.zero);
  });

  testWidgets('a row of bounded height cannot stretch it', (tester) async {
    final size = await sizeOf(
      tester,
      3,
      around: (badge) => SizedBox(
        height: 48,
        width: 200,
        child: Row(children: <Widget>[const Text('label'), badge]),
      ),
    );
    expect(size, const Size(20, 20));
  });

  testWidgets('a positioned one is not stretched either', (tester) async {
    final size = await sizeOf(
      tester,
      3,
      around: (badge) => SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          children: <Widget>[
            PositionedDirectional(top: 4, end: 4, child: badge),
          ],
        ),
      ),
    );
    expect(size, const Size(20, 20));
  });

  testWidgets('AppBarAction draws it as a circle too', (tester) async {
    await pumpApp(
      tester,
      AppBarAction(
        icon: AppIcons.bell,
        label: 'Alerts',
        onTap: () {},
        badgeCount: 4,
      ),
    );
    final size = tester.getSize(badgeBox());
    expect(size.width, size.height);
  });
}
