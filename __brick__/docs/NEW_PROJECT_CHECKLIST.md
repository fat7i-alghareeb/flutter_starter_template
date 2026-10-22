# New project checklist

The steps that are yours, in order, for every new project made from this brick. Tick them off; each says where the detail is.

## 1. Create the project (terminal, once)

- [ ] **Create the platform folders** (any time before the setup script in the next steps):
  ```bash
  flutter create --org com.yourcompany --project-name my_app \
    --platforms=android,ios,windows,macos my_app
  cd my_app
  ```
- [ ] **Apply the brick** inside that folder (answer the four prompts: package name, title, bundle id, description):
  ```bash
  mason make flutter_app_template --on-conflict overwrite
  ```
- [ ] **Set up the desktop runners and the Windows GUID:** `dart run tool/setup_project.dart`. It lists each file it patched;
  a line starting `CHECK` is a file to edit by hand from the table in `docs/DESKTOP_SETUP.md`. Safe to run again, and to run after
  adding a platform later.
- [ ] `flutter pub get`
- [ ] `dart run build_runner build`
- [ ] **Baseline:** `flutter analyze` must end with *No issues found!*, then `flutter test`. Fix nothing yet — just know the baseline.
- [ ] `flutter run --dart-define=USE_MOCK=true` — the app opens, in Arabic and light.

## 2. Set up Claude for this project (once)

- [ ] Open the project folder in Claude Code.
- [ ] Run **`/first-run`**. It checks the platform folders, runs the baseline, asks the project questions (with options) and
      records the answers under "This project" in `CLAUDE.md`.
- [ ] Answer how you pay for Claude. On an **API key**, add `"promptCacheTtl": "1h"` to `.claude/settings.local.json`
      (a subscription already gets one hour).
- [ ] `/memory` — auto memory is **on**.
- [ ] `/context` — shows `CLAUDE.md` and `.ai/project-rules.md` loaded, and no surprises.
- [ ] Private notes go in `CLAUDE.local.md`; personal settings in `.claude/settings.local.json` (both git-ignored).
- [ ] Commit `CLAUDE.md` and `.claude/` so every chat, and everyone, starts from the same set-up.

## 3. Make it yours (decisions Claude will ask you)

- [ ] App name, id, colours: `lib/core/config/app_config.dart`, `lib/core/theme/app_colors.dart` (the one file to rebrand).
- [ ] Icon and splash: put the images in place, then
      `dart run flutter_launcher_icons -f flutter_launcher_icons.yaml` and
      `dart run flutter_native_splash:create --path flutter_native_splash.yaml`.
- [ ] **API base URL:** `ApiConfig._baseUrl` in `lib/core/network/api_config.dart` (empty until you set it; endpoints in `api_endpoints.dart`). Every other switch: the README's *Configuration reference*.
- [ ] Auth mode and guest button: `AppFlowConfig` in `lib/utils/constants/app_flow_constants.dart`.
- [ ] Default language and theme: `lib/core/config/localization_config.dart`, `AppThemeConfig`.
- [ ] Delete the showcase when your own features replace it: `lib/features/showcase_feed/`, the demo tabs in
      `lib/features/root/presentation/ui/widgets/showcase/`, `assets/mock/showcase/`.

## 4. Before a release (when you get there)

- [ ] Android: signing and a small APK — `docs/ANDROID_RELEASE_SETUP.md`. iOS — `docs/IOS_SETUP.md`.
- [ ] Windows and macOS: installers, Store package, macOS App Group — `docs/DESKTOP_SETUP.md`.
      **The first Windows build downloads about 960 MB** (Firebase C++ SDK); it is slow once, then reused.
- [ ] Push notifications: a Firebase project, then turn on `_fcmEnabled` in `lib/bootstrap.dart` — `lib/core/notification/notification.md`.
- [ ] CI: `docs/CODEMAGIC.md`. Over-the-air patches (optional): `docs/SHOREBIRD.md`.
- [ ] Bump `version: x.y.z+N` in `pubspec.yaml`.
- [ ] `/release <platform>` in Claude Code walks the checklist.

## Every feature after that

- [ ] Name the reference feature in `docs/CODE_STYLE.md` and `CLAUDE.md` when you pick one (it starts as `showcase_feed`).
- [ ] Read `docs/CODE_STYLE.md` once and strike every `observed` line that is not how you want it; fix `needs a decision`.
- [ ] After each feature or new UI element Claude runs `/finish` (or type it). Correct Claude when its code is not how you write it;
      it records the correction.
- [ ] With a Figma design: give Claude the node link; it matches existing widgets first and records new ones in `DESIGN_SYSTEM.md`.

## Every chat after that

- Start with a specific task. One task per chat; `/clear` before an unrelated one.
- Let Claude ask you questions — answer with the options.
- Nothing to re-load: `CLAUDE.md` and the digest are already read for you.
