import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/user_entity.dart';

/// Global reactive holder for the current user and authentication status.
///
/// This notifier is intended to be registered in DI and used as
/// `refreshListenable` for routing as well as a source of truth for widgets
/// and services that need to react to authentication changes.
@lazySingleton
class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier() : _authStatus = AuthStatus.initial();

  UserEntity? _user;
  bool _isGuest = false;
  bool _sessionExpired = false;
  AuthStatus _authStatus;

  /// The currently authenticated user, or `null` when unauthenticated.
  UserEntity? get user => _user;

  /// Whether the app is currently running in guest mode.
  bool get isGuest => _isGuest;

  /// A signed-in session ended without the reader asking — a refresh that
  /// failed, or a token the server revoked.
  ///
  /// In guest-first mode the reader keeps browsing as a guest and the app
  /// draws `SessionExpiredBanner` over itself while this holds; with the
  /// login wall the sign-in screen explains it. Signing in, or dismissing
  /// the banner, clears it. It lives in
  /// memory only: after a restart the reader is simply a guest, and there is
  /// nothing left to explain.
  bool get sessionExpired => _sessionExpired;

  /// The latest authentication status as reported by dio_refresh_bot.
  AuthStatus get authStatus => _authStatus;

  /// Returns `true` when a user is authenticated and not in guest mode.
  bool get isAuthenticated =>
      _authStatus.status == Status.authenticated && !isGuest;

  /// Returns `true` when the status is unauthenticated and not guest.
  bool get isUnauthenticated =>
      _authStatus.status == Status.unauthenticated && !isGuest;

  /// Updates the current [user] and notifies listeners.
  void setUser(UserEntity? user) {
    _user = user;
    notifyListeners();
  }

  /// Updates the guest flag and notifies listeners.
  void setGuest(bool value) {
    _isGuest = value;
    notifyListeners();
  }

  /// Raises or clears [sessionExpired].
  void setSessionExpired(bool value) {
    if (_sessionExpired == value) return;
    _sessionExpired = value;
    notifyListeners();
  }

  /// Updates the authentication status and notifies listeners.
  void setAuthStatus(AuthStatus status) {
    _authStatus = status;
    notifyListeners();
  }
}
