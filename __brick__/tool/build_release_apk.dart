// Builds a release APK and drops it on the Desktop.
//
// Run from the project root:
//   dart run tool/build_release_apk.dart            -> {{project_name}}.apk      (real network)
//   dart run tool/build_release_apk.dart --mock     -> {{project_name}}-mock.apk (assets/mock/)
//   dart run tool/build_release_apk.dart --clean    (combines with --mock)
//
// The flags match codemagic.yaml, so a local build is what CI ships.
// The Android side (signing, ABI filter, the mock flavour's id and label) is
// set up by following docs/ANDROID_RELEASE_SETUP.md; until then this still
// builds, just debug-signed and with every ABI a plugin brings:
//
//   --target-platform android-arm64   one APK, 64-bit ARM only (no --split-per-abi)
//   --obfuscate --split-debug-info    moves Dart symbols out of libapp.so
//   --mock                            USE_MOCK=true, plus its own package id
//                                     ({{package_name}}.mock) and
//                                     launcher name, so it installs beside the
//                                     real app instead of replacing it
//
// Pass --clean when the previous build used different ABI or AOT flags. Gradle's
// native-library merge is incremental and never drops stale per-ABI folders, so
// without it an APK can silently keep architectures from an earlier build. It
// deliberately does NOT run `flutter clean`: only the build caches that matter
// are removed, so the next build does not start from nothing.

import 'dart:io';

const _apkOutput = 'build/app/outputs/flutter-apk/app-release.apk';
const _symbolsOutput = 'build/symbols/app.android-arm64.symbols';

const _baseBuildArgs = <String>[
  'build',
  'apk',
  '--release',
  '-t',
  'lib/main.dart',
  '--target-platform',
  'android-arm64',
  '--obfuscate',
  '--split-debug-info=build/symbols',
];

/// Read by android/app/build.gradle.kts (docs/ANDROID_RELEASE_SETUP.md).
/// Left out for the real build, so it keeps the default package id and the
/// app's own label.
const _mockBuildArgs = <String>[
  '--dart-define=USE_MOCK=true',
  '--android-project-arg=appIdSuffix=.mock',
  '--android-project-arg=appLabel={{project_title}} Mock',
];

/// Architectures that must not appear in the release APK. Flutter's own
/// libraries are handled by --target-platform, but plugin AARs ship every ABI
/// and are filtered by the packaging rules in android/app/build.gradle.kts.
const _forbiddenAbis = <String>['lib/x86/', 'lib/x86_64/', 'lib/armeabi-v7a/'];

const _knownArgs = <String>{'--clean', '--mock'};

