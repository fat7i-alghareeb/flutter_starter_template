# 🗺️ Navigation & Router Guide (`lib/core/router/`)

## 🛑 AI AGENT MANDATE (READ BEFORE PROCEEDING)

This document is a **Hard Requirement** for any AI agent interacting with routes, navigation, or deep links. You **MUST** ensure your internal state is synced with the following navigation anchors:

- **Global Rules**: [.ai/project-rules.md](.ai/project-rules.md)
- **Feature Structure**: [lib/features/features_overview.md](lib/features/features_overview.md)

Failure to follow the Typed Navigation Protocol (using `Arguments` classes and `extra`) is a protocol violation.

---

The router is intentionally written so that **startup is driven by state**:

- **`AuthStateNotifier`** decides whether the user is authenticated/guest.
- **`OnboardingService`** decides whether onboarding is finished.
- **`SplashConfig.initialDelay`** enforces a minimum splash duration.

So the app does not manually navigate during startup; instead, routing reacts to state changes.

## Files in this folder

### `router_config.dart`

Owns the router instance and all redirect logic.

Key parts:

- **`RouterRefreshListenable`**
  - Purpose: provide _one_ `Listenable` for GoRouter to re-evaluate redirects.
  - It listens to:
    - `AuthStateNotifier`
    - `OnboardingService`

  - It starts `OnboardingService.initialize()` without awaiting it so storage loading happens outside the redirect path.
  - It also starts a timer that waits `SplashConfig.initialDelay` before allowing the app to leave splash.
  - Any change triggers `notifyListeners()`, which causes `GoRouter.redirect` to run again.

- **`AppRouterConfig`**
  - Purpose: composition root for routing.
  - Builds:
    - `RouterRefreshListenable`
    - `AppRouteGuard`
    - `GoRouter`

  - Sets `initialLocation` to `SplashScreen.pagePath`.

- **`AppRouteGuard`**
  - Purpose: keep _all_ redirect rules in a single focused class.
  - Exposes one method: `handleRedirect(...)`.
  - Internally uses:
    - `_handleSplash(...)`
    - `_handleOnboarding(...)`
    - `_handleAuth(...)`

### `app_routes.dart`

Central registry of app routes (`List<GoRoute>`). This is where you add/remove screens.

Responsibilities:

- Own route `path` and `name` constants (usually on the screen).
- Map each route to its screen widget.

### `app_page_transitions.dart`

Shared helper for consistent transitions between pages.

Responsibilities:

- Centralize animation duration/curve and reduce repeated `CustomTransitionPage` boilerplate.

## What triggers redirects (when does the guard run?)

`GoRouter.redirect` runs when:

- The current location changes.
- `RouterRefreshListenable` calls `notifyListeners()`.

`RouterRefreshListenable` notifies when:

- `AuthStateNotifier` changes (login, logout, token refresh, guest mode).
- `OnboardingService` changes (onboarding finished flag changes).
- The splash delay timer finishes.

## Startup flow (from first frame to the final screen)

This is the exact order enforced by `AppRouteGuard.handleRedirect`.

### Step 0: App starts on Splash

- Router starts at `SplashScreen.pagePath`.
- At this moment, one (or both) may still be _unresolved_:
  - **Auth**: `AuthStateNotifier.authStatus.status` can still be `Status.initial`.
  - **Onboarding**: `OnboardingService.initialize()` may still be loading the cached flag.

Additionally:

- `RouterRefreshListenable` starts the `SplashConfig.initialDelay` timer.

### Step 1: Splash guard (minimum splash + initial auth status)

Guard logic (simplified):

- If `splashDelayElapsed == false` **OR** `authStatus.status == Status.initial`:
  - Stay on splash (or redirect back to splash if you tried to navigate away).

What this means:

- Even if auth/onboarding resolve instantly, the splash remains visible for at least `SplashConfig.initialDelay`.
- If the app is still bootstrapping session state, splash stays until `AuthStateNotifier` moves out of `Status.initial`.

### Step 2: Onboarding guard (only if enabled)

After splash conditions are satisfied, the guard checks onboarding:

- If `AppFlowConfig.onboardingEnabled == false`:
  - Skip onboarding completely.

- Else, it reads the synchronous cached value from `OnboardingService`.
  - If onboarding cache is not initialized yet:
    - Stay on `SplashScreen.pagePath`.
    - The service notifies the router when the value is loaded.

  - If onboarding is **not finished**:
    - Redirect to `OnboardingScreen.pagePath`.
    - While the user is on onboarding and it is still not finished, the guard allows staying there and does not run auth redirects yet.

  - If onboarding is **finished**:
    - Continue to the auth step.

Transition point:

- When onboarding is completed, the service notifies listeners → `RouterRefreshListenable` notifies → redirect re-runs.

### Step 3: Auth guard (only if enabled)

After onboarding (or if onboarding is disabled), the guard checks auth:

- If `AppFlowConfig.authEnabled == false`:
  - Always redirect to `RootScreen.pagePath`.

- Else, compute authenticated state:
  - `isAuthenticated = (authStatus.status == Status.authenticated) && !authState.isGuest`

Then:

- If **not authenticated**:
  - Redirect to `LoginScreen.pagePath`.

- If **authenticated**:
  - If you are currently on splash/login/onboarding, redirect to `RootScreen.pagePath`.
  - Otherwise, allow the current route.

## Common scenarios (what happens in real life)

### Fresh install (onboarding enabled)

1. Start on Splash.
2. Wait for splash delay + auth status resolves.
3. Onboarding not finished → go to Onboarding.
4. User completes onboarding → redirect re-runs.
5. Auth enabled → unauthenticated → go to Login.

### Returning user (onboarding finished, already logged in)

1. Start on Splash.
2. Wait for splash delay + auth status resolves to authenticated.
3. Onboarding finished → proceed.
4. Authenticated → go to Root.

### Token expired (JWT mode)

1. Requests may return 401 or token may be near expiry.
2. `DioClient` refresh flow attempts refresh.
3. If refresh succeeds → status stays authenticated.
4. If refresh fails/revoked → `AuthManager.logout()` → notifier updates → redirect runs → user sent to Login.

## How to add a new route

1. Add a new screen with `static const pagePath` and `static const pageName`.
2. Register it in `AppRouteRegistry.routes`.
3. If the route needs protection/redirect rules, update `AppRouteGuard`.
