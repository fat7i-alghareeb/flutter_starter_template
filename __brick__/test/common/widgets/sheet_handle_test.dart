import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// One drag handle per sheet.
///
/// The theme turns Material's handle on (`showDragHandle: true`, 34×4). A sheet shown on a TRANSPARENT modal draws its own
/// surface, and its own handle — and Material's was drawn as well, floating
/// on the scrim above it: two handles.
void main() {
  test('a sheet on a transparent modal turns the theme\'s handle off', () {
    final offenders = <String>[];
    final call = RegExp(r'showModalBottomSheet<[^>]*>\(([\s\S]*?)\n\s*\);');

    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final path = file.path.replaceAll(r'\', '/');
      if (path.contains('/stage_tools/')) continue;
      final source = file.readAsStringSync();
      for (final match in call.allMatches(source)) {
        final args = match.group(1)!;
        if (args.contains('backgroundColor: Colors.transparent') &&
            !args.contains('showDragHandle: false')) {
          offenders.add(path);
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
