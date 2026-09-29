# Decisions

This file records durable project decisions so agents can follow the architecture without rediscovering the reasoning each task.

## AppStrings for User Text

All user-visible text goes through generated `AppStrings` constants. This keeps Arabic and English coverage synchronized and prevents raw `.tr()` keys or duplicated localization strings from spreading through UI code.

## AppTextStyles for Typography

Typography is centralized in `AppTextStyles` so screens share scale, weight, and responsive behavior. Widgets may customize color with semantic theme tokens, but should not define ad-hoc text styles.

## StatusBuilder for Async UI

Async UI state is rendered through `StatusBuilder<T>` backed by `BlocStatus<T>`. This keeps loading, error, empty, and success rendering consistent and avoids repeated status-switching logic in widgets. One `BlocStatus` **per operation** in a state (`listState`, `loadMoreState`, `saveState`…): one shared status would put a sign-out spinner on the sign-in button, or let one failed section empty the whole page.

## Skeletons, Never Spinners, for Content

Every widget with a loading state extends `SkeletonWidget` (`.success` / `.loading` over one `buildBody`), so the skeleton cannot drift from the content. A height-parity test is mandatory for each. Spinners are only for an action in progress. See `DESIGN_SYSTEM.md` → States.

## Fast — and Correct — First Frame

Startup does only the work required to render the first **correct** Flutter frame. The saved theme and the saved language ARE read before it (each within a 250ms budget): restored after it, a dark-mode user saw a light splash fade to dark, and a language switch could race `easy_localization`'s own load. Onboarding, auth/session restore, stage tools and notifications run after the first frame. The notification permission is asked from the shell (`RootScreen`), never behind the splash or on top of onboarding.

## Preload the First Tab Behind the Splash

`BlocPreloader` (`FeedPreloader` in the showcase) starts the first tab's requests the moment the session is read, while the splash is still up, and hands the bloc to the tab when it is built. It skips a first launch (onboarding comes first) and the login wall.

## Showcase Stays

The root showcase remains in the generated app by design, even though it has runtime/demo cost. App teams can delete it after cloning when they no longer need the component examples. Its first tab (`features/showcase_feed`) is a complete reference feature — lazy sections, paging, search, detail page, skeletons, mock data, tests — to copy from.

## Auth Mode Is a Switch

`AppFlowConfig.authMode`: `loginRequired` (default — a sign-in wall after onboarding) or `guestFirst` (browse freely; protected actions open a sign-in sheet and resume after sign-in via `PendingActionQueue`). The router guard, logout, onboarding and the session banner all follow it; tests run the rules of the active mode.

## One Navigation Stack, Nested Paths

Pages are pushed as children of the page that opens them (`AppPage` + `AppNavigator.push`), so the path reads like the walk (`/root/items/1/items/2`) and back pops one page. `context.go` is for replacing the whole stack only (sign-out, the login wall). Links from outside (web, notifications) go through `LinkDispatcher`, which pushes them OVER the shell — held until the shell is up on a cold start.

## Mock Layer at the Dio Level

`USE_MOCK=true` answers every request from `assets/mock/` in the first interceptor, so repositories, parsing, paging and errors run exactly as against a server. Fixtures use relative dates (`-2h`) so they never age. The mock APK has its own package id and name and installs beside the real app.

## Versions Come Only From pubspec.yaml

`version: x.y.z+N` is the one source for local builds, Codemagic and Shorebird. Bump `+N` before a release; a patch never bumps it.

## Shorebird Is Optional and Scripted

Over-the-air patches are documented, not wired (`docs/SHOREBIRD.md`). Once enabled, every release and patch goes through `tool/shorebird.dart`, which pins the Flutter version (`--flutter-version=system`), the dart-defines and the version, cuts the APK from the uploaded AAB, and keeps the mock app a separate Shorebird app.

## Native Setup Is Documented, Not Generated

`flutter create` owns `android/` and `ios/`. `docs/ANDROID_RELEASE_SETUP.md` and `docs/IOS_SETUP.md` hold every file in full: signing, R8 without blanket keeps, arm64-only release, locale filters, 120 Hz, the per-app night mode, links, notification icon.

## One Icon Family, Bundled Font

Lucide line SVGs compiled with `vector_graphics` (`AppIcons`); no Material or FontAwesome glyphs. Tajawal is bundled, never fetched: a network font flashes unstyled text on first launch and falls back silently offline.

## Entity, Model, Mapper Separation

Data models represent API/storage shapes. Domain entities represent app meaning. Mappers keep those layers separate so API details do not leak into BLoC or UI.

## No Melos

This is not a Melos workspace. Agents must use direct project commands such as `dart run tool/generate_app_strings.dart` and `dart run build_runner build`.
