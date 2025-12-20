import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../core/router/app_page_transitions.dart';

/// * AppRouteRegistry
///
/// Single-responsibility class that knows how to register all core
/// app routes. Screen-specific files will eventually expose their own
/// static `routePath` / `routeName` and this registry will simply
/// reference them.
@lazySingleton
class AppRouteRegistry {
  const AppRouteRegistry();

  /// * Splash screen (initial route).
  /// For now we keep an empty placeholder path until the real
  /// splash screen is implemented.
  String get splashPath => "/splash"; // splash screen

  /// * Onboarding flow route.
  String get onboardingPath => "/onBoarding"; // onboarding screen

  /// * Login / authentication entry point.
  String get loginPath => "/loginPath"; // login screen

  /// * Home / root of the authenticated app.
  String get rootPath => "/rootPath"; // home/root screen

  /// * All GoRouter routes for the app.
  List<GoRoute> get routes => [
    GoRoute(
      path: splashPath,
      name: splashPath,
      pageBuilder: (context, state) => AppPageTransitions.build(
        state: state,
        transition: AppTransition.fade,
        // TODO: Replace with real splash screen widget.
        child: Scaffold(body: Center(child: Text("splashPath"))),
      ),
    ),
    GoRoute(
      path: onboardingPath,
      name: onboardingPath,
      pageBuilder: (context, state) => AppPageTransitions.build(
        state: state,
        transition: AppTransition.fade,
        // TODO: Replace with real onboarding screen widget.
        child: Scaffold(body: Center(child: Text("onboardingPath"))),
      ),
    ),
    GoRoute(
      path: loginPath,
      name: loginPath,
      pageBuilder: (context, state) => AppPageTransitions.build(
        state: state,
        transition: AppTransition.fade,
        // TODO: Replace with real login screen widget.
        child: Scaffold(body: Center(child: Text("loginPath"))),
      ),
    ),
    GoRoute(
      path: rootPath,
      name: rootPath,
      pageBuilder: (context, state) => AppPageTransitions.build(
        state: state,
        transition: AppTransition.fade,
        // TODO: Replace with real root/home screen widget.
        child: Scaffold(body: Center(child: Text("rootPath"))),
      ),
    ),
  ];
}
