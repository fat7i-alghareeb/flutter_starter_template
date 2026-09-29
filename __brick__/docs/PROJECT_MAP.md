# Project Map

This map helps agents find the right files without reading the entire project.

## Top Level

- `lib/bootstrap.dart`: startup — DI, link dispatcher, saved theme + language before the first frame, `runApp`, then onboarding/auth/notifications and the first-tab preload.
- `lib/app.dart`: root app — router, theme, localization, offline and session banners, locale rebuild, stage tools.
- `DESIGN_SYSTEM.md`: the visual rules and why.
- `assets/l10n/`: Arabic and English strings (dotted keys, plural groups).
- `assets/mock/`: fixtures for `USE_MOCK=true` (one folder per feature, listed in `pubspec.yaml`).
- `assets/svgIcons/`: Lucide icons; `assets/fonts/`: Tajawal.
- `tool/`: `generate_app_strings.dart`, `generate_feature.dart`, `build_release_apk.dart`.
- `test/`: unit, bloc, widget, golden and contract tests — read `test/README.md` first. `integration_test/`: one boot test on a device.
- `.ai/`: agent-facing rule files.
- `.vscode/launch.json`: seven launch configs (debug/profile/release × mock data × stage tools).
- `codemagic.yaml`: CI release workflows (`docs/CODEMAGIC.md`).
- `docs/`:
  - `COMMANDS.md`: every command, define and tool.
  - `DECISIONS.md`: durable decisions and their reasons.
  - `FEATURE_SPEC_TEMPLATE.md`: the spec every new feature starts from.
  - `ANDROID_RELEASE_SETUP.md` / `IOS_SETUP.md`: native release setup, file by file.
  - `CODEMAGIC.md` / `SHOREBIRD.md`: CI and optional over-the-air patches.
  - `PERFORMANCE_AUDIT.md`: startup, frame-rate and APK-size notes.
  - `AGENT_TASK_PROMPT_TEMPLATE.md`: prompts for agent tasks.

## Core

`lib/core/` contains cross-cutting foundations:

- `config/`: app, localization and mock configuration. `app_config.dart` holds `stageToolsEnabled`; `mock_config.dart` holds `MockConfig` (the `USE_MOCK` switches) and `MockRoutes` (path → fixture).
- `domain/`: shared domain entities such as user data.
- `error/`: global exceptions and error conversion helpers.
- `injection/`: GetIt and Injectable setup.
- `network/`: Dio client, endpoints, interceptors (mock first, then offline cache, memory, JWT refresh, localization, log, error), `offline/` response cache + `OfflineNotice`.
- `notification/`: push/local notification infrastructure.
- `router/`: GoRouter config and guard (`router_config.dart`), the page tree (`app_routes.dart`: `AppPage`, `AppRouteTree`), `app_navigator.dart` (`AppNavigator.push`), `app_links.dart` (`AppLinks`, `LinkDispatcher`), transitions.
- `services/`: storage (+ `last_visit.dart`), session/auth (+ `pending_action.dart`), `startup/bloc_preloader.dart`, ObjectBox, onboarding, localization, memory.
- `theme/`: colours + semantic extension, colour schemes, typography, text styles, effects, page transitions, `ThemeController`, `NativeNightMode`, system UI.
- `utils/`: shared result/status helpers such as `BlocStatus` and `StatusBuilder`.

## Common

`lib/common/` contains reusable UI and shared presentation components:

- `imports/imports.dart`: common barrel import used by many feature files.
- `widgets/custom_scaffold/`: `AppScaffold` and related app shell components.
- `widgets/button/`: `AppButton` system.
- `widgets/form/`: reactive form fields and validation messages.
- `widgets/ds/`: the design system — `app_skeleton.dart` (`SkeletonWidget`), `app_motion.dart` (motion kit), `app_card`, `app_badge`, `app_chip`, `app_icons`, `app_rail`, `app_peek_carousel`, `app_lazy_section`, `app_hero_detail_layout`, `app_action_capsule`, `app_settings_tile`, `app_top_bar`… (barrel: `ds.dart`).
- `widgets/scroll_reveal.dart`, `widgets/nav_bar_visibility.dart`, `widgets/top_banner_slot.dart`, `widgets/rebuild_on_locale_change.dart`: shell-wide behaviour.
- `widgets/failed_state_widget.dart`: standard error state.
- `widgets/empty_state_widget.dart`: standard empty state.
- `widgets/main_loading_progress.dart` and `widgets/loading_dots.dart`: standard loaders.
- `widgets/stage_tools/`: dev-only overlay (device preview, locale, theme), gated by `AppConfig.stageToolsEnabled`.

Read `lib/common/common_folder_guide.md` before creating reusable widgets.

## Utils

`lib/utils/` contains shared constants, helpers, extensions, and generated accessors:

- `constants/`: design tokens, auth constants, localization constants, app flow constants.
- `extensions/`: context, theme, date, string, widget, reactive forms, and numeric extensions.
- `helpers/`: logging, input formatters, JWT helpers, SVG helpers, device helpers.
- `gen/`: generated `AppStrings` and FlutterGen `Assets`.

Read `lib/utils/utils_folder_guide.md` before creating utilities, helpers, extensions, or constants.

## Features

`lib/features/` contains product features. The standard shape is:

```text
feature_name/
├── constants/
├── data/
├── domain/
└── presentation/
```

Feature responsibilities:

- `constants/forms/`: reactive form definitions and static field keys.
- `data/datasources/`: remote/local IO.
- `data/models/`: DTOs and serialization.
- `data/mappers/`: Model to Entity conversion.
- `data/repositories/`: repository implementations.
- `domain/entities/`: domain entities.
- `domain/repositories/`: repository contracts.
- `domain/facade/`: orchestration APIs used by presentation/state.
- `presentation/states/`: BLoCs, events, states.
- `presentation/ui/screens/`: route entry screens.
- `presentation/ui/widgets/`: sections and atomic widgets.

Current template features: `auth` (login wall / sign-in sheet), `onboarding`, `splash`, `root` (the shell: floating nav bar, tab stack, back guard, showcase tabs), `settings`, and `showcase_feed` (the reference feature — copy from it).

## Conditional Guides

- Feature architecture: `lib/features/features_overview.md`
- Core architecture: `lib/core/core_architecture_overview.md`
- Router: `lib/core/router/router_guide.md`
- Session/auth: `lib/core/services/session/session_service_guide.md`
- ObjectBox: `lib/core/services/objectbox/objectbox_service_guide.md`
- Performance audit: `docs/PERFORMANCE_AUDIT.md`
- Common UI: `lib/common/common_folder_guide.md`
- Utilities: `lib/utils/utils_folder_guide.md`
