# Session Service (core/services/session)

This folder owns *session state* for the entire app.

The most important design rule is:

- **Domain/data layer changes the session through `AuthManager`.**
- **UI and Router observe session changes through `AuthStateNotifier`.**

This keeps storage, JWT refresh, and auth status transitions centralized and consistent.

## Files in this folder (what each file does)

### `auth_manager.dart`

`AuthManager` is the *imperative API* for changing session.

It coordinates:

- Persisting user/guest flag via `StorageService`
- Updating the reactive state in `AuthStateNotifier`
- (JWT mode) writing/deleting tokens through `JwtTokenStorage`
- (JWT mode) listening to token status updates and forwarding them into `AuthStateNotifier`

Key points:

- It supports two modes:

  - `AuthMode.withJwt`: token storage + refresh flow is active.
  - `AuthMode.withoutJwt`: no token storage; `AuthStatus` must be computed and set manually.

- During `initialize()`:

  - Loads persisted user + guest flag.
  - Ensures `AuthStateNotifier.authStatus` is not stuck on `Status.initial`.
  - (JWT mode) initializes token storage and subscribes to `authenticationStatus`.
  - (JWT mode) may log token expiry/remaining time for debugging purposes.

- During `login(...)`:

  - Persists user.
  - Clears guest.
  - Updates router-facing status: `AuthStatus.authenticated()`.
  - (JWT mode) persists token into secure storage.

- During `logout()`:

  - Clears persisted user + guest.
  - Sets status to `AuthStatus.unauthenticated(message: ...)`.
  - (JWT mode) deletes token and emits unauthenticated through dio_refresh_bot.

#### How it should be used in your architecture

- Preferred: call it from **repository/facade** after a successful domain action.

  - Example (current project style):

    - `AuthBloc` triggers a login use case.
    - Repository maps response to `UserEntity` + `AuthTokenModel`.
    - Repository calls `AuthManager.login(...)`.

- Avoid: calling it directly from UI widgets, except for very small apps or prototype screens.

### `auth_state_notifier.dart`

`AuthStateNotifier` is the app-wide reactive *source of truth* for UI and routing.

It holds:

- `UserEntity? user`
- `bool isGuest`
- `AuthStatus authStatus` (from `dio_refresh_bot`)

It also exposes derived helpers:

- `isAuthenticated` (authenticated and not guest)
- `isUnauthenticated` (unauthenticated and not guest)

#### What uses it right now

- Router (`GoRouter.refreshListenable`) uses it to re-run redirects.
- Any widget can read it to decide:

  - show/hide authenticated UI
  - show guest-specific UI
  - show login-required prompts

#### Important rule

- You typically do **not** set it directly from UI.
- `AuthManager` is the owner that mutates it.

### `auth_token_model.dart`

Your concrete token type.

- It extends `AuthToken` from `dio_refresh_bot`.
- That allows `RefreshTokenInterceptor<AuthTokenModel>` to read:

  - `accessToken`
  - `refreshToken`
  - `expiresIn`

This file is intentionally small: it’s a compatibility bridge between API/storage and the refresh library.

### `jwt_token_storage.dart`

`JwtTokenStorage` is the bridge between:

- **Secure persistence** (via `StorageService`)
- **In-memory token cache** (via `BotMemoryTokenStorage`)
- **Auth status stream** (via `RefreshBotMixin`)

What it does:

- `initialize()` loads token JSON from secure storage and seeds the in-memory token.
- If a stored token is expired, it is intentionally kept in memory so the refresh interceptor can attempt a refresh on the first protected call (401) instead of forcing an immediate logout on app start.
- `write(token)` persists token + a derived expiry timestamp.
- `delete(reason)` clears secure storage and updates the dio_refresh_bot status stream.

Why it exists:

- `dio_refresh_bot` needs a token storage that it can query synchronously and also observe status changes from.
- The app needs persistence across restarts.

## How the session is used today (current flow)

### App startup

1. DI is configured.
2. The correct `AuthManager` variant is registered depending on `AuthMode`.
3. `AuthManager.initialize()` runs:

   - Loads user/guest from `StorageService`.
   - Ensures status is not `Status.initial`.
   - (JWT mode) restores token in `JwtTokenStorage` and begins streaming `AuthStatus`.

4. Router starts on splash and then decides the next route based on:

   - `AuthStateNotifier.authStatus.status`
   - `AuthStateNotifier.isGuest`
   - onboarding state

### Login

The intended responsibility split is:

- UI triggers the domain action (Bloc/event).
- Repository performs mapping.
- Repository calls `AuthManager.login(...)`.

Result:

- `AuthStateNotifier` updates.
- Router refresh listenable notifies.
- Guard redirects to root.

## How `dio_client.dart` fits in (JWT refresh + logout)

File: `lib/core/network/dio_client.dart`

This file builds the app’s global `Dio` instance.

### What it uses

- Session files:

  - `AuthManager`
  - `AuthTokenModel`
  - `JwtTokenStorage`

