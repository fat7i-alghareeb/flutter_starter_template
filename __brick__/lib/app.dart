import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'common/widgets/stage_tools/stage_tools_overlay.dart';
import 'common/widgets/stage_tools/stage_device_preview_controller.dart';
import 'common/widgets/rebuild_on_locale_change.dart';
import 'common/widgets/top_banner_slot.dart';
import 'core/network/offline/response_cache.dart';
import 'core/config/app_config.dart';
import 'core/config/localization_config.dart';
import 'core/layout/app_scroll_behavior.dart';
import 'core/shortcuts/app_commands.dart';
import 'core/shortcuts/app_menu_bar.dart';
import 'core/shortcuts/app_shortcut_catalog.dart';
import 'core/shortcuts/app_shortcuts.dart';
import 'core/platform/app_platform.dart';
import 'core/window/app_title_bar.dart';
import 'features/auth/presentation/ui/screens/login_screen.dart';
import 'features/root/presentation/ui/screens/root_screen.dart';
import 'features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';
import 'features/root/presentation/ui/widgets/nav_bar/side_nav_controller.dart';
import 'features/settings/presentation/ui/screens/settings_screen.dart';
import 'features/showcase_feed/presentation/ui/widgets/feed_navigation.dart';
import 'core/layout/adaptive_typography.dart';
import 'core/layout/app_layout_scope.dart';
import 'core/layout/layout_reader.dart';
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
import 'utils/helpers/app_strings.dart';

/// Stage tools stay off on desktop: a phone-sized preview inside a desktop
/// window adds little, and the window can simply be resized.
bool get _stageToolsOn =>
    AppConfig.stageToolsEnabled && !AppPlatform.hasDesktopWindow;

/// The current page's name for the desktop title bar: the open tab, or the
/// page pushed over the tabs.
class _WindowPageTitle extends ValueNotifier<String?> {
  _WindowPageTitle() : super(null) {
    if (!AppPlatform.hasDesktopWindow) return;
    _router = getIt.isRegistered<AppRouterConfig>()
        ? getIt<AppRouterConfig>().router
        : null;
    _tabs = getIt.isRegistered<NavigationController>()
        ? getIt<NavigationController>()
        : null;
    _router?.routerDelegate.addListener(_update);
    _tabs?.addListener(_update);
    _update();
  }

  GoRouter? _router;
  NavigationController? _tabs;

  /// Whether the open page can run the title bar's search: the tabs can (the
  /// feed answers it), the sign-in page and the rest cannot.
  final ValueNotifier<bool> searchAvailable = ValueNotifier<bool>(true);

  void _update() {
    final router = _router;
    if (router == null) return;
    final uri = router.routerDelegate.currentConfiguration.uri;
    final segments = uri.pathSegments;
    final last = segments.isEmpty ? '' : segments.last;
    searchAvailable.value = uri.path == RootScreen.pagePath;
    value = switch (last) {
      SettingsScreen.pagePath => AppStrings.settingsTitle,
      LoginScreen.pagePath => AppStrings.authSignIn,
      _ when uri.path == RootScreen.pagePath => RootScreen.tabLabelAt(
        _tabs?.currentIndex ?? 0,
      ),
      // A page with its own title in the content (an item), the splash,
      // onboarding: the bar shows the app alone.
      _ => null,
    };
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_update);
    _tabs?.removeListener(_update);
    searchAvailable.dispose();
    super.dispose();
  }
}

