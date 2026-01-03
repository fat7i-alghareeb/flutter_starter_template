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
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();

    // Prefer DI when available. In the template (`__brick__`) this controller
    // may not be registered until the consumer project runs codegen, so we
    // fall back to a local instance.
    final hasDiController = getIt.isRegistered<NavigationController>();
    _controller = hasDiController
        ? getIt<NavigationController>()
        : NavigationController();
    _ownsController = !hasDiController;

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
    if (_ownsController) {
      _controller.dispose();
    }
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
        label: "Forms",
      ),
      BottomNavItem.builder(
        builder: (context, state) {
          final isActive = state.isActive;

          return AnimatedContainer(
            duration: 180.ms,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? state.color.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: state.color,
                  size: state.iconSize,
                ),
                const SizedBox(height: 4),
                Text(
                  'Dialogs',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.s11w500.copyWith(color: state.color),
                ),
              ],
            ),
          );
        },
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
        bottomNavigationBar: BottomNavBar(
          controller: _controller,
          items: items,
        ),
        child: PageView(
          controller: _controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: _controller.handlePageChanged,
          children: List.generate(pages.length, (index) {
            return AnimatedBuilder(
              animation: _controller,
              child: pages[index],
              builder: (context, child) {
                final isActive = index == _controller.currentIndex;

                final animation = child!.animate(
                  key: ValueKey(_controller.transitionToken),
                  target: isActive ? 1 : 0,
                );

                return switch (_controller.transitionType) {
                  RootTransitionType.fade =>
                    animation
                        .fadeIn(duration: 200.ms)
                        .scale(begin: const Offset(0.98, 0.98)),

                  RootTransitionType.scale =>
                    animation
                        .scale(
                          begin: const Offset(0.96, 0.96),
                          end: const Offset(1, 1),
                        )
                        .fadeIn(duration: 160.ms),

                  RootTransitionType.slideLeft =>
                    animation
                        .slideX(begin: 0.08, end: 0)
                        .fadeIn(duration: 180.ms),

                  RootTransitionType.slideRight =>
                    animation
                        .slideX(begin: -0.08, end: 0)
                        .fadeIn(duration: 180.ms),
                };
              },
            );
          }),
        ),
      ),
    );
  }
}
