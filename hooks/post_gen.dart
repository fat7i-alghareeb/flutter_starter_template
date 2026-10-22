import 'dart:io';

import 'package:mason/mason.dart';

import 'src/runner_patches.dart';

/// Runs after `mason make`, in the generated project's folder.
///
/// `flutter create` wrote `windows/` and `macos/`, and the brick wrote
/// `lib/`. A desktop app needs a handful of edits in the first two — a
/// window that stays hidden until its first frame, a link forwarded to the
/// running copy, the network entitlement a sandboxed Mac app cannot do
/// without. They are made here, once, so nobody has to follow a checklist.
///
/// Nothing is required to succeed: a project made for phones only has
/// neither folder, and a file this Flutter version laid out differently is
/// reported and left alone (`docs/DESKTOP_SETUP.md` lists the same edits by
/// hand).
void run(HookContext context) {
  final logger = context.logger;
  final root = Directory.current.path;

  final windows = Directory('$root/windows');
  final macos = Directory('$root/macos');
  if (!windows.existsSync() && !macos.existsSync()) {
    logger.detail('No windows/ or macos/ folder — nothing to patch.');
    return;
  }

  final appLinks = File('$root/lib/core/router/app_links.dart');
  final scheme = linkSchemeFrom(
    appLinks.existsSync() ? appLinks.readAsStringSync() : null,
  );

  final progress = logger.progress('Setting up the desktop runners');
  var problems = 0;

  void patch(
    String relative,
    PatchResult Function(String source) patcher,
  ) {
    final file = File('$root/$relative');
    if (!file.existsSync()) return;
    final result = patcher(file.readAsStringSync());
    switch (result.outcome) {
      case PatchOutcome.patched:
        file.writeAsStringSync(result.text);
        logger.detail('patched $relative');
      case PatchOutcome.alreadyPatched:
        logger.detail('already patched: $relative');
      case PatchOutcome.notFound:
        problems++;
        logger.warn(
          '$relative does not look like this brick expects — left as it is. '
          'See docs/DESKTOP_SETUP.md for the edit to make by hand.',
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
    progress.complete('Desktop runners set up');
  } else {
    progress.fail('Desktop runners set up, with $problems file(s) to check');
  }
}
