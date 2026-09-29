import '../../../../../common/imports/imports.dart';
import '../../../../../common/widgets/custom_scaffold/app_scaffold.dart';
import '../../../../../common/widgets/nav_bar_visibility.dart';
import '../../../../../core/notification/notification_coordinator.dart';
import '../../../../../core/router/app_links.dart';
import '../../../../../core/router/router_config.dart';
import '../../../../../utils/constants/app_flow_constants.dart';
import '../../../../showcase_feed/presentation/ui/screens/feed_screen.dart';
import '../../../constants/root_constants.dart';
import '../widgets/nav_bar/app_bottom_nav.dart';
import '../widgets/nav_bar/navigation_controller.dart';
import '../widgets/nav_bar/navigation_scope.dart';
import '../widgets/root_back_guard.dart';
import '../widgets/root_tab_stack.dart';
import '../widgets/showcase/root_tab_buttons_showcase.dart';
import '../widgets/showcase/root_tab_dialogs_sheets_showcase.dart';
import '../widgets/showcase/root_tab_forms_showcase.dart';
import '../widgets/showcase/root_tab_notifications_showcase.dart';
import '../widgets/tab_switch_stager.dart';

/// Root screen that hosts the bottom-tab navigation — the app's shell.
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

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final NavigationController _controller;
  late final bool _ownsController;

  /// The bar tucks into its dock on scroll.
  final NavBarVisibility _barVisibility = NavBarVisibility();
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
      AppNavDestination(icon: AppIcons.bell, label: AppStrings.navAlerts),
    ];

    // One builder per tab, in the order of the bar.
    final pageBuilders = <WidgetBuilder>[
      (_) => const FeedScreen(),
      (_) => const RootTabButtonsShowcase(),
      (_) => const RootTabFormsShowcase(),
      (_) => const RootTabDialogsSheetsShowcase(),
      (_) => const RootTabNotificationsShowcase(),
    ];

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
              scaffoldConfig: const AppScaffoldConfig(extendBody: true),
              bottomNavigationBar: AppBottomNav(
                controller: _controller,
                destinations: destinations,
                visibility: _barVisibility,
              ),
              child: NavBarScrollWatcher(
                visibility: _barVisibility,
                child: RootTabStack(
                  controller: _controller,
                  tabs: pageBuilders,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
