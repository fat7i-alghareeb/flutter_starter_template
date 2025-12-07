import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

/// Supported page transition types.
enum AppTransition {
  fade,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  scale,
  fadeScale,
  none,
}

/// * AppPageTransitions
///
/// Small utility responsible only for building pages with a given
/// [AppTransition]. This keeps animation logic separate from route
/// registration.
class AppPageTransitions {
  const AppPageTransitions._();

  static Page<T> build<T>({
    required GoRouterState state,
    required Widget child,
    AppTransition transition = AppTransition.fade,
  }) {
    switch (transition) {
      case AppTransition.none:
        return MaterialPage<T>(key: state.pageKey, child: child);

      case AppTransition.slideFromRight:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        );

      case AppTransition.slideFromLeft:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        );

      case AppTransition.slideFromBottom:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        );

      case AppTransition.slideFromTop:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.0, -1.0),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        );

      case AppTransition.scale:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(scale: animation, child: child);
          },
        );

      case AppTransition.fadeScale:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
        );

      case AppTransition.fade:
        return CustomTransitionPage<T>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
    }
  }
}

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
  String get splashPath => ""; // splash screen

  /// * Onboarding flow route.
  String get onboardingPath => ""; // onboarding screen

  /// * Login / authentication entry point.
  String get loginPath => ""; // login screen

  /// * Home / root of the authenticated app.
  String get rootPath => ""; // home/root screen

  /// * All GoRouter routes for the app.
  List<GoRoute> get routes => [
    GoRoute(
      path: splashPath,
      pageBuilder: (context, state) => AppPageTransitions.build(
        state: state,
        transition: AppTransition.fade,
        // TODO: Replace with real splash screen widget.
        child: const SizedBox.shrink(),
      ),
    ),
    GoRoute(
      path: onboardingPath,
      pageBuilder: (context, state) => AppPageTransitions.build(
        state: state,
        transition: AppTransition.fade,
        // TODO: Replace with real onboarding screen widget.
        child: const SizedBox.shrink(),
      ),
    ),
    GoRoute(
      path: loginPath,
      pageBuilder: (context, state) => AppPageTransitions.build(
        state: state,
        transition: AppTransition.fade,
        // TODO: Replace with real login screen widget.
        child: const SizedBox.shrink(),
      ),
    ),
    GoRoute(
      path: rootPath,
      pageBuilder: (context, state) => AppPageTransitions.build(
        state: state,
        transition: AppTransition.fade,
        // TODO: Replace with real root/home screen widget.
        child: const SizedBox.shrink(),
      ),
    ),
  ];
}
