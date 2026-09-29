import 'dart:async';
import 'dart:developer';

import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiMode;
import 'core/config/app_config.dart';
import 'core/config/localization_config.dart';
import 'core/injection/injectable.dart';
import 'core/notification/notification_config.dart';
import 'core/notification/notification_coordinator.dart';
import 'core/notification/notification_init_options.dart';
import 'core/notification/notification_payload.dart';
import 'core/notification/push_token_registrar.dart';
import 'core/router/app_links.dart';
import 'core/services/localization/locale_service.dart';
import 'core/services/onboarding/onboarding_service.dart';
import 'core/services/session/auth_manager.dart';
import 'core/services/session/auth_state_notifier.dart';
import 'core/theme/theme_controller.dart';
import 'features/showcase_feed/presentation/states/feed_preloader.dart';
import 'common/widgets/stage_tools/stage_device_preview_controller.dart';
import 'utils/constants/app_flow_constants.dart';
import 'utils/constants/design_constants.dart';
import 'utils/helpers/colored_print.dart';

const double _tinyPhoneMaxWidth = 320;
const double _smallPhoneMaxWidth = 360;
const double _basePhoneMaxWidth = 400;
const double _largePhoneMaxWidth = 480;

const double _tinyPhoneFontScaleFactor = 0.9;
const double _smallPhoneFontScaleFactor = 0.95;
const double _basePhoneFontScaleFactor = 1;
const double _largePhoneFontScaleFactor = 1.05;
const double _tabletFontScaleFactor = 1.1;

/// Common bootstrap entry point for the application.
///
/// This function wires together all low-level initialization steps:
///
/// - Ensures Flutter bindings are initialized.
/// - Initializes EasyLocalization's core infrastructure.
/// - Configures dependency injection via Injectable / GetIt.
/// - Configures Injectable / GetIt without blocking the first frame.
/// - Registers stage-only tooling when [AppConfig.stageToolsEnabled] is set.
/// - Resolves the initial locale using [LocaleService].
/// - Restores the saved theme, so the first frame is drawn in it.
/// - Runs the provided widget tree inside a guarded zone with
///   EasyLocalization.
/// - Starts non-critical service warmup after the first frame.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Important: keep `ensureInitialized` and `runApp` inside the same zone.
  await runZonedGuarded<Future<void>>(
    () async {
      //    Ensure Flutter engine + widget binding are ready before any
      //    plugins or framework APIs are used.
      WidgetsFlutterBinding.ensureInitialized();
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      //    Configure the dependency injection container.
      configureDependencies();

      //    Links from outside the app — a shared URL, a notification — go to
      //    the dispatcher BEFORE the router. The binding asks its observers
      //    in the order they were added and stops at the first `true`; the
      //    router adds its own when it is first built, after this line.
      WidgetsBinding.instance.addObserver(getIt<LinkDispatcher>());

      if (AppConfig.stageToolsEnabled) {
        if (!getIt.isRegistered<StageDevicePreviewController>()) {
          getIt.registerSingleton<StageDevicePreviewController>(
            StageDevicePreviewController(getIt()),
          );
        }
      }

      await EasyLocalization.ensureInitialized();

      // The saved LANGUAGE is read before the first frame, alongside the
      // theme below. Applied after it, the app would start in one language
      // and switch — and on a cold start that switch can race
      // `easy_localization`'s own load: `Localizations` takes the new locale
      // while its file is still loading and never reloads, so the app runs
      // in the new direction with every word in the old language. With the
      // right language from the first frame there is no switch to race.
      final savedLocale = _resolveSavedLocale();

      // The saved theme is read before the first frame too: it is part of
      // that frame being correct. Restored after it, every launch in dark
      // would draw the splash light and then fade it to dark in the middle
      // of its entrance — right after a native splash that was already
      // dark. It is one preferences read, made while the native splash
      // still covers the screen; the budget only guards against a read that
      // never returns, and a late one still lands, just animated.
      await _initializeTheme().timeout(
        _themeRestoreBudget,
        onTimeout: () {},
      );
      final initialLocale = await savedLocale;

      await _runGuardedApp(builder, initialLocale);
      _startPostLaunchWarmup();
    },
    (error, stackTrace) {
      // Last-resort safety net for any exceptions that happen outside
      // of Flutter's normal error handling pipeline.
      log('Uncaught application error', error: error, stackTrace: stackTrace);
    },
  );
}

double _resolveFontScaleFactor(double screenWidth) {
  if (screenWidth <= _tinyPhoneMaxWidth) return _tinyPhoneFontScaleFactor;
  if (screenWidth <= _smallPhoneMaxWidth) return _smallPhoneFontScaleFactor;
  if (screenWidth <= _basePhoneMaxWidth) return _basePhoneFontScaleFactor;
  if (screenWidth <= _largePhoneMaxWidth) return _largePhoneFontScaleFactor;
  return _tabletFontScaleFactor;
}

void _startPostLaunchWarmup() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeStageTools());
    unawaited(_initializeOnboarding());
    unawaited(_initializeAuthState());
    // The native splash is gone with this frame: the first tab's requests
    // start now, behind the custom splash, as soon as the session is read
    // (`BlocPreloader`).
    _preloadFirstTab();
    unawaited(
      Future<void>.delayed(SplashConfig.initialDelay, _initializeNotifications),
    );
  });
}

Future<void> _initializeStageTools() async {
  if (!AppConfig.stageToolsEnabled) return;

  try {
    await getIt<StageDevicePreviewController>().load();
  } catch (e) {
    printY('[Bootstrap] Stage tools initialize failed: $e');
  }
}

