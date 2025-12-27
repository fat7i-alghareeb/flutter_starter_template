import 'dart:async';
import 'dart:convert';

import 'package:dio_refresh_bot/dio_refresh_bot.dart';

import '../../../utils/constants/auth_constants.dart';
import '../../../utils/helpers/colored_print.dart';
import '../../domain/user_entity.dart';
import '../storage/storage_service.dart';
import 'auth_state_notifier.dart';
import 'auth_token_model.dart';
import 'jwt_token_storage.dart';

/// Defines how authentication is handled in the app.
///
/// Coordinates persisted user data, guest mode, and JWT token lifecycle via
/// [StorageService], [JwtTokenStorage], and [AuthStateNotifier].
enum AuthMode { withJwt, withoutJwt }

/// Central service responsible only for authentication concerns.
///
/// It exposes a simple API for login, logout, guest mode, user updates and
/// token updates, while keeping all persistence and reactive concerns hidden
/// behind dedicated collaborators.
class AuthManager {
  AuthManager._({
    required this.storage,
    required this.state,
    required this.mode,
    this.tokenStorage,
  });

  factory AuthManager.withJwt({
    required StorageService storage,
    required AuthStateNotifier state,
    required JwtTokenStorage tokenStorage,
  }) {
    return AuthManager._(
      storage: storage,
      state: state,
      mode: AuthMode.withJwt,
      tokenStorage: tokenStorage,
    );
  }

  factory AuthManager.withoutJwt({
    required StorageService storage,
    required AuthStateNotifier state,
  }) {
    return AuthManager._(
      storage: storage,
      state: state,
      mode: AuthMode.withoutJwt,
    );
  }

  final StorageService storage;
  final AuthStateNotifier state;
  final AuthMode mode;
  final JwtTokenStorage? tokenStorage;

  StreamSubscription<AuthStatus>? _tokenStatusSub;

  UserEntity? get currentUser => state.user;
  bool get isGuest => state.isGuest;
  bool get isAuthenticated => state.isAuthenticated;
  AuthStatus get authStatus => state.authStatus;

  /// Emits authentication status changes coming from dio_refresh_bot.
  Stream<AuthStatus>? get authStatusStream =>
      tokenStorage?.authenticationStatus;

  /// Initializes the manager by loading user and guest flag, and wiring token
  /// status updates when JWT mode is enabled.
  Future<void> initialize() async {
    printC('${AuthLogTags.authManager} initialize (mode: $mode)');
    await _loadUserFromStorage();

    // In non-JWT mode there is no token stream to update [AuthStatus], so we
    // must compute it once during initialization.
    if (mode == AuthMode.withoutJwt) {
      final shouldBeAuthenticated = state.user != null && !state.isGuest;
      state.setAuthStatus(
        shouldBeAuthenticated
            ? AuthStatus.authenticated()
            : AuthStatus.unauthenticated(message: 'No active session'),
      );
      return;
    }

    if (mode == AuthMode.withJwt && tokenStorage != null) {
      await tokenStorage!.initialize();

      // Make sure we don't stay in [Status.initial] while waiting for stream
      // emissions.
      if (state.authStatus.status == Status.initial) {
        state.setAuthStatus(
          AuthStatus.unauthenticated(message: 'No active session'),
        );
      }

      _tokenStatusSub = tokenStorage!.authenticationStatus.listen(
        _onAuthStatusChanged,
      );
    }
  }

  /// Disposes internal listeners and closes the underlying token storage.
  Future<void> dispose() async {
    await _tokenStatusSub?.cancel();
    tokenStorage?.close();
  }

  /// Logs in the given [user], persists their data and optionally stores JWT
  /// tokens when JWT mode is active.
  Future<void> login({required UserEntity user, AuthTokenModel? token}) async {
    printG('${AuthLogTags.authManager} login');

    await _persistUser(user);
    await _setGuest(false);

    // Update router-facing status immediately.
    state.setAuthStatus(AuthStatus.authenticated());

    if (mode == AuthMode.withJwt && tokenStorage != null && token != null) {
      await tokenStorage!.write(token);
    }
  }

  /// Logs out the current user, clears persisted data and removes tokens.
  Future<void> logout() async {
    printY('${AuthLogTags.authManager} logout');

    await storage.remove(AuthStorageKeys.user);
    await storage.remove(AuthStorageKeys.guestFlag);

    state.setUser(null);
    state.setGuest(false);
    state.setAuthStatus(
      AuthStatus.unauthenticated(message: AuthReasons.logout),
    );

    if (mode == AuthMode.withJwt && tokenStorage != null) {
      await tokenStorage!.delete(AuthReasons.logout);
    }
  }

  /// Updates the persisted user data and notifies listeners.
  Future<void> updateUser(UserEntity user) async {
    await _persistUser(user);
  }

  /// Updates the stored JWT token when JWT mode is active.
  Future<void> updateToken(AuthTokenModel token) async {
    if (mode == AuthMode.withJwt && tokenStorage != null) {
      await tokenStorage!.write(token);
    }
  }

  /// Enters guest mode by clearing the user and setting the guest flag.
  Future<void> continueAsGuest() async {
    printC('${AuthLogTags.authManager} continueAsGuest');

    state.setUser(null);
    await _setGuest(true);
    state.setAuthStatus(AuthStatus.unauthenticated(message: AuthReasons.guest));

    if (mode == AuthMode.withJwt && tokenStorage != null) {
      await tokenStorage!.delete(AuthReasons.guest);
    }
  }

  /// Persists the given [user] in storage and updates the in-memory state.
  Future<void> _persistUser(UserEntity user) async {
    state.setUser(user);

    final jsonString = json.encode(user.toJson());
    await storage.writeString(AuthStorageKeys.user, jsonString);
  }

  /// Persists the guest flag and updates the in-memory representation.
  Future<void> _setGuest(bool value) async {
    state.setGuest(value);
    await storage.writeBool(AuthStorageKeys.guestFlag, value);
  }

  /// Loads user and guest flag from storage to compute the initial state.
  Future<void> _loadUserFromStorage() async {
    final jsonString = await storage.readString(AuthStorageKeys.user);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final decoded = json.decode(jsonString) as Map<String, dynamic>;
        final user = UserEntity.fromJson(decoded);
        state.setUser(user);
      } catch (_) {}
    }

    final guestFlag = await storage.readBool(AuthStorageKeys.guestFlag);
    state.setGuest(guestFlag ?? false);
  }

  /// Forwards status changes from dio_refresh_bot into the reactive notifier.
  void _onAuthStatusChanged(AuthStatus status) {
    state.setAuthStatus(status);
  }
}
