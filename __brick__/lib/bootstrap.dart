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
import 'core/router/router_config.dart';
import 'core/services/localization/locale_service.dart';
import 'core/services/onboarding/onboarding_service.dart';
import 'core/services/session/auth_manager.dart';
import 'core/services/session/auth_state_notifier.dart';
import 'core/theme/theme_controller.dart';
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

      if (AppConfig.stageToolsEnabled) {
        if (!getIt.isRegistered<StageDevicePreviewController>()) {
          getIt.registerSingleton<StageDevicePreviewController>(
            StageDevicePreviewController(getIt()),
          );
        }
      }

      await EasyLocalization.ensureInitialized();

      // Resolve the locale for the first frame without touching storage.
      final initialLocale = getIt<LocaleService>().resolveStartupLocale();

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
    unawaited(_initializeTheme());
    unawaited(_initializeOnboarding());
    unawaited(_initializeAuthState());
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

Future<void> _initializeTheme() async {
  try {
    await getIt<ThemeController>().initialize();
  } catch (e) {
    printY('[Bootstrap] Theme initialize failed: $e');
  }
}

Future<void> _initializeOnboarding() async {
  try {
    await getIt<OnboardingService>().initialize();
  } catch (e) {
    printY('[Bootstrap] Onboarding initialize failed: $e');
  }
}

/// Initializes notifications.
///
/// Note:
/// - Firebase/FCM initialization is controlled by [NotificationInitOptions]
///   passed to [NotificationCoordinator.initialize].
Future<void> _initializeNotifications() async {
  try {
    final coordinator = getIt<NotificationCoordinator>();

    await coordinator.initialize(
      config: AppNotificationConfig.defaults(),
      options: const NotificationInitOptions(
        initializeFirebase: false,
        enableFcm: false,
      ),
      onNotificationTap: (payload) async {
        await _handleNotificationNavigation(payload);
      },
    );

    printG('[Bootstrap] Notifications initialized');
  } catch (e) {
    printY('[Bootstrap] Notifications initialize failed: $e');
  }
}

Future<void> _handleNotificationNavigation(
  AppNotificationPayload payload,
) async {
  final location = payload.toGoRouterLocation;
  if (location == null || location.isEmpty) {
    printC('[Notifications] Tap ignored (no route/deepLink)');
    return;
  }

  try {
    final router = getIt<AppRouterConfig>().router;
    router.go(location);
    printG('[Notifications] Navigated to $location');
  } catch (e) {
    printY('[Notifications] Navigation failed: $e (location=$location)');
  }
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
