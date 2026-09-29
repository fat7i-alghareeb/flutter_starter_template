import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/root_back_guard.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/root_tab_stack.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/tab_switch_stager.dart';
import 'package:{{project_name}}/utils/constants/design_constants.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/test_app.dart';

/// A tab switch is a cross-fade and the bar's pill slides; a tab asked for
/// from inside a page is staged — the bar moves first, then the page, then
/// «Now in …» is announced; back on another tab returns to the first tab,
/// back on the first tab asks before leaving.
void main() {
  late NavigationController controller;

  setUp(() => controller = NavigationController());
  tearDown(() => controller.dispose());

  group('the cross-fade', () {
    Widget shell() => RootTabStack(
      controller: controller,
      tabs: <WidgetBuilder>[
        for (var i = 0; i < 4; i++)
          (_) => ColoredBox(
            key: ValueKey<String>('tab-$i'),
            color: Colors.primaries[i],
          ),
      ],
    );

    double opacityOf(WidgetTester tester, int tab) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byKey(
                  ValueKey<String>('tab-$tab'),
                  skipOffstage: false,
                ),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    testWidgets('both tabs dissolve at once, nothing moves or clips', (
      tester,
    ) async {
      await pumpApp(tester, shell(), fullScreen: true);

      controller.setIndex(2);
      await tester.pump();
      await tester.pump(AppDurations.tabSwitch ~/ 2);

      // Halfway: one fading out, the other in, at the same time.
      final leaving = opacityOf(tester, 0);
      final arriving = opacityOf(tester, 2);
      expect(leaving, inExclusiveRange(0, 1));
      expect(arriving, inExclusiveRange(0, 1));
      expect(leaving + arriving, closeTo(1, 0.01));
      // No wipe and no settle.
      expect(
        find.descendant(
          of: find.byType(RootTabStack),
          matching: find.byType(ClipPath),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(RootTabStack),
          matching: find.byType(ScaleTransition),
        ),
        findsNothing,
      );

      await tester.pumpAndSettle();
      expect(opacityOf(tester, 2), 1);
      expect(find.byKey(const ValueKey<String>('tab-0')), findsNothing);
    });
  });

  group('a tab asked for from a page', () {
    test('with no shell to stage it, the tab changes at once', () {
      controller.switchFromBody(2);
      expect(controller.currentIndex, 2);
    });

    Widget staged({required GlobalKey buttonKey}) => TabSwitchStager(
      controller: controller,
      labels: const <String>['الرئيسية', 'الأخبار', 'السوق', 'المحلات'],
      child: Center(
        child: Builder(
          builder: (context) => TextButton(
            key: buttonKey,
            onPressed: () => controller.switchFromBody(1),
            child: const Text('عرض الكل'),
          ),
        ),
      ),
    );

    testWidgets('the bar moves first, then the page, then the sentence', (
      tester,
    ) async {
      final key = GlobalKey();
      await pumpApp(tester, staged(buttonKey: key), fullScreen: true);

      await tester.tap(find.byKey(key));
      await tester.pump();

      // The bar's pill has moved; the page has not changed yet.
      expect(controller.barIndex, 1);
      expect(controller.currentIndex, 0);

      // The handoff's ticker starts on the frame after the tap.
      await tester.pump(AppDurations.tabHandoff);
      await tester.pump(const Duration(milliseconds: 20));
      expect(controller.currentIndex, 1);
      expect(find.text(AppStrings.navSwitchedTo('الأخبار')), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text(AppStrings.navSwitchedTo('الأخبار')), findsNothing);
    });

    testWidgets('under reduced motion the tab changes at once', (tester) async {
      final key = GlobalKey();
      await pumpApp(
        tester,
        staged(buttonKey: key),
        fullScreen: true,
        disableAnimations: true,
      );

      await tester.tap(find.byKey(key));
      await tester.pump();

      expect(controller.currentIndex, 1);
      // Still told where it went.
      expect(find.text(AppStrings.navSwitchedTo('الأخبار')), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('back on the tabs', () {
    Widget guarded({Future<void> Function()? onLeave}) => RootBackGuard(
      controller: controller,
      onLeave: onLeave,
      child: const SizedBox.expand(),
    );

    Future<void> pressBack(WidgetTester tester) async {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    testWidgets('on another tab it returns home first', (tester) async {
      controller.setIndex(2);
      await pumpApp(tester, guarded(), fullScreen: true);

      await pressBack(tester);

      expect(controller.currentIndex, 0);
      expect(find.text(AppStrings.exitTitle), findsNothing);
    });

    testWidgets('on home it asks, and «البقاء» stays', (tester) async {
      var left = false;
      await pumpApp(
        tester,
        guarded(onLeave: () async => left = true),
        fullScreen: true,
      );

      await pressBack(tester);
      expect(find.text(AppStrings.exitTitle), findsOneWidget);

      await tester.tap(find.text(AppStrings.exitStay));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.exitTitle), findsNothing);
      expect(left, isFalse);
    });

    testWidgets('«خروج» leaves the app', (tester) async {
      var left = false;
      await pumpApp(
        tester,
        guarded(onLeave: () async => left = true),
        fullScreen: true,
      );

      await pressBack(tester);
      await tester.tap(find.text(AppStrings.exitConfirm));
      await tester.pumpAndSettle();

      expect(left, isTrue);
    });
  });
}
