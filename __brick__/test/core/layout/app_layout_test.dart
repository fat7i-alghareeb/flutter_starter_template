import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/layout/adaptive_layout.dart';
import 'package:{{project_name}}/core/layout/app_layout.dart';
import 'package:{{project_name}}/core/layout/app_layout_scope.dart';

import '../../helpers/test_app.dart';

/// Device type and window size classes: where the breakpoints fall, what
/// each size class shows, and that a widget rebuilds when its CLASS changes
/// — not on every pixel of a window being dragged.
void main() {
  group('WindowSize', () {
    test('Material 3 window size classes, edges included', () {
      expect(WindowSize.fromWidth(0), WindowSize.compact);
      expect(WindowSize.fromWidth(599.9), WindowSize.compact);
      expect(WindowSize.fromWidth(600), WindowSize.medium);
      expect(WindowSize.fromWidth(839.9), WindowSize.medium);
      expect(WindowSize.fromWidth(840), WindowSize.expanded);
      expect(WindowSize.fromWidth(1199.9), WindowSize.expanded);
      expect(WindowSize.fromWidth(1200), WindowSize.large);
      expect(WindowSize.fromWidth(1599.9), WindowSize.large);
      expect(WindowSize.fromWidth(1600), WindowSize.extraLarge);
    });

    test('compact height is what every phone in landscape has', () {
      expect(HeightClass.fromHeight(390), HeightClass.compact);
      expect(HeightClass.fromHeight(479.9), HeightClass.compact);
      expect(HeightClass.fromHeight(480), HeightClass.medium);
      expect(HeightClass.fromHeight(899.9), HeightClass.medium);
      expect(HeightClass.fromHeight(900), HeightClass.expanded);
    });
  });

  group('AppLayout.nav', () {
    AppLayout at(double w, double h, [DeviceType type = DeviceType.phone]) =>
        AppLayout.resolve(size: Size(w, h), deviceType: type);

    test('a phone upright keeps the floating capsule', () {
      expect(at(390, 844).nav, NavLayout.bar);
    });

    test('a phone on its side gets the rail, even 844 wide', () {
      expect(at(844, 390).nav, NavLayout.rail);
      expect(at(932, 430).nav, NavLayout.rail);
    });

    test('medium windows get the rail — an iPad upright, half a screen', () {
      expect(at(820, 1180, DeviceType.tablet).nav, NavLayout.rail);
      expect(at(600, 900).nav, NavLayout.rail);
    });

    test('expanded windows get the sidebar', () {
      expect(at(1180, 820, DeviceType.tablet).nav, NavLayout.sidebar);
      expect(at(1280, 800, DeviceType.desktop).nav, NavLayout.sidebar);
    });

    test('the window decides, not the device', () {
      // A desktop window dragged phone-narrow behaves like a phone.
      expect(at(420, 760, DeviceType.desktop).nav, NavLayout.bar);
      // An iPad in a narrow Stage Manager window too.
      expect(at(540, 720, DeviceType.tablet).nav, NavLayout.bar);
    });
  });

  group('AppLayout values', () {
    test('the gutter widens with the window: 16 · 24 · 32', () {
      AppLayout at(double w) =>
          AppLayout.resolve(size: Size(w, 900), deviceType: DeviceType.tablet);
      expect(at(390).gutter, 16);
      expect(at(700).gutter, 24);
      expect(at(900).gutter, 32);
      expect(at(1400).gutter, 32);
    });

    test('cards run 1 → 2 → 3 columns by the width they get', () {
      expect(AppLayout.columnsFor(358), 1);
      expect(AppLayout.columnsFor(539), 1);
      expect(AppLayout.columnsFor(540), 2);
      expect(AppLayout.columnsFor(899), 2);
      expect(AppLayout.columnsFor(900), 3);
    });

    test('compared by value, so an equal layout notifies nobody', () {
      final a = AppLayout.resolve(
        size: const Size(390, 844),
        deviceType: DeviceType.phone,
      );
      final b = AppLayout.resolve(
        size: const Size(390, 844),
        deviceType: DeviceType.phone,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(
        a,
        isNot(
          AppLayout.resolve(
            size: const Size(391, 844),
            deviceType: DeviceType.phone,
          ),
        ),
      );
    });
  });

  group('AdaptiveLayout', () {
    Widget probe() => AdaptiveLayout(
      compact: (_) => const Text('compact'),
      medium: (_) => const Text('medium'),
      expanded: (_) => const Text('expanded'),
    );

    testWidgets('picks the builder for the window size class', (tester) async {
      await pumpApp(tester, probe());
      expect(find.text('compact'), findsOneWidget);

      await pumpApp(tester, probe(), surfaceSize: TestDevices.tablet);
      expect(find.text('medium'), findsOneWidget);

      await pumpApp(tester, probe(), surfaceSize: TestDevices.desktop);
      expect(find.text('expanded'), findsOneWidget);
    });

    testWidgets('a missing builder falls back to the next smaller one', (
      tester,
    ) async {
      await pumpApp(
        tester,
        AdaptiveLayout(compact: (_) => const Text('compact')),
        surfaceSize: TestDevices.desktop,
      );
      expect(find.text('compact'), findsOneWidget);
    });

    testWidgets('follows a window resize in the same app, with no restart', (
      tester,
    ) async {
      await pumpApp(tester, probe());
      expect(find.text('compact'), findsOneWidget);

      tester.view.physicalSize = TestDevices.desktop;
      await tester.pumpAndSettle();
      expect(find.text('expanded'), findsOneWidget);
    });
  });

  group('AppLayoutScope aspects', () {
    testWidgets('a widget reading the size class rebuilds only when it '
        'changes', (tester) async {
      var classBuilds = 0;
      var fullBuilds = 0;

      await pumpApp(
        tester,
        Column(
          children: <Widget>[
            Builder(
              builder: (context) {
                classBuilds++;
                AppLayoutScope.windowSizeOf(context);
                return const SizedBox();
              },
            ),
            Builder(
              builder: (context) {
                fullBuilds++;
                AppLayoutScope.of(context);
                return const SizedBox();
              },
            ),
          ],
        ),
        surfaceSize: const Size(400, 800),
      );
      final classAtStart = classBuilds;
      final fullAtStart = fullBuilds;

      // Same class, different pixels: only the whole-layout reader rebuilds.
      tester.view.physicalSize = const Size(450, 800);
      await tester.pump();
      expect(classBuilds, classAtStart);
      expect(fullBuilds, greaterThan(fullAtStart));

      // Across a breakpoint both rebuild.
      tester.view.physicalSize = const Size(700, 800);
      await tester.pump();
      expect(classBuilds, greaterThan(classAtStart));
    });
  });
}
