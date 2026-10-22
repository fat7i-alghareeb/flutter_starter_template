import '../../../../../common/imports/imports.dart';
import '../../../../../common/widgets/custom_scaffold/app_scaffold.dart';
import '../../../../../common/widgets/nav_bar_visibility.dart';
import '../../../../../core/notification/notification_coordinator.dart';
import '../../../../../core/router/app_links.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/services/session/auth_state_notifier.dart';
import '../../../../../core/router/router_config.dart';
import '../../../../../utils/constants/app_flow_constants.dart';
import '../../../../showcase_feed/presentation/ui/screens/feed_screen.dart';
import '../../../../showcase_feed/presentation/ui/widgets/feed_navigation.dart';
import '../../../constants/root_constants.dart';
import '../widgets/nav_bar/app_bottom_nav.dart';
import '../widgets/nav_bar/app_side_nav.dart';
import '../widgets/nav_bar/navigation_controller.dart';
import '../widgets/nav_bar/navigation_scope.dart';
import '../widgets/nav_bar/side_nav_controller.dart';
import '../widgets/root_back_guard.dart';
import '../widgets/root_tab_stack.dart';
import '../widgets/showcase/root_tab_buttons_showcase.dart';
import '../widgets/showcase/root_tab_dialogs_sheets_showcase.dart';
import '../widgets/showcase/root_tab_forms_showcase.dart';
import '../widgets/showcase/root_tab_notifications_showcase.dart';
import '../widgets/tab_switch_stager.dart';

