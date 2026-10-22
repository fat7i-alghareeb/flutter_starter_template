---
name: add-string
description: Add a localised string to both languages and regenerate.
argument-hint: "[dotted.key] [English text] [Arabic text]"
disable-model-invocation: true
---

# Add string: $ARGUMENTS

1. `grep` both `assets/l10n/en.json` and `ar.json` for the English and Arabic sentence — if one exists, reuse its key and stop.
2. Add the key to **both** files (same dotted key; a counted sentence is a plural group with `.other`). If the Arabic is missing from
   the arguments, propose a natural one and ask me to confirm.
3. `dart run tool/generate_app_strings.dart`. If it refuses, fix the files (do not work around).
4. Reply with the getter name (`AppStrings.…`) only.
