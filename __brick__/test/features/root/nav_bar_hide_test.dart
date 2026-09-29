import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_icons.dart';
import 'package:{{project_name}}/common/widgets/nav_bar_visibility.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/app_bottom_nav.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/test_app.dart';

/// The bottom bar tucks into a dock on scroll, and comes back.
void main() {
  const destinations = <AppNavDestination>[
    AppNavDestination(icon: AppIcons.home, label: 'الرئيسية'),
    AppNavDestination(icon: AppIcons.news, label: 'الأخبار'),
    AppNavDestination(icon: AppIcons.marketplace, label: 'السوق'),
    AppNavDestination(icon: AppIcons.store, label: 'المحلات'),
  ];

  late NavBarVisibility visibility;
  late NavigationController controller;

  setUp(() {
    visibility = NavBarVisibility();
    controller = NavigationController();
  });
  tearDown(() {
    visibility.dispose();
    controller.dispose();
  });

  Widget list() => NavBarScrollWatcher(
    visibility: visibility,
    child: ListView.builder(
      itemCount: 80,
      itemExtent: 60,
      itemBuilder: (_, i) => Text('row $i'),
    ),
  );

  Future<void> scrollBy(WidgetTester tester, double dy) async {
    // Positive dy scrolls the list DOWN (the finger moves up).
    await tester.drag(find.byType(ListView), Offset(0, -dy));
    await tester.pump();
  }

  group('NavBarScrollWatcher', () {
    testWidgets('scrolling down hides the bar', (tester) async {
      await pumpApp(tester, list(), fullScreen: true);
      await scrollBy(tester, 200);
      expect(visibility.hidden, isTrue);
    });

    testWidgets('a small scroll back up does not bring it back', (
      tester,
    ) async {
      await pumpApp(tester, list(), fullScreen: true);
      await scrollBy(tester, 400);
      await scrollBy(tester, -40);
      expect(visibility.hidden, isTrue, reason: 'under 64dp is a correction');
    });

    testWidgets('a clear scroll up brings it back', (tester) async {
      await pumpApp(tester, list(), fullScreen: true);
      await scrollBy(tester, 400);
      await scrollBy(tester, -120);
      expect(visibility.hidden, isFalse);
    });

    testWidgets('the top of the list brings it back', (tester) async {
      await pumpApp(tester, list(), fullScreen: true);
      await scrollBy(tester, 300);
      expect(visibility.hidden, isTrue);
      await scrollBy(tester, -600);
      expect(visibility.hidden, isFalse);
    });

    testWidgets('a horizontal rail never hides it', (tester) async {
      await pumpApp(
        tester,
        NavBarScrollWatcher(
          visibility: visibility,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              for (var i = 0; i < 40; i++)
                SizedBox(width: 80, child: Text('card $i')),
            ],
          ),
        ),
        fullScreen: true,
      );
      await tester.drag(find.byType(ListView), const Offset(-400, 0));
      await tester.pump();
      expect(visibility.hidden, isFalse);
    });

    testWidgets('with a screen reader on, it never hides', (tester) async {
      await pumpApp(
        tester,
        MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: list(),
        ),
        fullScreen: true,
      );
      await scrollBy(tester, 400);
      expect(visibility.hidden, isFalse);
    });
  });

  group('AppBottomNav, tucked away', () {
    Widget bar() => AppBottomNav(
      controller: controller,
      destinations: destinations,
      visibility: visibility,
    );

    testWidgets('morphs into a small dock, and the words go', (tester) async {
      await pumpApp(tester, bar());
      final full = tester.getSize(find.byType(DecoratedBox).first).width;

      visibility.hide();
      await tester.pumpAndSettle();

      final dock = tester.getSize(find.byType(DecoratedBox).first).width;
      expect(full, greaterThan(dock));
      expect(dock, AppBottomNav.dockWidth);
      expect(find.bySemanticsLabel(AppStrings.navShow), findsOneWidget);
      expect(find.text('الأخبار'), findsNothing);
    });

    testWidgets('a tap on the dock brings the bar back', (tester) async {
      visibility.hide();
      await pumpApp(tester, bar());
      await tester.tap(find.bySemanticsLabel(AppStrings.navShow));
      await tester.pumpAndSettle();
      expect(visibility.hidden, isFalse);
      expect(find.text('الأخبار'), findsOneWidget);
    });

    testWidgets('so does a swipe up on it', (tester) async {
      visibility.hide();
      await pumpApp(tester, bar());
      await tester.drag(
        find.bySemanticsLabel(AppStrings.navShow),
        const Offset(0, -40),
      );
      await tester.pumpAndSettle();
      expect(visibility.hidden, isFalse);
    });

    testWidgets('the dock does not switch tabs', (tester) async {
      visibility.hide();
      await pumpApp(tester, bar());
      await tester.tap(find.bySemanticsLabel(AppStrings.navShow));
      await tester.pump();
      expect(controller.currentIndex, 0);
    });
  });
}
