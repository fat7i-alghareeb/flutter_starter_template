# Performance Audit

This audit records the startup, routing, memory, and frame-rate review for the Flutter starter template.

## Scope

- Audited the full `__brick__` inventory: 187 files excluding cache/build folders such as `.dart_tool/` and `build/`.
- Read the startup-critical path in full: `main.dart`, `bootstrap.dart`, `app.dart`, DI setup, router, splash, onboarding, auth/session, storage, notifications, localization, theme, and root shell.
- Searched the complete brick for performance hotspots: awaits before `runApp`, timers, Firebase, notifications, ObjectBox, storage, secure storage, image loading, list builders, progress loaders, print/log calls, and route constants.
- Generated files such as `*.freezed.dart`, `objectbox.g.dart`, and lockfiles were checked for integration/runtime impact and left generated.

## Inventory Coverage

- Startup/config: `pubspec.yaml`, `analysis_options.yaml`, `core/config/app_config.dart`, native splash/icons config, `main.dart`, `bootstrap.dart`, `app.dart`.
- Agent/docs: `.ai/`, `docs/`, folder guides, architecture guides.
- Assets/config-only: localization JSON, SVG/icon/image placeholders.
- Core startup/runtime: config, injection, router, storage, localization, session/auth, theme, error handling, network, notifications, ObjectBox, memory services.
- Common UI/runtime: scaffold, buttons, forms, dialogs, sheets, loaders, image widgets, stage tools.
- Feature runtime: auth, splash, onboarding, root showcase, navigation, generated state files.
- Generated/codegen: `injectable.config.dart`, `*.freezed.dart`, `objectbox.g.dart`, FlutterGen outputs, lockfile.
- Tools: app string generator and feature generator.

## Fixed Breakpoints

### 1. DI used async storage pre-resolve before `runApp`

`StorageService` previously depended on a legacy shared-preferences singleton load through an async Injectable pre-resolve provider. That forced storage plugin work during DI before the custom Flutter splash could render.

Current behavior:

- `StorageService.createDefault()` is synchronous.
- Persistent storage uses `SharedPreferencesAsync`, so the service object can be injected immediately.
- Read/write APIs remain async, and callers still await the actual storage operation.
- Injectable now registers `StorageService` as a normal lazy singleton, not as an async pre-resolved factory.

### 2. Startup was doing too much before the first Flutter frame

Before the refactor, startup awaited notification initialization, theme restore, auth/session restore, and saved locale storage before `runApp`.

Current behavior:

- `configureDependencies()` registers the graph without storage pre-resolve.
- Runtime auth/network services are registered before the app, but persisted auth restore runs after the first frame.
- Theme, onboarding, auth restore, stage preview load, saved locale reconciliation, and notifications warm after the first frame.
- If auth restore fails, `AuthStateNotifier` is forced to unauthenticated so the router cannot stay stuck on splash.

### 3. Notification permission could appear before the custom splash

Notification initialization used to run before the app was shown. Permission requests can trigger platform UI, so that could interrupt startup before the custom splash screen.

Current behavior:

- Notifications initialize after the first frame and after `SplashConfig.initialDelay`.
- The permission prompt is delayed until after the splash duration.
- FCM remains disabled by default through `NotificationInitOptions(enableFcm: false)`.

### 4. Onboarding redirects depended on async storage during routing

`GoRouter.redirect` should be fast and deterministic. Awaiting onboarding storage from the redirect path can create fragile fresh-clone behavior and repeated redirect work.

Current behavior:

- `OnboardingService.initialize()` loads storage once and caches the result.
- The router uses synchronous cached state.
- While onboarding state is still loading, the guard stays on splash instead of producing a wrong route.
- Concurrent startup reads share one initialization future.

### 5. Route paths were noisy and one notification payload path was stale

Template paths like `/onboarding_screen` and hardcoded notification routes like `/root_screen` are easy to mistype after cloning or renaming.

Current behavior:

- Splash: `/splash`
- Onboarding: `/onboarding`
- Login: `/login`
- Root: `/root`
- Root notification payload examples use `RootConstants.routePath`.

No malicious router behavior was found. The issue was route fragility: async onboarding lookup inside redirects plus stale/hardcoded path strings.

### 6. Repeated platform calls added runtime cost

Several runtime paths could ask plugins/platform APIs repeatedly.

Current behavior:

- `LocaleService` caches the current language after startup or user changes.
- `LocalizationInterceptor` caches the device timezone after the first lookup.
- `AppButton` caches whether the device has a vibrator.

### 7. Network and image defaults fought caching

The memory interceptor forced `Connection: close` and `Cache-Control: no-cache`, and inspected large responses through `response.data.toString()`.

Current behavior:

- The interceptor no longer disables HTTP caching/connection reuse globally.
- It still rejects responses when `content-length` is known and over the configured limit.
- Full-screen network image previews use `CachedNetworkImage`.

### 8. Hot-path system UI side effect

`SystemChrome.setSystemUIOverlayStyle` was called from `MaterialApp.builder`, which can run often during rebuilds.

Current behavior:

- `AnnotatedRegion<SystemUiOverlayStyle>` carries the overlay style.
- The builder no longer performs a platform side effect on each rebuild.

### 9. ScreenUtil added an async gate before rendering children

`ScreenUtilInit(ensureScreenSize: true)` uses an async validation path and can briefly return an empty widget before children are built.

Current behavior:

- `ensureScreenSize` is no longer enabled.
- Screen metrics are configured from available `MediaQueryData` during build, so the app tree can appear sooner.

## Intentional Runtime Cost

- The root feature keeps the showcase tabs by design. They are useful for verifying the template and demonstrating components, but production teams should delete the showcase when it is no longer needed.
- Showcase pages are built through `PageView.builder` to avoid constructing every showcase page eagerly.
- ObjectBox, Firebase/FCM, notifications, and device preview remain available, but they are lazy and do not initialize unless explicitly used.

## Remaining Watchpoints

- `EasyLocalization.ensureInitialized()` still runs before `runApp` because localization assets must exist before the app tree is wrapped.
- Saved locale/theme are applied after the first frame. This favors launch speed and may cause one post-splash correction if the persisted setting differs from the device/fallback value.
- ObjectBox dependencies and generated files are present, but ObjectBox is not opened during startup unless a feature explicitly asks for `ObjectBoxService`.
- `debugPrint` appears in debug-only helpers/assert paths. Keep production features on `printC/printG/printY` and localized `AppStrings`.
- Large images should keep using generated `Assets`, `CachedNetworkImage`, and explicit dimensions. Avoid decoding full-resolution images into small UI slots.

## Startup Contract

Keep this order when editing startup code:

1. Initialize Flutter binding and system UI.
2. Configure DI and register runtime singletons.
3. Initialize localization core.
4. Resolve first-frame locale synchronously from device/fallback.
5. Call `runApp`.
6. After the first frame, reconcile saved locale and warm non-critical services.
7. Ask notification permission only after the splash duration or after a user action.

Do not add storage reads, Firebase, ObjectBox, network calls, permission requests, asset precaching, or heavy JSON parsing before `runApp` unless the app cannot render a correct first screen without it.
