---
paths:
  - "lib/core/router/**"
  - "lib/core/services/session/**"
  - "lib/features/auth/**"
  - "lib/features/onboarding/**"
  - "lib/features/splash/**"
---

# Routing, guard and session (loads when you touch them)

- A page is an `AppPage` opened with `AppNavigator.push(context, AppPage.x, params: {...})`; ids travel in the path. Pushed pages
  have a **relative** `pagePath`; only top-level routes are absolute. `context.go` only replaces the whole stack.
- The guard is state-driven (splash → onboarding → login wall in `loginRequired` → shell). Never navigate by hand during start-up.
- Session ends: `logout()` (the reader asked) vs `expireSession()` (it ended). `AuthMode.guestFirst` keeps them browsing as a guest.
- Read `lib/core/router/router_guide.md` / `lib/core/services/session/session_service_guide.md` before changing a redirect.
