import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_status_bar_scrim.dart';

/// The band behind the status bar: absent while the page's picture is under
/// it, present once the picture has scrolled past — so text never runs under
/// the clock.
void main() {
  Future<ScrollController> pump(WidgetTester tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.only(top: 40),
          ),
          child: AppStatusBarScrim(
            controller: controller,
            showAfter: 200,
            child: ListView(
              controller: controller,
              children: const <Widget>[SizedBox(height: 3000)],
            ),
          ),
        ),
      ),
    );
    return controller;
  }

  double opacity(WidgetTester tester) =>
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

  testWidgets('hidden over the picture, shown once it has scrolled past', (
    tester,
  ) async {
    final controller = await pump(tester);
    expect(opacity(tester), 0);

    controller.jumpTo(150);
    await tester.pump();
    expect(opacity(tester), 0, reason: 'the picture is still under it');

    controller.jumpTo(260);
    await tester.pump();
    expect(opacity(tester), 1);
  });

  testWidgets('it is exactly the status bar tall', (tester) async {
    await pump(tester);
    final box = tester.getSize(
      find.descendant(
        of: find.byType(AnimatedOpacity),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(box.height, 40);
  });
}
