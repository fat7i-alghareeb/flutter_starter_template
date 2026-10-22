import 'dart:io';
import 'dart:math';

import 'setup/runner_patches.dart';

/// Sets the project up for its desktop platforms. Run it once after
/// `flutter create` and `mason make` — in either order — and again whenever you
/// add a platform (`flutter create --platforms=windows,macos .`):
///
/// ```bash
/// dart run tool/setup_project.dart
/// ```
///
/// It does two things, both safe to repeat:
///
/// 1. Gives the project its own Windows toast GUID (`AppConfig.windowsToastGuid`),
///    replacing the placeholder. Windows files this app's toast notifications
///    under it and Inno Setup uses it to recognise an earlier install, so it is
///    one per project, for the project's lifetime.
/// 2. Patches the runner files `flutter create` wrote into `windows/` and
///    `macos/` — a window that stays hidden until its first frame, a link
///    forwarded to the running copy, the network entitlement a sandboxed Mac app
///    cannot do without, and the build-warning fixes. A file it does not
///    recognise is reported and left alone; `docs/DESKTOP_SETUP.md` lists the
///    same edits by hand.
///
/// A phones-only project has neither folder, and nothing happens to it.
///
/// Plain Dart with no packages, on purpose: it runs anywhere `dart` does, with
/// nothing to download or compile first.
void main() {
  final root = Directory.current.path;
  stdout.writeln('Setting up {{project_title}}…');

  _giveItsOwnGuid(root);

  final windows = Directory('$root/windows');
  final macos = Directory('$root/macos');
  if (!windows.existsSync() && !macos.existsSync()) {
    stdout.writeln(
      'No windows/ or macos/ folder — nothing to patch. Add one with '
      '`flutter create --platforms=windows,macos .` and run this again.',
    );
    return;
  }

  final appLinks = File('$root/lib/core/router/app_links.dart');
  final scheme = linkSchemeFrom(
    appLinks.existsSync() ? appLinks.readAsStringSync() : null,
  );

  var problems = 0;

  void patch(String relative, PatchResult Function(String source) patcher) {
    final file = File('$root/$relative');
    if (!file.existsSync()) return;
    final result = patcher(file.readAsStringSync());
    switch (result.outcome) {
      case PatchOutcome.patched:
        file.writeAsStringSync(result.text);
        stdout.writeln('  patched          $relative');
      case PatchOutcome.alreadyPatched:
        stdout.writeln('  already patched  $relative');
      case PatchOutcome.notFound:
        problems++;
        stdout.writeln(
          '  CHECK            $relative does not look the way this script '
          'expects — left as it is. See docs/DESKTOP_SETUP.md.',
        );
    }
  }

  if (windows.existsSync()) {
    patch('windows/CMakeLists.txt', patchWindowsCMake);
    patch('windows/CMakeLists.txt', patchWindowsCMakePolicy);
    patch('windows/CMakeLists.txt', patchWindowsLinkerNoise);
    patch('windows/CMakeLists.txt', patchWindowsAwaitFlag);
    patch('windows/runner/flutter_window.cpp', patchWindowsFlutterWindow);
    patch('windows/runner/main.cpp', patchWindowsMain);
  }
  if (macos.existsSync()) {
    patch('macos/Runner/MainFlutterWindow.swift', patchMacosMainWindow);
    patch('macos/Runner/DebugProfile.entitlements', patchMacosEntitlements);
    patch('macos/Runner/Release.entitlements', patchMacosEntitlements);
    patch(
      'macos/Runner/Info.plist',
      (source) => patchMacosInfoPlist(source, scheme),
    );
  }

  if (problems == 0) {
    stdout.writeln('Done.');
  } else {
    stdout.writeln('Done, with $problems file(s) to check by hand.');
    exitCode = 1;
  }
}

/// The placeholder `app_config.dart` ships with; replaced once per project.
const String windowsToastGuidPlaceholder = '00000000-0000-4000-8000-000000000000';

void _giveItsOwnGuid(String root) {
  final file = File('$root/lib/core/config/app_config.dart');
  if (!file.existsSync()) return;
  final source = file.readAsStringSync();
  if (!source.contains(windowsToastGuidPlaceholder)) {
    stdout.writeln('  kept             this project\'s Windows toast GUID');
    return;
  }
  file.writeAsStringSync(
    source.replaceFirst(windowsToastGuidPlaceholder, uuidV4()),
  );
  stdout.writeln('  created          a Windows toast GUID in lib/core/config/app_config.dart');
}

/// A random (version 4) UUID, lower case, from the secure generator.
String uuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int from, int to) => bytes
      .sublist(from, to)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
