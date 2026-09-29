import 'dart:async';

import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../core/router/app_page_transitions.dart';
import '../../features/auth/presentation/ui/screens/login_screen.dart';
import '../../features/onboarding/presentation/ui/screens/onboarding_screen.dart';
import '../../features/root/presentation/ui/screens/root_screen.dart';
import '../../features/settings/presentation/ui/screens/settings_screen.dart';
import '../../features/showcase_feed/presentation/ui/screens/feed_item_screen.dart';
import '../../features/splash/presentation/ui/screens/splash_screen.dart';
import '../../utils/constants/app_flow_constants.dart';
import '../../utils/helpers/colored_print.dart';
import '../services/onboarding/onboarding_service.dart';
import '../services/session/auth_state_notifier.dart';
import 'app_links.dart';

part 'app_routes.dart';

/// * RouterRefreshListenable
///
/// Bridges authentication status, onboarding state, and the splash timers
/// into a single [Listenable] used by GoRouter.
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable({
    required this.authState,
    required this.onboardingService,
  }) {
    // * Listen to all reactive sources that affect routing.
    authState.addListener(_onSourceChanged);
    onboardingService.addListener(_onSourceChanged);
    unawaited(onboardingService.initialize());

    // * Hold the splash for at least [SplashConfig.initialDelay], so a fast
    //   device never cuts its entrance off mid-flight.
    _minimumTimer = Timer(SplashConfig.initialDelay, () {
      _splashDelayElapsed = true;
      printC('${RouterLogTags.router} splash minimum elapsed ⏱');
      notifyListeners();
    });

    // * And never hold it longer than [SplashConfig.maxWait]. If bootstrap has
    //   not resolved by then the app moves on instead of stranding the user
    //   on a screen with no end — a stalled token refresh would otherwise
    //   hang here forever.
    _timeoutTimer = Timer(SplashConfig.maxWait, () {
      if (authState.authStatus.status != Status.initial) return;
      printY('${RouterLogTags.router} splash timed out → moving on ⚠');
      _bootstrapTimedOut = true;
      if (AppFlowConfig.authMode == AuthMode.guestFirst) {
        authState.setGuest(true);
      }
      authState.setAuthStatus(
        AuthStatus.unauthenticated(message: 'Startup timed out'),
      );
      notifyListeners();
    });
  }

  Timer? _minimumTimer;
  Timer? _timeoutTimer;

  bool _bootstrapTimedOut = false;

  /// True when bootstrap exceeded [SplashConfig.maxWait]. The shell uses it
  /// to explain why, once ([SplashConfig.timeoutMessage]).
  bool get bootstrapTimedOut => _bootstrapTimedOut;

  final AuthStateNotifier authState;
  final OnboardingService onboardingService;

  bool _splashDelayElapsed = false;

  bool get splashDelayElapsed => _splashDelayElapsed;

  void _onSourceChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _minimumTimer?.cancel();
    _timeoutTimer?.cancel();
    authState.removeListener(_onSourceChanged);
    onboardingService.removeListener(_onSourceChanged);
    super.dispose();
  }
}

/// * AppRouterConfig
///
/// High-level configuration object that owns the [GoRouter] instance and
/// wires together:
/// - [RouterRefreshListenable]
/// - [AppRouteRegistry]
/// - [AppRouteGuard]
/// - [LinkDispatcher]
@lazySingleton
class AppRouterConfig {
  AppRouterConfig(
    this._authState,
    this._onboardingService,
    this._routeRegistry,
    this._links,
  ) {
    _refresh = RouterRefreshListenable(
      authState: _authState,
      onboardingService: _onboardingService,
    );

    _guard = AppRouteGuard(
      authState: _authState,
      onboardingService: _onboardingService,
      splashPath: SplashScreen.pagePath,
      onboardingPath: OnboardingScreen.pagePath,
      loginPath: LoginScreen.wallPath,
      rootPath: RootScreen.pagePath,
      links: _links,
    );

    _router = GoRouter(
      // * Initial route is the splash screen.
      initialLocation: SplashScreen.pagePath,
      routes: _routeRegistry.routes,
      refreshListenable: _refresh,
      redirect: (context, state) => _guard.handleRedirect(
        state: state,
        splashDelayElapsed: _refresh.splashDelayElapsed,
      ),
    );
    _links.attach(_router);
  }

  final AuthStateNotifier _authState;
  final OnboardingService _onboardingService;
  final AppRouteRegistry _routeRegistry;
  final LinkDispatcher _links;

  late final RouterRefreshListenable _refresh;
  late final AppRouteGuard _guard;
  late final GoRouter _router;

  GoRouter get router => _router;

  /// See [RouterRefreshListenable.bootstrapTimedOut].
  bool get bootstrapTimedOut => _refresh.bootstrapTimedOut;
}

