import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

import '../../utils/helpers/colored_print.dart';
import 'notification_background.dart';
import 'notification_config.dart';
import 'notification_payload.dart';

/// Wrapper around `firebase_messaging`.
///
/// Responsibilities:
/// - Register the FCM background handler
/// - Configure iOS foreground presentation options
/// - Provide streams for foreground messages, opened messages, token refresh
///
/// Note:
/// - Foreground notifications are intentionally presented via local
///   notifications to keep presentation logic in one place.
@lazySingleton
class NotificationFcmService {
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;

  bool _initialized = false;
  String? _cachedToken;

  bool get isInitialized => _initialized;
  String? get cachedToken => _cachedToken;

  Future<void> initialize({required AppNotificationConfig config}) async {
    if (_initialized) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // This call is safe even when the permission was requested earlier via
    // permission_handler. On iOS it will not prompt again once granted.
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Prevent iOS from showing system notifications in foreground.
    // Foreground notifications are shown via flutter_local_notifications.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    if (config.enableDebugLogs) {
      printG('[Notifications] FCM configured');
    }

    _initialized = true;
  }

  void startListening({
    required AppNotificationConfig config,
    required Future<void> Function(AppNotificationPayload payload)
    onNotificationTap,
    required Future<void> Function(AppNotificationPayload payload)
    onForegroundMessage,
    Future<void> Function(String token)? onTokenRefresh,
  }) {
    _openedSub ??= FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      final payload = AppNotificationPayload.fromRemoteMessage(message);

      if (config.enableDebugLogs) {
        printG('[Notifications] opened from background/terminated');
      }

      await onNotificationTap(payload);
    });

    _foregroundSub ??= FirebaseMessaging.onMessage.listen((message) async {
      final payload = AppNotificationPayload.fromRemoteMessage(message);

      if (config.enableDebugLogs) {
        printG('[Notifications] foreground message received');
      }

      await onForegroundMessage(payload);
    });

    _tokenRefreshSub ??= _messaging.onTokenRefresh.listen((token) {
      _cachedToken = token;
      if (config.enableDebugLogs) {
        printG('[Notifications] token refreshed');
      }
      onTokenRefresh?.call(token);
    });
  }

  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  Future<String?> getDeviceToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _messaging.getToken();
    return _cachedToken;
  }

  Future<void> subscribeToTopics({required List<String> topics}) async {
    for (final topic in topics) {
      await _messaging.subscribeToTopic(topic);
    }
  }

  Future<void> unsubscribeFromTopics({required List<String> topics}) async {
    for (final topic in topics) {
      await _messaging.unsubscribeFromTopic(topic);
    }
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _cachedToken = null;
  }

  Future<void> dispose({bool deleteFcmToken = false}) async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();

    _tokenRefreshSub = null;
    _foregroundSub = null;
    _openedSub = null;

    if (deleteFcmToken) {
      await deleteToken();
    }

    _initialized = false;
  }
}
