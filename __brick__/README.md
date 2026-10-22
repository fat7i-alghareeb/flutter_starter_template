# {{project_title}}

{{project_description}}

One Flutter codebase for phones, tablets, iPads and Windows/macOS windows. Arabic (default) and English, light (default) and dark.

## Start

```bash
flutter pub get
flutter run --dart-define=USE_MOCK=true     # the whole app on mock data
flutter test
```

Desktop: `flutter run -d windows` (or `-d macos`) — first read `docs/DESKTOP_SETUP.md`.
VS Code: pick a configuration in Run and Debug (`.vscode/launch.json`).

## Read next

| Document | For |
| --- | --- |
| `.ai/project-rules.md` | **AI agents start here**: the rules, and which file to read for which task |
| `docs/NEW_PROJECT_CHECKLIST.md` | **Your steps for a new project**, in order |
| `docs/COMMANDS.md` | Every command and `--dart-define` |
| `docs/PROJECT_MAP.md` | Where things live |
| `DESIGN_SYSTEM.md` | The visual rules |
| `docs/RESPONSIVE.md` · `docs/DESKTOP_SETUP.md` | Window sizes and adaptive widgets; Windows and macOS |
| `docs/DECISIONS.md` | Why it is built this way |
| `docs/FEATURE_SPEC_TEMPLATE.md` + `dart run tool/generate_feature.dart <name> --mock` | A new feature |
| `test/README.md` | How to test |
| `docs/ANDROID_RELEASE_SETUP.md` · `docs/IOS_SETUP.md` | Before the first mobile release |
| `docs/CODEMAGIC.md` · `docs/SHOREBIRD.md` | CI and optional over-the-air patches |
| `docs/AGENT_TASK_PROMPT_TEMPLATE.md` | Prompts to give a coding agent |

## Working with Claude Code

`CLAUDE.md` and `.claude/` are set up to keep each chat cheap (see `docs/DECISIONS.md` → Working with Claude Code). In a new project
run **`/first-run`** once: it checks the platform folders, asks the project questions with options, and records the answers in
`CLAUDE.md`. Personal settings go in `CLAUDE.local.md` and `.claude/settings.local.json` (git-ignored).

## Make it yours

- Name, id and colours: `lib/core/config/app_config.dart`, `lib/core/theme/app_colors.dart` (one file to rebrand).
- Language and theme defaults: `lib/core/config/localization_config.dart`, `AppThemeConfig` in `lib/utils/constants/app_flow_constants.dart`.
- Auth: `AppFlowConfig.authMode` (`loginRequired` or `guestFirst`), `guestOnLoginWall`.

The showcase (`lib/features/showcase_feed/`, the Buttons / Forms / Dialogs / Alerts tabs, `assets/mock/showcase/`) is there to copy
from — delete it when your own features replace it.
