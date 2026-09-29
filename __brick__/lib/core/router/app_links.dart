import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../utils/helpers/colored_print.dart';
import 'app_navigator.dart';

/// The pages a link from OUTSIDE the app may open.
///
/// A share link is `https://<host>/<page path>` — `https://example.com/items/42`.
/// Once its host is dropped it is a SHARE PATH (`/items/42`): the public
/// address of a page. It is not a route — pages live under the shell,
/// nested under whatever opened them — so [targetOf] turns it into the page
/// to push. A notification names the same pages by type and id
/// ([locationOfTarget]).
///
/// Nothing else is reachable from outside: not the tabs, not the account,
/// not `/login`. Opening an account screen from a URL would skip the
/// questions its own screens ask first.
///
/// **Setup** (Android intent-filter, iOS Associated Domains, the hosted
/// `assetlinks.json` / `apple-app-site-association`): see
/// `docs/ANDROID_RELEASE_SETUP.md` and `docs/IOS_SETUP.md`.
class AppLinks {
  AppLinks._();

  /// The web domains share links are written on. Replace with yours.
  static const Set<String> hosts = <String>{'example.com', 'www.example.com'};

  /// The custom scheme (`myapp://items/42`), without `://`. Replace with
  /// yours.
  static const String scheme = 'myapp';

  /// The pages a link may open, by the FIRST segment of their path. Every
  /// page listed here takes exactly the segments its own `AppPage.segment`
  /// has (`items/:id` → `/items/42`).
  static final Map<String, AppPage> linkable = <String, AppPage>{
    _firstSegment(AppPage.feedItem.segment): AppPage.feedItem,
  };

  /// Notification target types → the page they open, for
  /// [locationOfTarget]. Keep in step with what your backend sends.
  static final Map<String, AppPage> targetTypes = <String, AppPage>{
    'item': AppPage.feedItem,
  };

  /// `https://example.com/items/42` → `/items/42`.
  ///
  /// Also takes a bare location (`/items/42`, what the router hands the
  /// guard) and a custom-scheme link whose host is the first segment
  /// (`myapp://items/42`). Anything that is not a [linkable] page is `null`.
  static String? locationOf(Uri uri) {
    final List<String> segments;
    final uriScheme = uri.scheme.toLowerCase();

    if (uriScheme == 'http' || uriScheme == 'https') {
      if (!hosts.contains(uri.host.toLowerCase())) return null;
      segments = uri.pathSegments;
    } else if (uriScheme.isEmpty) {
      segments = uri.pathSegments;
    } else if (uriScheme == scheme) {
      segments = <String>[
        if (uri.host.isNotEmpty) uri.host,
        ...uri.pathSegments,
      ];
    } else {
      return null;
    }

    final parts = segments.where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    final page = linkable[parts.first];
    if (page == null) return null;
    if (parts.length != page.segment.split('/').length) return null;

    return '/${parts.map(Uri.encodeComponent).join('/')}';
  }

  /// The page a notification points at, from its target fields.
  static String? locationOfTarget({String? type, String? id}) {
    if (id == null || id.isEmpty) return null;
    final page = targetTypes[type];
    if (page == null) return null;
    final parts = page.segment.split('/');
    // One parameter per page: the id.
    return '/${parts.map((p) => p.startsWith(':') ? Uri.encodeComponent(id) : p).join('/')}';
  }

  /// The link to share for an item: `https://example.com/items/42`.
  static String shareUrlOf(String itemId) {
    final location = locationOfTarget(type: 'item', id: itemId) ?? '/';
    return Uri(scheme: 'https', host: hosts.first, path: location).toString();
  }

  /// The page a share path opens: `/items/42` → the item `42`.
  /// Anything [locationOf] would not accept is `null`.
  static AppTarget? targetOf(String sharePath) {
    final location = locationOf(Uri.parse(sharePath));
    if (location == null) return null;
    // `pathSegments` hands the segments back decoded.
    final parts = Uri.parse(location).pathSegments;
    final page = linkable[parts.first]!;
    final template = page.segment.split('/');

    final params = <String, String>{
      for (var i = 0; i < template.length; i++)
        if (template[i].startsWith(':')) template[i].substring(1): parts[i],
    };
    return AppTarget(page, params: params);
  }

  static String _firstSegment(String pagePath) =>
      pagePath.split('/').firstWhere((part) => part.isNotEmpty);
}

/// Opens a link from outside the app OVER the shell — never instead of it.
///
/// go_router treats a link from the platform as `go`: it REPLACES the
/// stack, so the linked page would open with nothing under it and back
/// would leave the app. On a cold start it is worse: the guard sends the
/// link to the splash while the app boots, and it is gone by the time the
/// shell comes up.
///
/// So links come here first. This observer is registered before the
/// router's own (`bootstrap`), and the binding stops at the first observer
/// that answers `true`: a link to one of [AppLinks]' pages is pushed over
/// whatever is showing, and one that arrives while the app is still
/// starting is HELD until `RootScreen` says the shell is up — then pushed,
/// so back lands on the first tab. A notification tap takes the same road.
@lazySingleton
class LinkDispatcher with WidgetsBindingObserver {
  GoRouter? _router;
  bool _shellReady = false;
  String? _pending;

  /// The link waiting for the shell, if one is.
  @visibleForTesting
  String? get pending => _pending;

  /// Handed the router by `AppRouterConfig` as soon as it exists — it
  /// cannot be asked for through the container, because the router's guard
  /// needs this object first.
  void attach(GoRouter router) => _router = router;

  /// Called by `RootScreen` once it is on screen: a held link opens now.
  void shellReady() {
    _shellReady = true;
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    _push(pending);
  }

  /// Called by `RootScreen` when it leaves the tree.
  void shellGone() => _shellReady = false;

  /// Opens [location] over the shell now, or as soon as the shell is up.
  void open(String location) {
    if (_shellReady && _router != null) {
      _push(location);
    } else {
      hold(location);
    }
  }

  /// Keeps [location] until [shellReady]. The newest link wins: a reader
  /// who tapped two links before the app finished starting wants the last.
  void hold(String location) {
    printC('[Links] holding $location until the shell is up');
    _pending = location;
  }

  void _push(String location) {
    final router = _router;
    final target = AppLinks.targetOf(location);
    if (router == null || target == null) return;
    printG('[Links] opening $location over the shell');
    AppNavigator.pushTarget<void>(router, target);
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    final uri = routeInformation.uri;
    final location = AppLinks.locationOf(uri);
    if (location != null) {
      open(location);
      return SynchronousFuture<bool>(true);
    }

    // A link on the app's own domain that is not one of its pages — a
    // shortened or broken share. The app comes forward and stays where the
    // reader was; handing it to the router would `go` to a page that does
    // not exist.
    if (AppLinks.hosts.contains(uri.host.toLowerCase())) {
      printY('[Links] ignored $uri — not a page a link may open');
      return SynchronousFuture<bool>(true);
    }

    return SynchronousFuture<bool>(false);
  }
}
