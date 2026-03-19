import 'package:easy_localization/easy_localization.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'common/widgets/stage_tools/stage_tools_overlay.dart';
import 'common/widgets/stage_tools/stage_device_preview_controller.dart';
import 'core/injection/injectable.dart';
import 'core/router/router_config.dart';
import 'core/theme/app_system_ui_overlay.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'flavors.dart';
import 'utils/constants/design_constants.dart';

/// Root widget of the application.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouterConfig = getIt<AppRouterConfig>();
    final themeController = getIt<ThemeController>();
    final stageDevicePreview = StageDevicePreviewController.tryGet();

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        Widget buildMaterialApp({required bool devicePreviewEnabled}) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
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
              SystemChrome.setSystemUIOverlayStyle(overlayStyle);

              final builtChild = devicePreviewEnabled
                  ? DevicePreview.appBuilder(context, child)
                  : child;

              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: StageToolsOverlay(
                  child: builtChild ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        }

        if (F.appFlavor != Flavor.stage || stageDevicePreview == null) {
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
    );
  }
}