/// The longest the first frame waits for the saved theme.
const Duration _themeRestoreBudget = Duration(milliseconds: 250);

/// The reader's saved language, or the device's when there is none or the
/// read is slower than [_themeRestoreBudget] — `App` still applies a late
/// one after the first frame (`LocaleService.reconcilePersistedLocale`).
Future<Locale> _resolveSavedLocale() async {
  final service = getIt<LocaleService>();
  try {
    final saved = await service.resolveSavedLocale().timeout(
      _themeRestoreBudget,
      onTimeout: () => null,
    );
    return saved ?? service.resolveStartupLocale();
  } catch (e) {
    printY('[Bootstrap] Saved locale read failed: $e');
    return service.resolveStartupLocale();
  }
}

Future<void> _initializeTheme() async {
  try {
    await getIt<ThemeController>().initialize();
  } catch (e) {
    printY('[Bootstrap] Theme initialize failed: $e');
  }
}

void _preloadFirstTab() {
  try {
    getIt<FeedPreloader>().start();
  } catch (e) {
    printY('[Bootstrap] Feed preload failed to start: $e');
  }
}

Future<void> _initializeOnboarding() async {
  try {
    await getIt<OnboardingService>().initialize();
  } catch (e) {
    printY('[Bootstrap] Onboarding initialize failed: $e');
  }
}

/// Firebase Cloud Messaging (push). OFF by default: the template ships no
/// Firebase project. Turn it on once `google-services.json` /
/// `GoogleService-Info.plist` and the Gradle plugin are in place
/// (`docs/ANDROID_RELEASE_SETUP.md`, `docs/IOS_SETUP.md`). Local
/// notifications work either way.
const bool _fcmEnabled = false;

/// Initializes notifications.
///
/// No permission prompt here: this runs behind the splash, and on a first
/// launch the prompt would land on top of onboarding. `RootScreen` asks
/// once the user is in the app.
Future<void> _initializeNotifications() async {
  try {
    final coordinator = getIt<NotificationCoordinator>();

    await coordinator.initialize(
      config: AppNotificationConfig.defaults(),
      onNotificationTap: (payload) async {
        await _handleNotificationNavigation(payload);
      },
      // With FCM on, every new token is sent to the server (`/devices`).
      onTokenRefresh: _fcmEnabled
          ? getIt<PushTokenRegistrar>().tokenChanged
          : null,
      options: const NotificationInitOptions(
        initializeFirebase: _fcmEnabled,
        enableFcm: _fcmEnabled,
        requestPermissionsAtStartup: false,
      ),
    );

    printG('[Bootstrap] Notifications initialized');
  } catch (e) {
    printY('[Bootstrap] Notifications initialize failed: $e');
  }
}

/// A tapped notification opens its page OVER the shell.
///
/// `go` would replace the stack: the page would open with nothing under it
/// and back would leave the app. And on a cold start the shell is not up
/// yet — the dispatcher holds the page until it is.
Future<void> _handleNotificationNavigation(
  AppNotificationPayload payload,
) async {
  final location = payload.toGoRouterLocation;
  if (location == null || location.isEmpty) {
    printC('[Notifications] Tap ignored (no page to open)');
    return;
  }

  getIt<LinkDispatcher>().open(location);
}

/// Initializes persisted authentication state after the first frame.
///
/// Responsibilities:
/// - Loads user/guest and JWT token state from storage.
/// - Moves [AuthStateNotifier] out of `Status.initial` so the router can
///   leave splash once all startup guards are resolved.
Future<void> _initializeAuthState() async {
  try {
    final authManager = getIt<AuthManager>();
    await authManager.initialize();
  } catch (e) {
    printY('[Bootstrap] Auth initialize failed: $e');
    getIt<AuthStateNotifier>().setAuthStatus(
      AuthStatus.unauthenticated(message: 'Startup auth failed'),
    );
  }
}

/// Runs the application inside a guarded zone and wraps it with
/// [EasyLocalization].
///
/// Parameters:
/// - [builder]: Factory that constructs the root widget tree.
/// - [initialLocale]: Locale that should be used as the starting
///   locale for the app.
///
/// Any uncaught errors are logged via [log].
Future<void> _runGuardedApp(
  FutureOr<Widget> Function() builder,
  Locale initialLocale,
) async {
  // Build the actual root widget tree provided by the caller.
  final app = await builder();

  // Wrap the root app with EasyLocalization and ScreenUtil so that:
  // - Localized strings are available everywhere.
  // - The app starts with the resolved [initialLocale].
  // - Responsive sizing via ScreenUtil is available globally.
  final localizedApp = EasyLocalization(
    supportedLocales: AppLocalizationConfig.supportedLanguageCodes
        .map((code) => Locale(code))
        .toList(),
    path: AppLocalizationConfig.translationsPath,
    fallbackLocale: const Locale(AppLocalizationConfig.fallbackLanguageCode),
    startLocale: initialLocale,
    saveLocale: false,
    useOnlyLangCode: true,
    // The package's default ignores the language's plural rules and knows
    // only 0 · 1 · 2 · «other» — Arabic's «few» (3-10) and «many» (11-99)
    // would both print the «other» form (`AppStrings`' `_plural`).
    ignorePluralRules: false,
    child: ScreenUtilInit(
      designSize: AppDesign.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      fontSizeResolver: (fontSize, instance) {
        return fontSize * _resolveFontScaleFactor(instance.screenWidth);
      },
      builder: (context, _) => app,
    ),
  );

  // Finally render the localized app tree.
  runApp(localizedApp);
}
