# Session and auth guide (`lib/core/services/session/`)

Read this before you change sign-in, tokens, token refresh, logout, guest mode, session expiry, or anything that reads
"is the user signed in". Constants: `lib/utils/constants/auth_constants.dart`. Routing consequences: `lib/core/router/router_guide.md`.

## The one rule

- **Change the session through `AuthManager`** (from a repository or facade, after a successful domain action).
- **Observe it through `AuthStateNotifier`** (from widgets and the router).

Storage, JWT refresh and status transitions stay in one place, and no widget mutates the session.

## The files

### `auth_manager.dart` — `AuthManager` (imperative API; a domain service)

| Method | What it does |
| --- | --- |
| `initialize()` | After the first frame: loads the stored user and guest flag, moves `authStatus` out of `Status.initial`, restores the token in `JwtTokenStorage`, subscribes to `authenticationStatus`. Never blocks `runApp` |
| `login(user: …, token: …)` | Persists the user, clears the guest flag, sets `AuthStatus.authenticated()`, stores the token in secure storage, clears `sessionExpired` |
| `logout()` | The reader asked to leave. Clears the user and tokens (see "after the session ends" below) |
| `expireSession()` | The session ended without the reader asking (refresh failed, token revoked). Same cleanup, then sets `sessionExpired` so the UI can explain. Does nothing if nobody is signed in, so a second call is harmless |
| `continueAsGuest()` | Clears the user, sets the guest flag and `AuthStatus.unauthenticated(message: AuthReasons.guest)`, deletes any token |
| `isGuest`, `isAuthenticated` | Read-through to the notifier |

**After the session ends** (`logout` and `expireSession`) the result depends on `AppFlowConfig.authMode`:

- `loginRequired`: status becomes unauthenticated and the guest flag is cleared — "neither signed in nor a guest" is exactly the state the
  router sends to the sign-in wall.
- `guestFirst`: the reader becomes a **guest** (flag set *before* the status changes, so no frame ever reads "neither" and
  redirects) and keeps browsing.

### `auth_state_notifier.dart` — `AuthStateNotifier` (`ChangeNotifier`; the source of truth for UI and routing)

Holds `user`, `isGuest`, `authStatus` (from `dio_refresh_bot`), `sessionExpired`. Derived: `isAuthenticated` (authenticated **and
not** guest), `isUnauthenticated` (unauthenticated and not guest). Only `AuthManager` mutates it. The router listens to it.

### `auth_token_model.dart`

`AuthTokenModel extends AuthToken` (from `dio_refresh_bot`): `accessToken`, `refreshToken`, `expiresIn`. A small bridge between the API,
storage and the refresh library.

### `jwt_token_storage.dart` — `JwtTokenStorage`

Bridges secure storage (`StorageService`), the in-memory token the refresh interceptor reads synchronously, and the auth status
stream. A stored token that is already expired is **kept in memory on purpose**: the first protected call returns 401 and the
interceptor tries to refresh, instead of logging the reader out at launch. `write` persists the token and its expiry; `delete(reason)`
clears storage and publishes the status.

### `pending_action.dart` — `PendingActionQueue`, `ProtectedAction`

For `AuthMode.guestFirst`: a guest touches something that needs an account (`AuthGate.run(context, ProtectedAction.save, onGranted)`),
the sign-in sheet opens, and `PendingActionQueue` remembers what they wanted. After a successful sign-in it runs, and the reader
stays where they were. One action is remembered (the newest); backing out of the sheet clears it.

## Start-up

1. DI registers `StorageService`, `AuthManager` and the JWT Dio client — no storage is read.
2. The first frame is drawn.
3. The post-frame warm-up calls `AuthManager.initialize()`.
4. The router starts on the splash and decides the next route from `authStatus.status`, `isGuest` and onboarding. While the status is
   `Status.initial` the guard keeps the reader on the splash, so session restore never blocks the first frame. If bootstrap has not
   resolved after `SplashConfig.maxWait` (8 s) the app moves on.

## Sign-in

Bloc event → facade → repository (maps to `UserEntity` + `AuthTokenModel`) → `AuthManager.login(...)`. The notifier updates, the
router's refresh listenable fires, and the guard moves the reader to the shell. A guest who signs in via the sheet or the pushed
page stays on the page they were on; the screen closes itself on success. With no backend (`USE_MOCK=true`, or no base URL in
`ApiConfig`) the demo identity is filled in and any password of six characters works.

## Token refresh (`lib/core/network/dio_client.dart`)

`createDioClient` installs `RefreshTokenInterceptor<AuthTokenModel>`: it adds `Authorization: Bearer <accessToken>`, refreshes when
the token is about to expire (`isTokenAboutToExpire`) or the response is 401 — never when nobody is signed in or there is no token —
using a dedicated `tokenDio` (so the refresh call is not itself intercepted), posts to `ApiEndpoints.refreshToken`, and writes the new
`AuthTokenModel`. If the refresh fails or the token is revoked it calls **`AuthManager.expireSession()`**, which updates the notifier and
the router reacts (the wall, with "your session has ended", or in guest-first mode a banner over the app).

## Using it from a widget

Observe the notifier with `ListenableBuilder` (built into Flutter; the project does not use `provider`):

```dart
ListenableBuilder(
  listenable: getIt<AuthStateNotifier>(),
  builder: (context, _) {
    final session = getIt<AuthStateNotifier>();
    if (session.isAuthenticated) return Text(session.user?.name ?? '');
    if (session.isGuest) return Text(AppStrings.navGuest);
    return const SizedBox.shrink();
  },
)
```

A widget never calls `AuthManager`. A protected action in a widget is `AuthGate.run(...)`; signing out is a bloc event or the
settings row (`_confirmSignOut` calls `getIt<AuthManager>().logout()` after a confirmation dialog).

## Extending

- A derived getter on `AuthStateNotifier` (pure computation only).
- A session action on `AuthManager` (side effect + notifier update), e.g. refreshing the profile.
- More token fields on `AuthTokenModel` if the backend needs them.
- A second Dio (public vs authenticated) in `dio_client.dart`, sharing the same `JwtTokenStorage`.
