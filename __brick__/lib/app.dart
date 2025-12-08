import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/injection/injectable.dart';
import 'core/router/router_config.dart';
import 'core/services/session/auth_manager.dart';
import 'core/theme/app_system_ui_overlay.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/theme_controller.dart';
import 'utils/constants/design_constants.dart';

/// Global auth mode selector for this app.
///
/// Change this single constant to switch between JWT and non-JWT auth flows.
const AuthMode appAuthMode = AuthMode.withJwt;

/// Root widget of the application.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouterConfig = getIt<AppRouterConfig>();
    final themeController = getIt<ThemeController>();

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final textTheme = AppTypography.buildTextTheme(context);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(context, textTheme),
          darkTheme: AppTheme.dark(context, textTheme),
          themeMode: themeController.themeMode,
          themeAnimationDuration: AppDurations.themeAnimation,
          themeAnimationCurve: AppCurves.theme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: appRouterConfig.router,
          // Wrap the app in an AnnotatedRegion so the system UI (status
          // bar, navigation bar) can adapt its colors and icon brightness
          // based on the active theme.
          builder: (context, child) {
            final theme = Theme.of(context);
            final overlayStyle = AppSystemUiOverlay.forTheme(theme);

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlayStyle,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
