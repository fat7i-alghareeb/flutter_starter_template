/// Text patches for the files `flutter create` writes into `windows/` and
/// `macos/`.
///
/// Pure functions of the file's text, so each one is safe to run twice (`tool/setup_project.dart` runs them):
/// every patch answers with a [PatchOutcome], and a file this Flutter
/// version laid out differently is reported, never half-edited.
library;

enum PatchOutcome {
  /// The text changed.
  patched,

  /// The patch was already in the file.
  alreadyPatched,

  /// The file does not look the way the patch expects.
  notFound,
}

class PatchResult {
  const PatchResult(this.outcome, this.text);

  final PatchOutcome outcome;
  final String text;
}

/// windows/CMakeLists.txt — let plugins that still use the old coroutine
/// header build with the newest Visual Studio.
///
/// permission_handler_windows includes `<experimental/coroutine>`. MSVC 14.51
/// (Visual Studio 2026) turned that header's deprecation notice into a hard
/// error (STL1011), and the plugin has no release that avoids it. The error
/// message names the switch; defining it project-wide keeps every plugin
/// building on old and new toolchains alike. Remove it once the plugins move
/// to C++20 `<coroutine>`.
PatchResult patchWindowsCMake(String source) {
  const define = '_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS';
  if (source.contains(define)) {
    return PatchResult(PatchOutcome.alreadyPatched, source);
  }
  const anchor = 'add_definitions(-DUNICODE -D_UNICODE)';
  if (!source.contains(anchor)) {
    return PatchResult(PatchOutcome.notFound, source);
  }
  return PatchResult(
    PatchOutcome.patched,
    source.replaceFirst(
      anchor,
      '$anchor\n'
      '# Plugins that still include <experimental/coroutine> fail on MSVC 14.51+\n'
      '# without this (STL1011); see tool/setup/runner_patches.dart.\n'
      'add_definitions(-D$define)',
    ),
  );
}

/// windows/CMakeLists.txt — silence two linker warnings that come from
/// prebuilt third-party libraries and that the app cannot act on.
///
/// - **LNK4099** («PDB … was not found; linking object as if no debug
///   info»): the Firebase C++ SDK's `.lib` files point at `.pdb` files the SDK
///   does not ship. Nothing is wrong with the program; only stepping into
///   Firebase's own code in a debugger is lost. Fixing it would mean Google
///   shipping the PDBs or this project rebuilding the SDK.
/// - **LNK4078** («multiple `.voltbl` sections found with different
///   attributes»): Microsoft's own `msvcprtd.lib` meeting prebuilt code. The
///   cause is not documented anywhere I could find, and the link succeeds.
///
/// This hides the messages; it does not remove their cause. Drop it, and see
/// what the build says, after raising the Firebase or Visual Studio version.
PatchResult patchWindowsLinkerNoise(String source) {
  const flag = '/ignore:4099';
  if (source.contains(flag)) {
    return PatchResult(PatchOutcome.alreadyPatched, source);
  }
  const anchor = 'add_definitions(-DUNICODE -D_UNICODE)';
  if (!source.contains(anchor)) {
    return PatchResult(PatchOutcome.notFound, source);
  }
  return PatchResult(
    PatchOutcome.patched,
    source.replaceFirst(
      anchor,
      '$anchor\n'
      '# Prebuilt libraries without PDBs (Firebase C++ SDK) and Microsoft\'s own\n'
      '# msvcprtd.lib: harmless linker warnings, hidden on purpose;\n'
      '# see tool/setup/runner_patches.dart.\n'
      'add_link_options($flag /ignore:4078)',
    ),
  );
}

