# Notifications

This module wraps:

- `flutter_local_notifications` for local display and scheduling.
- `firebase_messaging` for optional FCM push notifications.
- `permission_handler` for the user-facing notification permission prompt.
- `timezone` + `flutter_timezone` for timezone-aware scheduling.

Notifications are initialized from `lib/bootstrap.dart` after the first Flutter frame and after `SplashConfig.initialDelay`. That keeps the custom splash visible before any notification permission prompt appears.

Official references used for this checklist:

- `flutter_local_notifications`: https://pub.dev/packages/flutter_local_notifications
- `firebase_messaging`: https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages
- FCM on Apple platforms/APNs: https://firebase.google.com/docs/cloud-messaging/ios/get-started
- `permission_handler`: https://pub.dev/packages/permission_handler

## Default Behavior

By default, `bootstrap.dart` initializes the local notification module only:

```dart
options: const NotificationInitOptions(
  initializeFirebase: false,
  enableFcm: false,
),
```

This means:

- Firebase does not initialize during startup.
- FCM listeners are not registered.
- Permission requests are still delayed until after the splash duration.
- Local notifications and scheduling are available once the native setup below is completed.

## Android Setup

### 1. Gradle Requirements

`flutter_local_notifications` 22 requires Android desugaring setup even if your app does not currently schedule notifications.

In `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }

    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
```

Use `compileSdk` / `compileSdkVersion` 35 or newer. The current plugin docs show `compileSdk 36`; `permission_handler` 12 requires at least 35.

If Android 12L+ devices crash with desugaring enabled, the `flutter_local_notifications` docs mention adding AndroidX WindowManager dependencies as a workaround:

```gradle
dependencies {
    implementation 'androidx.window:window:1.0.0'
    implementation 'androidx.window:window-java:1.0.0'
}
```

### 2. AndroidManifest Permissions

Add these under the root `<manifest>` tag in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
```

`flutter_local_notifications` also declares these, but keeping them explicit in the app manifest makes the runtime permission path clearer, especially because this template calls `Permission.notification.request()`.

If you schedule local notifications, add:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

If you use the template default scheduling mode, `AndroidScheduleMode.exactAllowWhileIdle`, choose one exact-alarm policy:

```xml
<!-- Recommended for most apps that need exact reminders. Requires runtime settings flow. -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

or:

```xml
<!-- Only for apps whose core approved purpose is alarms/calendar-style exact alarms. -->
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

Important:

- `SCHEDULE_EXACT_ALARM` requires calling `requestExactAlarmsPermission()` before exact scheduling can work on affected Android versions.
- `USE_EXACT_ALARM` does not show a permission prompt, but Google Play may review/audit this usage.
- If exact timing is not required, call `scheduleLocal(..., androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle)` and skip exact-alarm permissions.

### 3. AndroidManifest Receivers

For scheduled notifications, add these under `<application>`:

```xml
<receiver
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
    android:exported="false" />

<receiver
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
    </intent-filter>
</receiver>
```

If you add Android notification actions, also add:

```xml
<receiver
    android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver"
    android:exported="false" />
```

Only add the full-screen intent permission if you actually implement full-screen notifications:

```xml
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
```

### 4. Android Notification Icon

The template defaults to the launcher icon as a development fallback:

```dart
AppNotificationConfig(defaultAndroidSmallIcon: '@mipmap/ic_launcher', ...)
```

Before shipping, create a proper monochrome notification icon drawable and update the config:

```dart
AppNotificationConfig.defaults().copyWith(
  defaultAndroidSmallIcon: 'ic_notification',
)
```

Add the icon under:

```text
android/app/src/main/res/drawable/ic_notification.xml
```

Release builds may remove unused resources. Add a keep file if needed:

```xml
<!-- android/app/src/main/res/raw/keep.xml -->
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/ic_notification" />
```

### 5. Exact Alarm Helpers

The coordinator exposes Android exact-alarm helpers:

```dart
final coordinator = getIt<NotificationCoordinator>();

final canSchedule = await coordinator.canScheduleExactNotifications();
if (canSchedule == false) {
  await coordinator.requestExactAlarmsPermission();
}
```

Use this before calling `scheduleLocal` with `AndroidScheduleMode.exact` or `AndroidScheduleMode.exactAllowWhileIdle`.

## iOS / macOS Setup

### 1. Local Notifications

For basic local notifications, Flutter-side initialization is already handled by `NotificationLocalService`.

For background notification actions, `flutter_local_notifications` requires plugin registration in the action isolate. In `ios/Runner/AppDelegate.swift`, add:

```swift
import UIKit
import Flutter
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

