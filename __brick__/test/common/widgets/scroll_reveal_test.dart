import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/scroll_reveal.dart';
import 'package:{{project_name}}/utils/constants/design_constants.dart';

import '../../helpers/test_app.dart';

/// The scroll entrance. A list that plays `.animate()` on BUILD runs the
/// entrance off screen — a list builds ahead of the viewport — and the user
/// never sees it. These pin that
/// the entrance waits for the item to actually come into view.
void main() {
  /// Opacity the item is drawn at right now.
  double opacityOf(WidgetTester tester, int index) {
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byKey(ValueKey<int>(index), skipOffstage: false),
            matching: find.byType(FadeTransition, skipOffstage: false),
          )
          .first,
    );
    return fade.opacity.value;
  }

  Widget list(ScrollController controller) => ListView.builder(
    controller: controller,
    // A generous cache so items far below the fold are BUILT — the case the
    // old entrance got wrong.
    scrollCacheExtent: const ScrollCacheExtent.pixels(2000),
    itemCount: 40,
    itemBuilder: (_, index) => SizedBox(
      key: ValueKey<int>(index),
      height: 120,
      child: Text('item $index'),
    ).revealOnScroll(),
  );

  testWidgets('items on screen rise in when the list first appears', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    // Pumped by hand: `pumpApp` waits out every entrance before returning.
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: list(controller))));

    // Started, not finished.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(opacityOf(tester, 0), lessThan(1));

    await tester.pumpAndSettle();
    expect(opacityOf(tester, 0), 1);
  });

  testWidgets('an item built below the fold waits until it scrolls in', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpApp(tester, list(controller), fullScreen: true);

    // Built in the cache, well below the 844dp screen — and still hidden,
    // however long the list sits there.
    await tester.pump(const Duration(seconds: 2));
    expect(opacityOf(tester, 12), 0);

    controller.jumpTo(12 * 120 - 400);
    await tester.pump();
    await tester.pump(AppDurations.listStagger * 6);
    await tester.pumpAndSettle();
    expect(opacityOf(tester, 12), 1);
  });

  testWidgets('an item scrolled back to from above drops in (mirror)', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpApp(tester, list(controller), fullScreen: true);

    // Far down, so the first items are thrown away, then back up: they are
    // rebuilt ABOVE the viewport while it moves up to them.
    controller.jumpTo(30 * 120);
    await tester.pumpAndSettle();
    controller.jumpTo(10 * 120);
    await tester.pumpAndSettle();
    controller.jumpTo(0);
    await tester.pump();
    await tester.pump();

    // Owner's pick C2: coming back into view from above is an entrance too.
    expect(opacityOf(tester, 0), lessThan(1));
    await tester.pumpAndSettle();
    expect(opacityOf(tester, 0), 1);
  });

  testWidgets('reduced motion shows every item at once', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpApp(
      tester,
      list(controller),
      fullScreen: true,
      disableAnimations: true,
      settle: false,
    );
    await tester.pump();

    expect(opacityOf(tester, 0), 1);
    expect(opacityOf(tester, 12), 1);
  });

  testWidgets('an item not yet risen is still in the semantics tree', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpApp(tester, list(controller), fullScreen: true);

    expect(opacityOf(tester, 12), 0);
    expect(
      find.bySemanticsLabel('item 12', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('a tile in a grid that never scrolls waits for the PAGE', (
    tester,
  ) async {
    // The store's category and photo grids: `shrinkWrap`, never scrolling,
    // one section of a page that does. Measured against the grid itself
    // every tile would count as on screen and play at once.
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpApp(
      tester,
      ListView(
        controller: controller,
        children: <Widget>[
          // Below the 844dp screen, inside the list's 250dp build cache.
          const SizedBox(height: 1000),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              for (var i = 0; i < 4; i++)
                SizedBox(key: ValueKey<int>(i)).revealOnScroll(),
            ],
          ),
        ],
      ),
      fullScreen: true,
    );

    expect(opacityOf(tester, 0), 0);

    controller.jumpTo(800);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(opacityOf(tester, 0), 1);
  });

  test('each() wraps the blocks and leaves the gaps alone', () {
    final wrapped = ScrollReveal.each(<Widget>[
      const Text('a'),
      const SizedBox(height: 8),
      const Divider(),
      const Text('b', key: ValueKey<String>('b')),
    ]);

    expect(wrapped[0], isA<ScrollReveal>());
    expect(wrapped[1], isA<SizedBox>());
    expect(wrapped[2], isA<Divider>());
    expect(wrapped[3].key, const ScrollRevealKey(ValueKey<String>('b')));
  });

  test('the wrapper key never equals the row key it sits beside', () {
    const Key wrapper = ScrollRevealKey('a');
    const Key row = ValueKey<String>('a');
    expect(wrapper == row, isFalse);
  });
}
