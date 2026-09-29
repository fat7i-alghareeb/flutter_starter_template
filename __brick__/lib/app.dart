import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import 'common/widgets/stage_tools/stage_tools_overlay.dart';
import 'common/widgets/stage_tools/stage_device_preview_controller.dart';
import 'common/widgets/rebuild_on_locale_change.dart';
import 'common/widgets/top_banner_slot.dart';
import 'core/network/offline/response_cache.dart';
import 'core/config/app_config.dart';
import 'features/auth/presentation/states/auth_bloc.dart';
import 'core/router/app_navigator.dart';
import 'features/auth/presentation/ui/widgets/session_expired_banner.dart';
import 'core/injection/injectable.dart';
import 'core/router/router_config.dart';
import 'core/services/localization/locale_service.dart';
import 'core/services/session/auth_state_notifier.dart';
import 'core/theme/app_system_ui_overlay.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'utils/constants/app_flow_constants.dart';
import 'utils/constants/design_constants.dart';

/// Root widget of the application.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      unawaited(getIt<LocaleService>().reconcilePersistedLocale(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final appRouterConfig = getIt<AppRouterConfig>();
    final themeController = getIt<ThemeController>();
    final stageDevicePreview = StageDevicePreviewController.tryGet();

    // AuthBloc sits ABOVE MaterialApp on purpose.
    //
    // In `AuthMode.guestFirst` a protected action can be touched from any
    // screen, and the sheet that asks for sign-in is not a route — it is a
    // modal over whatever is already there. Providing the bloc per screen
    // would give each one its own instance, so a sign-in started in the
    // sheet would not be seen by the screen underneath it.
    //
    // `create`, not `.value(getIt())`: `AuthBloc` is a DI factory, and a
    // factory asked for inside `build` is a new instance on every rebuild.
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>(),
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          Widget buildMaterialApp({required bool devicePreviewEnabled}) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: AppConfig.appTitle,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeController.themeMode,
              themeAnimationDuration: AppDurations.themeAnimation,
              themeAnimationCurve: AppCurves.theme,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: devicePreviewEnabled
                  ? DevicePreview.locale(context)
                  : context.locale,
              routerConfig: appRouterConfig.router,
              // Wrap the app in an AnnotatedRegion so the system UI (status
              // bar, navigation bar) can adapt its colors and icon brightness
              // based on the active theme.
              builder: (context, child) {
                final theme = Theme.of(context);
                final overlayStyle = AppSystemUiOverlay.forTheme(theme);

                final builtChild = devicePreviewEnabled
                    ? DevicePreview.appBuilder(context, child)
                    : child;

                // Two strips can sit above the app — an expired session
                // (guest-first only: with a login wall the router already
                // sends the user to sign in) and no network — each pushing
                // it down, neither covering it.
                var app = builtChild ?? const SizedBox.shrink();
                if (getIt.isRegistered<OfflineNotice>()) {
                  app = OfflineBannerHost(
                    notice: getIt<OfflineNotice>(),
                    child: app,
                  );
                }
                final content =
                    AppFlowConfig.authMode == AuthMode.guestFirst &&
                        getIt.isRegistered<AuthStateNotifier>()
                    ? SessionBannerHost(
                        session: getIt<AuthStateNotifier>(),
                        onSignIn: () => AppNavigator.pushTarget<void>(
                          appRouterConfig.router,
                          const AppTarget(AppPage.login),
                        ),
                        child: app,
                      )
                    : app;

                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: overlayStyle,
                  // A change of language rebuilds the whole app in place.
                  // Keyed to `Localizations`, not to `context.locale`: the
                  // `Localizations` locale changes only once the new strings
                  // are LOADED; a rebuild fired on `context.locale` can run
                  // before that on a cold start — the direction flips and
                  // every word stays in the old language.
                  child: RebuildOnLocaleChange(
                    locale: Localizations.localeOf(context),
                    // Only wrap when stage tools are compiled in, so regular
                    // builds do not pay for an extra widget in the tree.
                    child: AppConfig.stageToolsEnabled
                        ? StageToolsOverlay(child: content)
                        : content,
                  ),
                );
              },
            );
          }

          if (!AppConfig.stageToolsEnabled || stageDevicePreview == null) {
            return buildMaterialApp(devicePreviewEnabled: false);
          }

          return ValueListenableBuilder<bool>(
            valueListenable: stageDevicePreview.enabled,
            builder: (context, enabled, _) {
              if (!enabled) {
                return buildMaterialApp(devicePreviewEnabled: false);
              }

              return DevicePreview(
                enabled: enabled,
                builder: (context) =>
                    buildMaterialApp(devicePreviewEnabled: true),
              );
            },
          );
        },
      ),
    );
  }
}
