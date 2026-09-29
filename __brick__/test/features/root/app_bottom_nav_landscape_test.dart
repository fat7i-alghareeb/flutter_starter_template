import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_icons.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/app_bottom_nav.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/test_app.dart';

/// The capsule on a short screen — the landscape treatment.
///
/// `DESIGN_SYSTEM.md` → Layout asks for the same layout at compressed heights, not a
/// second design: the four items, their icons AND their words all stay. What
/// changes is that the glyph sits beside its word rather than over it, and the
/// bar stops stretching across a screen far wider than it needs.
void main() {
  const destinations = <AppNavDestination>[
    AppNavDestination(icon: AppIcons.home, label: 'الرئيسية'),
    AppNavDestination(icon: AppIcons.news, label: 'الأخبار'),
    AppNavDestination(icon: AppIcons.marketplace, label: 'السوق'),
    AppNavDestination(icon: AppIcons.store, label: 'المحلات'),
  ];

  /// A landscape phone: wide, and short enough to count every dp of height.
  const landscape = Size(844, 390);

  /// The capsule itself: the `SizedBox` the bar gives its height to.
  final capsule = find.descendant(
    of: find.byType(AppBottomNav),
    matching: find.byType(SizedBox).first,
  );

  Future<void> pumpBar(WidgetTester tester, {required Size size}) async {
    final controller = NavigationController();
    addTearDown(controller.dispose);

    await pumpApp(
      tester,
      Align(
        alignment: Alignment.bottomCenter,
        child: AppBottomNav(controller: controller, destinations: destinations),
      ),
      surfaceSize: size,
      fullScreen: true,
    );
  }

  testWidgets('keeps all four destinations, with icon AND word', (
    tester,
  ) async {
    await pumpBar(tester, size: landscape);

    for (final destination in destinations) {
      expect(find.text(destination.label), findsOneWidget);
    }
    expect(find.byType(AppIcon), findsNWidgets(4));
  });

  testWidgets('is shorter than the portrait bar', (tester) async {
    await pumpBar(tester, size: landscape);
    final short = tester.getSize(capsule).height;

    await pumpBar(tester, size: TestDevices.reference);
    final tall = tester.getSize(capsule).height;

    expect(short, AppBottomNav.shortBarHeight);
    expect(tall, AppBottomNav.barHeight);
    expect(short, lessThan(tall));
  });

  testWidgets('stops stretching, and stays centred', (tester) async {
    await pumpBar(tester, size: landscape);

    final bar = tester.getRect(capsule);
    expect(bar.width, AppBottomNav.maxWidth);
    // Centred: the same gap either side of it.
    expect(bar.left, closeTo(landscape.width - bar.right, 0.5));
  });

  testWidgets('a list reserves the height the bar actually has', (
    tester,
  ) async {
    // The padding is computed from the same constant the bar draws with, so a
    // shorter bar gives its height back to the content instead of leaving a
    // gap — or, worse, covering the last row.
    late double landscapePadding;
    late double portraitPadding;

    await pumpApp(
      tester,
      Builder(
        builder: (context) {
          landscapePadding = AppBottomNav.listBottomPadding(context);
          return const SizedBox.shrink();
        },
      ),
      surfaceSize: landscape,
      fullScreen: true,
    );
    await pumpApp(
      tester,
      Builder(
        builder: (context) {
          portraitPadding = AppBottomNav.listBottomPadding(context);
          return const SizedBox.shrink();
        },
      ),
      fullScreen: true,
    );

    expect(
      portraitPadding - landscapePadding,
      AppBottomNav.barHeight - AppBottomNav.shortBarHeight,
    );
  });

  testWidgets('every item still names its position for a screen reader', (
    tester,
  ) async {
    await pumpBar(tester, size: landscape);

    // The position is the node's VALUE, not its label — the label is the
    // destination's own word. Through `AppFormats`, so «2 من 4» is spoken in
    // the reader's own numerals.
    final node = tester.getSemantics(find.text('الأخبار'));
    expect(node.value, AppStrings.a11yPositionOf('2', '4'));
  });
}
