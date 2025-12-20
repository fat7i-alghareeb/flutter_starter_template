import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_background.dart';
import 'notification_config.dart';
import 'notification_payload.dart';

/// Wrapper around `flutter_local_notifications`.
///
/// Responsibilities:
/// - Initialize the plugin for Android/iOS/macOS
/// - Create Android channels from [AppNotificationConfig]
/// - Convert local tap callbacks into [AppNotificationPayload]
/// - Forward app-launch details to the tap handler
@lazySingleton
class NotificationLocalService {
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Initializes the local notifications plugin.
  ///
  /// Note:
  /// - This module expects permissions to be requested separately using
  ///   `permission_handler` (see [NotificationPermissionService]).
  Future<void> initialize({
    required AppNotificationConfig config,
    required Future<void> Function(AppNotificationPayload payload)
    onNotificationTap,
    required bool requestPermissions,
  }) async {
    if (_initialized) return;

    Future<void> initializeWithIcon(String icon) async {
      final androidInit = AndroidInitializationSettings(icon);

      final darwinInit = DarwinInitializationSettings(
        requestAlertPermission: requestPermissions,
        requestBadgePermission: requestPermissions,
        requestSoundPermission: requestPermissions,
        notificationCategories: config.iosNotificationCategories,
      );

      final initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );

      await _local.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) async {
          final payloadString = response.payload;
          if (payloadString == null || payloadString.isEmpty) return;

          final payload = AppNotificationPayload.fromJsonString(payloadString);
          await onNotificationTap(payload);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
    }

    try {
      await initializeWithIcon(config.defaultAndroidSmallIcon);
    } on PlatformException catch (e) {
      // Fail-safe: if the icon resource isn't packaged yet, fallback to the
      // default launcher icon so the app still boots.
      if (e.code == 'invalid_icon') {
        await initializeWithIcon('@mipmap/ic_launcher');
      } else {
        rethrow;
      }
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      for (final c in config.androidChannels) {
        await android?.createNotificationChannel(c.toAndroidChannel());
      }
    }

    await _forwardLaunchDetailsToTapHandler(onNotificationTap);

    _initialized = true;
  }

  Future<void> showFromPayload({
    required AppNotificationConfig config,
    required AppNotificationPayload payload,
  }) async {
    if (!_initialized) return;

    final title = payload.title ?? '';
    final body = payload.body ?? '';

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    final channel = _resolveAndroidChannel(config, payload.androidChannelId);

    final details = NotificationDetails(
      android: channel.toAndroidNotificationDetails(
        smallIcon: config.defaultAndroidSmallIcon,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: config.iosPresentAlertInForeground,
        presentBadge: config.iosPresentBadgeInForeground,
        presentSound: config.iosPresentSoundInForeground,
      ),
    );

    await _local.show(
      _generateNotificationId(),
      title,
      body,
      details,
      payload: payload.toJsonString(),
    );
  }

  Future<void> schedule({
    required AppNotificationConfig config,
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledAt,
    DateTimeComponents? matchDateTimeComponents,
    Map<String, dynamic> data = const <String, dynamic>{},
    String? androidChannelId,
  }) async {
    if (!_initialized) return;

    final channel = _resolveAndroidChannel(config, androidChannelId);

    final details = NotificationDetails(
      android: channel.toAndroidNotificationDetails(
        smallIcon: config.defaultAndroidSmallIcon,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: config.iosPresentAlertInForeground,
        presentBadge: config.iosPresentBadgeInForeground,
        presentSound: config.iosPresentSoundInForeground,
      ),
    );

    final payload = AppNotificationPayload(
      data: data,
      title: title,
      body: body,
      androidChannelId: channel.id,
    );

    await _local.zonedSchedule(
      id,
      title,
      body,
      scheduledAt,
      details,
      payload: payload.toJsonString(),
      matchDateTimeComponents: matchDateTimeComponents,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) async {
    if (!_initialized) return;
    await _local.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _local.cancelAll();
  }

  Future<void> _forwardLaunchDetailsToTapHandler(
    Future<void> Function(AppNotificationPayload payload) onNotificationTap,
  ) async {
    final launchDetails = await _local.getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload;
    if (launchPayload == null || launchPayload.isEmpty) return;

    final payload = AppNotificationPayload.fromJsonString(launchPayload);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(onNotificationTap(payload));
    });
  }

  AppAndroidNotificationChannelConfig _resolveAndroidChannel(
    AppNotificationConfig config,
    String? channelId,
  ) {
    if (channelId == null || channelId.isEmpty) {
      return config.defaultAndroidChannel;
    }

    return config.androidChannels.firstWhere(
      (c) => c.id == channelId,
      orElse: () => config.defaultAndroidChannel,
    );
  }
}

int _generateNotificationId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  return now ^ Random(now).nextInt(1 << 31);
}
