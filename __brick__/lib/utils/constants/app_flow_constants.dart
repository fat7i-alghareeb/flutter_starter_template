import 'package:flutter/material.dart' show ThemeMode;

import '../../core/platform/app_platform.dart';
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
  ///
  /// None on desktop: the window stays hidden until its first frame
  /// (`AppWindow`), so there is no native splash to hand over from, and
  /// desktop users expect the app the moment it appears.
  static Duration get initialDelay =>
      AppPlatform.hasDesktopWindow ? Duration.zero : _mobileInitialDelay;
  static const Duration _mobileInitialDelay = Duration(milliseconds: 1750);

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

  /// * «Continue as guest» on the sign-in screen.
  ///
  /// Only matters with [AuthMode.loginRequired]: in [AuthMode.guestFirst] the
  /// button is always there. The router already lets a guest past the wall,
  /// and a guest who touches an action that needs an account is asked to sign
  /// in at that moment (`AuthGate`). Set it to `false` for a hard wall.
  static const bool guestOnLoginWall = true;

  /// Whether the sign-in screen offers «Continue as guest».
  static bool get offersGuest =>
      authMode == AuthMode.guestFirst || guestOnLoginWall;
}

/// Theme defaults.
class AppThemeConfig {
  AppThemeConfig._();

  /// The theme a first launch starts in. A value the user picked later (the
  /// settings screen, stage tools) always wins.
  ///
  /// Light, whatever the device is set to: the template's light palette is the
  /// reference one. Use `ThemeMode.system` to follow the device instead.
  static const ThemeMode defaultMode = ThemeMode.light;
}

/// Log tags for routing / flow related components.
class RouterLogTags {
  RouterLogTags._();

  static const String router = '[Router]';
  static const String redirect = '[RouterRedirect]';
}
