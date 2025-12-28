import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

/// Root-level navigation controller for the bottom tabs.
///
/// Responsibilities:
/// - Owns the [PageController] used by the root [PageView].
/// - Tracks the current selected tab index.
/// - Exposes a [transitionToken] that increments on tab changes.
///   Widgets can use it as a "change id" to restart animations.
/// - Exposes a [transitionType] describing *how* the UI should animate between
///   tabs (fade/scale/slide). The actual animation is implemented by the UI
///   layer (e.g. `RootScreen`).
///
/// Notes on DI:
/// - This controller is annotated with `@injectable` so it can be resolved via
///   GetIt in generated projects.
/// - In the template (`__brick__`) the DI config might not include it until the
///   consumer project runs code generation.
@injectable
class NavigationController extends ChangeNotifier {
  NavigationController() : _pageController = PageController();

  final PageController _pageController;

  int _currentIndex = 0;
  int _transitionToken = 0;
  int? _pendingJumpIndex;
  RootTransitionType _transitionType = RootTransitionType.fade;

  PageController get pageController => _pageController;

  int get currentIndex => _currentIndex;

  int get transitionToken => _transitionToken;
  RootTransitionType get transitionType => _transitionType;

  /// Sets the initial index before the [PageView] attaches to the
  /// [PageController].
  ///
  /// This is useful when you want to enter the root screen on a specific tab.
  void setInitialIndex(int index) {
    _currentIndex = index;
    _pendingJumpIndex = index;
  }

  /// Should be wired to `PageView.onPageChanged`.
  ///
  /// When a user changes the page (if swipe is enabled) or when the controller
  /// triggers a jump, this keeps [_currentIndex] in sync.
  void handlePageChanged(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    _transitionToken++;
    notifyListeners();
  }

  /// Changes the selected tab.
  ///
  /// We intentionally use `jumpToPage` (not `animateToPage`) to avoid building
  /// intermediate pages when jumping across multiple indices.
  ///
  /// The visual transition is handled separately (e.g. overlay animation in
  /// `RootScreen`) and keyed by [transitionToken] and [transitionType].
  void setIndex(
    int index, {
    RootTransitionType transition = RootTransitionType.fade,
  }) {
    if (index == _currentIndex) return;

    // Store the desired transition type so the UI layer can react.
    _transitionType = transition;
    _currentIndex = index;

    // Bump token so animation widgets can restart using ValueKey(token).
    _transitionToken++;

    if (_pageController.hasClients) {
      // PageView is attached; we can jump immediately.
      _pageController.jumpToPage(index);
    } else {
      // PageView isn't attached yet; store the index and apply it later.
      _pendingJumpIndex = index;
    }

    notifyListeners();
  }

  /// Call this after the `PageView` is built (post-frame) to apply any
  /// pending initial jump.
  void onPageViewReady() {
    final index = _pendingJumpIndex;
    if (index == null) return;
    if (!_pageController.hasClients) return;

    _pageController.jumpToPage(index);
    _pendingJumpIndex = null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// Supported tab transition types.
///
/// This enum is read by the UI (e.g. `RootScreen`) to decide which animation
/// to play when [NavigationController.setIndex] is called.
enum RootTransitionType { fade, scale, slide }
