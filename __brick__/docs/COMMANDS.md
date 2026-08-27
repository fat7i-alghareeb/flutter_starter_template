# Commands

Run commands from the project root unless noted otherwise.

## Install Dependencies

```bash
flutter pub get
```

## Generate AppStrings

Use after changing `assets/l10n/ar.json` or `assets/l10n/en.json`.

```bash
dart run tool/generate_app_strings.dart
```

## Run build_runner

Use after changing Freezed models/states, Injectable registrations, FlutterGen assets, ObjectBox entities, or other build_runner inputs.

```bash
dart run build_runner build
```

## Format

```bash
dart format lib
```

For a smaller task, format only the changed Dart files. Include `test` or `tool` as additional paths when those folders exist and were changed.

## Analyze

```bash
flutter analyze
```

## Test

```bash
flutter test
```

Run targeted tests when available for the touched area.

## Run the App

This project has no flavors. Run it normally:

```bash
flutter run
```

Run with the in-app stage tools overlay (device preview, locale, theme):

```bash
flutter run --dart-define=STAGE_TOOLS=true
```

`STAGE_TOOLS` is read as a compile-time constant by `AppConfig.stageToolsEnabled`
(`lib/core/config/app_config.dart`). Builds that omit it drop the stage tools
code during tree shaking. The same flag works for `flutter build`.

## Prohibited Commands

- Do not run `melos`; this project does not use it.
- Do not run `flutter pub run build_runner build`; use the `dart run` form above.
- Do not run `dart run build_runner watch` for one-off agent tasks.
