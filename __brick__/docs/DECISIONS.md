# Decisions

Durable decisions and the reasons behind them. Read the one that covers your change before you change how
something established works; when you make a new durable decision, add it here in the same task.

Each entry: **what** · **why** · **where**.

## Language and text

### Every visible string comes from `AppStrings`
Generated constants from `assets/l10n/ar.json` + `en.json`. Both languages stay in step, a typo cannot render a raw key, and the
discipline test fails the build on a hard-coded Arabic or English literal. · `.ai/localization-rules.md`,
`test/l10n/app_strings_discipline_test.dart`.

### Arabic is the default language, light is the default theme
A first launch starts in Arabic and light whatever the device is set to; what the reader picks later wins.
`AppLocalizationConfig.defaultLanguageCode` / `followDeviceLanguageOnFirstLaunch`, `AppThemeConfig.defaultMode`.

### Latin digits everywhere
Every number shown goes through `AppFormats`, and numeric inputs fold Arabic-Indic digits (`ArabicToEnglishDigitsFormatter`),
so one digit system is on screen and in the data.

## Look

### Type comes from the theme, not from `AppTextStyles`
The type scale is the theme's text roles (`DESIGN_SYSTEM.md` §2); widgets take a role and change only its colour.
`AppTextStyles.sXXwXXX` remain as aliases for the older shared widgets and are not for new code. · `lib/core/theme/app_typography.dart`.

### Sizes are plain logical pixels — no `flutter_screenutil`
Scaling by screen width made desktop windows absurd and tablets blurry; Flutter already accounts for density. What follows the
window comes from `AppLayout`, what follows the reader is the text scale. · `docs/RESPONSIVE.md`.

### One palette file; the page is a visible grey
`core/theme/app_colors.dart` is the one file to rebrand. The page is `#EDF0F5` (it was `#F5F6F8`, which read as white next to
white cards). A control's edge is `outlineVariant` at 3:1, hairlines are `outline`. Contrast is asserted in
`test/core/theme/app_theme_test.dart`.

### Grey means inactive — only that
Grey is the look of a button that cannot be pressed. A button that works is never grey: "Cancel", "Exit", "Close", "Reset" are
`error` (or `primary`). An active button cannot be grey (an assertion, plus a test over `lib/`), and any button with
`isActive: false` or no `onTap` is drawn grey by itself. · `lib/common/widgets/button/`.

### Fields are the card colour with a visible edge
A white plate on the grey page with a 3:1 border; the container draws the fill and the inner text field draws none (a second
fill showed as a box in a box in dark mode). 44dp tall, 40 on desktop. · `app_form_field_defaults.dart`.

### One icon family, bundled font
Lucide line SVGs compiled with `vector_graphics` (`AppIcons`); no Material or FontAwesome glyphs. Tajawal is bundled, never
fetched: a network font flashes unstyled text on first launch and falls back silently offline.

### Skeletons, never spinners, for content
Every widget with a loading state extends `SkeletonWidget` (`.success` / `.loading` over one `buildBody`), so the skeleton
cannot drift from the content; a height-parity test is mandatory for each. Spinners only mean "an action is running".

### A count is a circle
`AppCountBadge`: a circle for one digit, a pill beyond, measured from its text so a row or a `Positioned` cannot stretch it.

## One app, every screen

### One branch, every package, platform guards
Phones, tablets, iPads and Windows/macOS windows come from one branch. Nothing mobile is removed for desktop; a plugin that
ships no code for a platform is called behind an `AppPlatform` capability or a DI service. · `core/platform/app_platform.dart`.

### Layout follows the window size class
Material 3 classes by **window** width (compact < 600 · medium < 840 · expanded < 1200 · large < 1600 · extra-large), plus a compact
height (a phone on its side). Never a device type or an orientation. The first frame is right and a resize is picked up in the
same frame. · `core/layout/`, `docs/RESPONSIVE.md`.

### Navigation changes shape with the window
Capsule (compact) → 80dp rail (medium, or a phone on its side) → collapsible 256dp sidebar (expanded and wider). Tabs stay alive
across the switch. Sheets become centred dialogs (at most 720dp) from 840dp. · `RootScreen`, `AppSideNav`, `AppBottomSheet.showAdaptive`.

### Text grows a little with the window
×1.05 / ×1.10 / ×1.15 at expanded / large / extra-large, on top of the reader's own size (capped at 130% first). A desktop window
is read from further away than a phone. · `AppTextScaleHost`.

### The desktop window draws its own title bar
Microsoft's sizes and Segoe Fluent caption buttons on Windows, the real traffic lights on macOS; the window is hidden until its
first frame and restored where it was; one running copy on Windows. · `core/window/`, `docs/DESKTOP_SETUP.md`.

### Pointer and keyboard are first-class
Hover, tooltips, a focus ring that shows for keyboard use only, `AppShortcuts`, context menus, always-visible scrollbars,
compact density on desktop. · `docs/RESPONSIVE.md`.

