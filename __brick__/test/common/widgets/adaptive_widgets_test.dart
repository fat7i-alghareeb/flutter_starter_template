import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/app_bottom_sheet.dart';
import 'package:{{project_name}}/common/widgets/ds/app_content_width.dart';
import 'package:{{project_name}}/common/widgets/form/app_form_field_grid.dart';
import 'package:{{project_name}}/core/shortcuts/app_shortcuts.dart';

import '../../helpers/test_app.dart';

/// The pieces that change shape with the window: a sheet that becomes a
/// dialog, a form that goes two columns, a content column that stops
/// growing, and shortcuts that step aside while the reader types.
void main() {
  group('AppBottomSheet.showAdaptive', () {
    Future<void> open(WidgetTester tester) async {
      late BuildContext context;
      await pumpApp(
        tester,
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
        surfaceSize: tester.view.physicalSize,
        fullScreen: true,
      );
      unawaited(
        AppBottomSheet.showAdaptive<void>(
          context,
          builder: (_) => AppBottomSheet.basic(
            title: 'Filter',
            child: const SizedBox(height: 60, child: Text('content')),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a phone gets a sheet from the bottom edge', (tester) async {
      tester.view.physicalSize = TestDevices.reference;
      await open(tester);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('an expanded window gets a centred dialog, at most 720 wide', (
      tester,
    ) async {
      tester.view.physicalSize = TestDevices.desktop;
      await open(tester);

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(Dialog), findsOneWidget);
      final width = tester.getSize(find.byType(AppBottomSheet)).width;
      expect(width, lessThanOrEqualTo(AppBottomSheet.dialogMaxWidth));
      final centre = tester.getCenter(find.byType(AppBottomSheet));
      expect(centre.dx, closeTo(TestDevices.desktop.width / 2, 1));
    });

    testWidgets('the dialog has no drag handle and rounds all four corners', (
      tester,
    ) async {
      tester.view.physicalSize = TestDevices.desktop;
      await open(tester);

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(AppBottomSheet),
              matching: find.byType(Material),
            )
            .first,
      );
      final radius = material.borderRadius! as BorderRadius;
      expect(radius.bottomLeft, isNot(Radius.zero));
      expect(radius.topLeft, radius.bottomLeft);
    });
  });

  group('AppFormFieldGrid', () {
    Widget grid() => const AppFormFieldGrid(
      children: <Widget>[
        SizedBox(key: ValueKey<int>(0), height: 40),
        SizedBox(key: ValueKey<int>(1), height: 40),
        SizedBox(key: ValueKey<int>(2), height: 40),
      ],
    );

    testWidgets('one column in a narrow window', (tester) async {
      await pumpApp(tester, grid());
      final a = tester.getTopLeft(find.byKey(const ValueKey<int>(0)));
      final b = tester.getTopLeft(find.byKey(const ValueKey<int>(1)));
      expect(b.dx, a.dx);
      expect(b.dy, greaterThan(a.dy));
    });

    testWidgets('two to a row in a wide one, the odd one on its own', (
      tester,
    ) async {
      await pumpApp(tester, grid(), surfaceSize: TestDevices.desktop);
      final a = tester.getTopLeft(find.byKey(const ValueKey<int>(0)));
      final b = tester.getTopLeft(find.byKey(const ValueKey<int>(1)));
      final c = tester.getTopLeft(find.byKey(const ValueKey<int>(2)));
      expect(b.dy, a.dy);
      expect(b.dx, isNot(a.dx));
      expect(c.dy, greaterThan(a.dy));
    });

    testWidgets('a field marked full width keeps a row to itself', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const AppFormFieldGrid(
          fullWidth: <int>{1},
          children: <Widget>[
            SizedBox(key: ValueKey<int>(0), height: 40),
            SizedBox(key: ValueKey<int>(1), height: 40),
            SizedBox(key: ValueKey<int>(2), height: 40),
          ],
        ),
        surfaceSize: TestDevices.desktop,
      );
      final a = tester.getTopLeft(find.byKey(const ValueKey<int>(0)));
      final b = tester.getTopLeft(find.byKey(const ValueKey<int>(1)));
      final c = tester.getTopLeft(find.byKey(const ValueKey<int>(2)));
      expect(b.dy, greaterThan(a.dy));
      expect(c.dy, greaterThan(b.dy));
    });
  });

  testWidgets('AppContentWidth stops growing and stays centred', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const AppContentWidth(
        maxWidth: 800,
        child: SizedBox(
          key: ValueKey<String>('c'),
          width: double.infinity,
          height: 40,
        ),
      ),
      surfaceSize: TestDevices.desktop,
      fullScreen: true,
    );
    final rect = tester.getRect(find.byKey(const ValueKey<String>('c')));
    expect(rect.width, 800);
    expect(rect.center.dx, closeTo(TestDevices.desktop.width / 2, 1));
  });

  group('AppShortcuts', () {
    late List<String> ran;

    AppShortcutHandlers handlers() => AppShortcutHandlers(
      switchTab: (i) => ran.add('tab$i'),
      focusSearch: () => ran.add('search'),
      openSettings: () => ran.add('settings'),
      goBack: () => ran.add('back'),
      refresh: () => ran.add('refresh'),
      toggleSidebar: () => ran.add('sidebar'),
      showHelp: () => ran.add('help'),
    );

    setUp(() => ran = <String>[]);

    Future<void> pumpKeys(WidgetTester tester, {Widget? inside}) {
      return pumpApp(
        tester,
        AppShortcuts(
          handlers: handlers(),
          child: Focus(
            // Two autofocus widgets in one scope: the first one built wins,
            // so the outer one steps aside when a field is inside.
            autofocus: inside == null,
            child: inside ?? const SizedBox.expand(),
          ),
        ),
        fullScreen: true,
      );
    }

    testWidgets('Ctrl + 1–5 switch tabs, Ctrl + K searches, Ctrl + B folds', (
      tester,
    ) async {
      await pumpKeys(tester);

      Future<void> chord(LogicalKeyboardKey key) async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(key);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      }

      await chord(LogicalKeyboardKey.digit3);
      await chord(LogicalKeyboardKey.keyK);
      await chord(LogicalKeyboardKey.keyB);
      await chord(LogicalKeyboardKey.comma);
      await chord(LogicalKeyboardKey.keyR);

      expect(ran, <String>['tab2', 'search', 'sidebar', 'settings', 'refresh']);
    });

    testWidgets('Esc goes back and F5 refreshes', (tester) async {
      await pumpKeys(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyEvent(LogicalKeyboardKey.f5);
      expect(ran, <String>['back', 'refresh']);
    });

    testWidgets('while a text field has the focus, the keys are the field\'s', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpKeys(
        tester,
        inside: Material(
          child: Center(
            child: SizedBox(
              width: 200,
              child: TextField(controller: controller, autofocus: true),
            ),
          ),
        ),
      );
      await tester.pump();

      // Esc and F5 do nothing while typing.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyEvent(LogicalKeyboardKey.f5);
      expect(ran, isEmpty);
    });
  });
}
