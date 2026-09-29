import 'package:flutter/material.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_icons.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/app_bottom_nav.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';

import '../../helpers/test_app.dart';

void main() {
  const destinations = <AppNavDestination>[
    AppNavDestination(icon: AppIcons.home, label: 'الرئيسية'),
    AppNavDestination(icon: AppIcons.news, label: 'الأخبار'),
    AppNavDestination(icon: AppIcons.marketplace, label: 'السوق'),
    AppNavDestination(icon: AppIcons.store, label: 'المحلات'),
    // Literals here are TEST DATA, not app copy — the widget takes its
    // labels as parameters, so this proves it renders whatever it is given.
  ];

  late NavigationController controller;

  setUp(() => controller = NavigationController());
  tearDown(() => controller.dispose());

  Widget bar() =>
      AppBottomNav(controller: controller, destinations: destinations);

  group('AppBottomNav', () {
    testWidgets('shows exactly four destinations and no + button', (
      tester,
    ) async {
      // The `+` was cancelled with the scope change. Four items divide the
      // width; there is no hole in the middle where it used to sit.
      await pumpApp(tester, bar());

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الأخبار'), findsOneWidget);
      expect(find.text('السوق'), findsOneWidget);
      expect(find.text('المحلات'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('every item carries an icon AND a label', (tester) async {
      // `DESIGN_SYSTEM.md` → Accessibility: both, always. An icon-only bar is unreadable to
      // someone who does not recognise the glyph.
      await pumpApp(tester, bar());
      expect(find.byType(AppIcon), findsNWidgets(4));
    });

    // Owner's pick I B, 2026-09-28: an olive pill behind the active tab
    // slides to the next one, and the whole icon and word sit inside it.
    testWidgets('the pill slides to the tapped tab and holds it whole', (
      tester,
    ) async {
      await pumpApp(tester, bar(), fullScreen: true);

      final pill = find.byType(AnimatedAlign);
      expect(
        tester.widget<AnimatedAlign>(pill).alignment,
        const AlignmentDirectional(-1, 0),
      );

      await tester.tap(find.text('السوق'));
      await tester.pumpAndSettle();

      final at =
          tester.widget<AnimatedAlign>(pill).alignment as AlignmentDirectional;
      expect(at.start, closeTo(1 / 3, 1e-9));
      final pillBox = tester.getRect(
        find.descendant(of: pill, matching: find.byType(DecoratedBox)).first,
      );
      final word = tester.getRect(find.text('السوق'));
      final icon = tester.getRect(find.byType(AppIcon).at(2));
      for (final part in <Rect>[word, icon]) {
        expect(pillBox.contains(part.topLeft), isTrue);
        expect(pillBox.contains(part.bottomRight), isTrue);
      }
    });

    testWidgets('the bar runs ahead of the page on a highlight', (
      tester,
    ) async {
      await pumpApp(tester, bar(), fullScreen: true);

      controller.highlight(3);
      await tester.pumpAndSettle();

      expect(
        tester.widget<AnimatedAlign>(find.byType(AnimatedAlign)).alignment,
        const AlignmentDirectional(1, 0),
      );
      expect(controller.currentIndex, 0);
    });

    testWidgets('tapping switches the active index', (tester) async {
      await pumpApp(tester, bar());
      expect(controller.currentIndex, 0);

      await tester.tap(find.text('السوق'));
      await tester.pumpAndSettle();

      expect(controller.currentIndex, 2);
    });

    testWidgets('the active item differs by colour AND weight', (tester) async {
      await pumpApp(tester, bar());

      // The style lives on the AnimatedDefaultTextStyle above each label, not
      // on the Text itself — reading `Text.style` here would give null and the
      // assertion would silently prove nothing.
      // `.first`: MaterialApp puts its own AnimatedDefaultTextStyle higher up,
      // so the ancestor chain has more than one. The nearest is the item's.
      TextStyle styleOf(String label) => tester
          .widget<AnimatedDefaultTextStyle>(
            find
                .ancestor(
                  of: find.text(label),
                  matching: find.byType(AnimatedDefaultTextStyle),
                )
                .first,
          )
          .style;

      final active = styleOf('الرئيسية');
      final inactive = styleOf('الأخبار');

      expect(active.fontWeight, FontWeight.w700);
      expect(inactive.fontWeight, FontWeight.w400);
      expect(active.color, isNot(inactive.color));
    });

    testWidgets('each item announces its position in the bar', (tester) async {
      // "2 of 4" is what makes a tab bar navigable without sight; a plain Row
      // gives a screen reader nothing to say.
      await pumpApp(tester, bar());

      final node = tester.getSemantics(find.text('الأخبار'));
      expect(node.value, AppStrings.a11yPositionOf(2, 4));
      expect(node, isSemantics(isButton: true));
    });

    testWidgets('every touch target clears 48dp', (tester) async {
      await pumpApp(tester, bar());
      for (final label in <String>['الرئيسية', 'الأخبار', 'السوق', 'المحلات']) {
        final size = tester.getSize(
          find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
        );
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('reserves enough bottom padding for a list to clear it', (
      tester,
    ) async {
      // A list that ignores this hides its last row behind the floating bar.
      late double padding;
      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            padding = AppBottomNav.listBottomPadding(context);
            return const SizedBox();
          },
        ),
      );
      expect(
        padding,
        greaterThanOrEqualTo(
          AppBottomNav.barHeight + AppBottomNav.bottomMargin,
        ),
      );
    });

    testWidgets('survives the narrowest supported screen', (tester) async {
      await pumpApp(tester, bar(), surfaceSize: TestDevices.small);
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a 1.3x system font', (tester) async {
      // Large-font users are common; an overflowing bar is the
      // first thing that breaks.
      await pumpApp(tester, bar(), textScale: 1.3);
      expect(tester.takeException(), isNull);
    });

    forEachBrightness('renders in both themes', (tester, brightness) async {
      final local = NavigationController();
      addTearDown(local.dispose);
      await pumpApp(
        tester,
        AppBottomNav(controller: local, destinations: destinations),
        brightness: brightness,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
