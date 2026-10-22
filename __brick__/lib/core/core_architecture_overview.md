# `core/` overview

`core/` is the foundation: infrastructure that no single feature owns. Keep it feature-agnostic — if code only makes sense for
one product area, it belongs in `features/`. Three places wire the features together and may name them: the router
(`router/router_config.dart`, `app_routes.dart`), the generated `injection/injectable.config.dart`, and
`config/mock_config.dart` (`MockRoutes`).

Rules: `.ai/architecture-rules.md`. File map: `docs/PROJECT_MAP.md`.

## What is in it

| Folder | Responsibility | Read |
| --- | --- | --- |
| `config/` | `AppConfig` (title, stage tools, desktop ids, Windows toast GUID), `AppLocalizationConfig` (Arabic default), `MockConfig` / `MockRoutes` | — |
| `layout/` | The window size class for every frame: `AppLayout`, `AppLayoutHost`, `AppLayoutScope`, `AdaptiveLayout`, `LayoutReader`; text scale (`AppTextScale`, `AppTextScaleHost`); scroll behaviour | `docs/RESPONSIVE.md` |
| `platform/` | `AppPlatform`: what the platform can do | `docs/RESPONSIVE.md` |
| `window/` | Desktop window: `AppWindow` (limits, saved bounds, hidden until the first frame), `AppDesktopFrame` + the title bar | `docs/DESKTOP_SETUP.md` |
| `shortcuts/` | `AppShortcuts`, `AppCommands`, the shortcut list, the macOS menu bar | `docs/RESPONSIVE.md` |
| `router/` | `GoRouter` config and guard, `AppPage` tree, `AppNavigator`, `AppLinks` + `LinkDispatcher`, `DesktopLinks`, transitions | `router/router_guide.md` |
| `network/` | `DioClient`, `ApiConfig`, `ApiEndpoints`, interceptors, offline response cache | below |
| `notification/` | Local and push notifications | `notification/notification.md` |
| `services/` | `storage/`, `session/`, `onboarding/`, `localization/`, `objectbox/`, `memory/`, `haptics/`, `startup/` | `session/…_guide.md`, `objectbox/…_guide.md` |
| `theme/` | Palette, colour schemes, typography, effects, `ThemeController`, system UI | `DESIGN_SYSTEM.md` |
| `injection/` | GetIt + Injectable | — |
| `error/` | `AppException`, `runAsResult`, `rethrowAsAppException` | `.ai/architecture-rules.md` |
| `utils/` | `Result<T>`, `BlocStatus<T>`, `StatusBuilder<T>` | `features/features_overview.md` |
| `domain/` | Entities shared by features (`UserEntity`) | — |

## Theme and type

- The palette is one file: `theme/app_colors.dart`. Every value feeds `AppColorSchemes` (`app_theme_colors.dart`) or
  `AppSemanticColors`; widgets read `Theme.of(context).colorScheme` or `context.semantic`, never the palette class.
  Contrast is asserted in `test/core/theme/app_theme_test.dart` — keep it green when you change a colour.
- Type is the theme's text roles (`app_typography.dart`, table in `DESIGN_SYSTEM.md` §2). Widgets take a role and change only the
  colour. `AppTextStyles.sXXwXXX` (`app_text_styles.dart`) are aliases for the older shared widgets; they carry no colour.
- Sizes are plain logical pixels. Nothing is scaled by screen width.

## Text size

- The reader's own text size is applied by `AppTextScaleHost` in `App`, kept between **85% and 130%** (`AppTextScale`), then
  multiplied by a window step: ×1.05 expanded, ×1.10 large, ×1.15 extra-large, nothing below 840dp. A box that holds text must
  not have a fixed height.
- Headings step up one size from 840dp (`AppTypography.expandedFrom`, applied by `AdaptiveTypography`); content is capped in width
  instead of growing (`AppLayout.contentMaxWidth`).
- Touch targets are at least 44dp (48 in navigation) on every device.

## Network

`DioClient` builds one Dio with, in order: the **mock** interceptor (`USE_MOCK=true` answers from `assets/mock/` — repositories,
parsing and paging run unchanged), the **offline cache**, the **memory** interceptor, then JWT refresh, localisation (sends the
language), logging and **error** mapping. A request fails as an `AppException`; the data source rethrows it with
`rethrowAsAppException`, the repository turns it into a `Result` with `runAsResult`.

## Dependency injection

`injectable` annotations generate `injection/injectable.config.dart` (committed). Blocs are factories, services are
`@lazySingleton`. A thing created by hand (stage tools) is registered in `bootstrap.dart`. `getIt.isRegistered<T>()` guards optional
services in tests.

## When you add something here

- A new service: `services/<name>/`, injected, with a guide if it has rules.
- A platform-only capability: a getter on `AppPlatform` and a DI service behind it; never a bare plugin call from a widget.
- Something several features need but that has UI: `lib/common/`, not `core/`.
