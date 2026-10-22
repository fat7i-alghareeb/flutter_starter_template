# Localization rules

Read this when you add or change anything a person can read: a label, a title, a hint, a toast, an error, a
notification, a dialog, a semantics label.

The app ships Arabic (default, right-to-left) and English. Every visible string is a generated `AppStrings` constant.

## Add a string

1. Search both `assets/l10n/ar.json` and `en.json` for the sentence. **Reuse** a key that already says it.
2. Otherwise add the **same key to both files**, with a dotted name by area: `feed.saved`, `auth.signIn`,
   `showcase.forms.title`.
3. Regenerate: `dart run tool/generate_app_strings.dart`.
4. Use it: `AppStrings.feedSaved`. Never `'feed.saved'.tr()` in UI code — only the generated file calls `.tr()`.

The generator **refuses** to run when a key is missing in one language, the placeholder counts differ, the same sentence
sits under two keys, or a plural group has no `.other`. Fix the files; do not work around it.

## Placeholders and counts

- A value: `"feed.newSince": "{} new"` → `AppStrings.feedNewSince(count)`. One `{}` per argument, in the same order in both
  languages.
- A counted sentence is a **plural group**, never one fixed template. Arabic has six forms (`zero one two few many other`),
  English two. Write `key.one`, `key.other` (required) and, in Arabic, the others:

  ```json
  "feed.readMinutes.one": "1 min read",
  "feed.readMinutes.other": "{n} min read"
  ```

  → `AppStrings.feedReadMinutes(count, formattedCount)`. A form a language does not write falls back to its `other`.
- Numbers shown to people go through `AppFormats` (Latin digits app-wide), including inside a sentence:
  pass `AppFormats.number(context, n)` as the printed count.

## Rules

- No literal sentence in a widget, screen, dialog, snackbar or notification — in the shared widgets as well as the
  features. `test/l10n/app_strings_discipline_test.dart` fails the build on one.
- Do not add a key to one language only; do not add a second key for a sentence that exists.
- Write for people: say what happened and what to do next. Empty and error states get specific sentences.
- Keep the Arabic natural, not a literal translation. Latin product names and code identifiers (`AppButton`) may stay Latin.
- Test the longest string in both languages at 320dp and 1.3× text.
- Directions: start/end, never left/right (`EdgeInsetsDirectional`, `AlignmentDirectional`).

## Defaults

`lib/core/config/localization_config.dart`: Arabic is the default and the fallback, and a first launch does **not** follow
the device language (`followDeviceLanguageOnFirstLaunch = false`). A language the reader picks later is saved and wins.
To add a language, add its code to `supportedLanguageCodes`, add the JSON file with every key, and regenerate.

## Strings that may stay raw

Only values nobody reads: route names and paths, form field keys, log tags, API field names, storage keys, test fixtures,
and a sample e-mail address (`name@example.com`).