/// Root screen that hosts the top-level navigation — the app's shell.
///
/// The floating capsule in a compact window, a rail in a medium one (or on
/// a phone held sideways), the sidebar from 840dp (`docs/RESPONSIVE.md`).
///
/// Implementation notes:
/// - The tabs live in a [RootTabStack]: each is built on its first visit and
///   kept from then on (scroll position, filters, loaded data), and a switch
///   is a 220ms cross-fade.
/// - A tab asked for from inside a page is staged by [TabSwitchStager] so it
///   reads as a tab change, not a new page.
/// - Back on another tab returns to the first tab; back on the first tab
///   asks before leaving the app ([RootBackGuard]).
/// - The floating capsule sits over the tabs' content (`extendBody`), and
///   tucks into a dock while a tab scrolls down ([NavBarVisibility]).
/// - Tabs own no scaffold: two scaffolds stacked would give the page two
///   grounds and two safe areas.
///
/// The five destinations below are the template's showcase — replace them
/// with your own tabs (five is the ceiling).
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  static const String pagePath = RootConstants.routePath;
  static const String pageName = 'RootScreen';

  /// The tabs' names, in the order of the bar — also what the desktop title
  /// bar shows for the open tab.
  static List<String> get tabLabels => <String>[
    AppStrings.navFeed,
    AppStrings.navButtons,
    AppStrings.navForms,
    AppStrings.navDialogs,
    AppStrings.navAlerts,
  ];

  static String? tabLabelAt(int index) {
    final labels = tabLabels;
    return index >= 0 && index < labels.length ? labels[index] : null;
  }

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final NavigationController _controller;
  late final bool _ownsController;

  /// The bar tucks into its dock on scroll.
  final NavBarVisibility _barVisibility = NavBarVisibility();

  /// Keeps the tabs alive across a change of navigation layout.
  final GlobalKey _tabsKey = GlobalKey(debugLabel: 'root-tabs');

  /// Demo unread count on Alerts, cleared once the tab is opened, as both
  /// Apple's and Material's badge guidance ask.
  final ValueNotifier<int> _alertsUnread = ValueNotifier<int>(3);
  bool _wasCurrent = true;

  @override
  void initState() {
    super.initState();

    // Prefer DI when available; fall back to a local instance (a test).
    final hasDiController = getIt.isRegistered<NavigationController>();
    _controller = hasDiController
        ? getIt<NavigationController>()
        : NavigationController();
    _ownsController = !hasDiController;
    // Every new screen shows the bar: a tab switch, or a tap on the tab
    // already open.
    _controller.addListener(_barVisibility.show);
    _controller.addListener(_clearAlertsBadge);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // The shell is up: a link that opened the app, or a notification
      // tapped while it started, opens now — OVER the first tab, so back
      // lands here rather than outside the app.
      if (getIt.isRegistered<LinkDispatcher>()) {
        getIt<LinkDispatcher>().shellReady();
      }
      _explainTimeout();
      _askForNotifications();
    });
  }

  void _clearAlertsBadge() {
    if (_controller.currentIndex == 4) _alertsUnread.value = 0;
  }

  /// The notification prompt belongs HERE, not at start-up: asked behind the
  /// splash it would land on top of onboarding on a first launch. Once per
  /// launch; the coordinator remembers.
  void _askForNotifications() {
    if (!getIt.isRegistered<NotificationCoordinator>()) return;
    unawaited(
      getIt<NotificationCoordinator>().requestPermissionFromShell().catchError((
        Object e,
      ) {
        printY('[Root] notification permission request failed: $e');
        return false;
      }),
    );
  }

  /// Startup hit [SplashConfig.maxWait] and the app moved on without a
  /// session read: say so, once.
  void _explainTimeout() {
    if (!getIt.isRegistered<AppRouterConfig>()) return;
    if (!getIt<AppRouterConfig>().bootstrapTimedOut) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: AppSnackContent(SplashConfig.timeoutMessage),
        duration: AppDurations.snackBar,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // …and so does coming back to the tabs from a page opened over them.
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrent && !_wasCurrent) _barVisibility.show();
    _wasCurrent = isCurrent;
  }

  @override
  void dispose() {
    _controller.removeListener(_barVisibility.show);
    _controller.removeListener(_clearAlertsBadge);
    _alertsUnread.dispose();
    _barVisibility.dispose();
    if (getIt.isRegistered<LinkDispatcher>()) {
      getIt<LinkDispatcher>().shellGone();
    }
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;

    final destinations = <AppNavDestination>[
      AppNavDestination(icon: AppIcons.home, label: AppStrings.navFeed),
      AppNavDestination(icon: AppIcons.grid, label: AppStrings.navButtons),
      AppNavDestination(icon: AppIcons.edit, label: AppStrings.navForms),
      AppNavDestination(icon: AppIcons.comment, label: AppStrings.navDialogs),
      AppNavDestination(
        icon: AppIcons.bell,
        label: AppStrings.navAlerts,
        badge: _alertsUnread,
      ),
    ];

    // One builder per tab, in the order of the bar.
    final pageBuilders = <WidgetBuilder>[
      (_) => const FeedScreen(),
      (_) => const RootTabButtonsShowcase(),
      (_) => const RootTabFormsShowcase(),
      (_) => const RootTabDialogsSheetsShowcase(),
      (_) => const RootTabNotificationsShowcase(),
    ];

    // Where the destinations go is the window's call, not the device's
    // (`docs/RESPONSIVE.md`): the capsule in a compact window, the rail in
    // a medium one or on a phone held sideways, the sidebar from 840dp.
    final nav = AppLayoutScope.navOf(context);

    // The SAME tab stack in every layout: a GlobalKey carries it — its
    // scroll positions, loaded data and open search — across a rotation or
    // a window resize instead of rebuilding it from scratch.
    final tabs = NavBarScrollWatcher(
      key: _tabsKey,
      visibility: _barVisibility,
      child: RootTabStack(controller: _controller, tabs: pageBuilders),
    );

    final body = nav == NavLayout.bar
        ? tabs
        : _sideNavLayout(context, nav, destinations, tabs);

    return RootBackGuard(
      controller: _controller,
      child: NavigationScope(
        controller: _controller,
        child: NavBarVisibilityScope(
          visibility: _barVisibility,
          child: TabSwitchStager(
            controller: _controller,
            visibility: _barVisibility,
            labels: <String>[
              for (final destination in destinations) destination.label,
            ],
            child: AppScaffold.body(
              // The capsule floats OVER the tabs rather than sitting on a
              // strip of its own: the lists run on underneath it and show
              // around its edges (`AppBottomNav.listBottomPadding` keeps
              // each last row clear).
              scaffoldConfig: AppScaffoldConfig(
                extendBody: nav == NavLayout.bar,
              ),
              bottomNavigationBar: nav == NavLayout.bar
                  ? AppBottomNav(
                      controller: _controller,
                      destinations: destinations,
                      visibility: _barVisibility,
                    )
                  : null,
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sideNavLayout(
    BuildContext context,
    NavLayout nav,
    List<AppNavDestination> destinations,
    Widget tabs,
  ) {
    final layout = context.layout;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final sideNav = getIt.isRegistered<SideNavController>()
        ? getIt<SideNavController>()
        : null;

    Widget buildSide(bool collapsed) {
      final extended = nav == NavLayout.sidebar && !collapsed;
      return SafeArea(
        // Clear of the status bar, the home indicator and, on a phone held
        // sideways, the notch on the start side.
        left: !isRtl,
        right: isRtl,
        child: AppSideNav(
          controller: _controller,
          destinations: destinations,
          extended: extended,
          short: layout.isShort,
          config: AppSideNavConfig(
            // On desktop the search lives in the title bar.
            showSearch: !layout.isDesktop,
            collapsible: nav == NavLayout.sidebar,
          ),
          onSearch: _search,
          onSettings: () => AppNavigator.push<void>(context, AppPage.settings),
          onAccount: () => _openAccount(context),
        ),
      );
    }

    // The rail sits on the START edge, so it flips with the language like
    // everything else: right in Arabic, left in English.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (sideNav == null)
          buildSide(false)
        else
          ValueListenableBuilder<bool>(
            valueListenable: sideNav,
            builder: (context, collapsed, _) => buildSide(collapsed),
          ),
        Expanded(child: tabs),
      ],
    );
  }

  /// A search typed into the sidebar runs on the feed.
  void _search(String query) {
    FeedNavigation.searchIntent.request(
      _controller,
      FeedNavigation.tabIndex,
      query.trim(),
    );
  }

  void _openAccount(BuildContext context) {
    final auth = getIt.isRegistered<AuthStateNotifier>()
        ? getIt<AuthStateNotifier>()
        : null;
    final page = auth != null && auth.isAuthenticated
        ? AppPage.settings
        : AppPage.login;
    AppNavigator.push<void>(context, page);
  }
}
