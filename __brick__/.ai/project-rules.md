# Project rules

**Read this file first, every task** (Claude Code loads it automatically through `CLAUDE.md`; other tools are pointed here by their
own rules file — do not open it a second time). {{project_title}} is one Flutter codebase for phones, tablets, iPads and
Windows/macOS windows, in Arabic (default) and English, light (default) and dark.

This file is the entry point. It tells you what to read for your task and states the rules that
fail reviews. The detail lives in the files it points to — read those only when your task touches them.

## How to work

1. Read this file, then [`task-workflow.md`](task-workflow.md).
2. Find your task in the table below and read **only** those files.
3. Look for a similar thing that already exists and copy its shape. Do not invent a new pattern.
4. Say what you will change (files, commands) before you edit. Planning-only requests: stop there.
5. Make the change, run the commands, then walk [`final-checklist.md`](final-checklist.md).
6. In your first reply, list the files you read.

## What to read for which task

| Your task touches | Read |
| --- | --- |
| Any screen, widget, colour, spacing, icon, animation | [`flutter-ui-rules.md`](flutter-ui-rules.md) · `DESIGN_SYSTEM.md` |
| Layout that changes with window size, desktop, platform differences | `docs/RESPONSIVE.md` · `docs/DESKTOP_SETUP.md` |
| A feature, bloc, repository, data source, model, form, service | [`architecture-rules.md`](architecture-rules.md) · `lib/features/features_overview.md` |
| A new feature from scratch | `docs/FEATURE_SPEC_TEMPLATE.md` (spec first), then `dart run tool/generate_feature.dart <name> --mock` |
| A page, route, redirect, deep link | `lib/core/router/router_guide.md` |
| Sign-in, tokens, guest mode, session expiry | `lib/core/services/session/session_service_guide.md` |
| Local storage, ObjectBox | `lib/core/services/objectbox/objectbox_service_guide.md` |
| Push or local notifications | `lib/core/notification/notification.md` |
| Any visible text | [`localization-rules.md`](localization-rules.md) |
| A reusable widget | `lib/common/common_folder_guide.md` (check it does not exist yet) |
| A helper, extension, constant | `lib/utils/utils_folder_guide.md` (check it does not exist yet) |
| Mock data (`USE_MOCK=true`) | `assets/mock/README.md` |
| Tests | `test/README.md` |
| Finding a file | `docs/PROJECT_MAP.md` |
| A command or `--dart-define` | `docs/COMMANDS.md` |
| Changing something established | `docs/DECISIONS.md` (why it is this way) |
| Cleanup before you finish | [`code-quality-rules.md`](code-quality-rules.md) |
| Release, CI, store setup | `docs/ANDROID_RELEASE_SETUP.md` · `docs/IOS_SETUP.md` · `docs/CODEMAGIC.md` · `docs/SHOREBIRD.md` |

## Stack

| Concern | What the project uses |
| --- | --- |
| State | `bloc` + `freezed`; one `BlocStatus<T>` per async operation; `StatusBuilder<T>` in the UI |
| DI | `get_it` + `injectable` (generated `injectable.config.dart`) |
| Routing | `go_router`, wrapped by `AppPage` / `AppNavigator.push` |
| Network | `dio`, one interceptor chain (mock → offline cache → memory → JWT refresh → locale → log → error) |
| Storage | `shared_preferences`, `flutter_secure_storage`, ObjectBox |
| Language | `easy_localization`, generated `AppStrings`; default Arabic |
| Forms | `reactive_forms` through `AppReactiveTextField` / `…DropdownField` / `…DateTimeField` |
| Layout | window size classes from `AppLayout` (compact · medium · expanded · large · extra-large) |
| Desktop | `window_manager`, custom title bar, `AppShortcuts`, single instance on Windows |
| Generated code | **committed**: `*.g.dart`, `*.freezed.dart`, `injectable.config.dart`, `lib/utils/gen/*` |

## Rules that fail reviews

**Text and language**
- Every visible string is a generated `AppStrings.x` constant, present in both `ar.json` and `en.json`.
- Every number shown goes through `AppFormats`; numeric inputs use `ArabicToEnglishDigitsFormatter`.
- Use start/end (`EdgeInsetsDirectional`, `AlignmentDirectional`), never left/right. Check Arabic (RTL) and English.

**Look**
- Type comes from the theme roles: `Theme.of(context).textTheme.titleMedium`, `copyWith(color: …)` for colour only.
  No inline `TextStyle(fontSize: …)`. `AppTextStyles.sXXwXXX` are legacy aliases for older shared widgets — not for new code.
