import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/domain/user_entity.dart';
import 'package:{{project_name}}/core/injection/injectable.dart';
import 'package:{{project_name}}/core/router/app_links.dart';
import 'package:{{project_name}}/core/router/app_navigator.dart';
import 'package:{{project_name}}/core/router/router_config.dart';
import 'package:{{project_name}}/core/services/onboarding/onboarding_service.dart';
import 'package:{{project_name}}/core/services/session/auth_manager.dart';
import 'package:{{project_name}}/core/services/session/auth_state_notifier.dart';
import 'package:{{project_name}}/core/services/session/jwt_token_storage.dart';
import 'package:{{project_name}}/core/services/storage/storage_service.dart';
import 'package:{{project_name}}/core/theme/app_theme.dart';
import 'package:{{project_name}}/features/auth/presentation/ui/screens/login_screen.dart';
import 'package:{{project_name}}/features/onboarding/presentation/ui/screens/onboarding_screen.dart';
import 'package:{{project_name}}/utils/constants/app_flow_constants.dart';
import 'package:{{project_name}}/utils/constants/design_constants.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

class _MockStorage extends Mock implements StorageService {}

class _MockTokenStorage extends Mock implements JwtTokenStorage {}

/// Where the router takes a user, for the auth mode this app is built with
/// (`AppFlowConfig.authMode`). Each group runs only in its own mode, so
/// flipping the switch flips which rules are checked.
///
/// A real `GoRouter`, the real guard, the real onboarding screen and the
/// real session: every location the router visits is recorded, so one
/// passing frame on the wrong page fails the test even if the next one
/// moves on.
void main() {
  late AuthStateNotifier auth;
  late OnboardingService onboarding;
  late AuthManager manager;
  late LinkDispatcher links;
  late _MockStorage storage;
  late bool onboardingDone;

  const loginWall = AppFlowConfig.authMode == AuthMode.loginRequired;
  final host = AppLinks.hosts.first;

  setUp(() async {
    await getIt.reset();
    storage = _MockStorage();
    final tokenStorage = _MockTokenStorage();
    onboardingDone = false;

    when(
      () => storage.readBool(any()),
    ).thenAnswer((_) async => onboardingDone);
    when(() => storage.writeBool(any(), any())).thenAnswer((_) async {});
    when(() => storage.remove(any())).thenAnswer((_) async {});
    when(() => tokenStorage.delete(any())).thenAnswer((_) async {});

    auth = AuthStateNotifier();
    onboarding = OnboardingService(storage);
    manager = AuthManager(
      storage: storage,
      state: auth,
      tokenStorage: tokenStorage,
    );
    links = LinkDispatcher();

    getIt
      ..registerSingleton<OnboardingService>(onboarding)
      ..registerSingleton<AuthManager>(manager)
      ..registerSingleton<LinkDispatcher>(links);
  });

  tearDown(() => getIt.reset());

  /// Boots a router over stand-in pages, and records every location it
  /// shows.
  Future<(GoRouter, List<String>)> boot(
    WidgetTester tester, {
    String initialLocation = '/splash',
  }) async {
    final guard = AppRouteGuard(
      authState: auth,
      onboardingService: onboarding,
      splashPath: '/splash',
      onboardingPath: OnboardingScreen.pagePath,
      loginPath: LoginScreen.wallPath,
      rootPath: '/root',
      links: links,
    );
    final router = GoRouter(
      initialLocation: initialLocation,
      refreshListenable: Listenable.merge(<Listenable>[auth, onboarding]),
      redirect: (context, state) =>
          guard.handleRedirect(state: state, splashDelayElapsed: true),
      routes: <RouteBase>[
        GoRoute(path: '/splash', builder: (_, _) => const Text('splash')),
        GoRoute(
          path: OnboardingScreen.pagePath,
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: LoginScreen.wallPath,
          builder: (_, _) => const Text('login wall'),
        ),
        // The real tree of pages under the shell, with stand-ins for the
        // screens: `feedItem item_008`, `settings `.
        AppRouteTree.build(
          shell: (_) => const _Shell(),
          builder: (page, _, param) => Text('${page.name} ${param('id')}'),
        ).route,
      ],
    );
    addTearDown(router.dispose);
    links.attach(router);

    final visited = <String>[];
    void record() {
      final uri = router.routerDelegate.currentConfiguration.uri.toString();
      if (visited.isEmpty || visited.last != uri) visited.add(uri);
    }

    router.routerDelegate.addListener(record);

    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppDesign.designSize,
        builder: (_, _) => MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    record();
    return (router, visited);
  }

  String where(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.toString();

  void signIn() => auth
    ..setUser(const UserEntity(id: 'usr_001', name: 'Demo User'))
    ..setAuthStatus(AuthStatus.authenticated());

  Future<GoRouter> signedInOnItem(WidgetTester tester) async {
    onboardingDone = true;
    await onboarding.initialize();
    signIn();

    final (router, _) = await boot(tester);
    AppNavigator.pushTarget<void>(
      router,
      const AppTarget(AppPage.feedItem, params: <String, String>{'id': 'item_008'}),
    );
    await tester.pumpAndSettle();
    expect(find.text('feedItem item_008'), findsOneWidget);
    return router;
  }

  group('login wall (AuthMode.loginRequired)', () {
    testWidgets('first launch: onboarding, then the sign-in wall', (
      tester,
    ) async {
      await onboarding.initialize();
      auth.setAuthStatus(AuthStatus.unauthenticated());

      final (router, _) = await boot(tester);
      expect(where(router), OnboardingScreen.pagePath);

      await tester.tap(find.text(AppStrings.onboardingSkip));
      await tester.pumpAndSettle();

      expect(where(router), LoginScreen.wallPath);
      expect(auth.isGuest, isFalse);
    });

    testWidgets('signing in on the wall moves on to the shell', (
      tester,
    ) async {
      onboardingDone = true;
      await onboarding.initialize();
      auth.setAuthStatus(AuthStatus.unauthenticated());

      final (router, _) = await boot(tester);
      expect(where(router), LoginScreen.wallPath);

      signIn();
      await tester.pumpAndSettle();
      expect(where(router), '/root');
    });

    testWidgets('signing out goes back to the wall', (tester) async {
      final router = await signedInOnItem(tester);

      await manager.logout();
      await tester.pumpAndSettle();

      expect(where(router), LoginScreen.wallPath);
      expect(auth.isGuest, isFalse);
    });

    testWidgets('an expired session goes to the wall, which says why', (
      tester,
    ) async {
      final router = await signedInOnItem(tester);

      await manager.expireSession();
      await tester.pumpAndSettle();

      expect(where(router), LoginScreen.wallPath);
      expect(auth.sessionExpired, isTrue);
    });

    testWidgets('a link that OPENED the app waits for sign-in and the shell, '
        'then opens over it — back lands on the first tab', (tester) async {
      onboardingDone = true;
      await onboarding.initialize();

      final (router, _) = await boot(
        tester,
        initialLocation: '/items/item_008',
      );
      expect(where(router), '/splash');
      expect(links.pending, '/items/item_008');

      auth.setAuthStatus(AuthStatus.unauthenticated());
      await tester.pumpAndSettle();
      expect(where(router), LoginScreen.wallPath);

      signIn();
      await tester.pumpAndSettle();
      expect(find.text('feedItem item_008'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(_Shell), findsOneWidget);
    });
  }, skip: !loginWall);

  group('guest first (AuthMode.guestFirst)', () {
    testWidgets('first launch: «Skip» lands on the shell as a guest — never '
        'on the wall', (tester) async {
      await onboarding.initialize();
      auth.setAuthStatus(AuthStatus.unauthenticated());

      final (router, visited) = await boot(tester);
      expect(where(router), OnboardingScreen.pagePath);

      await tester.tap(find.text(AppStrings.onboardingSkip));
      await tester.pumpAndSettle();

      expect(where(router), '/root');
      expect(visited, isNot(contains(LoginScreen.wallPath)));
      expect(auth.isGuest, isTrue);
    });

    testWidgets('signing out lands as a guest, not on the sign-in page', (
      tester,
    ) async {
      final router = await signedInOnItem(tester);

      await manager.logout();
      await tester.pumpAndSettle();

      expect(where(router), isNot(LoginScreen.wallPath));
      expect(auth.isGuest, isTrue);
    });

    testWidgets('an expired session keeps the user EXACTLY where they were', (
      tester,
    ) async {
      final router = await signedInOnItem(tester);

      await manager.expireSession();
      await tester.pumpAndSettle();

      expect(find.text('feedItem item_008'), findsOneWidget);
      expect(router.canPop(), isTrue, reason: 'the stack under it is intact');
      expect(auth.sessionExpired, isTrue);
    });
  }, skip: loginWall);

  group('a link while the app is open', () {
    testWidgets('is PUSHED, not gone to', (tester) async {
      onboardingDone = true;
      await onboarding.initialize();
      signIn();
      final (router, _) = await boot(tester);
      expect(find.byType(_Shell), findsOneWidget);

      final handled = await links.didPushRouteInformation(
        RouteInformation(uri: Uri.parse('https://$host/items/item_003')),
      );
      await tester.pumpAndSettle();

      expect(handled, isTrue, reason: 'the router must not see it as a `go`');
      expect(find.text('feedItem item_003'), findsOneWidget);
      expect(
        router.state.uri.path,
        '/root/items/item_003',
        reason: 'a link opens as a child of the page under it',
      );
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(_Shell), findsOneWidget);
    });
  });
}

/// Stands in for `RootScreen`, and tells the dispatcher the shell is up the
/// way `RootScreen` does.
class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<LinkDispatcher>().shellReady();
    });
  }

  @override
  Widget build(BuildContext context) => const Text('home');
}
