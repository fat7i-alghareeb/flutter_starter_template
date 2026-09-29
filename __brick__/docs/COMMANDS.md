# Commands

Run from the project root.

## Setup

```bash
flutter pub get
dart run build_runner build          # freezed, injectable, assets/fonts gen, ObjectBox
dart run tool/generate_app_strings.dart
```

Generated Dart (`*.g.dart`, `*.freezed.dart`, `injectable.config.dart`,
`lib/utils/gen/*`) is **committed**, so a fresh clone builds without running
`build_runner` first.

## Run

| What | Command | VS Code config |
| --- | --- | --- |
| Normal | `flutter run` | App (Debug) |
| Mock data | `flutter run --dart-define=USE_MOCK=true` | App (Debug, mock data) |
| Mock + stage tools | `flutter run --dart-define=USE_MOCK=true --dart-define=STAGE_TOOLS=true` | App (Debug, mock data, stage tools) |
| Stage tools | `flutter run --dart-define=STAGE_TOOLS=true` | Stage Tools (Debug) |
| Profile | `flutter run --profile` | App (Profile) |
| Release | `flutter run --release [--dart-define=USE_MOCK=true]` | App (Release[, mock data]) |

### Mock-layer switches (`lib/core/config/mock_config.dart`)

| Define | Effect |
| --- | --- |
| `USE_MOCK=true` | Every request is answered from `assets/mock/` at the Dio layer |
| `MOCK_DELAY_MS=600` | Simulated latency (default clears the 300ms skeleton threshold) |
| `MOCK_EMPTY=/showcase/feed,…` | These paths answer with an empty list |
| `MOCK_ERROR=/showcase/picks,…` | These paths answer with a server error |
| `MOCK_OFFLINE=true` | Every request fails as offline (tests the cache + offline banner) |

### Stage tools (`STAGE_TOOLS=true`)

Three draggable buttons above the nav bar: DevicePreview (any device frame),
language and theme — for QA and demos. Builds without the define compile the
code out.

## Strings

After editing `assets/l10n/en.json` or `ar.json`:

```bash
dart run tool/generate_app_strings.dart
```

It refuses to generate on: a key missing in one language, placeholder counts
that differ, the same value under two keys, a plural group without `.other`.

## New feature

```bash
dart run tool/generate_feature.dart "order item"          # lib/features/order_item/
dart run tool/generate_feature.dart "order item" --mock   # + assets/mock/order_item/list.json
dart run tool/generate_feature.dart orders --force        # recreate
```

Then: register an `AppPage` (`lib/core/router/app_routes.dart`), add the
card's parity test line, write its strings.

## Quality

```bash
dart format <the files you changed>      # not the whole tree
flutter analyze                          # also reads test/ and tool/
flutter test                             # everything, goldens included
flutter test --exclude-tags golden       # on a CI OS that differs from yours
flutter test --update-goldens            # after a deliberate visual change
flutter test integration_test --dart-define=USE_MOCK=true   # needs a device
```

## Icons, splash

```bash
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
dart run flutter_native_splash:create --path flutter_native_splash.yaml
```

## Release

```bash
dart run tool/build_release_apk.dart           # arm64, obfuscated, APK + symbols to the Desktop
dart run tool/build_release_apk.dart --mock    # the mock-data APK (own id + name)
dart run tool/build_release_apk.dart --clean   # after changing ABI/AOT flags
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
flutter symbolize -i trace.txt -d build/symbols/app.android-arm64.symbols
```

Setup for signing and a small APK: `docs/ANDROID_RELEASE_SETUP.md`.
iOS: `docs/IOS_SETUP.md`. CI: `docs/CODEMAGIC.md`. Over-the-air patches
(optional): `docs/SHOREBIRD.md`.

## Prohibited

- No `melos`; this project does not use it.
- No `flutter pub run …`; use `dart run …`.
- No `dart run build_runner watch` for one-off agent tasks.
- No `dart format lib/utils/gen/app_strings.g.dart` (the discipline test
  reads it line by line) — regenerate it instead.
- No `shorebird release|patch` by hand once Shorebird is set up — always
  `tool/shorebird.dart`.
