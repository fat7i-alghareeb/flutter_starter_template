/// Switches for the local mock layer.
///
/// Turn it on with:
///
/// ```bash
/// flutter run --dart-define=USE_MOCK=true
/// ```
///
/// Everything here is a compile-time constant, so a build without the define
/// drops the mock code paths.
class MockConfig {
  MockConfig._();

  /// Serve every request that has a fixture from `assets/mock/` instead of
  /// the network.
  static const bool enabled = bool.fromEnvironment('USE_MOCK');

  /// Artificial latency, so loading skeletons are actually visible.
  ///
  /// Skeletons stay hidden below 300ms (`AppDurations.loaderThreshold`), so
  /// the default sits above that line — at 0ms they would never be seen.
  static const int delayMs = int.fromEnvironment(
    'MOCK_DELAY_MS',
    defaultValue: 600,
  );

  static const Duration delay = Duration(milliseconds: delayMs);

  /// Every request whose path contains one of these returns an empty list.
  ///
  /// For checking empty states without editing a fixture:
  /// `--dart-define=MOCK_EMPTY=/showcase/feed,/items`
  static const String _emptyRaw = String.fromEnvironment('MOCK_EMPTY');

  /// Same, but returns HTTP 500 — for checking error states.
  static const String _errorRaw = String.fromEnvironment('MOCK_ERROR');

  /// Fails every request as a connection error — for the offline state.
  static const bool offline = bool.fromEnvironment('MOCK_OFFLINE');

  static List<String> get emptyPaths => _split(_emptyRaw);

  static List<String> get errorPaths => _split(_errorRaw);

  /// The identity returned when signing in with mocks on.
  ///
  /// A platform sign-in dialog (Google, Apple…) is not an HTTP call, so it is
  /// the one thing `MockInterceptor` cannot fake. `AuthRepositoryImpl` uses
  /// these values instead of the dialog when [enabled]; everything after it —
  /// the session, the router — still runs for real. They live here, with every
  /// other mock switch, so all fake content is in one file.
  static const String userId = 'usr_demo';
  static const String userName = 'Demo User';
  static const String userEmail = 'demo@example.com';

  static List<String> _split(String raw) => raw.isEmpty
      ? const <String>[]
      : raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

/// Maps a request path to the fixture that answers it.
///
/// Kept as data rather than a chain of `if`s so adding an endpoint is one line,
/// and so the whole contract between the app and its fixtures is readable in
/// one place. The paths are the ones in `ApiEndpoints` — change one, change
/// both.
///
/// Order matters: the FIRST pattern that matches wins, so a specific path such
/// as `/items/featured` must be listed before `/items/{id}`.
class MockRoutes {
  MockRoutes._();

  /// `(path pattern, fixture)`. A `{id}` segment matches any single segment,
  /// and a `{id}` in the fixture name is filled with whatever matched it.
  ///
  /// Examples for your own features:
  ///
  /// ```dart
  /// ('/items/featured', 'assets/mock/items/featured.json'),
  /// ('/items/{id}/comments', 'assets/mock/items/comments_{id}.json'),
  /// ('/items/{id}', 'assets/mock/items/detail_{id}.json'),
  /// ('/items', 'assets/mock/items/list.json'),
  /// ```
  ///
  /// Remember to list every `assets/mock/<feature>/` folder in `pubspec.yaml`.
  static const List<(String, String)> _routes = <(String, String)>[
    // ── showcase (the generated app's demo feed — delete with it)
    // `#id={id}`: answer with the ONE item of the list whose `id` matches —
    // no file per item, and an unknown id is a real 404 (the «gone» state).
    ('/showcase/feed/{id}', 'assets/mock/showcase/feed.json#id={id}'),
    ('/showcase/feed', 'assets/mock/showcase/feed.json'),
    ('/showcase/highlights', 'assets/mock/showcase/highlights.json'),
    ('/showcase/picks', 'assets/mock/showcase/picks.json'),
  ];

  /// The fixture for [path], or null when nothing matches.
  static String? assetFor(String path, Map<String, dynamic> query) {
    final normalized = path.startsWith('/') ? path : '/$path';

    for (final (pattern, asset) in _routes) {
      if (!_matches(pattern, normalized)) continue;

      if (asset.contains('{id}')) {
        final id = _segmentFor(normalized, pattern, '{id}');
        if (id == null || id.isEmpty) return null;
        return asset.replaceAll('{id}', id);
      }
      return asset;
    }
    return null;
  }

  /// Pulls the value that filled [placeholder] (`{id}`).
  static String? _segmentFor(String path, String pattern, String placeholder) {
    final patternParts = pattern.split('/');
    final pathParts = path.split('?').first.split('/');

    for (var i = 0; i < patternParts.length && i < pathParts.length; i++) {
      if (patternParts[i] == placeholder) return pathParts[i];
    }
    return null;
  }

  static bool _matches(String pattern, String path) {
    final patternParts = pattern.split('/');
    final pathParts = path.split('?').first.split('/');
    if (patternParts.length > pathParts.length) return false;

    for (var i = 0; i < patternParts.length; i++) {
      final expected = patternParts[i];
      if (expected.startsWith('{') && expected.endsWith('}')) continue;
      if (expected != pathParts[i]) return false;
    }
    // A longer request path may still match a shorter pattern only when the
    // pattern is the generic collection route, e.g. `/items` vs `/items/`.
    return patternParts.length == pathParts.length ||
        patternParts.length == pathParts.length - 1 && pathParts.last.isEmpty;
  }
}
