# 🔔 Notifications (FCM + Local)

This module provides a **unified notification system** for:

- **Remote notifications** via `firebase_messaging` (FCM)
- **Local notifications** via `flutter_local_notifications`

It is built so you can initialize everything with **one call** and control whether Firebase/FCM is enabled using `NotificationInitOptions`.

---

## 1) What you MUST do in the generated project (Required setup)

This section is the checklist to make notifications work end-to-end.

### ✅ Flutter dependencies

Already included by this Brick:

- `firebase_core`
- `firebase_messaging`
- `flutter_local_notifications`
- `permission_handler`
- `timezone`
- `flutter_timezone`

### ✅ Initialize notifications (one call)

In the generated project, notifications are initialized from `lib/bootstrap.dart`.

You only call:

- `getIt<NotificationCoordinator>().initialize(...)`

You can control behavior using:

- `NotificationInitOptions(initializeFirebase: ..., enableFcm: ...)`

### ✅ Firebase setup (required ONLY if you enable FCM)

If you use `NotificationInitOptions(enableFcm: true)` you must configure Firebase:

#### Android

- Add `android/app/google-services.json`
- Ensure the Firebase Gradle setup is correct for your FlutterFire version

#### iOS

- Add `ios/Runner/GoogleService-Info.plist`
- Ensure your iOS bundle id matches Firebase project settings

### ✅ Android folder changes

#### 0) Ensure POST_NOTIFICATIONS exists (Android 13+)

For Android 13 (API 33+) the runtime permission is:

- `android.permission.POST_NOTIFICATIONS`

Most projects get this through plugin manifest merging, but if you face issues
requesting permission, add it explicitly in `android/app/src/main/AndroidManifest.xml`.

#### 1) Android 13+ notification permission

This Brick requests permission using `permission_handler`:

- `Permission.notification.request()`

Make sure your app targets Android 13+ correctly.

#### 2) Notification icon (required)

This Brick expects an Android drawable resource:

- `@drawable/ic_notification`

If the resource is missing, notifications may show without the correct icon.

#### 3) Scheduled notifications (only if you use scheduling)

If you schedule notifications, follow the `flutter_local_notifications` Android setup.

Also note:

- Some plugin versions require **core library desugaring** for scheduling.
- The required `compileSdkVersion` / AGP version can change.

Always cross-check the official `flutter_local_notifications` README.

In `android/app/src/main/AndroidManifest.xml`:

- Add permissions between `<manifest>` tags:
  - `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>`
  - Exact alarms (choose one approach depending on your needs):
    - `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>` (prompt user)
    - OR `<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>` (store review may apply)

- Add receivers between `<application>` tags:
  - `<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />`
  - `<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"> ... </receiver>`

> Important: the exact configuration can change across plugin versions. Always cross-check with the official `flutter_local_notifications` README.

### ✅ iOS folder changes

#### 0) Enable iOS capabilities (FCM)

If you enable FCM on iOS, make sure your iOS target has:

- **Push Notifications** capability
- **Background Modes** -> **Remote notifications**

#### 1) Enable notifications in foreground

iOS won’t show notifications while the app is open unless configured.

This Brick controls foreground presentation via:

- `AppNotificationConfig.iosPresentAlertInForeground`
- `AppNotificationConfig.iosPresentBadgeInForeground`
- `AppNotificationConfig.iosPresentSoundInForeground`

#### 2) AppDelegate delegate configuration

For iOS, the `flutter_local_notifications` documentation recommends setting the notification center delegate.

Add in `ios/Runner/AppDelegate.swift`:

```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```

> Exact code differs by template / Swift vs Objective-C. Check plugin docs.

#### 3) Permission_handler notes

`permission_handler` requires adding Info.plist keys for permissions you request.

- For **notification permission**, iOS does not require a usage description key.
- If you request other permissions later (camera, photos, etc.), add those keys.

---

## 2) Native customization (icons, sounds, channels, behavior)

### 🎨 Change notification icon

- Update `AppNotificationConfig.defaultAndroidSmallIcon`
- Add the drawable under:
  - `android/app/src/main/res/drawable/`

### 🔊 Custom sounds

#### Android (custom sounds)

- Add sound file under:
  - `android/app/src/main/res/raw/`
- Reference it in a channel:
  - `AppAndroidNotificationChannelConfig(soundResource: 'my_sound')`

Important Android rule:

