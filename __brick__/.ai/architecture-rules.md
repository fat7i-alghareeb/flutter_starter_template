# Architecture rules

Read this when you touch a feature, a bloc, a repository, a data source, a model, a form, routing, a service,
storage, or session behaviour. Deeper guides: `lib/features/features_overview.md`, `lib/core/core_architecture_overview.md`.

## Where a thing goes

| It is… | It goes in |
| --- | --- |
| Behaviour of one product area | `lib/features/<name>/` |
| Used by two or more features: a widget | `lib/common/widgets/` (`ds/` for design-system primitives) |
| Used by two or more features: a helper, extension, constant | `lib/utils/` |
| Infrastructure with no product meaning: config, DI, network, router, theme, layout, platform, window, shortcuts, notifications, services | `lib/core/` |
| A visible string | `assets/l10n/ar.json` + `en.json`, read as `AppStrings.x` |
| A fixture for mock mode | `assets/mock/<feature>/` |

`core/` is feature-agnostic. Only three places in it know the features, because they wire them together: the router
(`router_config.dart`, `app_routes.dart`), the generated `injectable.config.dart`, and `mock_config.dart` (`MockRoutes`).
A feature never imports another feature — share through `core/`, `common/`, or a domain entity both can reach.

## Feature structure

`dart run tool/generate_feature.dart <name> --mock` creates this; `lib/features/auth/` is the full example.

```text
lib/features/<name>/
├── constants/            # route constants, forms/ (FormGroup definitions + static field keys)
├── data/
│   ├── datasources/      # IO only: remote / local
│   ├── models/           # DTOs: fromJson / toJson
│   ├── mappers/          # Model → Entity
│   ├── params/           # one `…Params` class per API call (e.g. SignInParams)
│   └── repositories/     # implementations
├── domain/
│   ├── entities/         # pure objects, no JSON
│   ├── repositories/     # contracts
│   └── facade/           # orchestration used by the bloc
└── presentation/
    ├── states/           # bloc, event, state (Freezed)
    └── ui/{screens,widgets}/
```

`features/showcase_feed/` is the **behaviour** reference (lazy sections, paging, search, detail page, skeletons, mock
data, tests). It keeps each layer in one file for readability — copy how it behaves, not how it is laid out.

## Layers

- **Entity** — what the app means. No JSON annotations, no API field names.
- **Model** — what the API sends. `fromJson` / `toJson` only. Never imported by a bloc or a widget.
- **Mapper** — `Model → Entity` (`toEntity()` or a mapper class). The only place the two meet.
- **Params** — the typed input of one API call. No raw maps, no loose primitives scattered through calls.
- **DataSource** — performs IO and wraps it: `rethrowAsAppException(() async { … })`. No presentation logic.
- **Repository** — domain-facing contract returning `Result<T>`; wraps each operation in `runAsResult(() async { … })`.
- **Facade** — combines repository calls into one business result for the bloc.

## State

- `bloc` + `freezed`. Events take typed entities or params classes, not maps.
- One `BlocStatus<T>` field per meaningful async operation (`listState`, `loadMoreState`, `saveState`) — one shared status
  puts a sign-out spinner on the sign-in button.
- The UI renders status through `StatusBuilder<T>`, never by switching on the status by hand.
- A bloc is `@injectable` (a factory). Provide it with `BlocProvider(create: (_) => getIt<X>())`. Never ask `getIt` for a
  factory inside `build` — each rebuild would get a new bloc. Use `.value` only for one you own and keep alive.
- A bloc used by several screens (the sign-in bloc) is provided once, above `MaterialApp` (see `lib/app.dart`).

## Forms

- Field keys are constants, never raw strings repeated in widgets or blocs. A form used by more than one file lives in
  `constants/forms/` as an `abstract class` with static keys and a static factory; a form owned by one screen may keep
  private constants in that file (`login_screen.dart` does).
- Read values with `formGroup.valueOf<T>(key)` where available. Validate on the device before anything is sent.

## Routing

- Every screen has `pagePath` and `pageName` and is an `AppPage` (`lib/core/router/app_routes.dart`).
  Pushed pages use a **relative** `pagePath` (`'settings'`, `'items/:id'`); only top-level routes are absolute.
- Open pages with `AppNavigator.push(context, AppPage.x, params: {'id': id})`; without a context,
  `AppNavigator.pushTarget(router, AppTarget(...))`. Pages nest under the page that opens them, and back pops one.
- Ids travel in the path so a deep link or a restored stack works. Use `extra` only for data a page cannot re-read by id,
  as a typed arguments class cast explicitly.
- `context.go` replaces the whole stack — only for sign-out and the login wall.
- Read `lib/core/router/router_guide.md` before changing a guard, a redirect, splash, onboarding or links.

## Services and DI

- Cross-cutting services live in `lib/core/services/` and are injected (constructor injection, `@injectable`,
  `@lazySingleton`). No ad-hoc service locators outside the existing GetIt setup.
- Session and tokens: `lib/core/services/session/session_service_guide.md`. ObjectBox and local persistence:
  `lib/core/services/objectbox/objectbox_service_guide.md`. Notifications: `lib/core/notification/notification.md`.
- A platform-only plugin is called through a capability (`AppPlatform`) or a DI service (`HapticsService`,
  `LinkDispatcher`), never directly from a widget.

## The shell, window and platform

- `RootScreen` owns navigation: the capsule (`AppBottomNav`) on a compact window, the 80dp rail (`AppSideNav`,
  not extended) on a medium one or a phone on its side, the 256dp sidebar (`AppSideNav`, extended) on an expanded one.
  A tab never draws its own navigation.
- Layout reads `AppLayout` (`core/layout/`); the desktop window, title bar and shortcuts are `core/window/` and
  `core/shortcuts/`; platform capabilities are `core/platform/app_platform.dart`. Details: `docs/RESPONSIVE.md`,
  `docs/DESKTOP_SETUP.md`.

## Start-up

Keep work before `runApp` minimal: bindings, DI registration, the saved theme and language (each within a 250 ms budget),
and on desktop the window set-up. Storage reads for onboarding and session, notifications, Firebase and ObjectBox opens
run after the first frame. See `lib/lib_overview.md`.
