import 'package:flutter/material.dart' show ThemeMode;

import '../helpers/app_strings.dart';

/// App flow and routing related constants.
class OnboardingStorageKeys {
  OnboardingStorageKeys._();

  /// Persistent flag indicating that onboarding was completed at least once.
  static const String finished = 'onboarding.finished';
}

/// Configuration for splash screen behavior.
class SplashConfig {
  SplashConfig._();

  /// How long the custom splash screen's entrance takes (name and tagline
  /// rising in). The splash screen drives its animation with this.
  static const Duration entrance = Duration(milliseconds: 950);

  /// How long the finished splash stays on screen after [entrance] before
  /// routing may leave it.
  static const Duration holdAfterEntrance = Duration(milliseconds: 800);

  /// How long the splash stays before routing may leave it: [entrance] +
  /// [holdAfterEntrance].
  ///
  /// The first tab's requests do not wait for it: they start as soon as the
  /// session is read, behind this screen (`BlocPreloader`).
  static const Duration initialDelay = Duration(milliseconds: 1750);

  /// Hard ceiling on the splash.
  ///
  /// If bootstrap has not finished by now the app moves on instead of
  /// holding the user on a screen that never ends — a stalled token refresh
  /// would otherwise strand them indefinitely. With [AuthMode.guestFirst]
  /// the reader continues as a guest; with [AuthMode.loginRequired] they
  /// land on the sign-in screen.
  static const Duration maxWait = Duration(seconds: 8);

  /// Message shown once, in the shell, when [maxWait] was hit.
  ///
  /// A getter rather than a constant: it resolves against the active locale,
  /// which a `const String` cannot do.
  static String get timeoutMessage => AppStrings.authTimeout;
}

/// How the app treats a reader without an account.
enum AuthMode {
  /// The sign-in screen is a wall: a reader who is neither signed in nor a
  /// guest is sent to it after onboarding.
  loginRequired,

  /// Everyone enters the app; the few actions that need an account ask for
  /// it at that moment (`AuthGateSheet`), then resume on their own
  /// (`PendingActionQueue`). An expired session shows a banner instead of
  /// throwing the reader out.
  guestFirst,
}

/// Global switches controlling which startup flows are active.
class AppFlowConfig {
  AppFlowConfig._();

  /// * Enable or disable the onboarding flow.
  static const bool onboardingEnabled = true;

  /// * Login wall or guest-first browsing. See [AuthMode].
  static const AuthMode authMode = AuthMode.loginRequired;
}

/// Theme defaults.
class AppThemeConfig {
  AppThemeConfig._();

  /// The theme a first launch starts in. A value the user picked later (the
  /// settings screen, stage tools) always wins.
  static const ThemeMode defaultMode = ThemeMode.system;
}

/// Log tags for routing / flow related components.
class RouterLogTags {
  RouterLogTags._();

  static const String router = '[Router]';
  static const String redirect = '[RouterRedirect]';
}
