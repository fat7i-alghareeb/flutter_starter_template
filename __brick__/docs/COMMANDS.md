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

## Flavor Generation

The template includes Flutter Flavorizr configuration in `pubspec.yaml`.
Run only when intentionally regenerating flavor files:

```bash
dart run flutter_flavorizr
```

## Prohibited Commands

- Do not run `melos`; this project does not use it.
- Do not run `flutter pub run build_runner build`; use the `dart run` form above.
- Do not run `dart run build_runner watch` for one-off agent tasks.
