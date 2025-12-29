import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app.dart' show appAuthMode;
import 'core/config/localization_config.dart';
import 'core/injection/injectable.dart';
import 'core/notification/notification_config.dart';
import 'core/notification/notification_coordinator.dart';
import 'core/notification/notification_init_options.dart';
import 'core/notification/notification_payload.dart';
import 'core/router/router_config.dart';
import 'core/services/localization/locale_service.dart';
import 'core/services/session/auth_manager.dart';
import 'core/theme/theme_controller.dart';
import 'flavors.dart' show F, Flavor;
import 'utils/constants/design_constants.dart';
import 'utils/helpers/colored_print.dart';

/// Common bootstrap entry point used by all flavors.
///
/// This function wires together all low-level initialization steps:
///
/// - Ensures Flutter bindings are initialized.
/// - Initializes EasyLocalization's core infrastructure.
/// - Configures dependency injection via Injectable / GetIt.
/// - Prepares the [AuthManager] and global Dio client according to
///   the selected [appAuthMode].
/// - Resolves the initial locale using [LocaleService].
/// - Runs the provided widget tree inside a guarded zone with
///   EasyLocalization and the active [Flavor].
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Important: keep `ensureInitialized` and `runApp` inside the same zone.
  await runZonedGuarded<Future<void>>(
    () async {
      //    Ensure Flutter engine + widget binding are ready before any
      //    plugins or framework APIs are used.
      WidgetsFlutterBinding.ensureInitialized();

      // Select the active flavor (stage / production) based on the
      // compile-time value provided by the native layer.
      F.appFlavor = Flavor.values.firstWhere(
        (element) => element.name == appFlavor,
        orElse: () => Flavor.stage,
      );

      //    Configure the dependency injection container and register
      //    low-level services and singletons.
      await configureDependencies();

      await _initializeNotifications();

      await EasyLocalization.ensureInitialized();
      await getIt<ThemeController>().initialize();

      await _initializeAuthAndNetwork();

      //    Resolve the locale that the app should start with using
      //    the [LocaleService] abstraction.
      final initialLocale = await getIt<LocaleService>().resolveInitialLocale();

      await _runGuardedApp(builder, initialLocale);
    },
    (error, stackTrace) {
      // Last-resort safety net for any exceptions that happen outside
      // of Flutter's normal error handling pipeline.
      log('Uncaught application error', error: error, stackTrace: stackTrace);
    },
  );
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

/// Initializes the authentication layer and HTTP client.
///
/// Responsibilities:
/// - Creates and registers a single [AuthManager] instance using the
///   globally configured [appAuthMode].
/// - Awaits [AuthManager.initialize] so user/guest and token state are
///   loaded before the UI starts.
/// - Creates and registers a global Dio client using [registerDioClient]
///   so repositories can perform network calls immediately.
Future<void> _initializeAuthAndNetwork() async {
  // Decide which AuthManager variant to use (JWT / non-JWT) based on
  // the app-level selector in app.dart.
  registerAuthManager(appAuthMode);

  // Retrieve the singleton instance that was just registered and
  // perform its asynchronous initialization.
  final authManager = getIt<AuthManager>();
  await authManager.initialize();

  // Prepare the global Dio client according to the selected auth mode so
  // that repositories can start using it immediately.
  registerDioClient(appAuthMode);
}

/// Runs the application inside a guarded zone and wraps it with
/// [EasyLocalization].
///
/// Parameters:
/// - [builder]: Factory that constructs the root widget tree.
/// - [initialLocale]: Locale that should be used as the starting
///   locale for the app.
///
/// This function also assigns the current [Flavor] based on the
/// native `appFlavor` and logs any uncaught errors via [log].
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
      ensureScreenSize: true,
      fontSizeResolver: (fontSize, instance) {
        final width = instance.screenWidth;
        //TODO make this logic const to be used in any other plce the width values i mean
        double factor;
        if (width <= 320) {
          factor = 0.9;
        } else if (width <= 360) {
          factor = 0.95;
        } else if (width <= 400) {
          factor = 1.0;
        } else if (width <= 480) {
          factor = 1.05;
        } else {
          factor = 1.1;
        }

        return fontSize * factor;
      },
      builder: (context, _) => app,
    ),
  );

  // Finally render the localized app tree.
  runApp(localizedApp);
}