/// * AppRouteGuard
///
/// Isolated class that owns all redirect / guard logic for the router so
/// the rules stay in one focused place instead of being spread across
/// multiple functions.
class AppRouteGuard {
  AppRouteGuard({
    required this.authState,
    required this.onboardingService,
    required this.splashPath,
    required this.onboardingPath,
    required this.loginPath,
    required this.rootPath,
    this.authMode = AppFlowConfig.authMode,
    this.onboardingEnabled = AppFlowConfig.onboardingEnabled,
    this.links,
  });

  final AuthStateNotifier authState;
  final OnboardingService onboardingService;
  final String splashPath;
  final String onboardingPath;
  final String loginPath;
  final String rootPath;

  /// From [AppFlowConfig]; a test passes its own.
  final AuthMode authMode;
  final bool onboardingEnabled;

  /// Where a link that arrives before the shell is up waits for it. Null in
  /// a test that is not about links.
  final LinkDispatcher? links;

  /// * Central route-guard / redirect logic.
  ///
  /// Rules:
  /// - While status is [Status.initial] OR splash delay not elapsed → stay on
  ///   splash.
  /// - If onboarding enabled and not finished → go to onboarding.
  /// - [AuthMode.loginRequired]: neither signed in nor a guest → the login
  ///   wall; signed in on the wall → root.
  /// - [AuthMode.guestFirst]: every reader enters the app; `/login` is a page
  ///   pushed on request, never a redirect target.
  /// - A share path that reaches the router is held and the reader sent to
  ///   the shell, which pushes it over the first tab (`LinkDispatcher`).
  String? handleRedirect({
    required GoRouterState state,
    required bool splashDelayElapsed,
  }) {
    final currentPath = state.matchedLocation;
    final status = authState.authStatus.status;
    final isGuest = authState.isGuest;

    printM(
      '${RouterLogTags.redirect} currentPath="$currentPath" '
      'status=$status isGuest=$isGuest',
    );

    // A link that opened the app lands here first, and the redirects below
    // send it to the splash, onboarding or the wall. Keep it: once the shell
    // is up it is pushed OVER the first tab, so back from it lands in the
    // app (`LinkDispatcher`).
    void holdLink() {
      final link = AppLinks.locationOf(state.uri);
      if (link != null) links?.hold(link);
    }

    // 1) Splash / initial state.
    //
    // While the splash is still active (delay not elapsed OR auth status
    // still bootstrapping), nothing else may redirect — otherwise GoRouter
    // leaves the splash before its first frame is even painted.
    if (!splashDelayElapsed || status == Status.initial) {
      if (currentPath != splashPath) {
        printC('${RouterLogTags.redirect} → splash (bootstrapping)');
        holdLink();
        return splashPath;
      }
      return null;
    }

    // 2) Onboarding — before any auth rule, or `/onboarding → /login →
    //    /onboarding` could loop.
    if (onboardingEnabled) {
      if (!onboardingService.isInitialized) {
        if (currentPath != splashPath) {
          printC('${RouterLogTags.redirect} → splash (onboarding loading)');
          holdLink();
          return splashPath;
        }
        return null;
      }

      if (!onboardingService.isOnboardingFinishedSync) {
        if (currentPath != onboardingPath) {
          printC('${RouterLogTags.redirect} → onboarding (not finished)');
          holdLink();
          return onboardingPath;
        }
        return null;
      }
    }

    // 3) The login wall.
    if (authMode == AuthMode.loginRequired) {
      final canEnter = authState.isAuthenticated || isGuest;
      if (!canEnter) {
        if (currentPath != loginPath) {
          printY('${RouterLogTags.redirect} → login (not signed in)');
          holdLink();
          return loginPath;
        }
        return null;
      }
      if (currentPath == loginPath) {
        printG('${RouterLogTags.redirect} signed in → root');
        return rootPath;
      }
    }

    // 4) Into the app.
    //
    // A share path (`/items/42`) is a page's public address, not a route:
    // pages live under the shell. One that reaches the router instead of
    // `LinkDispatcher` waits for the shell and is pushed over it.
    if (!currentPath.startsWith(rootPath) &&
        AppLinks.locationOf(state.uri) != null) {
      holdLink();
      printC('${RouterLogTags.redirect} → root (link held for the shell)');
      return rootPath;
    }
    return _handleEntry(currentPath: currentPath);
  }

  /// Leaves the startup screens for the shell, and nothing else.
  ///
  /// A pushed sign-in page is not on the list: it closes itself, so the
  /// stack under it is still there when it does. Redirecting it would `go`
  /// to root and throw that stack away.
  String? _handleEntry({required String currentPath}) {
    if (currentPath == splashPath ||
        currentPath == onboardingPath ||
        currentPath == loginPath) {
      printG('${RouterLogTags.redirect} → root');
      return rootPath;
    }
    return null;
  }
}