Future<void> main(List<String> args) async {
  final clean = args.contains('--clean');
  final mock = args.contains('--mock');
  final unknown = args.where((a) => !_knownArgs.contains(a)).toList();
  if (unknown.isNotEmpty) {
    _fail(
      'Unknown argument(s): ${unknown.join(' ')}\n'
      'Usage: dart run tool/build_release_apk.dart [--mock] [--clean]',
    );
  }

  if (!File('pubspec.yaml').existsSync()) {
    _fail('Run this from the project root (no pubspec.yaml here).');
  }

  if (!File('android/key.properties').existsSync()) {
    _log(
      'WARNING: android/key.properties is missing — this APK is signed with the '
      'DEBUG key and will not install over a release-signed one.',
    );
  }

  final desktop = _resolveDesktop();
  final baseName = mock ? '{{project_name}}-mock' : '{{project_name}}';
  final buildArgs = [..._baseBuildArgs, if (mock) ..._mockBuildArgs];

  final stopwatch = Stopwatch()..start();

  if (clean) {
    _log('Removing stale gradle intermediates and the AOT cache...');
    _deleteGradleIntermediates();
    _deleteAotCache();
  }

  await _runFlutterBuild(buildArgs);

  final apk = File(_apkOutput);
  if (!apk.existsSync()) {
    _fail('Build reported success but $_apkOutput is missing.');
  }

  // Flutter empties build/symbols on every build but only writes the symbols
  // file during the AOT step, so a build that reuses a cached snapshot leaves
  // the directory empty. An obfuscated APK whose symbols are gone produces
  // crash reports nobody can read, so force the AOT step to run again rather
  // than hand over an APK that can never be debugged.
  final symbols = File(_symbolsOutput);
  if (!symbols.existsSync()) {
    _log('');
    _log(
      'No symbols emitted — the AOT snapshot was reused from an earlier '
      'build.',
    );
    _log(
      'Clearing the AOT cache and rebuilding so the symbols match this APK.',
    );
    _deleteAotCache();
    await _runFlutterBuild(buildArgs);
    if (!symbols.existsSync()) {
      _fail(
        'Still no $_symbolsOutput after a full AOT rebuild.\n'
        'Refusing to publish an obfuscated APK whose crash reports could never '
        'be read.',
      );
    }
  }

  _verifyArchitectures(apk);
  stopwatch.stop();

  final separator = Platform.pathSeparator;
  final apkTargetPath = '$desktop$separator$baseName.apk';
  final symbolsTargetPath = '$desktop$separator$baseName.symbols';
  apk.copySync(apkTargetPath);
  symbols.copySync(symbolsTargetPath);

  final megabytes = (apk.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
  _log('');
  _log(
    'APK      $apkTargetPath  ($megabytes MB, ${mock ? 'mock data' : 'real network'})',
  );
  _log('Symbols  $symbolsTargetPath');
  _log('         Keep this next to the APK. Read a crash report back with:');
  _log('         flutter symbolize -i <stack_trace.txt> -d $baseName.symbols');
  _log('Built in ${stopwatch.elapsed.inSeconds}s.');
}

Future<void> _runFlutterBuild(List<String> buildArgs) async {
  _log('flutter ${buildArgs.join(' ')}');
  final build = await Process.start(
    'flutter',
    buildArgs,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await build.exitCode;
  if (exitCode != 0) {
    _fail('flutter build apk failed with exit code $exitCode.');
  }
}

void _deleteGradleIntermediates() {
  for (final path in ['build/app/intermediates', 'build/app/outputs']) {
    final dir = Directory(path);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}

/// Drops both AOT caches so the next build genuinely re-runs the AOT step.
///
/// Two of them exist and clearing either one alone is not enough: Flutter's own
/// build system caches under .dart_tool/flutter_build/, while gradle's Flutter
/// task caches its copy under build/app/intermediates/flutter/. With one warm,
/// app.so gets restored from cache without the AOT action executing — which
/// produces an APK but no symbols file.
///
/// Only build caches go. .dart_tool/package_config.json stays, so the next
/// build does not have to re-run `pub get`.
void _deleteAotCache() {
  for (final path in [
    '.dart_tool/flutter_build',
    'build/app/intermediates/flutter',
  ]) {
    final dir = Directory(path);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}

/// Scans the APK for entry names belonging to architectures this build should
/// not ship. Zip stores names uncompressed in both the local and central
/// headers, so a raw byte search is enough and needs no archive package.
void _verifyArchitectures(File apk) {
  final bytes = apk.readAsBytesSync();
  final found = <String>[];
  for (final abi in _forbiddenAbis) {
    if (_containsAscii(bytes, abi)) found.add(abi);
  }
  if (found.isEmpty) return;
  // A warning, not a failure: until the ABI filter from
  // docs/ANDROID_RELEASE_SETUP.md is in android/app/build.gradle.kts, plugin
  // libraries for every architecture are expected here.
  _log(
    'WARNING: APK contains ${found.join(', ')}.\n'
    '  - Without the ABI filter (docs/ANDROID_RELEASE_SETUP.md) plugins ship '
    'every architecture: add it for a smaller APK.\n'
    '  - With the filter in place, Gradle is packaging stale native libraries '
    'from an earlier build: re-run with --clean.',
  );
}

bool _containsAscii(List<int> haystack, String needle) {
  final pattern = needle.codeUnits;
  final last = haystack.length - pattern.length;
  outer:
  for (var i = 0; i <= last; i++) {
    for (var j = 0; j < pattern.length; j++) {
      if (haystack[i + j] != pattern[j]) continue outer;
    }
    return true;
  }
  return false;
}

/// Windows redirects the Desktop into OneDrive on plenty of machines, so try
/// the plain location first and fall back rather than guessing one of them.
String _resolveDesktop() {
  final home = Platform.isWindows
      ? Platform.environment['USERPROFILE']
      : Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    _fail('Could not resolve the home directory from the environment.');
  }

  final separator = Platform.pathSeparator;
  final candidates = <String>[
    '$home${separator}Desktop',
    '$home${separator}OneDrive${separator}Desktop',
  ];
  for (final candidate in candidates) {
    if (Directory(candidate).existsSync()) return candidate;
  }
  _fail('No Desktop directory found. Looked in:\n  ${candidates.join('\n  ')}');
}

void _log(String message) => stdout.writeln(message);

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
