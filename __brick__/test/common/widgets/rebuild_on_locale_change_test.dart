import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/rebuild_on_locale_change.dart';

/// Stands in for `AppStrings`: a word read from a global when a widget
/// builds, as every `'key'.tr()` is.
String _word = 'حسابي';

/// A language switch reaches every word on screen, and costs no state.
void main() {
  Widget app(Locale locale) => MaterialApp(
    home: RebuildOnLocaleChange(
      locale: locale,
      child: const Scaffold(body: _Screen()),
    ),
  );

  testWidgets('a widget with no reason to rebuild still takes the new '
      'language — and keeps its state', (tester) async {
    _word = 'حسابي';
    await tester.pumpWidget(app(const Locale('ar')));
    await tester.tap(find.byType(_Screen));
    await tester.pump();
    expect(find.text('حسابي 1'), findsOneWidget);

    _word = 'My account';
    await tester.pumpWidget(app(const Locale('en')));
    await tester.pump();

    expect(find.text('My account 1'), findsOneWidget);
  });
}

class _Screen extends StatefulWidget {
  const _Screen();

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _taps++),
    child: ColoredBox(
      color: Colors.transparent,
      child: SizedBox.expand(child: Center(child: Text('$_word $_taps'))),
    ),
  );
}
