import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../common/imports/imports.dart';
import '../../../../../common/widgets/custom_scaffold/app_scaffold.dart';
import '../../../../../core/injection/injectable.dart';
import '../widgets/nav_bar/bottom_navigation.dart';
import '../widgets/nav_bar/navigation_controller.dart';
import '../widgets/nav_bar/navigation_scope.dart';
import '../widgets/showcase/root_tab_buttons_showcase.dart';
import '../widgets/showcase/root_tab_dialogs_sheets_showcase.dart';
import '../widgets/showcase/root_tab_forms_showcase.dart';
import '../widgets/showcase/root_tab_notifications_showcase.dart';

/// Root screen that hosts the bottom-tab navigation.
///
/// Implementation notes:
/// - The root pages are hosted in a [PageView].
/// - Tab switching uses `jumpToPage` via [NavigationController] to avoid
///   building intermediate pages when switching across multiple indices.
/// - A lightweight overlay animation is used to provide a custom visual
///   transition while still keeping the `jumpToPage` behavior.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  static const String pagePath = '/root_screen';
  static const String pageName = 'RootScreen';

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final NavigationController _controller;

  @override
  void initState() {
    super.initState();

    // Prefer DI when available. In the template (`__brick__`) this controller
    // may not be registered until the consumer project runs codegen, so we
    // fall back to a local instance.
    _controller = getIt.isRegistered<NavigationController>()
        ? getIt<NavigationController>()
        : NavigationController();

    // PageController can't jump until the PageView attaches (hasClients).
    // This post-frame callback lets the controller apply any pending initial
    // index safely.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.onPageViewReady();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Example items. These can be replaced with your real tab definitions.
    final items = <BottomNavItem>[
      BottomNavItem.icon(
        icon: IconSource.icon(Icons.smart_button_rounded),
        semanticLabel: "Buttons",
      ),
      BottomNavItem.icon(
        icon: IconSource.icon(Icons.fact_check_rounded),
        semanticLabel: "Forms",
      ),
      BottomNavItem.icon(
        icon: IconSource.icon(Icons.chat_bubble_outline_rounded),
        semanticLabel: "Dialogs",
      ),
      BottomNavItem.icon(
        icon: IconSource.icon(Icons.notifications_active_rounded),
        semanticLabel: "Notifications",
      ),
    ];

    final pages = <Widget>[
      const RootTabButtonsShowcase(),
      const RootTabFormsShowcase(),
      const RootTabDialogsSheetsShowcase(),
      const RootTabNotificationsShowcase(),
    ];

    // Provide the controller to the subtree via a scope so any nested widget
    // can access it without passing it down manually.
    return NavigationScope(
      controller: _controller,
      child: AppScaffold.body(
        bottomNavigationBar: BottomNavigationBar(
          controller: _controller,
          items: items,
        ),
        child: Stack(
          children: [
            // Main content pages. Swiping is disabled to make tab changes
            // fully controlled by the bottom bar.
            PageView(
              controller: _controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _controller.handlePageChanged,
              children: pages,
            ),

            // Overlay transition.
            //
            // Because we use `jumpToPage`, the content changes instantly.
            // We briefly show a theme-colored overlay to mask the jump and
            // provide a custom animation.
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final overlayColor = context.surface;

                Widget overlay = ColoredBox(color: overlayColor);

                // Pick a visual effect based on the transition type requested
                // by the controller.
                overlay = switch (_controller.transitionType) {
                  RootTransitionType.fade =>
                    overlay
                        .animate(key: ValueKey(_controller.transitionToken))
                        .fadeIn(duration: 90.ms)
                        .then(delay: 40.ms)
                        .fadeOut(duration: 140.ms),

                  RootTransitionType.scale =>
                    overlay
                        .animate(key: ValueKey(_controller.transitionToken))
                        .scale(
                          begin: const Offset(0.96, 0.96),
                          end: const Offset(1, 1),
                        )
                        .fadeOut(duration: 160.ms),

                  RootTransitionType.slide =>
                    overlay
                        .animate(key: ValueKey(_controller.transitionToken))
                        .slideY(begin: 0.05, end: 0)
                        .fadeOut(duration: 180.ms),
                };

                // IgnorePointer ensures the overlay never blocks user input.
                return IgnorePointer(child: overlay);
              },
            ),
          ],
        ),
      ),
    );
  }
}
