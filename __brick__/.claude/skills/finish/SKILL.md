---
name: finish
description: End-of-feature routine — update docs, style and memory for what changed.
disable-model-invocation: true
---

# Finish a feature or a new UI element

Run this when a feature, a screen or a new shared widget is done (skip it for a bug fix or a one-line change). Be economical:
look only at what changed (`git diff --stat`, `git status`) and open only the docs a row below sends you to.

1. **What changed?** `git status --short` and `git diff --stat`. Name: new feature / new shared widget / new token or visual rule /
   new helper / new decision.
2. **Duplicates.** For each new widget or helper: `dart run tool/widget_catalog.dart <word>`. If it overlaps an existing one, do
   **not** merge on your own — put one question to me (merge, add a parameter, or keep both and why).
3. **Update only what applies** (one line or one row each; do not rewrite pages):
   | If you added… | Update |
   | --- | --- |
   | a shared widget (`lib/common/`) | its row in `lib/common/common_folder_guide.md`; `ds/ds.dart` export if it is a design-system piece |
   | a visual rule, token or component (also from Figma) | `DESIGN_SYSTEM.md` — the rule and its value; the Figma node link next to the component in `common_folder_guide.md` |
   | a helper, extension or constant | `lib/utils/utils_folder_guide.md` |
   | a route or page | `docs/PROJECT_MAP.md` only if a new feature folder; `lib/core/router/router_guide.md` only if the guard changed |
   | a command, define or dependency | `docs/COMMANDS.md` |
   | a durable decision (and why) | `docs/DECISIONS.md` |
   | a feature | the feature's `FEATURE_<name>.md` kept true; `docs/PROJECT_MAP.md` features table |
4. **Style.** If the feature introduced a convention worth repeating, or I corrected you during it, add a line to
   `docs/CODE_STYLE.md` (marked `corrected` with my words and the reason). If this feature is cleaner than the reference, say so and
   ask whether to make it the reference.
5. **Memory.** Save to auto memory only what the repo cannot tell the next chat: a decision and its reason, a preference of mine, a
   verified external fact with its URL. One fact per file. Never code structure or paths.
6. **Verify.** `flutter analyze` → "No issues found"; the new tests; the strings generator if `l10n` changed.
7. **Report in five lines or fewer:** what you updated, what you skipped and why, the duplicate question if any, check results.
   Do not commit.