- Network config:

  - `ApiConfig.baseUrl`
  - `ApiEndpoints.refreshToken`
  - Interceptors: `LocalizationInterceptor`, `CustomDioInterceptor`, `ErrorInterceptor`, `MemoryAwareInterceptor`

- JWT utilities:

  - `isTokenAboutToExpire(...)` from `jwt_token_utils.dart`

### What happens in JWT mode

When `createDioClient(mode: AuthMode.withJwt, ...)` is used:

1. `_configureJwtFlow(...)` installs `RefreshTokenInterceptor<AuthTokenModel>`.
2. For every request, the interceptor attaches:

   - `Authorization: Bearer <accessToken>` via `tokenHeaderBuilder`.

3. Before/after responses, `TokenProtocol.shouldRefresh` decides whether to refresh:

   - Refresh if token is about to expire OR if the response is `401`.
   - Do not refresh if the user is not authenticated or token is missing.

4. If refresh is needed, `refreshToken(...)` executes:

   - Uses a dedicated `tokenDio` to avoid recursive interceptors.
   - Calls `ApiEndpoints.refreshToken`.
   - Builds a new `AuthTokenModel`.
   - Writes it into `JwtTokenStorage`.

5. If refresh fails (or refresh token is revoked):

   - `authManager.logout()` is called.
   - That updates `AuthStateNotifier`.
   - Router is notified and redirects the user to Login.

This is the key connection:

- **`DioClient` logs you out by calling `AuthManager.logout()`**, which triggers router redirection via the notifier.

## UI usage guidelines (domain vs UI)

### What should be domain-only

- `AuthManager` should be treated as a *domain service*.

It performs side effects:

- storage writes/deletes
- token persistence
- session status transitions

So its ideal call sites are:

- repositories
- facades
- use cases

### What is UI-facing

- `AuthStateNotifier` is UI-facing.

UI can:

- read it to decide what to show
- listen to it to rebuild on session changes

### How a widget listens to `AuthStateNotifier`

You already have a `ChangeNotifier` (`AuthStateNotifier`). The simplest built-in Flutter pattern is `AnimatedBuilder`.

Example:

```dart
class SessionAwareHeader extends StatelessWidget {
  const SessionAwareHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthStateNotifier>();

    return AnimatedBuilder(
      animation: authState,
      builder: (context, _) {
        if (authState.isAuthenticated) {
          return Text('Hello ${authState.user?.name ?? ''}');
        }
        if (authState.isGuest) {
          return const Text('Hello Guest');
        }
        return const Text('Not signed in');
      },
    );
  }
}
```

Notes:

- This avoids manual `addListener/removeListener`.
- It rebuilds only this widget subtree when session changes.

#### Option 2: `ListenableBuilder` (built-in Flutter)

If you prefer a widget named specifically for listenables, Flutter also provides `ListenableBuilder`.

Example:

```dart
class SessionAwareHeader extends StatelessWidget {
  const SessionAwareHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthStateNotifier>();

    return ListenableBuilder(
      listenable: authState,
      builder: (context, _) {
        if (authState.isAuthenticated) {
          return Text('Hello ${authState.user?.name ?? ''}');
        }
        if (authState.isGuest) {
          return const Text('Hello Guest');
        }
        return const Text('Not signed in');
      },
    );
  }
}
```

#### Option 3: `Consumer` / `context.watch()` (Provider package)

If your project uses `provider`, you can expose the same singleton `AuthStateNotifier` to the widget tree and rebuild widgets using `Consumer` or `context.watch()`.

Important:

- This requires adding `provider` to `pubspec.yaml`.
- You should still treat `AuthManager` as domain-only; UI should only observe `AuthStateNotifier`.

Example (provide it above a subtree):

```dart
return ChangeNotifierProvider<AuthStateNotifier>.value(
  value: getIt<AuthStateNotifier>(),
  child: const MySubTree(),
);
```

Example (`Consumer`):

```dart
class SessionAwareHeader extends StatelessWidget {
  const SessionAwareHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateNotifier>(
      builder: (context, authState, _) {
        if (authState.isAuthenticated) {
          return Text('Hello ${authState.user?.name ?? ''}');
        }
        if (authState.isGuest) {
          return const Text('Hello Guest');
        }
        return const Text('Not signed in');
      },
    );
  }
}
```

Example (`context.watch()`):

```dart
final authState = context.watch<AuthStateNotifier>();
```

## Extending these files for “other things”

Common extensions that keep the architecture clean:

- Add additional derived getters in `AuthStateNotifier` (pure computations only).
- Add new session actions in `AuthManager` (side effects + notifier update), e.g.:

  - `refreshCurrentUserProfile()` (fetch + update user)
  - `invalidateSession(reason)` (central logout reasons)

- Add more token metadata to `AuthTokenModel` if your backend needs it.
- Add multi-client support in `dio_client.dart` (public vs authed Dio) while still sharing the same `JwtTokenStorage`.
