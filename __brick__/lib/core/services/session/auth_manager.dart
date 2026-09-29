import 'dart:async';
import 'dart:convert';

import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../utils/constants/app_flow_constants.dart';
import '../../../utils/constants/auth_constants.dart';
import '../../../utils/helpers/colored_print.dart';
import '../../domain/user_entity.dart';
import '../storage/storage_service.dart';
import 'auth_state_notifier.dart';
import 'auth_token_model.dart';
import 'jwt_token_storage.dart';

/// Central service responsible only for authentication concerns.
///
/// It exposes a simple API for login, logout, guest mode, user updates and
/// token updates, while keeping all persistence and reactive concerns hidden
/// behind dedicated collaborators.
@lazySingleton
class AuthManager {
  AuthManager({
    required this.storage,
    required this.state,
    required this.tokenStorage,
  });

  final StorageService storage;
  final AuthStateNotifier state;
  final JwtTokenStorage tokenStorage;

  StreamSubscription<AuthStatus>? _tokenStatusSub;

  UserEntity? get currentUser => state.user;
  bool get isGuest => state.isGuest;
  bool get isAuthenticated => state.isAuthenticated;
  AuthStatus get authStatus => state.authStatus;

  /// Emits authentication status changes coming from dio_refresh_bot.
  Stream<AuthStatus> get authStatusStream => tokenStorage.authenticationStatus;

  /// Initializes the manager by loading user and guest flag, and wiring token
  /// status updates.
  Future<void> initialize() async {
    printC('${AuthLogTags.authManager} initialize');
    await _loadUserFromStorage();

    await tokenStorage.initialize();

    final shouldLogExpiry = kDebugMode && state.user != null && !state.isGuest;
    if (shouldLogExpiry) {
      final expiry = await tokenStorage.loadExpiry();
      final remaining = await tokenStorage.remainingUntilExpiry();

      if (expiry == null || remaining == null) {
        printY('${AuthLogTags.authManager} token expiry not available');
      } else if (remaining.isNegative) {
        printR('${AuthLogTags.authManager} token expired');
      } else {
        final days = remaining.inDays;
        final hours = remaining.inHours % 24;
        final minutes = remaining.inMinutes % 60;
        printG(
          '${AuthLogTags.authManager} token expires in: '
          '$days d, $hours h, $minutes m (at $expiry)',
        );
      }
    }

    _tokenStatusSub = tokenStorage.authenticationStatus.listen(
      _onAuthStatusChanged,
    );

    // Make sure routing cannot remain stuck on splash if stream replay is
    // delayed by the runtime.
    if (state.authStatus.status == Status.initial) {
      state.setAuthStatus(
        tokenStorage.cachedToken != null
            ? AuthStatus.authenticated()
            : AuthStatus.unauthenticated(message: 'No active session'),
      );
    }
  }

  /// Disposes internal listeners and closes the underlying token storage.
  Future<void> dispose() async {
    await _tokenStatusSub?.cancel();
    tokenStorage.close();
  }

  /// Logs in the given [user], persists their data and stores JWT tokens.
  Future<void> login({
    required UserEntity user,
    required AuthTokenModel token,
  }) async {
    printG('${AuthLogTags.authManager} login');

    await _persistUser(user);
    await tokenStorage.write(token);

    // Update router-facing status immediately — and BEFORE the guest flag
    // is cleared.
    //
    // The other order leaves one frame where the reader is neither a guest
    // nor authenticated, and the router's guard reads exactly that pair: it
    // redirected to `/login` and then to `/root`, which threw away the whole
    // pushed stack — a reader who signed in from a deep screen landed on
    // home instead of the screen they were on.
    state.setAuthStatus(AuthStatus.authenticated());
    await _setGuest(false);
    state.setSessionExpired(false);
  }

  /// Signs the reader out.
  ///
  /// With [AuthMode.guestFirst] they keep browsing as a guest; with
  /// [AuthMode.loginRequired] the router sends them to the sign-in screen.
  Future<void> logout() async {
    printY('${AuthLogTags.authManager} logout');
    await _endSession(AuthReasons.logout);
  }

  /// A signed-in session that ended without the reader asking — a refresh
  /// that failed, or a token the server revoked.
  ///
  /// Not a logout: with [AuthMode.guestFirst] the reader keeps browsing as a
  /// guest and a banner says what happened; with [AuthMode.loginRequired]
  /// the sign-in screen explains it. A reader who is not signed in has no
  /// session to lose, so this does nothing for them — which also makes a
  /// second call, from the interceptor's revoke after its refresh, harmless.
  Future<void> expireSession() async {
    if (!state.isAuthenticated) return;

    printY('${AuthLogTags.authManager} session expired');
    await _endSession(AuthReasons.expired);
    state.setSessionExpired(true);
  }

  /// Clears the account and the tokens.
  Future<void> _endSession(String reason) async {
    await storage.remove(AuthStorageKeys.user);
    state.setUser(null);

    if (AppFlowConfig.authMode == AuthMode.guestFirst) {
      // The guest flag BEFORE the status, for the reason [login] sets them
      // in the other order: no frame may read «neither a guest nor signed
      // in», or the guard redirects and drops the stack.
      await _setGuest(true);
      state.setAuthStatus(AuthStatus.unauthenticated(message: reason));
    } else {
      // Login wall: «neither a guest nor signed in» IS the state that sends
      // the reader to the sign-in screen.
      state.setAuthStatus(AuthStatus.unauthenticated(message: reason));
      await _setGuest(false);
    }

    await tokenStorage.delete(reason);
  }

  /// Updates the persisted user data and notifies listeners.
  Future<void> updateUser(UserEntity user) async {
    await _persistUser(user);
  }

  /// Updates the stored JWT token.
  Future<void> updateToken(AuthTokenModel token) async {
    await tokenStorage.write(token);
  }

  /// Enters guest mode by clearing the user and setting the guest flag.
  Future<void> continueAsGuest() async {
    printC('${AuthLogTags.authManager} continueAsGuest');

    state.setUser(null);
    await _setGuest(true);
    state.setAuthStatus(AuthStatus.unauthenticated(message: AuthReasons.guest));
    state.setSessionExpired(false);

    await tokenStorage.delete(AuthReasons.guest);
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
