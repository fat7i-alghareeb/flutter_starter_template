# `lib/` overview

The map of the app's code: how it starts, what the root widget wires together, and which guide to read for each folder.
Rules are in `.ai/project-rules.md`; the file-by-file map is `docs/PROJECT_MAP.md`.

## Folders

| Folder | Holds | Guide |
| --- | --- | --- |
| `bootstrap.dart`, `app.dart`, `main.dart` | Start-up and the root widget | this file |
| `core/` | Infrastructure: config, DI, network, router, theme, layout, platform, window, shortcuts, notifications, services | `core/core_architecture_overview.md` |
| `common/` | Shared widgets and the `imports.dart` barrel | `common/common_folder_guide.md`, `ui_overview.md` |
| `utils/` | Constants, extensions, helpers, generated code | `utils/utils_folder_guide.md` |
| `features/` | Product features | `features/features_overview.md` |

## Start-up (`bootstrap.dart`)

`bootstrap()` runs everything inside one guarded zone (`runZonedGuarded`), in this order:

1. `WidgetsFlutterBinding.ensureInitialized()`, edge-to-edge system UI.
2. `configureDependencies()` — GetIt / Injectable registration only; no stored state is read.
3. **Desktop only**: `_ensureSingleInstance(args)` (a second Windows launch focuses the first and exits), `AppWindow.initialize()`
   (size limits, hidden title bar, saved bounds — the window stays **hidden**), `DesktopLinks.initialize()`.
4. `LinkDispatcher` is added as a binding observer **before** the router exists, so links from outside reach it first.
5. Stage tools are registered when `AppConfig.stageToolsEnabled` (`--dart-define=STAGE_TOOLS=true`).
6. `EasyLocalization.ensureInitialized()`, then the **saved language** and the **saved theme** are read, each within a 250 ms
   budget. They are part of the first frame being correct: restored after it, a dark-mode reader would see a light splash fade
   to dark, and a language switch could race `easy_localization`'s own load.
7. `runApp(App)` inside `EasyLocalization`; then `AppWindow.showWhenReady()` shows the desktop window once its first frame is
   on screen.
8. After the first frame (`_startPostLaunchWarmup`): stage tools, the onboarding flag, session restore (`AuthStateNotifier`
   leaves `Status.initial`), the first-tab preload (`BlocPreloader`), and — after `SplashConfig.initialDelay` — notifications.
   `SplashConfig.initialDelay` is zero on desktop (the window already waited for its first frame).

**Do not** add storage reads, Firebase, ObjectBox opens, permission prompts, network calls, asset precaching or heavy parsing
before `runApp`, unless the first visible route cannot render without it. A permission prompt never goes behind the splash:
`RootScreen` asks once the reader is in the app.

## The root widget (`app.dart`)

`App` builds, from the outside in:

- `BlocProvider<AuthBloc>` — above `MaterialApp` on purpose, so a sign-in started in the protected-action sheet is seen by the
  screen under it.
- `MaterialApp.router` with the light and dark themes, `ThemeController`, the saved locale, `AppScrollBehavior`, and `routerConfig`.
- In `builder`: `AnnotatedRegion` (system UI colours) → `AppTextScaleHost` (the reader's text size, 85–130%, plus a step in
  large windows) → `AppLayoutHost` (the window size class for each frame) → `AdaptiveTypography` → `RebuildOnLocaleChange` →
  `AppMenuBar` / `AppShortcuts` → `AppDesktopFrame` (the custom title bar, desktop only) → the offline banner, the session banner
  (guest-first), and `StageToolsOverlay` when compiled in.

## Principles

- **Logic stays out of widgets.** Services and blocs hold logic, `utils/` holds small helpers, complex UI is split into sections.
- **Inject, do not construct.** `getIt<T>()` or constructor injection for services, facades and blocs.
- **Models stay in the data layer.** The UI sees entities.
- **Layout follows the window size class** (`context.layout`, `AdaptiveLayout`), never a device type or an orientation. Platform
  capabilities go through `AppPlatform`. See `docs/RESPONSIVE.md`.
