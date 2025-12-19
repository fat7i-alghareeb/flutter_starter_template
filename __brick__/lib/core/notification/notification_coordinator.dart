import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show DateTimeComponents;
import 'package:injectable/injectable.dart';

import '../../utils/helpers/colored_print.dart';
import 'notification_config.dart';
import 'notification_fcm_service.dart';
import 'notification_init_options.dart';
import 'notification_local_service.dart';
import 'notification_payload.dart';
import 'notification_permission_service.dart';
import 'notification_timezone_service.dart';

/// Facade/orchestrator for the app notification system.
///
/// This class intentionally stays small by delegating work to focused services:
/// - [NotificationPermissionService] (permission_handler)
/// - [NotificationTimezoneService] (timezone + flutter_timezone)
/// - [NotificationLocalService] (flutter_local_notifications)
/// - [NotificationFcmService] (firebase_messaging)
@lazySingleton
class NotificationCoordinator {
  NotificationCoordinator(
    this._permissionService,
    this._timezoneService,
    this._localService,
    this._fcmService,
  );

  final NotificationPermissionService _permissionService;
  final NotificationTimezoneService _timezoneService;
  final NotificationLocalService _localService;
  final NotificationFcmService _fcmService;

  AppNotificationConfig? _config;
  NotificationInitOptions _options = const NotificationInitOptions();
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Cached FCM token (only available when FCM is enabled).
  String? get cachedToken => _fcmService.cachedToken;

  /// Returns whether notification permission is currently granted.
  Future<bool> isNotificationPermissionGranted() {
    return _permissionService.isNotificationPermissionGranted();
  }

  /// Requests notification permission.
  ///
  /// By default the module requests permission at startup (see
  /// [NotificationInitOptions.requestPermissionsAtStartup]).
  Future<bool> requestNotificationPermission({
    bool openSettingsIfPermanentlyDenied = false,
  }) {
    final enableDebugLogs = _config?.enableDebugLogs ?? false;
    return _permissionService.requestNotificationPermission(
      enableDebugLogs: enableDebugLogs,
      openSettingsIfPermanentlyDenied: openSettingsIfPermanentlyDenied,
    );
  }

  /// Initializes the notification system.
  ///
  /// This is designed to be the **single entry point** called from `bootstrap`.
  ///
  /// Order:
  /// 1) Request permissions (permission_handler)
  /// 2) Initialize timezones (timezone + flutter_timezone)
  /// 3) Initialize local notifications (flutter_local_notifications)
  /// 4) Optionally initialize Firebase + enable FCM
  Future<void> initialize({
    required AppNotificationConfig config,
    required Future<void> Function(AppNotificationPayload payload)
    onNotificationTap,
    NotificationInitOptions options = const NotificationInitOptions(),
    Future<void> Function(AppNotificationPayload payload)?
    onForegroundNotification,
    Future<void> Function(String token)? onTokenRefresh,
  }) async {
    if (_initialized) return;

    _config = config;
    _options = options;

    if (config.enableDebugLogs) {
      printG('[Notifications] initialize');
    }

    if (options.requestPermissionsAtStartup) {
      await _permissionService.requestNotificationPermission(
        enableDebugLogs: config.enableDebugLogs,
      );
    }

    await _timezoneService.initialize(enableDebugLogs: config.enableDebugLogs);

    await _localService.initialize(
      config: config,
      onNotificationTap: onNotificationTap,
      requestPermissions: false,
    );

    if (options.enableFcm) {
      try {
        if (Firebase.apps.isEmpty && options.initializeFirebase) {
          await Firebase.initializeApp();
        }

        if (Firebase.apps.isEmpty) {
          if (config.enableDebugLogs) {
            printY(
              '[Notifications] Firebase not initialized; skipping FCM. '
              '(set initializeFirebase: true or initialize Firebase elsewhere)',
            );
          }
        } else {
          await _fcmService.initialize(config: config);

          _fcmService.startListening(
            config: config,
            onNotificationTap: onNotificationTap,
            onForegroundMessage: (payload) async {
              await _localService.showFromPayload(
                config: config,
                payload: payload,
              );
              await onForegroundNotification?.call(payload);
            },
            onTokenRefresh: onTokenRefresh,
          );

          // Handle terminated launch via FCM.
          _fcmService.getInitialMessage().then((message) {
            if (message == null) return;
            final payload = AppNotificationPayload.fromRemoteMessage(message);

            if (config.enableDebugLogs) {
              printG('[Notifications] initial message (terminated launch)');
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              unawaited(onNotificationTap(payload));
            });
          });

          if (config.autoSubscribeToTopics && config.initialTopics.isNotEmpty) {
            await subscribeToTopics(config.initialTopics);
          }

          final token = await _fcmService.getDeviceToken();
          if (token != null && token.isNotEmpty) {
            await onTokenRefresh?.call(token);

            if (config.enableDebugLogs) {
              printG('[Notifications] token ready');
            }
          }
        }
      } catch (e) {
        if (config.enableDebugLogs) {
          printY('[Notifications] FCM init failed: $e');
        }
      }
    }

