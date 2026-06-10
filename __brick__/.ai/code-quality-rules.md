# Code Quality Rules

Read this file before final cleanup, and whenever touching imports, generated files, logging, dates, input formatting, or commands.

## Imports

- Prefer package imports for project files when available.
- Use `lib/common/imports/imports.dart` when it matches existing local style.
- Do not leave unused imports.
- Avoid relative imports that make cross-layer dependencies hard to read.

## Logging

- Use `printC` for general informational logs.
- Use `printM` for BLoC/state logs.
- Use `printY` for network/API logs.
- Do not use raw `print()`, `debugPrint()`, or `log()` in app code unless a narrow platform constraint requires it and is documented.

## Generated Files

- Do not manually edit generated files.
- Generated files include, but are not limited to:
  - `*.freezed.dart`
  - `*.g.dart`
  - `lib/utils/gen/app_strings.g.dart`
  - `lib/utils/gen/assets.gen.dart`
  - `lib/core/injection/injectable.config.dart`
  - `lib/objectbox.g.dart`
- Regenerate instead of hand-editing generated output.

## Commands

Use only the supported project commands from `docs/COMMANDS.md`.

For localization:

```bash
dart run tool/generate_app_strings.dart
```

For Freezed, Injectable, FlutterGen, ObjectBox, and other build_runner output:

```bash
dart run build_runner build
```

Do not use `melos`.
Do not use `flutter pub run build_runner build`.
Do not run `build_runner watch` for one-off tasks.

## Comments

- Comments should explain why, edge cases, or non-obvious data flow.
- Do not add comments that restate what the next line of code already says.
- Remove commented-out dead code before finishing.

## Dates and Numeric Input

- Display dates with the project date extensions from `lib/utils/extensions/date_time_extensions.dart`.
- Do not format UI dates with raw `DateFormat(...)` in widgets.
- Numeric text inputs must include `ArabicToEnglishDigitsFormatter` from `lib/utils/helpers/input_formatters.dart`.

## Cleanup

Before finishing:

- Format changed Dart files when code changed.
- Run analysis when practical.
- Run targeted tests when available or relevant.
- Confirm docs are updated for any new reusable component, helper, command, dependency, or architecture decision.
