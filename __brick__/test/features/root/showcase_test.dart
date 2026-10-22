import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/imports/imports.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/showcase/showcase_layout.dart';

import '../../helpers/test_app.dart';

/// The demo tabs sit in a centred, compact column (the language rule — no
/// hard-coded text — is enforced for all of `lib/` by
/// `test/l10n/app_strings_discipline_test.dart`).
void main() {
  group('ShowcasePage', () {
    Widget page(List<Widget> sections) => ShowcasePage(
      title: 'Title',
      subtitle: 'Subtitle',
      children: sections,
    );

    Widget button(String label) => AppButton.primary(
      onTap: () {},
      child: AppButtonChild.label(label),
    );

    testWidgets('the column is centred in a wide window, 840 at most', (
      tester,
    ) async {
      await pumpApp(
        tester,
        page(<Widget>[
          ShowcaseSection(title: 'S', children: <Widget>[button('a')]),
        ]),
        surfaceSize: const Size(1600, 900),
        fullScreen: true,
      );

      final divider = tester.getRect(find.byType(Divider));
      expect(divider.width, ShowcasePage.maxWidth);
      expect(divider.center.dx, closeTo(800, 1));
    });

    testWidgets('demos sit side by side and wrap, not one per line', (
      tester,
    ) async {
      await pumpApp(
        tester,
        page(<Widget>[
          ShowcaseSection(
            title: 'S',
            children: <Widget>[button('one'), button('two'), button('three')],
          ),
        ]),
        surfaceSize: const Size(1600, 900),
        fullScreen: true,
      );

      final tops = <double>[
        for (final label in <String>['one', 'two', 'three'])
          tester.getRect(find.text(label)).top,
      ];
      expect(tops[1], closeTo(tops[0], 1));
      expect(tops[2], closeTo(tops[0], 1));

      // On a phone the row is full, so they wrap.
      await pumpApp(
        tester,
        page(<Widget>[
          ShowcaseSection(
            title: 'S',
            children: <Widget>[
              button('a button with a long label'),
              button('another button with a long label'),
            ],
          ),
        ]),
        surfaceSize: TestDevices.small,
        fullScreen: true,
      );
      expect(
        tester.getRect(find.text('another button with a long label')).top,
        greaterThan(
          tester.getRect(find.text('a button with a long label')).top,
        ),
      );
    });

    testWidgets('nothing overflows at 320dp, 1.3× text, in both themes', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        await pumpApp(
          tester,
          page(<Widget>[
            ShowcaseSection(
              title: 'A section',
              children: <Widget>[button('one'), button('two')],
            ),
          ]),
          surfaceSize: TestDevices.small,
          textScale: 1.3,
          brightness: brightness,
          fullScreen: true,
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