/// windows/CMakeLists.txt — stop `permission_handler_windows` passing the
/// deprecated `/await` switch.
///
/// The plugin asks for C++20 (`cxx_std_20`) and ALSO passes `/await`, the
/// switch for the pre-C++20 coroutine extension. MSVC 14.51 reports it on
/// every build: «command line warning D9047: option 'await' has been
/// deprecated and will be removed in a future release». With C++20 on, the
/// standard coroutines need no switch, so the plugin builds without it —
/// checked with a clean build: 0 warnings, 0 errors.
///
/// Not hidden with `/wd9047`: `/wd` takes compiler warning numbers only, and
/// `9047` is a driver warning, so that switch earns a warning of its own
/// (D9014, once per target).
///
/// The switch is removed from that one target after the plugins are added,
/// so the plugin's files are untouched. Drop this when the plugin stops
/// passing `/await`.
PatchResult patchWindowsAwaitFlag(String source) {
  const marker = '_ph_opts';
  if (source.contains(marker)) {
    return PatchResult(PatchOutcome.alreadyPatched, source);
  }
  const anchor = 'include(flutter/generated_plugins.cmake)';
  if (!source.contains(anchor)) {
    return PatchResult(PatchOutcome.notFound, source);
  }
  return PatchResult(
    PatchOutcome.patched,
    source.replaceFirst(
      anchor,
      '$anchor\n'
      '\n'
      '# permission_handler_windows asks for C++20 and still passes /await, which\n'
      '# MSVC 14.51 reports as deprecated (D9047) on every build. C++20 coroutines\n'
      '# need no switch; see tool/setup/runner_patches.dart.\n'
      'if(TARGET permission_handler_windows_plugin)\n'
      '  get_target_property(_ph_opts permission_handler_windows_plugin COMPILE_OPTIONS)\n'
      '  if(_ph_opts)\n'
      '    list(REMOVE_ITEM _ph_opts /await)\n'
      '    set_target_properties(permission_handler_windows_plugin\n'
      '      PROPERTIES COMPILE_OPTIONS "\${_ph_opts}")\n'
      '  endif()\n'
      'endif()',
    ),
  );
}

/// windows/CMakeLists.txt — keep CMake quiet about a plugin's FetchContent.
///
/// objectbox_flutter_libs downloads its native library with
/// `FetchContent_Populate(<name>)` called directly, which CMake 3.30+ flags
/// on every configure (policy CMP0169: «call FetchContent_MakeAvailable
/// instead»). It is the plugin's code and ObjectBox 5.3.2 is its newest stable
/// release, so the project answers the policy itself.
///
/// `CMAKE_POLICY_DEFAULT_CMP0169`, not `cmake_policy(SET …)`: the plugin
/// begins with `cmake_policy(VERSION 3.14...3.25)`, which leaves every newer
/// policy UNSET inside its folder — a policy set at the top level would be
/// wiped there. The DEFAULT variable is what CMake consults for an unset
/// policy, so it holds in the plugin too. The OLD behaviour is still fully
/// supported. Remove this when the plugin moves to `FetchContent_MakeAvailable`.
PatchResult patchWindowsCMakePolicy(String source) {
  const variable = 'CMAKE_POLICY_DEFAULT_CMP0169';
  if (source.contains(variable)) {
    return PatchResult(PatchOutcome.alreadyPatched, source);
  }
  const anchor = 'include(flutter/generated_plugins.cmake)';
  if (!source.contains(anchor)) {
    return PatchResult(PatchOutcome.notFound, source);
  }
  return PatchResult(
    PatchOutcome.patched,
    source.replaceFirst(
      anchor,
      '# objectbox_flutter_libs calls FetchContent_Populate directly (CMP0169);\n'
      '# see tool/setup/runner_patches.dart.\n'
      'set($variable OLD)\n'
      '$anchor',
    ),
  );
}

/// windows/runner/flutter_window.cpp — keep the window hidden after the
/// first frame.
///
/// The Flutter template shows the window from `SetNextFrameCallback`, at
/// the runner's default size. The app restores its own size and place first
/// (`AppWindow.showWhenReady`), then shows it; showing here as well would
/// flash a window at 1280×720 and then move it.
PatchResult patchWindowsFlutterWindow(String source) {
  const done = 'AppWindow.showWhenReady';
  if (source.contains(done)) {
    return PatchResult(PatchOutcome.alreadyPatched, source);
  }
  final pattern = RegExp(
    r'(SetNextFrameCallback\(\[&\]\(\)\s*\{)\s*this->Show\(\);\s*(\}\))',
  );
  if (!pattern.hasMatch(source)) {
    return PatchResult(PatchOutcome.notFound, source);
  }
  return PatchResult(
    PatchOutcome.patched,
    source.replaceFirstMapped(
      pattern,
      (m) =>
          '${m[1]}\n'
          '    // Not shown here: Dart restores the window\'s size and place,\n'
          '    // then shows it (`$done`, window_manager).\n'
          '  ${m[2]}',
    ),
  );
}

