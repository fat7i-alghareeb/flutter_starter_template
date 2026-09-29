import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../common/widgets/app_dialog.dart';
import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../common/widgets/scroll_reveal.dart';
import '../../../../../core/injection/injectable.dart';
import '../../../../../core/services/session/auth_manager.dart';
import '../../../../../core/services/session/auth_state_notifier.dart';
import '../../../../../utils/constants/app_flow_constants.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/helpers/app_strings.dart';
import '../widgets/settings_pickers.dart';

/// Settings — one page of groups: appearance, notifications, about and the
/// account.
///
/// ```text
/// ┌──────────────────────────────┐
/// │ ←  Settings                  │
/// │ APPEARANCE                   │
/// │  ◐ Theme          System  ›  │  → picker sheet
/// │  文 Language       English ›  │  → picker sheet
/// │ NOTIFICATIONS                │
/// │  🔔 Notifications  Allowed ›  │  → the system asks, or its settings
/// │ ABOUT                        │
/// │  ⓘ Licenses               ›  │
/// │ ACCOUNT                      │
/// │  ⏻ Sign out                  │  (signed in only)
/// └──────────────────────────────┘
/// ```
///
/// Neither theme nor language is kept in a bloc: `ThemeController` and
/// `easy_localization` already own them for the whole app, and a copy here
/// would be a second answer that could disagree with the first.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String pageName = 'SettingsScreen';

  /// Relative: nested under the root route (`AppPage.settings`).
  static const String pagePath = 'settings';

  static const double maxContentWidth = 640;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.settingsTitle)),
      body: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: ListView(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.screenMargin,
              AppSpacing.sm,
              AppSpacing.screenMargin,
              AppSpacing.lg + MediaQuery.viewPaddingOf(context).bottom,
            ),
            children: ScrollReveal.each(<Widget>[
              const _AppearanceGroup(),
              const SizedBox(height: AppSpacing.lg2),
              const _NotificationsGroup(),
              const SizedBox(height: AppSpacing.lg2),
              const _AboutGroup(),
              const _AccountGroup(),
            ]),
          ),
        ),
      ),
    );
  }
}

class _AppearanceGroup extends StatelessWidget {
  const _AppearanceGroup();

  @override
  Widget build(BuildContext context) {
    return AppSettingsGroup(
      title: AppStrings.settingsAppearance,
      children: <Widget>[
        AppSettingsTile(
          icon: AppIcons.darkMode,
          label: AppStrings.settingsTheme,
          value: SettingsPickers.themeLabel(context),
          showChevron: true,
          onTap: () => SettingsPickers.showTheme(context),
        ),
        AppSettingsTile(
          icon: AppIcons.language,
          label: AppStrings.settingsLanguage,
          value: SettingsPickers.languageLabel(context),
          showChevron: true,
          onTap: () => SettingsPickers.showLanguage(context),
        ),
      ],
    );
  }
}

/// The permission as the system sees it. A denial the system still lets the
/// app ask about is asked again; a permanent one opens the app's settings,
/// the only place left to change it.
class _NotificationsGroup extends StatefulWidget {
  const _NotificationsGroup();

  @override
  State<_NotificationsGroup> createState() => _NotificationsGroupState();
}

class _NotificationsGroupState extends State<_NotificationsGroup>
    with WidgetsBindingObserver {
  PermissionStatus? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back from the system settings: the answer may have changed there.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final status = await Permission.notification.status;
      if (mounted) setState(() => _status = status);
    } on Object {
      // No plugin (a test, a preview): the row stays without a value.
    }
  }

  Future<void> _onTap() async {
    final status = _status;
    if (status == null) return;
    if (status.isGranted) {
      await openAppSettings();
      return;
    }
    final asked = await Permission.notification.request();
    if (asked.isPermanentlyDenied) await openAppSettings();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    return AppSettingsGroup(
      title: AppStrings.settingsNotifications,
      children: <Widget>[
        AppSettingsTile(
          icon: AppIcons.bell,
          label: AppStrings.settingsNotifications,
          value: status == null
              ? null
              : status.isGranted || status.isProvisional
              ? AppStrings.settingsNotificationsOn
              : AppStrings.settingsNotificationsOff,
          showChevron: true,
          onTap: _onTap,
        ),
      ],
    );
  }
}

class _AboutGroup extends StatelessWidget {
  const _AboutGroup();

  @override
  Widget build(BuildContext context) {
    return AppSettingsGroup(
      title: AppStrings.settingsAbout,
      children: <Widget>[
        AppSettingsTile(
          icon: AppIcons.info,
          label: AppStrings.settingsLicenses,
          showChevron: true,
          onTap: () => showLicensePage(
            context: context,
            applicationName: AppStrings.appName,
          ),
        ),
      ],
    );
  }
}

/// Sign out — only for a signed-in user. With `AuthMode.loginRequired` the
/// router then sends them to the sign-in screen; with `guestFirst` they
/// keep browsing as a guest.
class _AccountGroup extends StatelessWidget {
  const _AccountGroup();

  Future<void> _confirmSignOut(BuildContext context) async {
    final leave = await AppDialog.show<bool>(
      context,
      dialog: AppDialog.basic(
        title: AppStrings.settingsSignOutTitle,
        message: AppStrings.settingsSignOutMessage,
        borderRadius: AppRadii.sheet,
        primaryAction: AppDialogAction.primary(
          label: AppStrings.cancel,
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
        ),
        secondaryAction: AppDialogAction.danger(
          label: AppStrings.settingsSignOut,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        ),
      ),
    );
    if (leave != true) return;
    await getIt<AuthManager>().logout();
    if (context.mounted && AppFlowConfig.authMode == AuthMode.guestFirst) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!getIt.isRegistered<AuthStateNotifier>()) {
      return const SizedBox.shrink();
    }
    final session = getIt<AuthStateNotifier>();

    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        if (!session.isAuthenticated) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsetsDirectional.only(top: AppSpacing.lg2),
          child: AppSettingsGroup(
            title: AppStrings.settingsAccount,
            children: <Widget>[
              AppSettingsTile(
                icon: AppIcons.logout,
                label: AppStrings.settingsSignOut,
                isDestructive: true,
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
