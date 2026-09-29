import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../router/app_links.dart';

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

  /// The page this notification opens, as a router location — or `null`
  /// when it names none the app has.
  ///
  /// Read in this order:
  /// 1. [route] or [deepLink] — a location (`/items/42`), a share link
  ///    (`https://example.com/items/42`) or a custom-scheme link
  ///    (`myapp://items/42`);
  /// 2. the target fields `targetType` · `targetId` in [data], so a push and
  ///    its row in an in-app notifications list open the same page.
  ///
  /// A web link must NOT keep its host as the first segment:
  /// `https://example.com/items/42` → `/example.com/items/42` matches no
  /// route, and the tap goes nowhere. [AppLinks.locationOf] drops it.
  String? get toGoRouterLocation {
    for (final raw in <String?>[route, deepLink]) {
      if (raw == null || raw.trim().isEmpty) continue;
      final uri = Uri.tryParse(raw.trim());
      if (uri == null) continue;
      final location = AppLinks.locationOf(uri);
      if (location != null) return location;
    }

    return AppLinks.locationOfTarget(
      type: _readString(data, 'targetType'),
      id: _readString(data, 'targetId'),
    );
  }
}

String? _readString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value == null) return null;
  if (value is String && value.trim().isNotEmpty) return value;
  return value.toString();
}