/// windows/runner/main.cpp — a second launch forwards its link to the
/// window that is already open, and exits (app_links).
PatchResult patchWindowsMain(String source) {
  const include = '#include "app_links/app_links_plugin_c_api.h"';
  if (source.contains('SendAppLinkToInstance')) {
    return PatchResult(PatchOutcome.alreadyPatched, source);
  }
  const entry = 'int APIENTRY wWinMain(';
  final start = source.indexOf(entry);
  if (start < 0 || !source.contains('#include <windows.h>')) {
    return PatchResult(PatchOutcome.notFound, source);
  }
  final brace = source.indexOf('{', start);
  if (brace < 0) return PatchResult(PatchOutcome.notFound, source);

  var out = source.replaceFirst(
    '#include <windows.h>',
    '#include <windows.h>\n\n$include',
  );
  final shifted = brace + '\n\n$include'.length;
  out =
      '${out.substring(0, shifted + 1)}\n'
      '  // A launch with a link (myapp://items/42) goes to the window that is\n'
      '  // already open, brings it forward, and this process exits.\n'
      '  if (SendAppLinkToInstance()) {\n'
      '    return EXIT_SUCCESS;\n'
      '  }\n'
      '${out.substring(shifted + 1)}';
  return PatchResult(PatchOutcome.patched, out);
}

/// macos/Runner/MainFlutterWindow.swift — create the window hidden, so
/// there is no empty rectangle before the first frame (window_manager's
/// «hidden at launch»).
PatchResult patchMacosMainWindow(String source) {
  if (source.contains('hiddenWindowAtLaunch')) {
    return PatchResult(PatchOutcome.alreadyPatched, source);
  }
  if (!source.contains('class MainFlutterWindow: NSWindow')) {
    return PatchResult(PatchOutcome.notFound, source);
  }
  var out = source;
  if (!out.contains('import window_manager')) {
    out = out.replaceFirst(
      'import FlutterMacOS',
      'import FlutterMacOS\nimport window_manager',
    );
  }
  final close = out.lastIndexOf('}');
  if (close < 0) return PatchResult(PatchOutcome.notFound, source);
  out =
      '${out.substring(0, close)}\n'
      '  // Created hidden; Dart shows the window once its first frame is on\n'
      '  // screen (`AppWindow.showWhenReady`).\n'
      '  override public func order(\n'
      '    _ place: NSWindow.OrderingMode, relativeTo otherWin: Int\n'
      '  ) {\n'
      '    super.order(place, relativeTo: otherWin)\n'
      '    hiddenWindowAtLaunch()\n'
      '  }\n'
      '}\n';
  return PatchResult(PatchOutcome.patched, out);
}

/// macos/Runner/*.entitlements — the app is sandboxed, and a sandboxed app
/// may not open a network connection unless it says so. Without
/// `com.apple.security.network.client` every request in a release build
/// fails with «Operation not permitted» (Flutter's macOS guide). The same
/// edit goes into both files.
PatchResult patchMacosEntitlements(String source) {
  const key = 'com.apple.security.network.client';
  if (source.contains(key)) {
    return PatchResult(PatchOutcome.alreadyPatched, source);
  }
  final close = source.lastIndexOf('</dict>');
  if (close < 0) return PatchResult(PatchOutcome.notFound, source);
  return PatchResult(
    PatchOutcome.patched,
    '${source.substring(0, close)}'
    '\t<key>$key</key>\n\t<true/>\n'
    '${source.substring(close)}',
  );
}

/// macos/Runner/Info.plist — registers the app's URL scheme, so
/// `myapp://items/42` opens it (app_links).
PatchResult patchMacosInfoPlist(String source, String scheme) {
  if (source.contains('CFBundleURLTypes')) {
    return PatchResult(PatchOutcome.alreadyPatched, source);
  }
  final close = source.lastIndexOf('</dict>');
  if (close < 0) return PatchResult(PatchOutcome.notFound, source);
  return PatchResult(
    PatchOutcome.patched,
    '${source.substring(0, close)}'
    '\t<key>CFBundleURLTypes</key>\n'
    '\t<array>\n'
    '\t\t<dict>\n'
    '\t\t\t<key>CFBundleURLName</key>\n'
    '\t\t\t<string>$scheme</string>\n'
    '\t\t\t<key>CFBundleURLSchemes</key>\n'
    '\t\t\t<array>\n'
    '\t\t\t\t<string>$scheme</string>\n'
    '\t\t\t</array>\n'
    '\t\t</dict>\n'
    '\t</array>\n'
    '${source.substring(close)}',
  );
}

/// The app's link scheme, read from the Dart constant it is declared in —
/// one place to change it. `myapp` when the file cannot be read.
String linkSchemeFrom(String? appLinksSource) {
  if (appLinksSource == null) return 'myapp';
  final match = RegExp(
    r'''static const String scheme = ['"]([^'"]+)['"]''',
  ).firstMatch(appLinksSource);
  return match?[1] ?? 'myapp';
}
