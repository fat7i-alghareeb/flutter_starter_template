import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/domain/user_entity.dart';
import 'package:{{project_name}}/core/services/session/auth_manager.dart';
import 'package:{{project_name}}/core/services/session/auth_state_notifier.dart';
import 'package:{{project_name}}/core/services/session/auth_token_model.dart';
import 'package:{{project_name}}/core/services/session/jwt_token_storage.dart';
import 'package:{{project_name}}/core/services/storage/storage_service.dart';
import 'package:{{project_name}}/utils/constants/app_flow_constants.dart';

class _MockStorage extends Mock implements StorageService {}

class _MockTokenStorage extends Mock implements JwtTokenStorage {}

/// Signing in must never pass through «neither a guest nor authenticated».
///
/// The router's guard reads that exact pair as «this user has no business
/// in the app» and sends them to `/login`, which throws away everything
/// pushed over the tabs: a user who signed in from a deep screen would land
/// back on the first tab instead of the screen they were on.
///
/// It was invisible to every test: each one asks the manager what it holds
/// AFTER the call, and the state in question exists for one frame in the
/// middle of it. This watches the notifier instead.
void main() {
  setUpAll(() {
    registerFallbackValue(
      const AuthTokenModel(accessToken: 'a', refreshToken: 'r'),
    );
  });

  test('no frame of the sign-in reads as «kicked out»', () async {
    final storage = _MockStorage();
    final tokenStorage = _MockTokenStorage();
    final state = AuthStateNotifier()..setGuest(true);

    when(
      () => storage.writeString(any(), any()),
    ).thenAnswer((_) async {});
    when(() => storage.writeBool(any(), any())).thenAnswer((_) async {});
    when(() => tokenStorage.write(any())).thenAnswer((_) async {});

    final manager = AuthManager(
      storage: storage,
      state: state,
      tokenStorage: tokenStorage,
    );

    final seen = <bool>[];
    state.addListener(() {
      // What the router's guard computes: `canEnterApp`.
      seen.add(state.isAuthenticated || state.isGuest);
    });

    await manager.login(
      user: const UserEntity(
        id: 'usr_001',
        name: 'أحمد الحسن',
        email: 'ahmad@gmail.com',
      ),
      token: const AuthTokenModel(accessToken: 'a', refreshToken: 'r'),
    );

    expect(
      seen.contains(false),
      isFalse,
      reason: 'one frame of «no guest, no account» is a redirect to /login '
          'and a lost navigation stack',
    );
    expect(state.isAuthenticated, isTrue);
  });

  const guestFirst = AppFlowConfig.authMode == AuthMode.guestFirst;

  group('guest first: a session that ends leaves a GUEST behind', () {
    // Signing out is «back to the app as a guest», and a failed refresh is a
    // banner over the app. Clearing the guest flag would leave «neither a
    // guest nor signed in» — what sends a user to the sign-in screen.
    late _MockStorage storage;
    late _MockTokenStorage tokenStorage;
    late AuthStateNotifier state;
    late AuthManager manager;
    late List<bool> seen;

    setUp(() {
      storage = _MockStorage();
      tokenStorage = _MockTokenStorage();
      state = AuthStateNotifier()
        ..setUser(
          const UserEntity(id: 'usr_001', name: 'أحمد', email: 'a@b.c'),
        )
        ..setAuthStatus(AuthStatus.authenticated());

      when(() => storage.remove(any())).thenAnswer((_) async {});
      when(() => storage.writeBool(any(), any())).thenAnswer((_) async {});
      when(() => tokenStorage.delete(any())).thenAnswer((_) async {});

      manager = AuthManager(
        storage: storage,
        state: state,
        tokenStorage: tokenStorage,
      );

      seen = <bool>[];
      state.addListener(() => seen.add(state.isAuthenticated || state.isGuest));
    });

    test('signing out ends as a guest, with no frame of «neither»', () async {
      await manager.logout();

      expect(state.isGuest, isTrue);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(seen.contains(false), isFalse);
      // A sign-out the reader asked for explains nothing.
      expect(state.sessionExpired, isFalse);
      verify(() => storage.writeBool(any(), true)).called(1);
    });

    test('an expired session ends as a guest AND raises the banner', () async {
      await manager.expireSession();

      expect(state.isGuest, isTrue);
      expect(state.isAuthenticated, isFalse);
      expect(state.sessionExpired, isTrue);
      expect(seen.contains(false), isFalse);
      verify(() => tokenStorage.delete(any())).called(1);
    });

    test('a guest has no session to lose — expiring twice is harmless', () async {
      await manager.expireSession();
      state.setSessionExpired(false);

      // The interceptor's revoke runs after its refresh already failed.
      await manager.expireSession();

      expect(state.sessionExpired, isFalse);
      verify(() => tokenStorage.delete(any())).called(1);
    });

    test('signing in again puts the banner away', () async {
      await manager.expireSession();
      when(() => storage.writeString(any(), any())).thenAnswer((_) async {});
      when(() => tokenStorage.write(any())).thenAnswer((_) async {});

      await manager.login(
        user: const UserEntity(id: 'usr_001', name: 'أحمد', email: 'a@b.c'),
        token: const AuthTokenModel(accessToken: 'a', refreshToken: 'r'),
      );

      expect(state.sessionExpired, isFalse);
      expect(state.isAuthenticated, isTrue);
    });
  }, skip: !guestFirst);

  group('login wall: a session that ends is back at the wall', () {
    late _MockStorage storage;
    late _MockTokenStorage tokenStorage;
    late AuthStateNotifier state;
    late AuthManager manager;

    setUp(() {
      storage = _MockStorage();
      tokenStorage = _MockTokenStorage();
      state = AuthStateNotifier()
        ..setUser(const UserEntity(id: 'usr_001', name: 'Demo User'))
        ..setAuthStatus(AuthStatus.authenticated());

      when(() => storage.remove(any())).thenAnswer((_) async {});
      when(() => storage.writeBool(any(), any())).thenAnswer((_) async {});
      when(() => tokenStorage.delete(any())).thenAnswer((_) async {});

      manager = AuthManager(
        storage: storage,
        state: state,
        tokenStorage: tokenStorage,
      );
    });

    test('signing out is neither a guest nor signed in — the wall', () async {
      await manager.logout();

      expect(state.isGuest, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(state.sessionExpired, isFalse);
      verify(() => tokenStorage.delete(any())).called(1);
    });

    test('an expired session is the wall too, and it says why', () async {
      await manager.expireSession();

      expect(state.isGuest, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.sessionExpired, isTrue);
    });
  }, skip: guestFirst);
}
