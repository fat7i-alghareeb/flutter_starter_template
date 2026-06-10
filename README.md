# Flutter Starter Template (Mason Brick)

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

This repository is a **Mason brick** that generates a complete Flutter application template.

## What this brick provides (high level)

You get a production-ready starting point with:

- Clean architecture folder structure (`core/`, `features/`, `common/`, `utils/`)
- Routing with `go_router` (splash/onboarding/auth flow ready)
- Flavors (Stage/Production) via `flutter_flavorizr`
- Localization via `easy_localization`
- Notifications module (local + optional FCM)
- Code generation setup (`build_runner`, `injectable`, `freezed`, `flutter_gen`)

---

## Documentation index (inside the generated project)

Open these files **in the generated Flutter project** to learn how things are wired.

### `lib/` folder overview

**Where to find it:** `lib/lib_overview.md`

What to expect: high-level map of the `lib/` structure and how the app boots (`main.dart`, `bootstrap.dart`, `app.dart`).

### Core architecture overview

**Where to find it:** `lib/core/core_architecture_overview.md`

What to expect: how the `core/` layer is organized (DI, networking, routing, notifications, services).

### Router guide

**Where to find it:** `lib/core/router/router_guide.md`

What to expect: how `go_router` is configured, startup flow, and redirect/guard logic.

### Session service guide

**Where to find it:** `lib/core/services/session/session_service_guide.md`

What to expect: session/auth architecture (`AuthManager`, `AuthStateNotifier`), token storage, and logout/refresh behavior.

### Notifications guide

**Where to find it:** `lib/core/notification/notification.md`

What to expect: local notifications + (optional) FCM setup, required native configuration, and app-side API usage.

### Features overview

**Where to find it:** `lib/features/features_overview.md`

What to expect: how features are structured (data/domain/presentation) and how to scale feature modules.

### Common folder guide

**Where to find it:** `lib/common/common_folder_guide.md`

What to expect: reusable UI/widgets, scaffolds, dialogs, and form components.

### Utils folder guide

**Where to find it:** `lib/utils/utils_folder_guide.md`

What to expect: lightweight shared helpers (constants/extensions/generated wrappers).

### Reactive date/time field

**Where to find it:** `lib/common/widgets/form/date_time_field/app_reactive_date_time.md`

What to expect: how to use `AppReactiveDateTimeField` (supported types, modes, formatting, payloads).

---

## Quickstart (from zero to running)

### Prerequisites

Make sure Flutter is installed, then install Mason once:

```bash
dart pub global activate mason_cli
```

### 0) Create a Flutter project (you need `android/` and `ios/` folders)

If you don't already have a Flutter project, create one first:

```bash
flutter create <your_project_folder>
```

Then run the next steps inside that project folder.

### 1) Generate the template (Mason)

In your Flutter workspace (where you want to create the app):

### Step A: Initialize Mason

```bash
mason init
```

### Step B: Add the brick

Use the Git version when generating from a released/pinned template:

Edit `mason.yaml`:

```yaml
bricks:
  flutter_app_template:
    git:
      url: https://github.com/fat7i-alghareeb/flutter_starter_template.git
      ref: <TAG_OR_COMMIT_SHA>
```

Notes:

- Repo name is `flutter_starter_template`, but the brick key you run is `flutter_app_template`.
- `ref` is required so you pin a version (tag/commit). Choose what you want to generate.
- The name (`flutter_app_template`) is the command you will run in the next step.

Or, if you cloned this repository locally and want to use your local checkout:

```bash
mason add flutter_app_template --path <path_to_flutter_starter_template>
```

### Step C: Fetch the brick

```bash
mason get
```

### Step D: Generate the app

```bash
mason make flutter_app_template --on-conflict overwrite
```

During generation the brick asks for:

- `project_name`: the Dart package name. Natural input is accepted and normalized to `snake_case`.
- `project_title`: the visible app title used by flavors and `F.title`.
- `package_name`: the Android application id / iOS bundle id base. It is normalized to lower-case dotted segments.
- `project_description`: the `pubspec.yaml` description.

For example, `My Cool App 2026` becomes the Dart package name `my_cool_app_2026`, while `COM.Acme.123Cool_App` becomes `com.acme.coolapp`.

The `--on-conflict overwrite` flag is intentional for a fresh `flutter create` project because this brick replaces the default counter app files with the template files.

For non-interactive generation, create a config file and run:

```bash
mason make flutter_app_template --config-path mason_vars.json --on-conflict overwrite
```

---

## 2) Install deps + generate flavors + codegen (required)

Inside the generated project root:

```bash
flutter clean
flutter pub get
dart run flutter_flavorizr -f
dart run build_runner build
flutter analyze
```

Notes:

- `flutter_flavorizr -f` generates flavor files and IDE configs without asking for confirmation, so it works in terminals, scripts, and AI agents.
- `build_runner` generates/updates code for `injectable`, `freezed`, and `flutter_gen`.
- If you see import errors referencing a placeholder package name, run the `build_runner` command above (it regenerates the config with the correct package).

---

## 3) Native notifications setup

The generated project includes local notifications by default and optional FCM.

Notifications initialize after the first Flutter frame and after the configured splash delay, so permission prompts do not appear before the custom splash screen.

Read the full generated guide before shipping notifications:

- `lib/core/notification/notification.md`

### Android essentials

For `flutter_local_notifications` 22 and `permission_handler` 12:

- Use Android `compileSdk` / `compileSdkVersion` 35 or newer.
- Enable core library desugaring in `android/app/build.gradle`, including `desugar_jdk_libs:2.1.4`.
- Keep Java/Kotlin compatibility aligned with the plugin docs, currently Java 17.

Add notification permission under the root `<manifest>`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
```

If you use local scheduling, also add:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

The template default scheduler uses `AndroidScheduleMode.exactAllowWhileIdle`. For exact alarms, choose one:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

or:

```xml
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

Use `SCHEDULE_EXACT_ALARM` for most reminder-style apps and call the template helper:

```dart
await getIt<NotificationCoordinator>().requestExactAlarmsPermission();
```

Use `USE_EXACT_ALARM` only for apps whose core approved purpose is alarms/calendar-style exact alarms.

For scheduled notifications, add receivers under `<application>`:

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

Before release, replace the launcher-icon fallback with a real monochrome drawable notification icon and keep that resource from being removed by release shrinking.

### iOS essentials

For local notification actions, add the `flutter_local_notifications` plugin registrant callback in `ios/Runner/AppDelegate.swift` as described in the generated guide.

For FCM on iOS:

- Add `ios/Runner/GoogleService-Info.plist`.
- Match the Firebase bundle id to the generated app bundle id.
- Enable **Push Notifications**.
- Enable **Background Modes** -> **Remote notifications**.
- Upload an APNs authentication key or certificate in Firebase Console.
- Test on a real device.

---

## 4) Run the app

After flavor generation, you can run a flavor:

```bash
flutter run --flavor stage
```

Production:

```bash
flutter run --flavor production
```

If you use VS Code, `.vscode/launch.json` is provided with Stage/Production launch configurations.

## Optional: enable FCM (Firebase Cloud Messaging)

By default the project initializes notifications with FCM disabled.

If you want FCM:

- Run `flutterfire configure` in the generated project.
- Import `firebase_options.dart`.
- Update `lib/bootstrap.dart` and enable:

```dart
options: NotificationInitOptions(
  initializeFirebase: true,
  firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  enableFcm: true,
),
```

If Firebase is initialized elsewhere, keep `initializeFirebase: false` and set `enableFcm: true`.
