import 'package:flutter/widgets.dart';

import 'root_navigation_controller.dart';

/// An `InheritedNotifier` that exposes a [RootNavigationController] to the
/// widget subtree.
///
/// Why a "Scope"?
/// - In Flutter, a "scope" is a widget that provides a value (state/service)
///   to everything below it in the widget tree.
/// - We use a scope instead of passing the controller manually through
///   constructors (prop drilling), which becomes noisy as the tree grows.
///
/// Why `InheritedNotifier`?
/// - [InheritedNotifier] listens to a [Listenable] (here: [ChangeNotifier]) and
///   automatically rebuilds dependents when `notifyListeners()` is called.
/// - This gives us a Provider-like experience without adding a dependency on
///   provider packages.
class RootNavigationScope extends InheritedNotifier<RootNavigationController> {
  const RootNavigationScope({
    super.key,
    required RootNavigationController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Returns the controller if a [RootNavigationScope] exists above [context],
  /// otherwise returns `null`.
  ///
  /// Use this when you want to optionally react to the controller.
  static RootNavigationController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<RootNavigationScope>()
        ?.notifier;
  }

  /// Returns the controller from the nearest [RootNavigationScope].
  ///
  /// This will assert in debug mode if the scope is missing.
  ///
  /// Use this when the controller is required for the current widget to work.
  static RootNavigationController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'RootNavigationScope not found in widget tree');
    return controller!;
  }
}
