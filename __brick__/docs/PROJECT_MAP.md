# Project Map

This map helps agents find the right files without reading the entire project.

## Top Level

- `lib/bootstrap.dart`: app startup sequence, dependency setup, localization, auth/session initialization, and app launch.
- `lib/app.dart`: root Flutter app, router, theme, localization delegates, global overlays.
- `assets/l10n/`: Arabic and English localization JSON files.
- `.ai/`: agent-facing rule files.
- `docs/`: concise project reference docs.
  - `AGENT_TASK_PROMPT_TEMPLATE.md`: copy/paste prompts for starting agent tasks.
  - `PERFORMANCE_AUDIT.md`: startup, routing, RAM, and frame-rate audit notes.

## Core

`lib/core/` contains cross-cutting foundations:

- `config/`: app and localization configuration.
- `domain/`: shared domain entities such as user data.
- `error/`: global exceptions and error conversion helpers.
- `injection/`: GetIt and Injectable setup.
- `network/`: Dio client, endpoints, interceptors, refresh behavior.
- `notification/`: push/local notification infrastructure.
- `router/`: GoRouter config, route registry, guards, transitions.
- `services/`: storage, session/auth, ObjectBox, onboarding, localization, memory services.
- `theme/`: app colors, typography, text styles, theme effects, system UI.
- `utils/`: shared result/status helpers such as `BlocStatus` and `StatusBuilder`.

## Common

`lib/common/` contains reusable UI and shared presentation components:

- `imports/imports.dart`: common barrel import used by many feature files.
- `widgets/custom_scaffold/`: `AppScaffold` and related app shell components.
- `widgets/button/`: `AppButton` system.
- `widgets/form/`: reactive form fields and validation messages.
- `widgets/app_shimmer.dart`: shimmer base widget.
- `widgets/failed_state_widget.dart`: standard error state.
- `widgets/empty_state_widget.dart`: standard empty state.
- `widgets/main_loading_progress.dart` and `widgets/loading_dots.dart`: standard loaders.

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

Current template features include `auth`, `onboarding`, `root`, and `splash`.

## Conditional Guides

- Feature architecture: `lib/features/features_overview.md`
- Core architecture: `lib/core/core_architecture_overview.md`
- Router: `lib/core/router/router_guide.md`
- Session/auth: `lib/core/services/session/session_service_guide.md`
- ObjectBox: `lib/core/services/objectbox/objectbox_service_guide.md`
- Performance audit: `docs/PERFORMANCE_AUDIT.md`
- Common UI: `lib/common/common_folder_guide.md`
- Utilities: `lib/utils/utils_folder_guide.md`
