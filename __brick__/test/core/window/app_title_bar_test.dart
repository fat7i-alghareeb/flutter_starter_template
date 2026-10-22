import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/layout/app_layout_scope.dart';
import 'package:{{project_name}}/core/theme/app_theme.dart';
import 'package:{{project_name}}/core/window/app_title_bar.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/test_app.dart';

/// The desktop window's own title bar: it exists only where there is a
/// desktop window, takes Microsoft's two heights, shows the caption buttons
/// on Windows and leaves the traffic lights to macOS.
void main() {
  const marker = Key('page');

  /// A widget test as [platform]. The override is reset INSIDE the test:
  /// Flutter checks it is unset before `tearDown` runs.
  void testOn(
    TargetPlatform platform,
    String description,
    Future<void> Function(WidgetTester tester) body,
  ) {
    testWidgets(description, (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await body(tester);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  Future<void> pumpFrame(
    WidgetTester tester, {
    required AppTitleBarConfig config,
    Size size = TestDevices.desktop,
  }) {
    return pumpApp(
      tester,
      AppDesktopFrame(
        config: config,
        child: const SizedBox.expand(key: marker),
      ),
      surfaceSize: size,
      fullScreen: true,
    );
  }

  double barHeight(WidgetTester tester) =>
      tester.getRect(find.byKey(marker)).top;

  testOn(TargetPlatform.android, 'phones and tablets get the app untouched', (
    tester,
  ) async {
    await pumpFrame(tester, config: const AppTitleBarConfig());

    expect(barHeight(tester), 0);
    expect(find.bySemanticsLabel(AppStrings.windowMinimize), findsNothing);
  });

  group('Windows', () {
    void windows(String d, Future<void> Function(WidgetTester tester) body) =>
        testOn(TargetPlatform.windows, d, body);

    windows('minimise, maximise and close are in the bar', (tester) async {
      await pumpFrame(tester, config: const AppTitleBarConfig());

      expect(find.bySemanticsLabel(AppStrings.windowMinimize), findsOneWidget);
      expect(find.bySemanticsLabel(AppStrings.windowMaximize), findsOneWidget);
      expect(find.bySemanticsLabel(AppStrings.actionClose), findsOneWidget);
    });

    windows('32 tall; 48 once it carries the search field', (tester) async {
      await pumpFrame(tester, config: const AppTitleBarConfig());
      expect(barHeight(tester), 32);

      await pumpFrame(tester, config: AppTitleBarConfig(onSearch: (_) {}));
      expect(barHeight(tester), 48);
    });

    windows('a window too narrow for the search keeps the short bar', (
      tester,
    ) async {
      await pumpFrame(
        tester,
        config: AppTitleBarConfig(onSearch: (_) {}),
        size: TestDevices.tablet,
      );
      expect(barHeight(tester), 32);
    });

    windows('the search box fills the bar, not one line of text in it', (
      tester,
    ) async {
      await pumpFrame(tester, config: AppTitleBarConfig(onSearch: (_) {}));

      // The bar gives it 48 less 6 above and below. A field that is not told
      // to expand draws its border around a single ~18dp line and floats in
      // the middle of that box.
      expect(tester.getSize(find.byType(TextField)).height, 36);
      expect(tester.widget<TextField>(find.byType(TextField)).expands, isTrue);
    });

    windows('the search box grows with the window, between 360 and 640', (
      tester,
    ) async {
      Future<double> widthAt(Size size) async {
        await pumpFrame(
          tester,
          config: AppTitleBarConfig(onSearch: (_) {}),
          size: size,
        );
        return tester.getSize(find.byType(TextField)).width;
      }

      expect(await widthAt(const Size(900, 700)), 360);
      expect(await widthAt(TestDevices.desktop), closeTo(1280 / 3, 0.5));
      expect(await widthAt(const Size(3000, 1200)), 640);
    });

    windows('the caption buttons stay top-right in Arabic too', (tester) async {
      // pumpApp defaults to right-to-left.
      await pumpFrame(tester, config: const AppTitleBarConfig());
      final close = tester.getRect(
        find.bySemanticsLabel(AppStrings.actionClose),
      );
      expect(close.right, TestDevices.desktop.width);
    });

    windows('the page title shows beside the app name', (tester) async {
      final title = ValueNotifier<String?>('Settings');
      addTearDown(title.dispose);
      await pumpFrame(tester, config: AppTitleBarConfig(pageTitle: title));
      expect(find.text('Settings'), findsOneWidget);

      title.value = null;
      await tester.pump();
      expect(find.text('Settings'), findsNothing);
    });

    windows('mounted above the navigator, as App does, its tooltips work', (
      tester,
    ) async {
      // `pumpApp` puts the frame INSIDE a page, where an Overlay exists. The
      // real app puts it in `MaterialApp.builder`, above the navigator —
      // where a Tooltip once failed with «No Overlay widget found».
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = TestDevices.desktop;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => AppLayoutHost(
            child: AppDesktopFrame(
              config: AppTitleBarConfig(onToggleTheme: () {}),
              child: child!,
            ),
          ),
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(
        tester.getCenter(find.byTooltip(AppStrings.navDarkMode)),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      // The tooltip's own text is on screen, over the page.
      expect(find.text(AppStrings.navDarkMode), findsOneWidget);
    });

    windows('survives a 1.3x system font and both themes', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpApp(
          tester,
          AppDesktopFrame(
            config: AppTitleBarConfig(onSearch: (_) {}),
            child: const SizedBox.expand(),
          ),
          brightness: brightness,
          textScale: 1.3,
          surfaceSize: TestDevices.desktop,
          fullScreen: true,
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('macOS', () {
    void macos(String d, Future<void> Function(WidgetTester tester) body) =>
        testOn(TargetPlatform.macOS, d, body);

    macos('no drawn caption buttons — the traffic lights are the '
        'system\'s', (tester) async {
      await pumpFrame(tester, config: const AppTitleBarConfig());

      expect(find.bySemanticsLabel(AppStrings.windowMinimize), findsNothing);
      expect(find.bySemanticsLabel(AppStrings.windowMaximize), findsNothing);
      expect(find.bySemanticsLabel(AppStrings.actionClose), findsNothing);
      // The bar matches the system band the traffic lights sit in.
      expect(barHeight(tester), 28);
    });
  });
}