    _initialized = true;

    if (config.enableDebugLogs) {
      printG('[Notifications] initialized');
    }
  }

  /// Subscribes this device to the given FCM [topics].
  ///
  /// Use this for user-preference based topics.
  Future<void> subscribeToTopics(List<String> topics) async {
    final config = _config;
    if (!_initialized || config == null) return;
    if (!_options.enableFcm) return;

    await _fcmService.subscribeToTopics(topics: topics);

    if (config.enableDebugLogs) {
      printG('[Notifications] subscribed topics=${topics.join(',')}');
    }
  }

  /// Unsubscribes this device from the given FCM [topics].
  Future<void> unsubscribeFromTopics(List<String> topics) async {
    final config = _config;
    if (!_initialized || config == null) return;
    if (!_options.enableFcm) return;

    await _fcmService.unsubscribeFromTopics(topics: topics);

    if (config.enableDebugLogs) {
      printG('[Notifications] unsubscribed topics=${topics.join(',')}');
    }
  }

  /// Returns the current FCM device token.
  ///
  /// Notes:
  /// - This method returns a cached value when available.
  /// - If not initialized, it will still attempt to retrieve the token.
  Future<String?> getDeviceToken() async {
    if (!_options.enableFcm) return null;
    return _fcmService.getDeviceToken();
  }

  /// Displays a local notification using the unified configuration.
  ///
  /// This can be used to show local-only notifications (not coming from FCM).
  Future<void> showLocal({
    required String title,
    required String body,
    Map<String, dynamic> data = const <String, dynamic>{},
    String? androidChannelId,
  }) async {
    final config = _config;
    if (!_initialized || config == null) return;

    final payload = AppNotificationPayload(
      data: data,
      title: title,
      body: body,
      androidChannelId: androidChannelId,
    );

    await _localService.showFromPayload(config: config, payload: payload);
  }

  /// Schedules a local notification.
  ///
  /// This uses timezone-aware scheduling.
  ///
  /// Important notes:
  /// - Android exact scheduling may require additional permissions.
  /// - For recurring schedules, use [matchDateTimeComponents].
  Future<void> scheduleLocal({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    DateTimeComponents? matchDateTimeComponents,
    Map<String, dynamic> data = const <String, dynamic>{},
    String? androidChannelId,
  }) async {
    final config = _config;
    if (!_initialized || config == null) return;

    final scheduled = _timezoneService.toLocalTz(date);

    await _localService.schedule(
      config: config,
      id: id,
      title: title,
      body: body,
      scheduledAt: scheduled,
      matchDateTimeComponents: matchDateTimeComponents,
      data: data,
      androidChannelId: androidChannelId,
    );

    if (config.enableDebugLogs) {
      printG('[Notifications] scheduledLocal id=$id at=$scheduled');
    }
  }

  /// Cancels a scheduled/active local notification by [id].
  Future<void> cancelLocal(int id) async {
    if (!_initialized) return;
    await _localService.cancel(id);
  }

  /// Cancels all scheduled/active local notifications.
  Future<void> cancelAllLocal() async {
    if (!_initialized) return;
    await _localService.cancelAll();
  }

  /// Stops the coordinator and cleans up listeners.
  ///
  /// This is useful on logout when you want to unsubscribe from topics and
  /// stop listening for message events.
  Future<void> dispose({bool deleteFcmToken = false}) async {
    final config = _config;

    if (_options.enableFcm) {
      await _fcmService.dispose(deleteFcmToken: deleteFcmToken);
    }

    _initialized = false;

    if (config?.enableDebugLogs == true) {
      printY('[Notifications] disposed');
    }
  }
}
