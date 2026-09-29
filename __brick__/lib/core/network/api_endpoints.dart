/// Server paths, in one place.
///
/// These double as the keys `MockRoutes` (`core/config/mock_config.dart`)
/// matches on, so a path changed here must be changed there too.
class ApiEndpoints {
  ApiEndpoints._();

  // ── auth

  /// Exchanges credentials (or a platform sign-in token) for the app's own
  /// JWT pair. Adjust to your backend.
  static const String login = '/auth/login';

  /// Trades a refresh token for a new pair (`dio_client.dart`). Must not be
  /// empty: the refresh flow refuses to run against an empty path.
  static const String refreshToken = '/auth/refresh';

  /// Registers this device's push token: `POST {token, platform}`, with the
  /// session's `Authorization` when there is one (`PushTokenRegistrar`).
  /// Used only when FCM is enabled.
  static const String devices = '/devices';

  // ── showcase (the generated app's demo feed — delete with it)

  /// The paged demo list, `?page=` · `?limit=` · `?q=` · `?category=`.
  static const String showcaseFeed = '/showcase/feed';

  /// One demo item.
  static String showcaseFeedItem(String id) => '/showcase/feed/$id';

  /// The carousel section.
  static const String showcaseHighlights = '/showcase/highlights';

  /// The horizontal rail section.
  static const String showcasePicks = '/showcase/picks';
}
