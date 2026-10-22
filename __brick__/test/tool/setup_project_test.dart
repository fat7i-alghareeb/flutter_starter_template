import 'package:flutter_test/flutter_test.dart';

import '../../tool/setup/runner_patches.dart';
import '../../tool/setup_project.dart';

/// `dart run tool/setup_project.dart` edits files `flutter create` wrote, so
/// each edit must be exact, and safe to run again. (It replaced Mason hooks,
/// which had to be compiled from Mason's cache on every machine and failed
/// there.)
void main() {
  group('the Windows CMake patches', () {
    // The two lines of the Flutter template the patches hang off.
    const template = '''
cmake_minimum_required(VERSION 3.14)
add_definitions(-DUNICODE -D_UNICODE)
include(flutter/generated_plugins.cmake)
''';

    const patches = <PatchResult Function(String)>[
      patchWindowsCMake,
      patchWindowsCMakePolicy,
      patchWindowsLinkerNoise,
      patchWindowsAwaitFlag,
    ];

    String applyAll(String source, PatchOutcome expected) {
      var text = source;
      for (final patch in patches) {
        final result = patch(text);
        expect(result.outcome, expected);
        text = result.text;
      }
      return text;
    }

    test('patch a fresh file, and say so', () {
      final text = applyAll(template, PatchOutcome.patched);
      expect(text, contains('_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS'));
      expect(text, contains('CMAKE_POLICY_DEFAULT_CMP0169'));
      expect(text, contains('/ignore:4099'));
      expect(text, contains('_ph_opts'));
      // `/wd9047` is not a valid `/wd` value: it earns a warning per target.
      expect(text, isNot(contains('/wd9047')));
    });

    test('change nothing the second time', () {
      final once = applyAll(template, PatchOutcome.patched);
      final twice = applyAll(once, PatchOutcome.alreadyPatched);
      expect(twice, once);
    });

    test('leave a file they do not recognise alone', () {
      for (final patch in patches) {
        final result = patch('something else entirely');
        expect(result.outcome, PatchOutcome.notFound);
        expect(result.text, 'something else entirely');
      }
    });
  });

  test('the link scheme is read from app_links.dart, or defaults', () {
    expect(linkSchemeFrom("static const String scheme = 'shop';"), 'shop');
    expect(linkSchemeFrom(null), 'myapp');
    expect(linkSchemeFrom('nothing here'), 'myapp');
  });

  test('a project GUID is a random version 4 UUID', () {
    final pattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final a = uuidV4();
    expect(a, matches(pattern));
    expect(uuidV4(), isNot(a));
    expect(a, isNot(windowsToastGuidPlaceholder));
  });
}
