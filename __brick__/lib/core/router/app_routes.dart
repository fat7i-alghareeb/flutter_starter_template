part of 'router_config.dart';

/// * AppRouteRegistry
///
/// Single-responsibility class that knows how to register all core
/// app routes. Screen-specific files will eventually expose their own
/// static `routePath` / `routeName` and this registry will simply
/// reference them.
@lazySingleton
class AppRouteRegistry {
  const AppRouteRegistry();

  /// * All GoRouter routes for the app.
  List<GoRoute> get routes => [
    GoRoute(
      path: SplashScreen.pagePath,
      name: SplashScreen.pageName,
      pageBuilder: (context, state) =>
          AppPageTransitions.build(state: state, child: const SplashScreen()),
    ),
    GoRoute(
      path: OnboardingScreen.pagePath,
      name: OnboardingScreen.pageName,
      pageBuilder: (context, state) => AppPageTransitions.build(
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: LoginScreen.pagePath,
      name: LoginScreen.pageName,
      pageBuilder: (context, state) =>
          AppPageTransitions.build(state: state, child: const LoginScreen()),
    ),
    GoRoute(
      path: RootScreen.pagePath,
      name: RootScreen.pageName,
      pageBuilder: (context, state) =>
          AppPageTransitions.build(state: state, child: const RootScreen()),
    ),
  ];
}
