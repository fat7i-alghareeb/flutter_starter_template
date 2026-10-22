---
name: release
description: Release checklist for Android, iOS, Windows or macOS.
argument-hint: "[android|ios|windows|macos]"
disable-model-invocation: true
---

# Release: $ARGUMENTS

1. Confirm with me: the version in `pubspec.yaml` (`+N` bumped?), mock off, signing in place for this platform.
2. Read only the matching guide, once: android → `docs/ANDROID_RELEASE_SETUP.md`, ios → `docs/IOS_SETUP.md`,
   windows / macos → `docs/DESKTOP_SETUP.md` (Shipping). CI instead: `docs/CODEMAGIC.md`.
3. `flutter analyze` and `flutter test` first. Then the build command from `docs/COMMANDS.md` (Release / Desktop).
4. Report the artefact path and size. Anything that needs my account (stores, certificates) → list it for me; do not attempt it.
5. Do not commit, tag or push.
