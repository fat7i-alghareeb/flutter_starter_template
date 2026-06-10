# 🌍 Global Library Overview (`lib/`)

## 🛑 AI AGENT MANDATE (READ BEFORE PROCEEDING)

This document is the **Mandatory First Entry Point** for any AI agent interacting with the Alsultan codebase. It serves as the "Map of the Galaxy" that connects all specialized technical encyclopedias.

- **Global Protocol**: [.ai/project-rules.md](.ai/project-rules.md)
- **Hierarchy Protocol**: [lib/features/features_overview.md](lib/features/features_overview.md)

Failure to synchronize your internal state with this map before proceeding to specialized layers is a protocol violation.

---

## 🚀 1. The Bootstrap Sequence (`lib/bootstrap.dart`)

The startup path is optimized for a fast first Flutter frame. AI agents modifying startup logic **MUST** keep blocking work before `runApp` minimal:

1. **Engine Binding**: `WidgetsFlutterBinding.ensureInitialized()` and `SystemUiMode.edgeToEdge`.
2. **Flavor Discovery**: Resolve `F.appFlavor` from the native environment.
3. **Dependency Injection**: `configureDependencies()` (GetIt/Injectable).
4. **Runtime Registration**: Register `AuthManager`, Dio, and stage-only tooling singletons without loading stored state.
5. **Localization Core**: `EasyLocalization.ensureInitialized()`.
6. **Startup Locale**: `LocaleService.resolveStartupLocale()` using device/fallback only, with no storage read.
7. **Guarded Run**: Launch `ScreenUtilInit` and the root `App`.
8. **Post-Frame Warmup**: After the first frame, reconcile saved locale and load stage tooling, theme, onboarding cache, and auth/session state.
9. **Post-Splash Notifications**: Initialize notifications after `SplashConfig.initialDelay` so permission prompts never appear before the custom splash duration finishes.

Do not add storage reads, Firebase, ObjectBox opens, permission prompts, network calls, asset precaching, or heavy parsing before `runApp` unless the first visible route cannot render correctly without it.

---

## 🏛️ 2. The Application Root (`lib/app.dart`)

The `App` widget is the root of the Flutter tree. It manages:

- **Feature code** isolated in `features/`.
- **Cross-cutting foundations** centralized in `core/`.
- **Reusable UI building blocks** in `common/`.
- **Shared helpers and extensions** in `utils/`.
- **Router Configuration**: Integration with `AppRouterConfig`.
- **Theme Management**: Reactive switching via `ThemeController`.
- **Global Overlays**: `StageToolsOverlay` and `AnnotatedRegion` for System UI.
- **Localization**: Passing delegates and active locale to `MaterialApp.router`.

---

## 🏗️ 3. Layered Encyclopedia Map

Every subdirectory in `lib/` has a dedicated specialized encyclopedia. You **MUST** read the relevant guide before touching any file in these directories:

### 🧩 [Utilities & Tokens](lib/utils/utils_folder_guide.md)

**Path**: `lib/utils/`
Contains constants, design tokens, extensions, and generated logic.

### 🎨 [UI & Styling](lib/ui_overview.md)

**Path**: `lib/core/theme/` | `lib/common/`
Contains the design system implementation, typography, and shared widgets.

### 🗺️ [Navigation & State](lib/core/router/router_guide.md)

**Path**: `lib/core/router/` | `lib/features/`
Contains the routing logic and feature-specific state management (Bloc).

### 📦 [Persistence & Services](lib/core/services/objectbox/objectbox_service_guide.md)

**Path**: `lib/core/services/`
Contains all infrastructure services (ObjectBox, Session, Auth, Notifications).

---

## 📜 4. Core Principles for AI Agents

- **No Inlining**: Logic belongs in services/blocs, small helpers in utils, and complex UI in sections.
- **Dependency Inversion**: Always use `getIt<T>()` or constructor injection for facades/services.
- **Data Integrity**: Never expose Models/DTOs to the UI. Always map to Entities.
- **Scaling Sovereignty**: All dimensions **MUST** use `.h`, `.w`, or `.sp` extensions.

---

_For architectural rules and protocol details, see [.ai/project-rules.md](.ai/project-rules.md)._
