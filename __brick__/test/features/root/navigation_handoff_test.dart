import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:{{project_name}}/core/injection/injectable.config.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';

/// A screen pushed over the tab stack — a listing's page, unified search —
/// cannot reach the shell's `NavigationScope`, so it asks `getIt` for the
/// controller instead. That only works if `getIt` hands back the ONE the
/// shell listens to.
///
/// It did not: `NavigationController` was registered as a factory, so every
/// «عرض الكل» from search set the tab index on a fresh controller nobody was
/// listening to, popped the screen, and left home on screen. The
/// marketplace's category capsule had the same hole from a listing opened
/// off home. Found on a device on 2026-09-22; no test had ever asked the
/// container what it returns.
void main() {
  test('getIt hands every caller the same NavigationController', () {
    final container = GetIt.asNewInstance()..init();

    final first = container<NavigationController>();
    final second = container<NavigationController>();

    expect(
      identical(first, second),
      isTrue,
      reason: 'a routed screen must switch the tab the shell is actually '
          'listening to, not a controller of its own',
    );
  });
}
