import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification configuration used as the single source of truth for how
/// notifications are presented across:
/// - Firebase Cloud Messaging (FCM) remote messages
/// - flutter_local_notifications local presentation
///
/// This file defines pure configuration models and mapping helpers.
/// It intentionally does not contain initialization or runtime logic.

/// Cross-platform importance level used by the notification module.
///
/// This is mapped to platform-specific importance/priority values.
enum AppNotificationImportance {
  min,
  low,
  normal,
  high,
  max;

  Importance get importance {
    switch (this) {
      case AppNotificationImportance.min:
        return Importance.min;
      case AppNotificationImportance.low:
        return Importance.low;
      case AppNotificationImportance.normal:
        return Importance.defaultImportance;
      case AppNotificationImportance.high:
        return Importance.high;
      case AppNotificationImportance.max:
        return Importance.max;
    }
  }
}

/// Cross-platform priority level used by the notification module.
///
/// This is mapped to Android [Priority].
enum AppNotificationPriority {
  min,
  low,
  normal,
  high,
  max;

  Priority get priority {
    switch (this) {
      case AppNotificationPriority.min:
        return Priority.min;
      case AppNotificationPriority.low:
        return Priority.low;
      case AppNotificationPriority.normal:
        return Priority.defaultPriority;
      case AppNotificationPriority.high:
        return Priority.high;
      case AppNotificationPriority.max:
        return Priority.max;
    }
  }
}

/// Defines an Android notification channel.
///
/// Notes:
/// - On Android 8.0+, channel settings (sound/vibration) are mostly immutable
///   after the channel is created.
/// - Changing sound/vibration requires changing the channel id.
class AppAndroidNotificationChannelConfig {
  const AppAndroidNotificationChannelConfig({
    required this.id,
    required this.name,
    required this.description,
    this.importance = AppNotificationImportance.high,
    this.priority = AppNotificationPriority.high,
    this.playSound = true,
    this.soundResource,
    this.enableVibration = true,
    this.showBadge = true,
  });

  /// Stable channel id used by both FCM and local notifications.
  final String id;

  /// User-visible channel name.
  final String name;

  /// User-visible channel description.
  final String description;

  /// Channel importance.
  final AppNotificationImportance importance;

  /// Notification priority.
  final AppNotificationPriority priority;

  /// Whether notifications should play a sound.
  final bool playSound;

  /// Optional Android raw sound resource name (without extension).
  ///
  /// Example:
  /// - Put `my_sound.mp3` under `android/app/src/main/res/raw/`
  /// - Set [soundResource] to `my_sound`
  final String? soundResource;

  /// Whether notifications should vibrate.
  final bool enableVibration;

  /// Whether notifications should be allowed to show badges.
  final bool showBadge;

  /// Converts this config into an Android [AndroidNotificationChannel].
  ///
  /// This is used during initialization to create channels explicitly.
  AndroidNotificationChannel toAndroidChannel() {
    return AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance.importance,
      playSound: playSound,
      sound: soundResource == null
          ? null
          : RawResourceAndroidNotificationSound(soundResource!),
      enableVibration: enableVibration,
      showBadge: showBadge,
    );
  }

  /// Builds [AndroidNotificationDetails] used for presenting a notification
  /// via flutter_local_notifications.
  AndroidNotificationDetails toAndroidNotificationDetails({String? smallIcon}) {
    return AndroidNotificationDetails(
      id,
      name,
      channelDescription: description,
      importance: importance.importance,
      priority: priority.priority,
      playSound: playSound,
      sound: soundResource == null
          ? null
          : RawResourceAndroidNotificationSound(soundResource!),
      enableVibration: enableVibration,
      icon: smallIcon,
    );
  }
}

