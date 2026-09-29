# Android release setup

Everything the Android side of a release needs — signing, a small APK, the
120 Hz request, the Android 12 splash in the app's own theme, links from the
web, notification icons — written out in full. Nothing here is generated for
you: `flutter create` makes the `android/` folder, and this document turns it
into a release-ready one. Every file below is **complete and ready to paste**;
every setting carries its reason.

> **Required before the first build, even debug:** `compileSdk = 37` and core
> library desugaring (§6) — `flutter_local_notifications`, `flutter_secure_storage`
> and `permission_handler` refuse to build without them.
>
> Everything else is optional: skip it and the app still builds and runs; the
> APK is just much bigger, debug-signed, capped at 60 Hz on some phones, and
> its OS splash follows the device theme instead of the app's.
>
> Measured on a freshly generated app: **74.5 MB → 11.6 MB** release APK
> (arm64 only, R8, shrunk resources, compressed native libraries), with the
> files below pasted as they are.

Pinned versions (match Flutter 3.44.x): **AGP 9.0.1 · Kotlin 2.3.20 ·
Gradle 9.1.0 · compileSdk 37 · targetSdk 36 · minSdk 24 · Java 17**. When you
move Flutter, revisit the lines marked 🔁.

---

## Contents

1. [Measure first](#1-measure-first)
2. [Signing key](#2-signing-key)
3. [`android/settings.gradle.kts`](#3-androidsettingsgradlekts)
4. [`android/gradle.properties`](#4-androidgradleproperties)
5. [`android/gradle/wrapper/gradle-wrapper.properties`](#5-gradle-wrapper)
6. [`android/app/build.gradle.kts`](#6-androidappbuildgradlekts)
7. [`android/app/proguard-rules.pro`](#7-androidappproguard-rulespro)
8. [`AndroidManifest.xml`](#8-androidmanifestxml)
9. [Resources: backup rules, notification icon, keep list](#9-resources)
10. [`MainActivity.kt`](#10-mainactivitykt)
11. [Generated resources — never edited by hand](#11-generated-resources)
12. [Verify](#12-verify)

---

## 1. Measure first

Build once **before** changing anything, so you can see what each step buys:

```bash
flutter build apk --release
ls -la build/app/outputs/flutter-apk/app-release.apk
```

Write the size down. Do it again at the end ([§12](#12-verify)).

## 2. Signing key

```bash
keytool -genkey -v -keystore android/{{project_name}}-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias {{project_name}}
```

Then create `android/key.properties` (already in `.gitignore` — **never commit
it or the `.jks`**; back both up somewhere safe: a lost key means you can
never update the app on Google Play again):

```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias={{project_name}}
storeFile={{project_name}}-release.jks
```

`storeFile` is resolved relative to `android/`. Commit a
`android/key.properties.example` with the same keys and fake values so the next
person knows the shape.

On Codemagic the key is uploaded once and written into this file by the build
(`codemagic.yaml` → «Set up signing», `docs/CODEMAGIC.md`).

## 3. `android/settings.gradle.kts`

```kotlin
pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // 🔁 Move with Flutter: the versions `flutter create` writes are the
    // ones its Gradle plugin is tested against.
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
```

## 4. `android/gradle.properties`

```properties
# --- JVM ---------------------------------------------------------------
# 4G heap is plenty and leaves room for the Dart analyzer, an emulator and
# the IDE on a 16-24 GB machine.
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8

# --- Build speed -------------------------------------------------------
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
# Configuration cache OFF: the Flutter Gradle plugin is not fully
# compatible with it yet.
org.gradle.configuration-cache=false

# --- AndroidX / R8 -----------------------------------------------------
android.useAndroidX=true
# R8 full mode: more aggressive shrinking and inlining than compat mode.
android.enableR8.fullMode=true
# Each module's R class holds only its own resources: smaller dex, faster
# builds.
android.nonTransitiveRClass=true
android.nonFinalResIds=true

# --- Kotlin ------------------------------------------------------------
kotlin.code.style=official
kotlin.incremental=true

# Added by the Flutter template.
android.newDsl=false
# 🔁 Must stay false while plugins still apply the Kotlin Gradle Plugin
# (firebase_core, flutter_timezone, flutter_udid, objectbox_flutter_libs):
# AGP 9 hard-fails any module that applies KGP while built-in Kotlin is on.
# The cost: plugins that already migrated off KGP get their Kotlin silently
# skipped — that is why pubspec.yaml pins `device_info_plus: 13.1.0`.
android.builtInKotlin=false
```

## 5. Gradle wrapper

`android/gradle/wrapper/gradle-wrapper.properties`:

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
# 🔁
distributionUrl=https\://services.gradle.org/distributions/gradle-9.1.0-all.zip
```

## 6. `android/app/build.gradle.kts`

The file that does most of the work. Replace the whole file:

```kotlin
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin
    // Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is read from android/key.properties (never committed).
// If the file is missing, release falls back to the debug keystore so
// `flutter run --release` still works locally.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "{{package_name}}"

    // 🔁 Pinned for reproducible builds. flutter_secure_storage 11 and
    // permission_handler_android 14 both need API 37 or later to compile.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications 22.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "{{package_name}}"
        // Optional, passed by `tool/build_release_apk.dart --mock` and CI
        // (`--android-project-arg=appIdSuffix=.mock`), so the mock-data APK
        // installs BESIDE the real one instead of replacing it.
        applicationIdSuffix = (project.findProperty("appIdSuffix") as String?).orEmpty()
        manifestPlaceholders["appLabel"] =
            (project.findProperty("appLabel") as String?)?.takeIf { it.isNotBlank() }
                ?: "{{project_title}}"
        minSdk = 24
        // targetSdk stays at 36 deliberately: raising it opts the app into new
        // runtime behaviour and deserves its own testing pass. compileSdk can
        // move ahead independently.
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    androidResources {
        // Keep in step with AppLocalizationConfig.supportedLanguageCodes.
        // Without it, the Android strings of every AndroidX / Play Services /
        // Firebase library ship in ~80 languages the app never shows.
        // Dart-side text is untouched.
        localeFilters += listOf("ar", "en")
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { rootProject.file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
                enableV1Signing = true
                enableV2Signing = true
                enableV3Signing = true
                enableV4Signing = true
            }
        }
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }

        release {
            signingConfig =
                if (hasReleaseKeystore) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }

            // R8: removes unused classes, then unused resources.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    packaging {
        jniLibs {
            // Native libraries stored COMPRESSED in the APK. With `false`
            // they are stored raw and page-aligned so Android can map them in
            // place — libflutter.so, libapp.so and libobjectbox-jni.so then
            // take ~24 MB instead of ~9 MB. The cost of `true`: the installer
            // extracts a copy, so the on-device footprint is larger than the
            // APK. Runtime and frame rate are unaffected.
            useLegacyPackaging = true
        }
        resources {
            excludes += setOf(
                "META-INF/AL2.0",
                "META-INF/LGPL2.1",
                "META-INF/*.kotlin_module",
                "**/kotlin/**",
                "DebugProbesKt.bin",
            )
        }
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }

    dependenciesInfo {
        // Keep the dependency blob out of APKs; Play still gets it from the AAB.
        includeInApk = false
        includeInBundle = true
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Workaround documented by flutter_local_notifications for Android 12L+
    // crashes when desugaring is enabled.
    implementation("androidx.window:window:1.5.0")
    implementation("androidx.window:window-java:1.5.0")
}

flutter {
    source = "../.."
}

// Every RELEASE APK is arm64 only, with no `--target-platform` to remember:
// the other ABIs' native libraries are left out when it is packaged. An
// `abiFilters` on the release build type does NOT do it — Flutter's Gradle
// plugin adds its three ABIs and the sets are merged. Debug stays
// universal: the emulator is x86_64, and an arm64-only build would not run
// on it. (Google Play: upload an AAB and Play splits per device anyway.)
androidComponents {
    onVariants(selector().withBuildType("release")) { variant ->
        variant.packaging.jniLibs.excludes.addAll(
            listOf("lib/armeabi-v7a/**", "lib/x86_64/**", "lib/x86/**"),
        )
    }
}
```

## 7. `android/app/proguard-rules.pro`

**Only the rules libraries do NOT ship themselves.** Flutter's embedding,
Firebase, Play Services, Tink (flutter_secure_storage), ObjectBox and
androidx.window bundle consumer R8 rules in their AARs, and AGP merges them
automatically (see `build/app/outputs/mapping/release/configuration.txt`).
Blanket `-keep class x.** { *; }` rules for them disable shrinking of every
class in those packages — on the project this template came from that was
~4,700 classes (Tink alone 1,900) and the largest part of `classes.dex`.

```proguard
# ---------------------------------------------------------------------------
# flutter_local_notifications
# Ships no consumer rules; uses Gson reflection to (de)serialize
# scheduled-notification models. These are the rules its README documents.
# ---------------------------------------------------------------------------
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Gson
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# ---------------------------------------------------------------------------
# Missing-class warnings only (no keeps): optional references these libraries
# make to classes that are not on the classpath.
# ---------------------------------------------------------------------------
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.crypto.tink.**
-dontwarn io.objectbox.**
-dontwarn androidx.window.**
-dontwarn io.flutter.embedding.**

# Readable release crash reports; the source file name is hidden.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
```

## 8. `AndroidManifest.xml`

`android/app/src/main/AndroidManifest.xml`, whole file. Change the link host
(`example.com`) to yours — the same host as `AppLinks.hosts`.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- Networking. Must live in the MAIN manifest, not only in
         debug/profile, or release builds have no network access. -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Notifications -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.VIBRATE" />

    <!-- Local notification scheduling. SCHEDULE_EXACT_ALARM is the
         reminder-style policy: call
         NotificationCoordinator.requestExactAlarmsPermission() before
         scheduling. Use USE_EXACT_ALARM only if alarms ARE the app. -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

    <!-- android:appCategory: without it the category is UNDEFINED, and the
         game optimizers on Xiaomi/HyperOS, Samsung and OnePlus treat the app
         as an unlisted game and lock it to 60 Hz below any refresh-rate
         request (flutter/flutter#192600). Any non-game category lifts it —
         pick the one that fits: productivity, social, news, … -->
    <application
        android:appCategory="productivity"
        tools:targetApi="o"
        android:label="${appLabel}"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="false"
        android:fullBackupContent="false"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:enableOnBackInvokedCallback="true"
        android:usesCleartextTraffic="false">

        <!-- enableOnBackInvokedCallback: Android's predictive back gesture
             (the app previews the page underneath; AppTransition.platform
             pages support it). allowBackup=false + data_extraction_rules:
             JWT tokens live in flutter_secure_storage, and an encrypted blob
             restored onto another device is unreadable. -->

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

            <!-- Shared links open the app: `https://example.com/items/42`
                 → AppLinks.locationOf → LinkDispatcher pushes the page OVER
                 the shell, so back lands in the app. One pathPrefix per
                 AppLinks.linkable page. autoVerify needs
                 /.well-known/assetlinks.json on the domain (see below);
                 until it is there Android offers the app in a chooser. -->
            <meta-data
                android:name="flutter_deeplinking_enabled"
                android:value="true" />
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="https" />
                <data android:host="example.com" />
                <data android:pathPrefix="/items/" />
            </intent-filter>
            <!-- The custom scheme (AppLinks.scheme): myapp://items/42 -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="myapp" />
            </intent-filter>
        </activity>

        <!-- flutter_local_notifications: scheduled notifications, and
             rescheduling after a reboot or an app update. -->
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
        <!-- Needed only if notification actions are added. -->
        <receiver
            android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver"
            android:exported="false" />

        <!-- FCM (when enabled — bootstrap.dart `_fcmEnabled`): default
             channel + small icon for pushes that arrive in the background.
             Matches AppNotificationConfig. -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance" />

        <!-- Don't delete: used by the Flutter tool to generate
             GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <!-- Used by the Flutter engine's ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT" />
            <data android:mimeType="text/plain" />
        </intent>
    </queries>
</manifest>
```

Then pass the notification icon to Dart, in `bootstrap.dart`
`_initializeNotifications`:

```dart
config: AppNotificationConfig.defaults().copyWith(
  defaultAndroidSmallIcon: 'ic_notification',
),
```

**App Links verification** — host this at
`https://example.com/.well-known/assetlinks.json`:

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "{{package_name}}",
    "sha256_cert_fingerprints": ["AA:BB:…"]
  }
}]
```

The fingerprint: `keytool -list -v -keystore android/{{project_name}}-release.jks`
(and Play Console → App integrity → App signing, once Play signs the app).

## 9. Resources

`android/app/src/main/res/xml/data_extraction_rules.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- Android 12+ backup rules. Nothing is backed up: JWT tokens live in
     flutter_secure_storage, and restoring encrypted blobs onto another
     device produces unreadable data. -->
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="root" />
        <exclude domain="database" />
        <exclude domain="sharedpref" />
        <exclude domain="external" />
        <exclude domain="file" />
    </cloud-backup>
    <device-transfer>
        <exclude domain="root" />
        <exclude domain="database" />
        <exclude domain="sharedpref" />
        <exclude domain="external" />
        <exclude domain="file" />
    </device-transfer>
</data-extraction-rules>
```

`android/app/src/main/res/drawable/ic_notification.xml` — the status-bar
icon. Android tints it white and ignores colour, so it must be a solid
silhouette on transparent. Replace the path with your brand glyph; keep the
name.

```xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M12,22c1.1,0 2,-0.9 2,-2h-4c0,1.1 0.9,2 2,2zM18,16v-5c0,-3.07 -1.64,-5.64 -4.5,-6.32L13.5,4c0,-0.83 -0.67,-1.5 -1.5,-1.5s-1.5,0.67 -1.5,1.5v0.68C7.63,5.36 6,7.92 6,11v5l-2,2v1h16v-1l-2,-2z" />
</vector>
```

`android/app/src/main/res/raw/keep.xml` — `shrinkResources` removes drawables
referenced only from Dart or from manifest meta-data. This keeps the icon:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/ic_notification" />
```

## 10. `MainActivity.kt`

`android/app/src/main/kotlin/<your/package/path>/MainActivity.kt`, whole file.
Two jobs: ask for the display's fastest refresh rate, and let Dart tell the OS
the app's theme (so the Android 12+ splash is drawn in it —
`lib/core/theme/native_night_mode.dart`, `NativeNightMode.channelName`).

```kotlin
package {{package_name}}

import android.app.UiModeManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestHighestRefreshRate()
    }

    override fun onResume() {
        super.onResume()
        // Re-asserted: some OEM skins reset the window's preferred mode when
        // the app returns from the background or the surface is recreated.
        requestHighestRefreshRate()
    }

    /**
     * Asks for the display's fastest mode at the CURRENT resolution (120 Hz
     * on a 120 Hz panel). Many Samsung, Xiaomi and OnePlus builds keep an app
     * that does not ask at 60 Hz, and Flutter does not ask on its own
     * (flutter/flutter#160952). Filtering on resolution keeps the request
     * from switching to a lower-resolution mode that happens to be faster.
     * On LTPO panels the system may still lower the rate when nothing moves —
     * that is the panel saving power, not a dropped frame.
     */
    private fun requestHighestRefreshRate() {
        val display =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                display
            } else {
                @Suppress("DEPRECATION")
                windowManager.defaultDisplay
            } ?: return
        val current = display.mode
        val best =
            display.supportedModes
                .filter {
                    it.physicalWidth == current.physicalWidth &&
                        it.physicalHeight == current.physicalHeight
                }
                .maxByOrNull { it.refreshRate } ?: return
        val attrs = window.attributes
        if (attrs.preferredDisplayModeId == best.modeId) return
        attrs.preferredDisplayModeId = best.modeId
        window.attributes = attrs
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // The app keeps its own light / dark / system choice
        // (ThemeController), but the Android 12+ splash is drawn by the OS
        // before any Dart runs, from the night mode the OS holds for the app.
        // Dart reports the choice here, and Android persists it, so the next
        // cold start's splash is drawn in the app's theme.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NIGHT_MODE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "setNightMode") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                // API 30 and below has no persistent per-app night mode; the
                // pre-12 splash there is colour only.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val mode = when (call.arguments as? String) {
                        "light" -> UiModeManager.MODE_NIGHT_NO
                        "dark" -> UiModeManager.MODE_NIGHT_YES
                        // AUTO = no override: follow the device again.
                        else -> UiModeManager.MODE_NIGHT_AUTO
                    }
                    getSystemService(UiModeManager::class.java)
                        ?.setApplicationNightMode(mode)
                }
                result.success(null)
            }
    }

    private companion object {
        // Must equal NativeNightMode.channelName on the Dart side.
        const val NIGHT_MODE_CHANNEL = "{{package_name}}/night_mode"
    }
}
```

## 11. Generated resources

Never edit these by hand — change the YAML and regenerate:

| Tool | Command | Writes |
| --- | --- | --- |
| `flutter_native_splash` | `dart run flutter_native_splash:create --path flutter_native_splash.yaml` | `res/drawable*/launch_background.xml`, `background.png`, `android12splash.png`, `res/values*/styles.xml` |
| `flutter_launcher_icons` | `dart run flutter_launcher_icons -f flutter_launcher_icons.yaml` | `res/mipmap-*/ic_launcher.png`, `mipmap-anydpi-v26/ic_launcher.xml`, `drawable-*/ic_launcher_foreground.png` |

## 12. Verify

```bash
flutter clean
flutter build apk --release
ls -la build/app/outputs/flutter-apk/app-release.apk      # compare with §1
unzip -l build/app/outputs/flutter-apk/app-release.apk | grep "lib/"   # arm64-v8a only
flutter build apk --release --dart-define=USE_MOCK=true \
  --android-project-arg=appIdSuffix=.mock "--android-project-arg=appLabel={{project_title}} Mock"
```

Or all of it, with obfuscation and the symbols saved: `dart run
tool/build_release_apk.dart` (and `--mock`, `--clean`).

- Android Studio → **Build → Analyze APK…** shows what takes the room
  (`classes.dex`, `lib/`, `assets/flutter_assets/`).
- The APK must be signed with your key:
  `apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk`.
- On a 120 Hz phone: Developer options → «Show refresh rate».
- Links: `adb shell am start -a android.intent.action.VIEW -d "https://example.com/items/item_001"`.
- Theme splash: pick «Dark» in the app's settings, kill it, open it — the OS
  splash is dark on a light device (Android 12+).
