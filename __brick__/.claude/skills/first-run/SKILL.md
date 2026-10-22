---
name: first-run
description: Set Claude up for a new project made from this brick — run once.
disable-model-invocation: true
---

# First run for this project

Do this once, in order. Be economical: read each file at most once.

1. **Check the project.** Does `android/`, `ios/`, `windows/`, `macos/` exist (platform folders)? If not, tell me to run
   `flutter create . --org <id> --project-name <name>` and the hook patches (`docs/DESKTOP_SETUP.md`), then continue.
   Run `flutter pub get`, `flutter analyze`, and `flutter test --reporter=failures-only`; report the baseline in one line.
2. **Read once** (skim, do not dump): `docs/PROJECT_MAP.md` and `docs/DECISIONS.md`. Everything else loads on demand.
3. **Ask me the project questions** with the question tool (2–4 options each, your recommendation first, batched):
   - App name, id and brand colours (`lib/core/config/app_config.dart`, `lib/core/theme/app_colors.dart`).
   - Auth mode (`loginRequired` / `guestFirst`), whether "Continue as guest" stays, onboarding on/off.
   - Default language and theme (the template ships Arabic + light).
   - Platforms this app really targets (so unused ones can be left alone).
   - Push (Firebase) now or later; signing and store ids now or later.
   - How I pay for Claude (subscription or API key): for an API key, suggest `promptCacheTtl: "1h"` in `.claude/settings.local.json`.
4. **Apply** the answers in code only when I confirm; list anything that needs me (keystore, store accounts, Firebase files).
5. **Record.** Replace the line under "This project" in `CLAUDE.md` with a short block (≤ 12 lines): name, platforms, auth mode,
   defaults, what is still pending. Save the non-obvious decisions as auto-memory (one fact per file, with the reason).
6. **Manual checklist for me** (print it, short): `/memory` shows memory on; `/context` shows `CLAUDE.md` + rules loaded;
   `.claude/settings.local.json` for personal settings; `CLAUDE.local.md` for private notes (both git-ignored).
7. Finish with: what you changed, what is pending, the first question for my next task. Do not commit.
