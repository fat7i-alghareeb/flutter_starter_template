import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_icons.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/app_bottom_nav.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/app_side_nav.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';

import '../../helpers/test_app.dart';

/// The side navigation: the 80dp rail and the 256dp sidebar — every
/// destination keeps an icon AND a word, the open one is marked by pill and
/// weight, a badge is text, and a tap switches the tab.
void main() {
  const labels = <String>[
    'الرئيسية',
    'الأزرار',
    'النماذج',
    'الحوارات',
    'التنبيهات',
  ];

  late NavigationController controller;
  late ValueNotifier<int> unread;

  setUp(() {
    controller = NavigationController();
    unread = ValueNotifier<int>(3);
  });
  tearDown(() {
    controller.dispose();
    unread.dispose();
  });

  List<AppNavDestination> destinations() => <AppNavDestination>[
    const AppNavDestination(icon: AppIcons.home, label: 'الرئيسية'),
    const AppNavDestination(icon: AppIcons.grid, label: 'الأزرار'),
    const AppNavDestination(icon: AppIcons.edit, label: 'النماذج'),
    const AppNavDestination(icon: AppIcons.comment, label: 'الحوارات'),
    AppNavDestination(icon: AppIcons.bell, label: 'التنبيهات', badge: unread),
  ];

  Future<void> pumpSide(
    WidgetTester tester, {
    required bool extended,
    Size size = TestDevices.desktop,
    bool short = false,
    AppSideNavConfig config = const AppSideNavConfig(
      showAccount: false,
      showThemeToggle: false,
      collapsible: false,
    ),
  }) {
    return pumpApp(
      tester,
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: AppSideNav(
          controller: controller,
          destinations: destinations(),
          extended: extended,
          short: short,
          config: config,
        ),
      ),
      surfaceSize: size,
      fullScreen: true,
    );
  }

  testWidgets('the sidebar is 256 wide and the rail 80, margins aside', (
    tester,
  ) async {
    await pumpSide(tester, extended: true);
    expect(
      tester.getSize(find.byType(AppSideNav)).width,
      AppSideNav.widthOf(extended: true),
    );

    await pumpSide(tester, extended: false);
    expect(
      tester.getSize(find.byType(AppSideNav)).width,
      AppSideNav.widthOf(extended: false),
    );
  });

  testWidgets('every destination keeps its icon AND its word', (tester) async {
    for (final extended in <bool>[true, false]) {
      await pumpSide(tester, extended: extended);
      for (final label in labels) {
        expect(find.text(label), findsOneWidget, reason: 'extended=$extended');
      }
      for (final icon in <String>[
        AppIcons.home,
        AppIcons.grid,
        AppIcons.edit,
        AppIcons.comment,
        AppIcons.bell,
      ]) {
        expect(
          find.byWidgetPredicate((w) => w is AppIcon && w.asset == icon),
          findsOneWidget,
        );
      }
    }
  });

  testWidgets('a tap switches the tab', (tester) async {
    await pumpSide(tester, extended: true);
    expect(controller.currentIndex, 0);

    await tester.tap(find.text('النماذج'));
    await tester.pump();
    expect(controller.currentIndex, 2);
  });

  testWidgets('the open destination is bold as well as tinted', (tester) async {
    await pumpSide(tester, extended: true);
    FontWeight? weightOf(String label) =>
        tester.widget<Text>(find.text(label)).style?.fontWeight;

    expect(weightOf('الرئيسية'), FontWeight.w700);
    expect(weightOf('الأزرار'), isNot(FontWeight.w700));

    controller.setIndex(1);
    await tester.pumpAndSettle();
    expect(weightOf('الأزرار'), FontWeight.w700);
    expect(weightOf('الرئيسية'), isNot(FontWeight.w700));
  });

  testWidgets('an unread count is text, and clears when it reaches zero', (
    tester,
  ) async {
    await pumpSide(tester, extended: true);
    expect(find.text('3'), findsOneWidget);

    unread.value = 0;
    await tester.pump();
    expect(find.text('3'), findsNothing);
  });

  testWidgets('the unread badge is a small pill, not a stripe the row tall', (
    tester,
  ) async {
    for (final extended in <bool>[true, false]) {
      await pumpSide(tester, extended: extended);

      // The badge is the red box around the number.
      final box = find.ancestor(
        of: find.text('3'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).borderRadius != null,
        ),
      );
      final size = tester.getSize(box.first);
      // A Container that centres its text with `alignment` grows to the full
      // height of the 48dp row it sits in.
      expect(size.height, lessThan(26), reason: 'extended: $extended');
      expect(size.width, lessThan(40), reason: 'extended: $extended');
    }
  });

  testWidgets('a compact-height window keeps only the destinations', (
    tester,
  ) async {
    await pumpSide(
      tester,
      extended: false,
      short: true,
      size: TestDevices.phoneLandscape,
      config: const AppSideNavConfig(),
    );
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    // No brand, settings, account or collapse button to push them off.
    expect(find.byTooltip('إظهار الشريط الجانبي أو إخفاؤه'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('survives a 1.3x system font without overflowing', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: AppSideNav(
          controller: controller,
          destinations: destinations(),
          extended: false,
        ),
      ),
      surfaceSize: TestDevices.tablet,
      textScale: 1.3,
      fullScreen: true,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in both themes, in both directions', (tester) async {
    for (final brightness in Brightness.values) {
      for (final direction in TextDirection.values) {
        await pumpApp(
          tester,
          AppSideNav(
            controller: controller,
            destinations: destinations(),
            extended: true,
            config: const AppSideNavConfig(
              showAccount: false,
              showThemeToggle: false,
              collapsible: false,
            ),
          ),
          brightness: brightness,
          textDirection: direction,
          surfaceSize: TestDevices.desktop,
          fullScreen: true,
        );
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('a list leaves room for the capsule only where there is one', (
    tester,
  ) async {
    late double phone;
    late double desktop;
    await pumpApp(
      tester,
      Builder(
        builder: (context) {
          phone = AppBottomNav.listBottomPadding(context);
          return const SizedBox.shrink();
        },
      ),
      fullScreen: true,
    );
    await pumpApp(
      tester,
      Builder(
        builder: (context) {
          desktop = AppBottomNav.listBottomPadding(context);
          return const SizedBox.shrink();
        },
      ),
      surfaceSize: TestDevices.desktop,
      fullScreen: true,
    );
    expect(phone, greaterThan(desktop));
  });
}
