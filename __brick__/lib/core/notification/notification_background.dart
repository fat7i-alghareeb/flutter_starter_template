import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../utils/helpers/colored_print.dart';

/// Background handlers for the notification system.
///
/// These functions must be top-level and annotated with `@pragma('vm:entry-point')`
/// so they are not tree-shaken and can be invoked by the platform.

/// Handles Firebase Messaging background messages.
///
/// This callback runs in a background isolate. Keep the work minimal.
///
/// Notes:
/// - Do not depend on BuildContext.
/// - Initialize Firebase before accessing other Firebase services.
/// - Showing local notifications from here is possible but intentionally not
///   enabled by default to avoid complex isolate/plugin registrant setup.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  printC('[Notifications] FCM background message received');
  printC('[Notifications] data=${message.data}');
}

/// Handles background taps/actions from flutter_local_notifications.
///
/// This callback is required to support future action-button flows where
/// actions may be handled without showing the UI.
///
/// Notes:
/// - Runs in a background isolate on iOS/Android for some actions.
/// - Keep this function minimal and route work through persisted state or
///   a safe background mechanism.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  printC('[Notifications] Local notification background response');
  printC(
    '[Notifications] actionId=${response.actionId}, payload=${response.payload}',
  );
}
