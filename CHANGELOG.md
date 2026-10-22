# 0.3.0

One app for phones, tablets, iPads and Windows/macOS windows.

- **Adaptive layout**: `AppLayout` (device type + Material 3 window size classes + height class) rebuilt from `MediaQuery.sizeOf` every frame, so the first frame is right and a rotation or a window resize is picked up in the same frame; `AppLayoutScope` (`InheritedModel`), `AdaptiveLayout`, `LayoutReader` for code without a context. `flutter_screenutil` removed: sizes are plain logical pixels.
- **Shell**: capsule (compact) → rail (medium, or any phone held sideways) → collapsible sidebar (expanded and wider), with the tabs kept alive across the switch; `AppSideNav`, unread badges, remembered collapsed state.
- **Screens**: feed grid 1 → 2 → 3, side-by-side detail, two-pane settings, brand-panel sign-in, wide onboarding, sheets that become 720dp dialogs, a full pointer image viewer, gutters 16 · 24 · 32, headings one step larger from 840dp, snackbars in the bottom-end corner.
- **Input**: hover, tooltips, `AppFocusRing` (keyboard only), `AppShortcuts` (Ctrl/⌘ 1–5, K, `,`, R, B, Esc, `?`) that step aside while typing, a shortcuts list in Settings, context menus on cards, drag-and-arrows on rails, always-visible scrollbars and compact density on desktop.
- **Desktop**: custom title bar in the app's colours (Microsoft's sizes and Segoe Fluent caption buttons on Windows, real traffic lights on macOS), window hidden until the first frame and restored where it was, a single running copy on Windows, `myapp://` links, macOS menu bar, `AppPlatform` capability checks and a `HapticsService` so nothing mobile-only is called on desktop — and nothing on mobile was removed.
- **Brick**: `tool/setup_project.dart` (a project GUID; the runner, entitlement and Info.plist patches — run once after `mason make`, in any order with `flutter create`; it replaced Mason hooks, which failed to compile from Mason's git cache on Windows), `tool/build_windows_installer.dart` (Inno Setup), `tool/build_macos_dmg.sh`, `msix_config`, desktop icons, Codemagic `windows-release` and `macos-release`.
- **Defaults**: a first launch starts in the **light** theme and in **Arabic**, whatever the device is set to (`AppThemeConfig.defaultMode`, `AppLocalizationConfig.defaultLanguageCode` / `followDeviceLanguageOnFirstLaunch`); what the user picks later still wins.
- **Sign-in**: the login wall offers «Continue as guest» (`AppFlowConfig.guestOnLoginWall`, on by default; `false` for a hard wall).
- **Palette**: the grey page was almost white (`#F5F6F8`); it is `#EDF0F5` now, with cards that read as cards. Field borders and quiet icons are 3:1 (`outlineVariant` `#8893A8`, dark `#636C7E`), hairlines are stronger, placeholder text is readable, the warning colour is `#B45309` instead of a muddy olive, and the native splash and launcher background follow the page colour. Contrast is asserted in `app_theme_test.dart`.
- **Buttons**: **grey means inactive, and only that** — a flat muted plate for a button that cannot be pressed. An active button cannot be grey (an assertion, a test over `lib/`, and a note in `AppButton`'s docs); `AppButton.grey` is always inactive, and «Cancel», «Exit», «Reset» use the error variant (dialog secondary actions are red). Success, warning and error follow the theme in dark mode; gradients darken at the far end instead of fading, so their text stays readable.
- **Fields**: white plate on the grey page, 44dp tall (40 on desktop), tighter gaps; the phone field shows a flag picture on Windows and Linux (they have no flag emoji and printed «EG»).
- **Text size**: ×1.05 / ×1.10 / ×1.15 at expanded / large / extra-large windows (`AppTextScaleHost`).
- **Demo tabs**: Buttons, Dialogs, Forms and Alerts are translated (Arabic and English), share one `ShowcasePage` frame, flow buttons in rows and use tighter spacing.
- **Fixes**: the title-bar search box fills the bar's height and grows with the window (360–640dp); form fields no longer paint a second, differently coloured box inside their own container (visible in dark mode); the desktop title bar no longer fails with «No Overlay widget found» (it sits above the navigator and now brings its own `Overlay`).
- **Docs**: `docs/RESPONSIVE.md`, `docs/DESKTOP_SETUP.md`; every agent rule and guide that told you to use `.sp` / `.h` / `.w` now says what is true.
- **Tests**: 410+, including size classes, the side navigation, adaptive sheets, form grid, shortcuts, platform capabilities, text scaling, the count badge, the grey-means-inactive rule and the translated demo tabs.

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
