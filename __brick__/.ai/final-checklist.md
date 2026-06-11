# Final Checklist

Read this before declaring a task complete. Confirm the sections relevant to the task.

## Localization

- User-visible strings use `AppStrings`.
- New keys were checked for duplicates first.
- New keys were added to both `ar.json` and `en.json`.
- `dart run tool/generate_app_strings.dart` was run when localization changed.
- No raw `.tr()` calls on literal UI keys.

## UI and Design System

- Text uses `AppTextStyles`.
- Colors use semantic context tokens or approved `AppColors`.
- No `Colors.*`, raw hex colors, direct `Theme.of(context)`, or direct `context.colorScheme.*` in UI.
- `.withValues(alpha: ...)` is used instead of `.withOpacity()`.
- Spacing uses `AppSpacing`; radius uses `AppRadii`.
- Responsive UI dimensions use `.sp`, `.h`, `.w`, or `.r` where appropriate.
- Spacing-only gaps use `x.verticalSpace` or `y.horizontalSpace`, not `SizedBox(height: x)` or `SizedBox(width: y)`.
- Padding and margin use `REdgeInsets` where responsive insets are needed.
- Icons use `FaIcon(FontAwesomeIcons.*)` with `.r` sizes.
- Buttons use `AppButton` and disable through `isActive`.
- Screens use `AppScaffold` and include `pagePath` and `pageName`.
- UI is decomposed into screens, sections, and widgets.
- Animations are used where appropriate and avoided where they add noise.
- Assets use generated `Assets` references.

## Architecture

- Feature files follow the standard feature structure.
- BLoC and Freezed are used for feature state.
- Async state uses one `BlocStatus<T>` per meaningful operation.
- UI consumes async state through `StatusBuilder<T>`.
- Forms live in `constants/forms/` with static keys.
- No raw form field strings are scattered through UI/BLoC code.
- New reusable widgets/helpers were promoted to `common` or `utils` when appropriate.

## Data Layer

- Entities remain domain-focused.
- Models/DTOs contain serialization only.
- Mappers convert Model to Entity.
- Models do not leak into BLoC or UI.
- API inputs use a dedicated request model or the established local equivalent.
- Datasource IO is wrapped with `rethrowAsAppException`.
- Repository operations are wrapped with `runAsResult`.

## Navigation

- New routes are registered centrally.
- Route data is passed through typed argument classes and GoRouter `extra`.
- Router guard/session/onboarding changes were checked against `lib/core/router/router_guide.md`.

## Loading, Empty, and Error States

- Content loading states use shimmer components where appropriate.
- Full-screen blocking loading uses `MainLoadingProgress`.
- Inline loading uses `LoadingDots`.
- Empty states use `EmptyStateWidget`.
- Error states use `FailedStateWidget`.
- No raw `CircularProgressIndicator` is used directly in feature UI.

## Code Quality

- Imports are clean and project-style.
- No unused imports, variables, methods, or dead commented code remain.
- Logs use `printC`, `printM`, or `printY`.
- Comments explain why, not obvious what.
- Generated files were not manually edited.
- UI dates use date extensions.
- Numeric inputs use `ArabicToEnglishDigitsFormatter`.

## Docs

- Relevant docs were updated for reusable widgets, helpers, commands, dependencies, or architecture changes.
- `docs/DECISIONS.md` was updated for durable architectural decisions.
- `docs/COMMANDS.md` was updated for command changes.

## Security

- WebView auth flows clear both cookies and cache after authentication.
- Session/JWT changes were checked against `lib/core/services/session/session_service_guide.md`.
- Storage/ObjectBox changes were checked against `lib/core/services/objectbox/objectbox_service_guide.md`.

## Commands

- AppStrings generation was run when localization changed.
- Build runner was run when generated code/assets/ObjectBox/Freezed/Injectable changed.
- Formatting, analysis, and tests were run when relevant, or skipped with a clear reason.
- No `melos` command was used.
