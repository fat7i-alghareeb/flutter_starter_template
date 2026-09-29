# Codemagic CI

`codemagic.yaml` at the project root builds signed releases on Codemagic's
Macs — Android APK/AAB and iOS TestFlight — without a Mac of your own.

| Workflow | Produces |
| --- | --- |
| `android-release-mock` | APK with `USE_MOCK=true`, installs beside the real app (`{{package_name}}.mock`) |
| `android-release` | APK, real network |
| `android-bundle` | AAB for Google Play |
| `ios-release` | IPA uploaded to TestFlight |

Every workflow runs `flutter analyze` and `flutter test --exclude-tags golden`
first, and is started by hand (add a `triggering:` block for tags/pushes).

## 1. Connect the repository

codemagic.io → **Add application** → pick the Git provider and the repo →
project type «Flutter App (via codemagic.yaml)». Codemagic reads the YAML from
the branch you build.

## 2. Android signing (once)

1. Make the keystore (`docs/ANDROID_RELEASE_SETUP.md` §2).
2. Team settings → **Code signing identities** → Android keystores → upload
   the `.jks`, with its passwords and alias, under the reference name
   **`{{project_name}}_release_keystore`**.
3. That is all: the «Set up signing» step writes `android/key.properties`
   from `CM_KEYSTORE_*`. If the keystore is not attached, the step **fails the
   build** — otherwise the release would silently fall back to the debug key.

The mock APK's id/label need the Gradle lines from
`docs/ANDROID_RELEASE_SETUP.md` §6; without them the flags are ignored and the
mock APK replaces the real one on a device.

## 3. iOS signing (once)

1. App Store Connect → Users and Access → Integrations → **App Store Connect
   API** → generate a key (App Manager role). Download the `.p8`.
2. Codemagic → Team settings → Team integrations → **Developer Portal** → add
   the key under the name **`{{project_name}}_app_store_connect`**.
3. Code signing identities → iOS certificates → «Generate certificate»
   (Apple Distribution), and iOS provisioning profiles → «Fetch profiles» for
   `{{package_name}}`. Codemagic can create both through the key.
4. The app must exist in App Store Connect (My Apps → + → New App, bundle id
   `{{package_name}}`).

## 4. Versioning

`pubspec.yaml`'s `version: x.y.z+N` is the only source; Codemagic's build
counter is not used. Bump `+N` and commit before every release — both stores
refuse a build number they have already seen.

## 5. Notifications

Replace `you@example.com` under `publishing.email` with the people who should
get the build links.

## 6. Artifacts worth keeping

`build/symbols/*.symbols` and `mapping.txt` are saved with every build.
Without them an obfuscated stack trace (Dart or Java) cannot be read:

```bash
flutter symbolize -i trace.txt -d app.android-arm64.symbols
```

## 7. Over-the-air patches

`docs/SHOREBIRD.md` §7 has the same workflows as Shorebird release/patch
ones.
