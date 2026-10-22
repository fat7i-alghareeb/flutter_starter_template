---
paths:
  - "test/**"
  - "integration_test/**"
---

# Tests (loads when you touch tests)

- Read `test/README.md` for the "learned the hard way" list before writing a test that pumps widgets.
- `pumpApp` (no localisation) vs `pumpLocalizedApp` (one per file). Screens: `fullScreen: true`. Shimmer/looping screens: `settle: false`.
- Set a platform with `debugDefaultTargetPlatformOverride` inside the test body, reset in `try/finally`.
- Assert `AppStrings.x`, not Arabic text. Pump past an `AppButton` tap's 90 ms timer.
- A golden never contains the project name or the wall clock. After a deliberate visual change: `flutter test --update-goldens`, look at the images.
- **Never run the whole suite for a small task.** Run the changed file's test, then its folder; the whole suite only for `/finish`, a release or a big refactor (`.ai/project-rules.md`).
- Run a folder while you work (`flutter test test/features/root`).
