/// Authentication-related constants such as storage keys and log tags.
class AuthStorageKeys {
  AuthStorageKeys._();

  static const String user = 'session.user';
  static const String guestFlag = 'session.guest';
  static const String jwtToken = 'session.jwt.token';
}

/// Extra fields used when persisting tokens.
class AuthTokenJsonFields {
  AuthTokenJsonFields._();

  static const String expiry = 'expiry';
}

/// Reasons used when manipulating authentication state.
class AuthReasons {
  AuthReasons._();

  static const String logout = 'logout';
  static const String guest = 'guest';

  /// The session ended without the reader asking: a refresh that failed, or
  /// a token the server revoked.
  static const String expired = 'expired';
}

/// Log tags for auth-related components.
class AuthLogTags {
  AuthLogTags._();

  static const String authManager = '[AuthManager]';
  static const String jwtTokenStorage = '[JwtTokenStorage]';
}
