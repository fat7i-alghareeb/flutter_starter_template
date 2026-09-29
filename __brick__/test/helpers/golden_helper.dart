import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

/// Golden (screenshot) tests.
///
/// A golden catches what an assertion cannot: spacing that drifted, a badge
/// that wrapped, a dark-mode colour that turned invisible. It is the only test
/// type that checks the thing the user actually sees.
///
/// Two rules make them worth keeping rather than a running cost:
///
/// 1. **Real fonts are loaded.** Without this every glyph renders as a filled
///    box, so the image proves nothing about Arabic text and a font regression
///    is invisible.
/// 2. **They are tagged `golden`.** Text rasterises slightly differently per
///    platform, so a baseline generated on Windows will not match byte-for-byte
///    on a Linux CI runner. `flutter test` skips them by default; run them
///    deliberately with `--tags golden`, and regenerate with
///    `flutter test --tags golden --update-goldens`.

/// Loads Tajawal into the test binding.
///
/// Call once in `setUpAll` of any golden test file.
Future<void> loadTestFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const faces = <String>[
    'assets/fonts/Tajawal-Regular.ttf',
    'assets/fonts/Tajawal-Medium.ttf',
    'assets/fonts/Tajawal-Bold.ttf',
    'assets/fonts/Tajawal-ExtraBold.ttf',
  ];

  final loader = FontLoader('Tajawal');
  for (final path in faces) {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError(
        'Missing font $path. Goldens without the real font render every glyph '
        'as a box and prove nothing.',
      );
    }
    loader.addFont(
      Future<ByteData>.value(file.readAsBytesSync().buffer.asByteData()),
    );
  }
  await loader.load();
}

/// Pumps [child] and compares it against `test/goldens/<name>.png`.
///
/// Runs in both themes by default — dark mode swaps shadows for borders, so a
/// widget checked only in light can be visibly wrong in dark.

void goldenTest(
  String name,
  Widget Function() builder, {
  Size surfaceSize = TestDevices.reference,
  List<Brightness> brightnesses = Brightness.values,
  double textScale = 1,
}) {
  for (final brightness in brightnesses) {
    testWidgets('$name (${brightness.name})', (tester) async {
      await pumpApp(
        tester,
        builder(),
        brightness: brightness,
        surfaceSize: surfaceSize,
        textScale: textScale,
        // A golden of a half-finished animation is a flaky golden.
        disableAnimations: true,
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.${brightness.name}.png'),
      );
    }, tags: <String>['golden']);
  }
}