/// Unified configuration object for the notification module.
///
/// This config is expected to be used by both:
/// - FCM behavior (topics, foreground presentation)
/// - Local notification presentation (channels, icons, sounds)
class AppNotificationConfig {
  const AppNotificationConfig({
    required this.androidChannels,
    this.defaultAndroidSmallIcon = '@mipmap/ic_launcher',
    this.enableDebugLogs = true,
    this.autoSubscribeToTopics = true,
    this.initialTopics = const <String>[],
    this.iosPresentAlertInForeground = true,
    this.iosPresentBadgeInForeground = true,
    this.iosPresentSoundInForeground = true,
    this.iosNotificationCategories = const <DarwinNotificationCategory>[],
  });

  /// Android channels that the app will create and use.
  final List<AppAndroidNotificationChannelConfig> androidChannels;

  /// Default Android small icon resource name.
  ///
  /// This should be a drawable resource.
  /// Example: `ic_notification` refers to `@drawable/ic_notification`.
  final String defaultAndroidSmallIcon;

  /// Enables logging using `coloredPrint` helpers.
  final bool enableDebugLogs;

  /// Automatically subscribes to [initialTopics] during initialization.
  final bool autoSubscribeToTopics;

  /// Topics to subscribe to during initialization.
  final List<String> initialTopics;

  /// iOS/macOS foreground presentation options.
  final bool iosPresentAlertInForeground;
  final bool iosPresentBadgeInForeground;
  final bool iosPresentSoundInForeground;

  /// iOS/macOS notification categories.
  ///
  /// This is required to support notification action buttons on Apple
  /// platforms. It is intentionally empty by default.
  ///
  /// To enable actions later, provide categories through this config and add
  /// action handling in the app using the notification response callbacks.
  final List<DarwinNotificationCategory> iosNotificationCategories;

  /// The default channel used when no explicit channel id is provided.
  AppAndroidNotificationChannelConfig get defaultAndroidChannel {
    return androidChannels.first;
  }

  /// Creates a modified copy of this config.
  ///
  /// Use this to customize generated projects without rebuilding the entire
  /// object.
  AppNotificationConfig copyWith({
    List<AppAndroidNotificationChannelConfig>? androidChannels,
    String? defaultAndroidSmallIcon,
    bool? enableDebugLogs,
    bool? autoSubscribeToTopics,
    List<String>? initialTopics,
    bool? iosPresentAlertInForeground,
    bool? iosPresentBadgeInForeground,
    bool? iosPresentSoundInForeground,
    List<DarwinNotificationCategory>? iosNotificationCategories,
  }) {
    return AppNotificationConfig(
      androidChannels: androidChannels ?? this.androidChannels,
      defaultAndroidSmallIcon:
          defaultAndroidSmallIcon ?? this.defaultAndroidSmallIcon,
      enableDebugLogs: enableDebugLogs ?? this.enableDebugLogs,
      autoSubscribeToTopics:
          autoSubscribeToTopics ?? this.autoSubscribeToTopics,
      initialTopics: initialTopics ?? this.initialTopics,
      iosPresentAlertInForeground:
          iosPresentAlertInForeground ?? this.iosPresentAlertInForeground,
      iosPresentBadgeInForeground:
          iosPresentBadgeInForeground ?? this.iosPresentBadgeInForeground,
      iosPresentSoundInForeground:
          iosPresentSoundInForeground ?? this.iosPresentSoundInForeground,
      iosNotificationCategories:
          iosNotificationCategories ?? this.iosNotificationCategories,
    );
  }

  /// Provides a conservative but production-ready default configuration.
  ///
  /// Important:
  /// - You should customize [initialTopics] in your generated project.
  /// - You should ensure `defaultAndroidSmallIcon` exists as a drawable.
  factory AppNotificationConfig.defaults() {
    return const AppNotificationConfig(
      androidChannels: <AppAndroidNotificationChannelConfig>[
        AppAndroidNotificationChannelConfig(
          id: 'high_importance',
          name: 'High Importance Notifications',
          description: 'Used for important alerts.',
        ),
      ],
    );
  }
}
