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

### Desktop

| What | Command |
| --- | --- |
| Run on Windows / macOS | `flutter run -d windows` · `flutter run -d macos` |
| Build a desktop app | `flutter build windows --release` · `flutter build macos --release` |
| Windows installer (`setup.exe`, Inno Setup) | `dart run tool/build_windows_installer.dart` |
| Windows MSIX (test / Microsoft Store) | `dart run msix:create` · `dart run msix:create --store` |
| macOS `.dmg` | `tool/build_macos_dmg.sh` |
| Desktop icons | `dart run flutter_launcher_icons -f flutter_launcher_icons.yaml` |

Setup, the title bar, and what each route needs: `docs/DESKTOP_SETUP.md`.
Try a size by dragging the window (stage tools are off on desktop by design). The first Windows build downloads the Firebase
C++ SDK (about 960 MB) and is slow; later builds reuse it. A clean Windows build prints no warnings — if one appears, see
«Warnings that are hidden» in `docs/DESKTOP_SETUP.md`.

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

## Find an existing widget

```bash
dart run tool/widget_catalog.dart             # every shared widget, one line each
dart run tool/widget_catalog.dart button      # only those whose name, path or summary contains "button"
dart run tool/widget_catalog.dart --all card  # also the widgets inside features
```

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
flutter analyze                          # must end with «No issues found!»; also reads test/ and tool/
flutter test                             # everything, goldens included (about 420 tests)
flutter test test/features/root          # one folder — use while you work
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
