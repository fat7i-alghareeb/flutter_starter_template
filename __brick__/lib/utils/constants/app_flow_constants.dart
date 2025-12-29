/// App flow and routing related constants.
class OnboardingStorageKeys {
  OnboardingStorageKeys._();

  /// Persistent flag indicating that onboarding was completed at least once.
  static const String finished = 'onboarding.finished';
}

/// Configuration for splash screen behavior.
class SplashConfig {
  SplashConfig._();

  /// Minimal time the splash screen should remain visible before
  /// navigation logic can move away from it.
  static const Duration initialDelay = Duration(seconds: 2);
  static Duration durationForSplashScreen =
      initialDelay - const Duration(milliseconds: 1000);
}

/// Global switches controlling which startup flows are active.
class AppFlowConfig {
  AppFlowConfig._();

  /// * Enable or disable the onboarding flow.
  static const bool onboardingEnabled = true;

  /// * Enable or disable authentication-based routing.
  static const bool authEnabled = true;
}

/// Log tags for routing / flow related components.
class RouterLogTags {
  RouterLogTags._();

  static const String router = '[Router]';
  static const String redirect = '[RouterRedirect]';
}
