import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../common/widgets/app_dialog.dart';
import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../common/widgets/scroll_reveal.dart';
import '../../../../../core/injection/injectable.dart';
import '../../../../../core/layout/app_layout.dart';
import '../../../../../core/notification/notification_permission_service.dart';
import '../../../../../core/platform/app_platform.dart';
import '../../../../../core/shortcuts/app_shortcut_catalog.dart';
import '../../../../../core/services/session/auth_manager.dart';
import '../../../../../core/services/session/auth_state_notifier.dart';
import '../../../../../utils/constants/app_flow_constants.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/extensions/context_extensions.dart';
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
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String pageName = 'SettingsScreen';

  /// Relative: nested under the root route (`AppPage.settings`).
  static const String pagePath = 'settings';

  static const double maxContentWidth = 640;

  /// The groups' list in the two-pane layout.
  static const double paneWidth = 300;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// One group of the page: its row in the two-pane list, and its content.
class _Group {
  const _Group(this.icon, this.title, this.content);

  final String icon;
  final String title;
  final Widget content;
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selected = 0;

  List<_Group> _groups(BuildContext context) {
    final layout = context.layout;
    return <_Group>[
      _Group(
        AppIcons.darkMode,
        AppStrings.settingsAppearance,
        const _AppearanceGroup(),
      ),
      _Group(
        AppIcons.bell,
        AppStrings.settingsNotifications,
        const _NotificationsGroup(),
      ),
      // A phone has no keyboard to speak of; a tablet with one and a
      // desktop do.
      if (layout.deviceType != DeviceType.phone)
        _Group(
          AppIcons.keyboard,
          AppStrings.shortcutsTitle,
          const _ShortcutsGroup(),
        ),
      _Group(AppIcons.info, AppStrings.settingsAbout, const _AboutGroup()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final groups = _groups(context);
    final selected = _selected.clamp(0, groups.length - 1);
    final bottom = AppSpacing.lg + MediaQuery.viewPaddingOf(context).bottom;

    // Expanded windows: the groups on the start side, the chosen one beside
    // them — the shape of System Settings on macOS and Windows.
    if (layout.isExpandedUp) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.settingsTitle)),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: SettingsScreen.paneWidth,
              child: ListView(
                padding: EdgeInsetsDirectional.fromSTEB(
                  layout.gutter,
                  AppSpacing.sm,
                  AppSpacing.md,
                  bottom,
                ),
                children: <Widget>[
                  for (var i = 0; i < groups.length; i++)
                    _PaneItem(
                      icon: groups[i].icon,
                      title: groups[i].title,
                      selected: i == selected,
                      onTap: () => setState(() => _selected = i),
                    ),
                  const _AccountGroup(),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: SettingsScreen.maxContentWidth,
                  ),
                  child: ListView(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      layout.gutter,
                      bottom,
                    ),
                    children: <Widget>[
                      KeyedSubtree(
                        key: ValueKey<int>(selected),
                        child: groups[selected].content,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.settingsTitle)),
      body: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: SettingsScreen.maxContentWidth,
          ),
          child: ListView(
            padding: EdgeInsetsDirectional.fromSTEB(
              layout.gutter,
              AppSpacing.sm,
              layout.gutter,
              bottom,
            ),
            children: ScrollReveal.each(<Widget>[
              for (var i = 0; i < groups.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: AppSpacing.lg2),
                groups[i].content,
              ],
              const _AccountGroup(),
            ]),
          ),
        ),
      ),
    );
  }
}

/// A group's row in the two-pane list: the pill marks the open group, with
/// bold text — never colour alone.
class _PaneItem extends StatelessWidget {
  const _PaneItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: AppFocusRing(
        borderRadius: BorderRadius.circular(AppRadii.full),
        child: Semantics(
          selected: selected,
          button: true,
          child: Material(
            color: selected ? colors.primaryContainer : Colors.transparent,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: SizedBox(
                height: AppIconSizes.navTouchTarget,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: <Widget>[
                      AppIcon(
                        icon,
                        color: selected
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: selected
                                ? colors.onPrimaryContainer
                                : colors.onSurface,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A row that opens the list of keyboard shortcuts — the same list `?`
/// opens from anywhere.
class _ShortcutsGroup extends StatelessWidget {
  const _ShortcutsGroup();

  @override
  Widget build(BuildContext context) {
    return AppSettingsGroup(
      title: AppStrings.shortcutsTitle,
      children: <Widget>[
        AppSettingsTile(
          icon: AppIcons.keyboard,
          label: AppStrings.shortcutsTitle,
          value: AppStrings.shortcutsSubtitle,
          showChevron: true,
          onTap: () => AppShortcutCatalog.showHelp(context),
        ),
      ],
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

  /// Desktop has no `permission_handler`: a plain yes/no from
  /// `NotificationPermissionService` (macOS asks; Windows needs no
  /// permission for toasts).
  bool? _desktopGranted;

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
    if (!AppPlatform.isMobile) {
      try {
        final granted = await getIt<NotificationPermissionService>()
            .isNotificationPermissionGranted();
        if (mounted) setState(() => _desktopGranted = granted);
      } on Object {
        // No plugin (a test): the row stays without a value.
      }
      return;
    }
    try {
      final status = await Permission.notification.status;
      if (mounted) setState(() => _status = status);
    } on Object {
      // No plugin (a test, a preview): the row stays without a value.
    }
  }

  Future<void> _onTap() async {
    if (!AppPlatform.isMobile) {
      await getIt<NotificationPermissionService>()
          .requestNotificationPermission(enableDebugLogs: false);
      await _refresh();
      return;
    }
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
    final desktop = _desktopGranted;
    return AppSettingsGroup(
      title: AppStrings.settingsNotifications,
      children: <Widget>[
        AppSettingsTile(
          icon: AppIcons.bell,
          label: AppStrings.settingsNotifications,
          value: desktop != null
              ? (desktop
                    ? AppStrings.settingsNotificationsOn
                    : AppStrings.settingsNotificationsOff)
              : status == null
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
