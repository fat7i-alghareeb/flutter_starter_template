import 'dart:async';

import 'package:app_links/app_links.dart' as os_links;

import '../../utils/helpers/colored_print.dart';
import '../injection/injectable.dart';
import '../platform/app_platform.dart';
import 'app_links.dart';

/// Links that open the desktop app: `myapp://items/42`.
///
/// Phones and tablets get their links from the OS through the router
/// (`LinkDispatcher.didPushRouteInformation`). A desktop OS starts the app,
/// or tells the running one, through the `app_links` package instead:
///
/// - **Windows**: the scheme is registered by the installer — MSIX
///   `protocol_activation`, or the Inno Setup registry keys — and the
///   runner forwards a link to an app that is already open
///   (`SendAppLinkToInstance` in `windows/runner/main.cpp`, patched by
///   `hooks/post_gen.dart`).
/// - **macOS**: the scheme is declared in `Info.plist` (`CFBundleURLTypes`);
///   the plugin receives it, nothing else to wire.
///
/// Either way the link goes through `AppLinks.locationOf`, so a desktop link
/// opens exactly the pages a phone link can — and is held until the shell is
/// up, then opened over it (`LinkDispatcher`).
abstract final class DesktopLinks {
  static StreamSubscription<Uri>? _subscription;

  /// Opens the link the app was started with, and every one that arrives
  /// while it runs. Call once, after DI.
  static Future<void> initialize() async {
    if (!AppPlatform.isDesktop || _subscription != null) return;
    try {
      final links = os_links.AppLinks();
      final initial = await links.getInitialLink();
      if (initial != null) open(initial);
      _subscription = links.uriLinkStream.listen(
        open,
        onError: (Object e) => printY('[Links] desktop link stream failed: $e'),
      );
    } catch (e) {
      // No plugin (a test, a runner not patched): links simply do not open.
      printY('[Links] desktop links unavailable: $e');
    }
  }

  /// Opens [uri] if it is a link to one of the app's pages; ignores anything
  /// else.
  static void open(Uri uri) {
    final location = AppLinks.locationOf(uri);
    if (location == null) return;
    getIt<LinkDispatcher>().open(location);
  }
}