/// Root widget of the application.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// The page the desktop title bar names.
  late final _WindowPageTitle _pageTitle = _WindowPageTitle();

  @override
  void dispose() {
    _pageTitle.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      unawaited(getIt<LocaleService>().reconcilePersistedLocale(context));
    });
  }

  AppShortcutHandlers _shortcutHandlers(AppRouterConfig routerConfig) {
    final router = routerConfig.router;
    BuildContext? pageContext() =>
        router.routerDelegate.navigatorKey.currentContext;
    final tabs = getIt.isRegistered<NavigationController>()
        ? getIt<NavigationController>()
        : null;
    final sideNav = getIt.isRegistered<SideNavController>()
        ? getIt<SideNavController>()
        : null;
    return AppShortcutHandlers(
      switchTab: (index) {
        if (tabs == null) return;
        // From a page over the tabs: back to the tabs first.
        if (router.routerDelegate.currentConfiguration.uri.path !=
            RootScreen.pagePath) {
          router.go(RootScreen.pagePath);
        }
        tabs.setIndex(index);
      },
      focusSearch: AppCommands.focusSearch,
      openSettings: () {
        final context = pageContext();
        if (context != null) AppNavigator.push<void>(context, AppPage.settings);
      },
      goBack: () {
        final context = pageContext();
        if (context != null) Navigator.maybeOf(context)?.maybePop();
      },
      refresh: AppCommands.refresh,
      toggleSidebar: () => sideNav?.toggle(),
      showHelp: () {
        final context = pageContext();
        if (context != null) AppShortcutCatalog.showHelp(context);
      },
    );
  }

  AppTitleBarConfig _titleBarConfig(BuildContext context) {
    if (!AppPlatform.hasDesktopWindow) return const AppTitleBarConfig();
    final theme = getIt<ThemeController>();
    final sideNav = getIt.isRegistered<SideNavController>()
        ? getIt<SideNavController>()
        : null;
    return AppTitleBarConfig(
      pageTitle: _pageTitle,
      searchAvailable: _pageTitle.searchAvailable,
      isDark: Theme.of(context).brightness == Brightness.dark,
      onToggleSidebar: sideNav?.toggle,
      onToggleTheme: () => theme.setThemeMode(
        Theme.of(context).brightness == Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark,
      ),
      onToggleLanguage: () {
        final next = context.locale.languageCode == AppLanguage.ar.code
            ? AppLanguage.en
            : AppLanguage.ar;
        unawaited(getIt<LocaleService>().changeLanguage(next, context));
      },
      // One search for the whole app: back to the tabs, then the feed runs
      // it (`FeedNavigation.searchIntent`).
      onSearch: (query) {
        getIt<AppRouterConfig>().router.go(RootScreen.pagePath);
        FeedNavigation.searchIntent.request(
          getIt<NavigationController>(),
          FeedNavigation.tabIndex,
          query,
        );
      },
    );
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
              // Always-visible scrollbars on desktop (platform idioms).
              scrollBehavior: const AppScrollBehavior(),
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
                  // The reader's own text size, kept between 85% and 130%
                  // (past that the bar, the cards and the rail stop fitting),
                  // and a little more in a big window.
                  child: AppTextScaleHost(
                    // Device type and window size classes for this frame —
                    // right in the first frame, and in the same frame as a
                    // rotation or a window resize (`docs/RESPONSIVE.md`).
                    child: AppLayoutHost(
                      reader: getIt.isRegistered<LayoutReader>()
                          ? getIt<LayoutReader>()
                          : null,
                      child: AdaptiveTypography(
                        // A change of language rebuilds the whole app in
                        // place. Keyed to `Localizations`, not to
                        // `context.locale`: the `Localizations` locale
                        // changes only once the new strings are LOADED; a
                        // rebuild fired on `context.locale` can run before
                        // that on a cold start — the direction flips and
                        // every word stays in the old language.
                        child: RebuildOnLocaleChange(
                          locale: Localizations.localeOf(context),
                          // Only wrap when stage tools are compiled in, so
                          // regular builds do not pay for an extra widget.
                          // Desktop: the app's own title bar over it all —
                          // pages, dialogs and banners alike.
                          // The keyboard shortcuts and, on macOS, the menu
                          // bar — one set of handlers for both.
                          child: AppMenuBar(
                            handlers: _shortcutHandlers(appRouterConfig),
                            child: AppShortcuts(
                              handlers: _shortcutHandlers(appRouterConfig),
                              child: AppDesktopFrame(
                                config: _titleBarConfig(context),
                                child: _stageToolsOn
                                    ? StageToolsOverlay(child: content)
                                    : content,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          if (!_stageToolsOn || stageDevicePreview == null) {
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
