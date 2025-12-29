import 'dart:async';

import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../core/router/app_page_transitions.dart';
import '../../features/auth/presentation/ui/screens/login_screen.dart';
import '../../features/onboarding/presentation/ui/screens/onboarding_screen.dart';
import '../../features/root/presentation/ui/screens/root_screen.dart';
import '../../features/splash/presentation/ui/screens/splash_screen.dart';
import '../../utils/constants/app_flow_constants.dart';
import '../../utils/helpers/colored_print.dart';
import '../services/onboarding/onboarding_service.dart';
import '../services/session/auth_state_notifier.dart';

part 'app_routes.dart';

/// * RouterRefreshListenable
///
/// Bridges authentication status, onboarding state, and an internal
/// splash delay into a single [Listenable] used by GoRouter.
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable({
    required this.authState,
    required this.onboardingService,
  }) {
    // * Listen to all reactive sources that affect routing.
    authState.addListener(_onSourceChanged);
    onboardingService.addListener(_onSourceChanged);

    // * Ensure the splash is visible for at least [SplashConfig.initialDelay]
    //   even if auth/onboarding resolve instantly.
    Future<void>.delayed(SplashConfig.initialDelay, () {
      _splashDelayElapsed = true;
      printC('${RouterLogTags.router} splash delay elapsed ⏱');
      notifyListeners();
    });
  }

  final AuthStateNotifier authState;
  final OnboardingService onboardingService;

  bool _splashDelayElapsed = false;

  bool get splashDelayElapsed => _splashDelayElapsed;

  void _onSourceChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
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
@lazySingleton
class AppRouterConfig {
  AppRouterConfig(
    this._authState,
    this._onboardingService,
    this._routeRegistry,
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
      loginPath: LoginScreen.pagePath,
      rootPath: RootScreen.pagePath,
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
  }

  final AuthStateNotifier _authState;
  final OnboardingService _onboardingService;
  final AppRouteRegistry _routeRegistry;

  late final RouterRefreshListenable _refresh;
  late final AppRouteGuard _guard;
  late final GoRouter _router;

  GoRouter get router => _router;
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
  });

  final AuthStateNotifier authState;
  final OnboardingService onboardingService;
  final String splashPath;
  final String onboardingPath;
  final String loginPath;
  final String rootPath;

  /// * Central route-guard / redirect logic.
  ///
  /// Rules:
  /// - While status is [Status.initial] OR splash delay not elapsed → stay on
  ///   splash.
  /// - If onboarding enabled and not finished → go to onboarding.
  /// - After onboarding:
  ///   - If auth enabled:
  ///     - unauthenticated → login
  ///     - authenticated → root
  ///   - If auth disabled → root
  FutureOr<String?> handleRedirect({
    required GoRouterState state,
    required bool splashDelayElapsed,
  }) async {
    final currentPath = state.matchedLocation;
    final status = authState.authStatus.status;
    final isGuest = authState.isGuest;
    final isAuthenticated = status == Status.authenticated && !isGuest;

    printM(
      '${RouterLogTags.redirect} currentPath="$currentPath" '
      'status=$status isGuest=$isGuest',
    );

    // 1) Splash / initial state.
    final splashRedirect = _handleSplash(
      currentPath: currentPath,
      status: status,
      splashDelayElapsed: splashDelayElapsed,
    );
    if (splashRedirect != null) return splashRedirect;

    // Important: while splash is still active (delay not elapsed OR auth status
    // still bootstrapping), we must NOT run onboarding/auth redirects.
    // Otherwise GoRouter can immediately redirect away from the splash route
    // before the first frame is painted, making the splash appear to never show.
    if (!splashDelayElapsed || status == Status.initial) {
      return null;
    }

    // 2) Onboarding.
    final onboardingRedirect = await _handleOnboarding(currentPath);
    if (onboardingRedirect != null) return onboardingRedirect;

    // allow auth redirects to push the user to login.
    if (AppFlowConfig.onboardingEnabled && currentPath == onboardingPath) {
      final finished = await onboardingService.isOnboardingFinished();
      if (!finished) return null;
    }

    // 3) Auth.
    final authRedirect = _handleAuth(
      currentPath: currentPath,
      isAuthenticated: isAuthenticated,
    );
    return authRedirect;
  }

  String? _handleSplash({
    required String currentPath,
    required Status status,
    required bool splashDelayElapsed,
  }) {
    if (!splashDelayElapsed || status == Status.initial) {
      if (currentPath != splashPath) {
        printC('${RouterLogTags.redirect} → splash (bootstrapping)');
        return splashPath;
      }
      return null;
    }
    return null;
  }

  Future<String?> _handleOnboarding(String currentPath) async {
    if (!AppFlowConfig.onboardingEnabled) {
      return null;
    }

    final finished = await onboardingService.isOnboardingFinished();
    if (!finished) {
      if (currentPath != onboardingPath) {
        printC('${RouterLogTags.redirect} → onboarding (not finished)');
        return onboardingPath;
      }
      return null;
    }

    if (currentPath == onboardingPath) {
      printC('${RouterLogTags.redirect} onboarding finished → resolve next');
    }
    return null;
  }

  String? _handleAuth({
    required String currentPath,
    required bool isAuthenticated,
  }) {
    if (!AppFlowConfig.authEnabled) {
      if (currentPath != rootPath) {
        printG('${RouterLogTags.redirect} auth disabled → root');
        return rootPath;
      }
      return null;
    }

    if (!isAuthenticated) {
      if (currentPath != loginPath) {
        printY('${RouterLogTags.redirect} unauthenticated → login');
        return loginPath;
      }
      return null;
    }

    if (currentPath == splashPath ||
        currentPath == loginPath ||
        currentPath == onboardingPath) {
      printG('${RouterLogTags.redirect} authenticated → root');
      return rootPath;
    }

    return null;
  }
}
