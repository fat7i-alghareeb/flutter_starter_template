# 0.2.0

A large upgrade of everything the brick generates.

- **Design system**: tokens, explicit light/dark colour schemes with semantic colours, bundled Tajawal, 55 Lucide SVG icons (`AppIcons`), 20+ `ds/` widgets. `google_fonts`, `shimmer` and `font_awesome_flutter` removed.
- **Skeleton loading**: `SkeletonWidget` (`.success` / `.loading` over one layout), synced sweep, `SkeletonMore`, mandatory height-parity tests.
- **Motion kit**: scroll reveal, opening choreography, count-up, accent line, glint, Ken Burns, parallax, pop-in, rail nudge, pull-to-refresh, back-to-top, rotating hint.
- **Shell**: floating nav bar that morphs into a dock on scroll, cross-fade tab stack, reselect-to-top, exit confirmation, notification permission asked from the shell.
- **Startup**: colour-only native splash, logo-less in-app splash, theme + language restored before the first frame, first tab preloaded behind the splash.
- **Routing**: nested `AppPage` tree with `AppNavigator.push`, predictive back, `AppLinks` + `LinkDispatcher` for web links and notification taps.
- **Mock layer**: `USE_MOCK=true` with paging, search, per-item 404, delay/empty/error/offline switches; offline response cache with a banner.
- **Auth**: `AuthMode.loginRequired` / `guestFirst`, email + password form, sign-in sheet for protected actions with resume, session expiry that keeps the user's screen.
- **Localization**: dotted keys, plural groups (Arabic's six forms), generator checks, `AppFormats`, device language on first launch.
- **Showcase feed** reference feature and a **settings** page.
- **Stage tools** moved above the nav bar; new launch configurations (mock data, mock + stage tools, release mock).
- **Tests**: 290+ (bloc, widget, golden, parity, contracts, integration); `test/` and `tool/` are analyzed.
- **Tooling**: upgraded feature generator (skeleton card, stateful body, `--mock`), `tool/build_release_apk.dart`, `codemagic.yaml`.
- **Docs**: `DESIGN_SYSTEM.md`, Android/iOS release setup, Codemagic, optional Shorebird (with the full script), feature spec template, updated guides and agent rules.
- **Fixes**: missing splash/launcher images in configs, notification web links, a frame of «neither guest nor signed in» on sign-in, un-cancellable router timers, empty refresh endpoint, double sheet handles, left/right paddings, hard-coded English in login/onboarding.

# 0.1.1

- Initial public template.