- Colour comes from `Theme.of(context).colorScheme` or `context.semantic`. Never `Colors.*`, never a hex in a widget.
  Alpha with `.withValues(alpha: …)`, never `.withOpacity()`.
- Spacing, radii and icon sizes come from `AppSpacing`, `AppRadii`, `AppIconSizes`. Sizes are plain logical pixels;
  there is no `flutter_screenutil` (never `.sp .h .w .r`). Gaps: `AppSpacing.md.verticalSpace`.
- Icons are `AppIcons.*` drawn with `AppIcon` (Lucide SVG). Never `Icons.*` or an icon font.
- Content loading is a `SkeletonWidget` (`.success` / `.loading` over one layout), never a spinner.
  A spinner (`LoadingDots`, `MainLoadingProgress`) only means "an action is running".

**Layout and platform**
- Layout follows the **window size class**: `context.layout`, `AdaptiveLayout`, `AppLayoutScope.windowSizeOf`.
  Never `MediaQuery…width < 600`, an orientation check, a device type, or `Platform.isX` for layout.
- Platform **capabilities** go through `AppPlatform` (`supportsPush`, `supportsVibration`, `isDesktop`, `rendersFlagEmoji`, …).
  A plugin without code for a platform builds there and throws at run time, so guard every call into one.
- Never lock orientation. Every screen works in portrait, landscape and a resized window.
- Wide windows: cap content (`AppContentWidth`), never let a form field or a paragraph run the full width.
- Desktop users have a mouse and a keyboard: hover, tooltips on icon buttons, `AppFocusRing`, `AppShortcuts`.

**Components**
- Buttons are `AppButton`. **Grey means inactive, and only that.** Never use grey for a button that works:
  "Cancel", "Exit", "Close", "Reset" are `AppButton.error` (or `primary`). An unavailable button keeps its variant and
  gets `isActive: false` (or has no `onTap`) — it turns grey by itself. `AppButton.grey` is for always-inactive.
- A count on a tab or icon is `AppCountBadge` (a circle for one digit).
- Forms: `AppReactiveTextField` / dropdown / date-time, laid out with `AppFormFieldGrid`.
- Screens are built on `AppScaffold.body|appBar|search|all`; a hero or sliver page may use `Scaffold` directly.
  Every screen has `pagePath` and `pageName`.

**Architecture**
- Layers: Entity (domain) ← Mapper ← Model (data) ← DataSource; Repository returns `Result<T>`; Facade for orchestration.
  Models never reach the bloc or the UI. Every API call takes a `…Params` class (`data/params/`).
- Data sources wrap IO in `rethrowAsAppException`; repositories wrap in `runAsResult`.
- Bloc events and states are Freezed; the UI never switches on status enums by hand.
- Pages are `AppPage`s opened with `AppNavigator.push(context, AppPage.x, params: {…})`. `context.go` only replaces the
  whole stack (sign-out, the login wall). Ids travel in the path.
- Start-up work before `runApp` stays minimal (see `lib/lib_overview.md`).

**Process**
- Develop against mock data (`--dart-define=USE_MOCK=true`) until the API exists; new endpoints get fixtures.
- New behaviour gets tests; a new `.loading()` gets a parity line (`test/README.md`).
- Do not edit generated files; regenerate. Do not use `melos`, `flutter pub run`, or `build_runner watch`.
- Do not commit unless asked.
- Update the docs in the same task (below).

## Commands you will need

```bash
flutter pub get
dart run build_runner build                 # freezed, injectable, assets, ObjectBox
dart run tool/generate_app_strings.dart     # after editing assets/l10n/*.json
flutter analyze                             # must report: No issues found (it reads test/ and tool/ too)
flutter test                                # goldens included; --update-goldens after a deliberate visual change
flutter run --dart-define=USE_MOCK=true     # the whole app on mock data
```

Everything else: `docs/COMMANDS.md`.

## Keep the docs true

In the same task, update the matching document when you add or change a reusable widget (`lib/common/`), a helper,
extension or token (`lib/utils/`), a command, a dependency, a route, session/storage/localisation behaviour, or a
durable decision (`docs/DECISIONS.md`). A rule that is no longer true is worse than none: delete it.

## When documents disagree

Code that compiles and passes its tests wins over prose. Then, in order: this file → the other `.ai/` files → the
layer guide → `DESIGN_SYSTEM.md`. If you find a conflict, fix the prose in the same task.
