---
name: new-feature
description: Build a new feature from a spec, on mock data.
argument-hint: "[feature name — what it does]"
disable-model-invocation: true
---

# New feature: $ARGUMENTS

1. Read `docs/FEATURE_SPEC_TEMPLATE.md` once. Ask me the open questions (options, recommended first) — behaviour, states, edge cases,
   window sizes (§2.6), endpoints.
2. Write the spec to `lib/features/<name>/FEATURE_<name>.md` and **stop for my approval**.
3. `dart run tool/generate_feature.dart "<name>" --mock`, then build on the generated structure (`.ai/architecture-rules.md`).
4. Register an `AppPage` in `lib/core/router/app_routes.dart`; add strings (both languages) and run the strings generator.
5. Tests: bloc, widgets (320 and 1280 wide, both themes, both directions), a skeleton parity line per `.loading()`.
6. `flutter analyze` → "No issues found"; run the new tests; then the whole suite once. Report briefly. Do not commit.