### Windows installers are free
An Inno Setup `setup.exe` and a Microsoft Store MSIX; macOS ships an unsigned `.dmg`. · `tool/`, `docs/DESKTOP_SETUP.md`.

### A clean build has no warnings
`flutter build windows` from an empty folder prints 0 warnings. Fixed at the cause where possible (a plugin's deprecated
`/await` switch is removed from that target); three harmless messages from prebuilt libraries and plugins are hidden on purpose
and listed in `docs/DESKTOP_SETUP.md`. The hook applies all of it at generation time.

## State, data and routing

### `StatusBuilder` for async UI
Async state is rendered through `StatusBuilder<T>` over a `BlocStatus<T>`. One status **per operation** (`listState`,
`loadMoreState`, `saveState`): one shared status would put a sign-out spinner on the sign-in button.

### Entity, model, mapper, params separation
Models are API shapes, entities are app meaning, mappers are the only place they meet, and every API call takes a `…Params`
class. Models never reach a bloc or a widget. Data sources wrap IO in `rethrowAsAppException`, repositories in `runAsResult`.

### One navigation stack, nested paths
Pages are pushed as children of the page that opens them (`AppPage` + `AppNavigator.push`), so the path reads like the walk
(`/root/items/1/items/2`) and back pops one page. `context.go` only replaces the whole stack. Links from outside go through
`LinkDispatcher`, which pushes them over the shell, held until the shell is up on a cold start.

### Auth mode is a switch
`AppFlowConfig.authMode`: `loginRequired` (default — a sign-in wall after onboarding) or `guestFirst` (browse freely; protected
actions open a sign-in sheet and resume after sign-in via `PendingActionQueue`). The wall offers "Continue as guest" unless
`AppFlowConfig.guestOnLoginWall` is `false`. The guard, logout, onboarding and the session banner follow the mode.

### Mock layer at the Dio level
`USE_MOCK=true` answers every request from `assets/mock/` in the first interceptor, so repositories, parsing, paging and errors
run as against a server. Fixtures use relative dates (`-2h`) so they never age. The mock APK has its own package id and name.

## Working with Claude Code

### A small digest always loaded, everything else on demand
Every chat starts empty and whatever is loaded is paid for on every turn (cheaply, from the prompt cache, but not for free). So
`CLAUDE.md` is small (token discipline, how to work, a slot for project facts) and imports one digest, `.ai/project-rules.md`.
Detail is loaded only when needed: path-scoped `.claude/rules/` when matching files are touched, manual skills when invoked,
the long guides when the task's row in the digest says so. Generated files, build output and lockfiles are denied to `Read`
so they are never pulled into context. `test/claude_config_test.dart` keeps all of this from growing back.
Why not "load everything in the first chat": nothing survives into the next chat except what is auto-loaded, so a big
always-loaded file taxes every chat, and the docs warn that an over-long `CLAUDE.md` makes Claude ignore parts of it.

### Savings never replace verification
Tokens are saved by not re-reading, not loading unused rules and trimming test output (`tool/claude_test_filter.dart` adds
`--reporter=failures-only`). Analyze and the relevant tests always run; plan mode is used for multi-file changes.

## Start-up and delivery

### Fast — and correct — first frame
Only the work needed to render the first **correct** frame runs before `runApp`. The saved theme and language are read first
(each within a 250 ms budget): restored after it, a dark-mode reader saw a light splash fade to dark. Onboarding, session
restore, stage tools and notifications run after the first frame. The notification permission is asked from the shell, never
behind the splash or on top of onboarding.

### Preload the first tab behind the splash
`BlocPreloader` starts the first tab's requests the moment the session is read and hands the bloc to the tab. It skips a first
launch and the login wall.

### The showcase stays
The demo tabs and `features/showcase_feed` remain in the generated app on purpose: components to copy from. Delete them, with
`assets/mock/showcase/`, when your own features replace them.

### Generated code is committed
`*.g.dart`, `*.freezed.dart`, `injectable.config.dart` and `lib/utils/gen/*` are in the repository, so a fresh clone builds
without running the generators.

### The version comes only from `pubspec.yaml`
`version: x.y.z+N` is the one source for local builds, Codemagic and Shorebird. Bump `+N` before a release; a patch never bumps it.

### Native setup is documented, not generated
`flutter create` owns `android/` and `ios/` (and the desktop runners, which the hook patches). `docs/ANDROID_RELEASE_SETUP.md`
and `docs/IOS_SETUP.md` hold every file in full.

### Shorebird is optional and scripted
Over-the-air patches are documented, not wired (`docs/SHOREBIRD.md`). Once enabled, every release and patch goes through
`tool/shorebird.dart`.

### No Melos
This is not a Melos workspace. Use `dart run tool/generate_app_strings.dart` and `dart run build_runner build`.
