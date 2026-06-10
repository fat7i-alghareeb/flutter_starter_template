# Localization Rules

Read this file when adding or changing user-visible text.

## Required Workflow

1. Check both localization files first:
   - `assets/l10n/ar.json`
   - `assets/l10n/en.json`
2. Reuse an existing key if it already expresses the same text.
3. If a new key is needed, add it to both files.
4. Run:

```bash
dart run tool/generate_app_strings.dart
```

5. Use the generated constant:

```dart
AppStrings.yourKey
```

## Rules

- No hardcoded visible strings in widgets or screens.
- No raw `.tr()` calls on string literals in UI.
- Do not add a key to only one language file.
- Do not create duplicate keys with the same meaning.
- Do not run `melos`; this project does not use it.
- Keep validation, empty, error, action, label, title, subtitle, and button text localized.

## Acceptable Non-Localized Text

Only use raw strings for non-visible internal values, such as:

- route names and paths
- form field keys
- log tags
- API field names
- storage keys
- test-only technical fixtures