- On Android 8+, **sound/vibration are channel-level** and mostly immutable.
- If you change sound/vibration, you typically must **change the channel id**.

#### iOS ()

- iOS sound restrictions apply (file format + bundling). Follow the official plugin docs.

### 🧩 Add new channels

Create channels in `AppNotificationConfig.androidChannels`.

- Use the channel id in your payload (`android_channel_id` / `channelId`) to route notifications to the correct channel.

---

## 3) How the flow works (what happens behind the scenes)

### 🧱 Classes involved

- `NotificationCoordinator`
  - Thin facade/orchestrator

- `NotificationPermissionService`
  - Requests permission using `permission_handler`

- `NotificationTimezoneService`
  - Initializes TZ database (`timezone` + `flutter_timezone`)

- `NotificationLocalService`
  - Initializes and displays local notifications

- `NotificationFcmService`
  - Configures FCM and listens to:
    - foreground messages
    - opened notifications
    - token refresh

### ✅ Initialization sequence

Called from `bootstrap.dart`:

1. Resolve `NotificationCoordinator` from GetIt
2. Call `NotificationCoordinator.initialize(config, options, ...)`
3. Coordinator runs:
   - Permission request first (`Permission.notification.request()`)
   - Timezone initialization
   - Local notifications plugin initialization
   - If enabled:
     - Firebase initialization (optional)
     - FCM setup + listeners

### Foreground message handling

When a message arrives while the app is open:

- `NotificationFcmService` receives it via `FirebaseMessaging.onMessage`
- Converts it to `AppNotificationPayload`
- Forwards it to `NotificationLocalService.showFromPayload(...)`

This keeps **all presentation logic** in one place (local notifications).

### Background / terminated handling

- Background tap: `FirebaseMessaging.onMessageOpenedApp`
- Terminated launch: `FirebaseMessaging.getInitialMessage()`

Both are normalized into `AppNotificationPayload` and passed to the `onNotificationTap` callback.

---

## 4) What you can do from Flutter code (features + how to use)

All features are exposed through:

- `getIt<NotificationCoordinator>()`

### 🔑 Get device token from anywhere

```dart
final coordinator = getIt<NotificationCoordinator>();
final token = await coordinator.getDeviceToken();
```

You can also read a cached value:

```dart
final token = getIt<NotificationCoordinator>().cachedToken;
```

### 🔔 Show a local notification

```dart
await getIt<NotificationCoordinator>().showLocal(
  title: 'Hello',
  body: 'This is local',
  data: {'route': '/home'},
);
```

### ⏰ Schedule a local notification

```dart
await getIt<NotificationCoordinator>().scheduleLocal(
  id: 1,
  title: 'Reminder',
  body: 'Don\'t forget',
  date: DateTime.now().add(const Duration(minutes: 10)),
);
```

### 🧹 Cancel notifications

- Cancel one:

```dart
await getIt<NotificationCoordinator>().cancelLocal(1);
```

- Cancel all:

```dart
await getIt<NotificationCoordinator>().cancelAllLocal();
```

### 🧵 Subscribe / unsubscribe to topics (FCM only)

```dart
await getIt<NotificationCoordinator>().subscribeToTopics(['news']);
await getIt<NotificationCoordinator>().unsubscribeFromTopics(['news']);
```

Recommended usage:

- Subscribe after login (user-specific topics)
- Unsubscribe on logout

### ✅ Permission checks

```dart
final granted = await getIt<NotificationCoordinator>()
    .isNotificationPermissionGranted();

if (!granted) {
  await getIt<NotificationCoordinator>().requestNotificationPermission();
}
```

### 🧨 Dispose (logout)

```dart
await getIt<NotificationCoordinator>().dispose(deleteFcmToken: true);
```

---

## 5) Adding new features (extending the module)

### 🧷 Notification action buttons

This Brick is prepared for actions:

- Background entry-point exists:
  - `notificationTapBackground(NotificationResponse response)`

To add actions:

1. Define iOS categories in `AppNotificationConfig.iosNotificationCategories`
2. Add Android actions in `AndroidNotificationDetails(actions: ...)`
3. Handle `NotificationResponse.actionId` in your tap handler

### 🧠 Advanced behaviors

Common extensions:

- **Show notifications from FCM background handler**
  - Requires extra care (plugins in background isolate)

- **Custom payload parsing**
  - Extend `AppNotificationPayload` to support your backend contract

- **Custom navigation**
  - Keep `onNotificationTap` in bootstrap as the single navigation entry point

---
