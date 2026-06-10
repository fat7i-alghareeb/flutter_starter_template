# Project Rules

This is the always-loaded entry point for AI coding agents working on the Alsultan single-app Flutter project template.

Use this file to decide which detailed rules to load. Keep daily task context small, but do not weaken the project standards.

## First Steps

Before editing any file:

1. Read the always-required files:
   - `.ai/project-rules.md`
   - `.ai/task-workflow.md`
   - `docs/PROJECT_MAP.md`
   - `docs/COMMANDS.md`
2. Identify which files and layers the task touches.
3. Load only the relevant conditional rule files listed below.
4. Inspect related existing implementations before creating new patterns.
5. Make a short implementation plan before editing code.

In the first response for a coding task, list the files read for that session.

## Conditional Rule Files

Read these only when the task touches the relevant area:

- `.ai/flutter-ui-rules.md`: UI, widgets, screens, theme, assets, loading, empty/error states, animations.
- `.ai/architecture-rules.md`: features, BLoC, repositories, datasources, models, entities, forms, routing, services.
- `.ai/localization-rules.md`: adding or changing user-visible text.
- `.ai/code-quality-rules.md`: final cleanup, imports, logging, generated files, dates, numeric inputs.
- `.ai/final-checklist.md`: before declaring the task complete.

Read these project guides only when needed:

- `lib/core/services/objectbox/objectbox_service_guide.md`: local storage, ObjectBox, persistence.
- `lib/core/router/router_guide.md`: routes, navigation, redirect guards, deep links.
- `lib/core/services/session/session_service_guide.md`: auth, JWT, session state.
- `lib/common/common_folder_guide.md`: before creating reusable widgets or shared UI.
- `lib/utils/utils_folder_guide.md`: before creating utilities, constants, helpers, or extensions.

## Non-Negotiable Standards

- User-visible strings must use generated `AppStrings` constants.
- Text styles must come from `AppTextStyles`.
- Colors must use semantic context tokens or approved `AppColors`.
- Screens must use `AppScaffold` and define `pagePath` and `pageName`.
- Buttons must use the `AppButton` system.
- State management uses BLoC, Freezed, `BlocStatus<T>`, and `StatusBuilder<T>`.
- Data layers must separate Entity, Model, Mapper, Repository, DataSource, and RequestModel responsibilities.
- Data sources wrap failures with `rethrowAsAppException`; repositories wrap operations with `runAsResult`.
- Navigation uses typed arguments through GoRouter `extra` when passing data.
- Loading states use shimmer or platform loading widgets, not ad-hoc spinners.
- Assets must be referenced through FlutterGen `Assets`.
- Do not run `melos`; this project does not use it.
- Keep documentation in sync when adding reusable patterns, commands, dependencies, or architecture.
- After any auth flow that uses a WebView, clear both cookies and cache.

## Documentation Sync

Update documentation in the same task when you:

- Add or change a reusable widget in `lib/common/`.
- Add or change a utility, helper, extension, or design token in `lib/utils/`.
- Add a major dependency, command, architecture pattern, or long-term decision.
- Change routing, session, storage, or localization behavior.

## Conflict Rule

When docs conflict, prefer the newer modular rules in `.ai/`. Then consult the layer-specific guide for implementation details.
