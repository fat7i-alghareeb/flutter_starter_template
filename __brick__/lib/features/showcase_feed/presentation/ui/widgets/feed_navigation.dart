import 'package:flutter/material.dart';

import '../../../../../core/router/app_navigator.dart';
import '../../../../root/presentation/ui/widgets/nav_bar/tab_intent.dart';
import '../../../../settings/presentation/ui/screens/settings_screen.dart';
import '../screens/feed_item_screen.dart';

/// Every way into and out of the feed, in one place — cards never call the
/// router themselves, so a route change touches this file only.
class FeedNavigation {
  FeedNavigation._();

  /// The feed's place in the bar.
  static const int tabIndex = 0;

  /// A search another tab asks the feed to run when it opens
  /// (`TabIntent`, e.g. from the Buttons showcase).
  static final TabIntent<String> searchIntent = TabIntent<String>();

  /// Opens an item PUSHED over whatever is showing — from «More like this»
  /// too: every screen stacks on the one it was opened from.
  static void openItem(BuildContext context, String id) {
    final pushed = AppNavigator.push<void>(
      context,
      AppPage.feedItem,
      params: <String, String>{FeedItemScreen.idParam: id},
    );
    if (pushed != null) return;

    // Outside the app's router — a test, a preview — a plain push still
    // opens the page, so the tap is never a silent no-op.
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => FeedItemScreen(itemId: id)),
    );
  }

  static void openSettings(BuildContext context) {
    final pushed = AppNavigator.push<void>(context, AppPage.settings);
    if (pushed != null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }
}