If your app migrates to the newer `UIScene` lifecycle, move this setup to the method recommended by the official plugin docs.

### 2. Permission Notes

`Permission.notification` does not require an Info.plist usage description key and is enabled by default in `permission_handler`.

If you later request other permissions, add their Info.plist keys before calling `permission_handler`.

### 3. FCM on Apple Platforms

If FCM is enabled on iOS/macOS:

- Add `ios/Runner/GoogleService-Info.plist`.
- Make sure the bundle id matches Firebase.
- Enable **Push Notifications** in Xcode.
- Enable **Background Modes** -> **Remote notifications**.
- Upload an APNs authentication key or certificate in Firebase Console.
- Test on a real device; FCM/APNs push notifications do not work on iOS simulators the same way real device push does.

If you send notification images through FCM on Apple platforms, add a Notification Service Extension. This is optional and only needed for rich/image notifications.

## Enabling FCM

The template keeps FCM disabled until the generated app is configured.

Recommended setup:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Then update `lib/bootstrap.dart`:

```dart
import 'firebase_options.dart';

await coordinator.initialize(
  config: AppNotificationConfig.defaults(),
  options: NotificationInitOptions(
    initializeFirebase: true,
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    enableFcm: true,
  ),
  onNotificationTap: (payload) async {
    await _handleNotificationNavigation(payload);
  },
);
```

If Firebase is initialized elsewhere in your app:

```dart
options: const NotificationInitOptions(
  initializeFirebase: false,
  enableFcm: true,
),
```

For FCM background messages, this template already provides a top-level, annotated handler:

```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
```

If your project uses `firebase_options.dart` and Firebase cannot initialize with the default native config, update this handler to call:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Foreground, Background, and Terminated Flow

Foreground FCM messages:

- `NotificationFcmService` listens to `FirebaseMessaging.onMessage`.
- The payload is normalized into `AppNotificationPayload`.
- The module shows it through local notifications so presentation stays consistent.

Background tap:

- `FirebaseMessaging.onMessageOpenedApp` is mapped to the app-level tap handler.

Terminated launch:

- `FirebaseMessaging.getInitialMessage()` is checked after initialization.
- The tap callback runs after a frame so router navigation has a mounted app.

Local notification tap:

- `NotificationLocalService` reads the JSON payload.
- The same app-level tap handler receives `AppNotificationPayload`.

## Usage

Show a local notification:

```dart
await getIt<NotificationCoordinator>().showLocal(
  title: 'Hello',
  body: 'This is local',
  data: {'route': '/home'},
);
```

Schedule an exact local notification:

```dart
await getIt<NotificationCoordinator>().scheduleLocal(
  id: 1,
  title: 'Reminder',
  body: 'Do not forget',
  date: DateTime.now().add(const Duration(minutes: 10)),
);
```

Schedule an inexact notification without exact-alarm permission:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show AndroidScheduleMode;

await getIt<NotificationCoordinator>().scheduleLocal(
  id: 2,
  title: 'Reminder',
  body: 'Battery-friendly reminder',
  date: DateTime.now().add(const Duration(minutes: 10)),
  androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
);
```

Cancel notifications:

```dart
await getIt<NotificationCoordinator>().cancelLocal(1);
await getIt<NotificationCoordinator>().cancelAllLocal();
```

FCM token:

```dart
final token = await getIt<NotificationCoordinator>().getDeviceToken();
```

FCM topics:

```dart
await getIt<NotificationCoordinator>().subscribeToTopics(['news']);
await getIt<NotificationCoordinator>().unsubscribeFromTopics(['news']);
```

Permission check:

```dart
final granted = await getIt<NotificationCoordinator>()
    .isNotificationPermissionGranted();

if (!granted) {
  await getIt<NotificationCoordinator>().requestNotificationPermission();
}
```

Dispose on logout:

```dart
await getIt<NotificationCoordinator>().dispose(deleteFcmToken: true);
```

## Production Checklist

- Android Gradle desugaring enabled.
- Android `compileSdk` is 35+.
- Android manifest has notification permission.
- Android scheduling receivers are present if scheduling is used.
- Exact alarm permission policy is chosen if exact scheduling is used.
- `ActionBroadcastReceiver` is present if Android notification actions are used.
- Android notification icon is a real drawable and kept in release builds.
- iOS background-action plugin registrant callback is added if background actions are used.
- FCM native files and APNs setup are complete before `enableFcm: true`.
- Notification IDs fit in a signed 32-bit integer. The template generator already uses a safe random 31-bit id for non-scheduled local notifications.
