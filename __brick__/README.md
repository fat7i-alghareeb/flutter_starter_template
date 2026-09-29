# {{project_title}}

{{project_description}}

## Start

```bash
flutter pub get
flutter run --dart-define=USE_MOCK=true     # the whole app on mock data
flutter test
```

VS Code: pick a configuration in Run and Debug (`.vscode/launch.json`).

## Read next

| Document | For |
| --- | --- |
| `docs/COMMANDS.md` | Every command and `--dart-define` |
| `DESIGN_SYSTEM.md` | The visual rules |
| `docs/PROJECT_MAP.md` | Where things live |
| `docs/DECISIONS.md` | Why it is built this way |
| `docs/FEATURE_SPEC_TEMPLATE.md` + `dart run tool/generate_feature.dart <name> --mock` | A new feature |
| `test/README.md` | How to test |
| `docs/ANDROID_RELEASE_SETUP.md` · `docs/IOS_SETUP.md` | Before the first release |
| `docs/CODEMAGIC.md` · `docs/SHOREBIRD.md` | CI and optional over-the-air patches |

The showcase (`lib/features/showcase_feed/`, the Buttons/Forms/Dialogs/Alerts tabs,
`assets/mock/showcase/`) is there to copy from — delete it when your own features replace it.
