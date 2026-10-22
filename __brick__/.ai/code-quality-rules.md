# Code quality rules

Read this before you finish a task, and whenever you touch imports, generated files, logging, dates, numeric input or
commands.

## Imports

- Project files by package path (`package:<app>/…`) or the existing relative style of the folder you are in; do not mix
  both in one file. Use `lib/common/imports/imports.dart` where the neighbouring files do.
- No unused imports (`flutter analyze` reports them). A relative import that climbs across layers is a smell: import the
  barrel or the public file instead.

## Logging

- `print`, and a bare `debugPrint`, are banned (`avoid_print`). Use the coloured helpers in `lib/utils/helpers/colored_print.dart`.
  They print in debug builds only.
- The project's convention: `printC` flow and information, `printG` success, `printY` warnings and redirects, `printR`
  errors, `printM` network responses. Prefix with a tag constant (`RouterLogTags.redirect`, `AuthLogTags.authManager`).
- Never log a token, a password or personal data.

## Generated files

- Never edit by hand; regenerate. They are **committed**, so a fresh clone builds without running the generators.
  `*.freezed.dart`, `*.g.dart`, `injectable.config.dart`, `lib/utils/gen/app_strings.g.dart`, `lib/utils/gen/assets.gen.dart`,
  `lib/objectbox.g.dart`.
- Strings: `dart run tool/generate_app_strings.dart`. Everything else: `dart run build_runner build`.
- Do not `dart format` `lib/utils/gen/app_strings.g.dart` (a test reads it line by line).
- When a change needs regeneration, commit the regenerated files with it.

## Commands

Only the commands in `docs/COMMANDS.md`. Not `melos`, not `flutter pub run …` (use `dart run …`), not
`build_runner watch` for a one-off task.

## Style

- Comments say **why**, an edge case, or a non-obvious data flow — not what the next line does. Delete commented-out code.
- `const` wherever possible; final locals (`prefer_final_locals`). Public API gets a doc comment saying what it is for.
- Dates shown to people go through the date extensions (`lib/utils/extensions/date_time_extensions.dart`) or `AppFormats`.
  Never a raw `DateFormat(...)` in a widget.
- Every numeric text input carries `ArabicToEnglishDigitsFormatter` (`lib/utils/helpers/input_formatters.dart`).
- Prefer the existing helper over a new one: check `lib/utils/utils_folder_guide.md` and `lib/common/common_folder_guide.md`.

## Before you finish

1. `dart format` the files you changed (not the whole tree).
2. `flutter analyze` → **No issues found**, with no new `// ignore`.
3. `flutter test` (or the relevant folders) → green. After a deliberate visual change, `flutter test --update-goldens`
   and look at the new images.
4. Docs updated for anything reusable (see "Keep the docs true" in `project-rules.md`).
5. Walk `final-checklist.md`.
