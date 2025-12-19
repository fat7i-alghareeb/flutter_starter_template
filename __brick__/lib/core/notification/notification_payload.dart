import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Normalized notification payload representation.
///
/// This model is used as the single Dart-level representation regardless of
/// where the payload came from:
/// - FCM `RemoteMessage` (remote)
/// - flutter_local_notifications `payload` string (local)
///
/// This file intentionally contains no UI or platform logic.
class AppNotificationPayload {
  const AppNotificationPayload({
    required this.data,
    this.title,
    this.body,
    this.route,
    this.deepLink,
    this.androidChannelId,
  });

  /// Raw key/value payload.
  final Map<String, dynamic> data;

  /// Optional presentation title.
  final String? title;

  /// Optional presentation body.
  final String? body;

  /// Optional app route to navigate to (recommended to be a GoRouter location).
  ///
  /// Example: `/orders/123`.
  final String? route;

  /// Optional deep-link string.
  ///
  /// Example: `myapp://orders/123`.
  final String? deepLink;

  /// Optional Android channel id.
  ///
  /// When present, this can be used to select the channel configuration.
  final String? androidChannelId;

  /// Creates a payload from a Firebase Messaging [RemoteMessage].
  ///
  /// This should be used for:
  /// - Foreground messages (from `FirebaseMessaging.onMessage`)
  /// - Messages opened by tapping a notification
  ///   (from `getInitialMessage` / `onMessageOpenedApp`)
  factory AppNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = <String, dynamic>{...message.data};

    final title = message.notification?.title ?? _readString(data, 'title');
    final body = message.notification?.body ?? _readString(data, 'body');

    final route = _readString(data, 'route') ?? _readString(data, 'screen');
    final deepLink =
        _readString(data, 'deep_link') ?? _readString(data, 'deepLink');

    final channelId =
        message.notification?.android?.channelId ??
        _readString(data, 'android_channel_id') ??
        _readString(data, 'channelId');

    return AppNotificationPayload(
      data: data,
      title: title,
      body: body,
      route: route,
      deepLink: deepLink,
      androidChannelId: channelId,
    );
  }

  /// Creates a payload from a JSON string previously produced by [toJsonString].
  ///
  /// This is used when handling taps on local notifications.
  factory AppNotificationPayload.fromJsonString(String payload) {
    final decoded = json.decode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid payload shape: $decoded');
    }

    final data =
        (decoded['data'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    return AppNotificationPayload(
      data: data,
      title: decoded['title'] as String?,
      body: decoded['body'] as String?,
      route: decoded['route'] as String?,
      deepLink: decoded['deepLink'] as String?,
      androidChannelId: decoded['androidChannelId'] as String?,
    );
  }

  /// Encodes this payload as a JSON string suitable for
  /// flutter_local_notifications `payload` field.
  String toJsonString() {
    return json.encode(toMap());
  }

  /// Converts this payload to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': data,
      'title': title,
      'body': body,
      'route': route,
      'deepLink': deepLink,
      'androidChannelId': androidChannelId,
    };
  }

  /// Returns the best navigation target for this payload.
  ///
  /// Priority:
  /// 1) [route]
  /// 2) [deepLink]
  String? get navigationTarget => route ?? deepLink;

  /// Converts [route] / [deepLink] into a GoRouter-compatible location.
  ///
  /// This helper is intended to be used by the bootstrap navigation handler.
  ///
  /// Supported patterns:
  /// - `route`: `/orders/123`
  /// - `deepLink`: `myapp://orders/123?tab=items` -> `/orders/123?tab=items`
  ///
  /// Important notes:
  /// - This method only normalizes the location string.
  /// - Your router must have a matching route definition.
  String? get toGoRouterLocation {
    final direct = route;
    if (direct != null && direct.trim().isNotEmpty) {
      return direct;
    }

    final link = deepLink;
    if (link == null || link.trim().isEmpty) return null;

    try {
      final uri = Uri.parse(link);

      final host = uri.host;
      final path = uri.path;

      final basePath = host.isEmpty ? path : '/$host$path';
      if (basePath.isEmpty) return null;

      final query = uri.hasQuery ? '?${uri.query}' : '';
      return '$basePath$query';
    } catch (_) {
      return link;
    }
  }
}

String? _readString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value == null) return null;
  if (value is String && value.trim().isNotEmpty) return value;
  return value.toString();
}
