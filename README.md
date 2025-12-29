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

### Step B: Add the brick from git

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

### Step C: Fetch the brick

```bash
mason get
```

### Step D: Generate the app

```bash
mason make flutter_app_template
```

---

## 2) Install deps + generate flavors + codegen (required)

Inside the generated project root:

```bash
flutter clean
flutter pub get
dart run flutter_flavorizr
dart run build_runner build --delete-conflicting-outputs
```

Notes:

- `flutter_flavorizr` generates flavor files and IDE configs.
- `build_runner` generates/updates code for `injectable`, `freezed`, and `flutter_gen`.
- If you see import errors referencing a placeholder package name, run the `build_runner` command above (it regenerates the config with the correct package).

---

## 3) Android notifications setup (required if you use scheduling)

### A) AndroidManifest changes for notifications

Open (generated project):

- `android/app/src/main/AndroidManifest.xml`

Important:

- If you ran `dart run flutter_flavorizr`, you may also get flavor manifests under `android/app/src/<flavor>/AndroidManifest.xml`.
- Apply the changes below to the manifest(s) you actually build with.

#### 1) Add permissions (inside `<manifest>`)

Place these **as direct children of `<manifest>`** (usually near the top, before `<application>`):

```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
```

#### 2) Add scheduled notification receivers (inside `<application>`)

Place these **as direct children of `<application>`**:

```xml
<!-- Scheduled notifications -->
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

For a full checklist (exact alarms, icons, iOS notes), read:

- `lib/core/notification/notification.md`

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

- Add Firebase native configs (`google-services.json` / `GoogleService-Info.plist`).
- Update `lib/bootstrap.dart` and enable it via `NotificationInitOptions(enableFcm: true, initializeFirebase: true)`.
