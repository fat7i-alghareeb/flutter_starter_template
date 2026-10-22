# Flutter UI rules

Read this when you touch a screen, a widget, a colour, spacing, an icon, a loading state or an animation.
Values and the reasons behind them: `DESIGN_SYSTEM.md`. Window sizes and desktop: `docs/RESPONSIVE.md`.

## Type

- Take a role from the theme: `Theme.of(context).textTheme.titleMedium` (or `context.titleMedium`).
  The roles and sizes are the table in `DESIGN_SYSTEM.md` §2 — `headlineSmall` for a page title, `titleMedium` for a
  section, `bodyMedium` for text, `labelLarge` for a button.
- Change **colour only**: `style?.copyWith(color: scheme.onSurfaceVariant)`. Never `TextStyle(fontSize: …)`,
  never a font weight outside 400 / 500 / 700 / 800, never body text under 14.
- `AppTextStyles.sXXwXXX` are aliases kept for the older shared widgets in `lib/common/`. Do not use them in new code.
- Do not fix the height of anything that holds text: the reader's text size (85–130%) and, in large windows, a
  further step (×1.05 / ×1.10 / ×1.15, `AppTextScaleHost`) both change it.

## Colour

- From `Theme.of(context).colorScheme` and `context.semantic` (`AppSemanticColors`: `background`, `success`,
  `warning`, `urgent`, `info`). Never `Colors.*` (except `Colors.transparent`), never `Color(0x…)`.
- The **page** colour is `context.semantic.background`; the **card** colour is `colorScheme.surface`. They differ on purpose.
- Secondary text and idle icons: `colorScheme.onSurfaceVariant`. Never `outline` for text or an icon — it is a hairline colour.
- The edge of a control (field border, ghost button): `colorScheme.outlineVariant` (`context.grey`), 3:1 against a card.
  Dividers and card hairlines: `colorScheme.outline`.
- Alpha: `.withValues(alpha: …)`. Shadows and gradients: `context.shadows.*`, `context.gradients.*`; a new reusable one
  goes into `core/theme/app_theme_effects.dart`, not inline.
- A colour you add goes in `core/theme/app_colors.dart` with its contrast asserted in `test/core/theme/app_theme_test.dart`.

## Spacing and size

- `AppSpacing` (gaps, padding), `AppRadii`, `AppIconSizes`. Allowed bare numbers: `0`, 1-pixel lines, flex, opacity,
  indexes, animation values, `double.infinity`.
- Sizes are plain logical pixels. There is no `flutter_screenutil`: never `.sp .h .w .r`, never `REdgeInsets`.
- A gap is `AppSpacing.md.verticalSpace` / `.horizontalSpace`, not `SizedBox(height: x)`.
- Touch targets are at least 44 (48 in navigation). Use `AppBarAction` for an icon button.

## Layout follows the window, not the device

- Read the size class: `context.layout` (rebuilds on any size change), `AppLayoutScope.windowSizeOf(context)`
  (rebuilds only when the class changes), or `AdaptiveLayout(compact:, medium:, expanded:)`.
  Never `MediaQuery.of(context).size.width < 600`, never an orientation check, never `Platform.isX`.
- Margins: `context.layout.gutter` (16 · 24 · 32). Columns: `AppLayout.columnsFor(width)` (1 · 2 · 3).
  A column that stops growing: `AppContentWidth` (`AppLayout.contentMaxWidth` 1200, reading width 640, forms 840).
- Navigation is chosen by the shell (`NavLayout`: bar → rail → sidebar); a screen never draws its own.
- Sheets become centred dialogs from 840dp: open them with `AppBottomSheet.showAdaptive`.
- Never lock orientation. Every screen works in portrait, landscape and a resized window.
- Platform **capabilities** (`AppPlatform.supportsPush`, `supportsVibration`, `isDesktop`, `hasDesktopWindow`,
  `rendersFlagEmoji`) are checked through `AppPlatform` — not `dart:io`, not `defaultTargetPlatform` inline. A mobile-only
  plugin is called behind a capability or a DI service (`HapticsService`).
- Pointer and keyboard are first-class: hover and a cursor on tappable things, a `Tooltip` on icon-only buttons,
  `AppFocusRing` (shown for keyboard only), shortcuts through `AppShortcuts`, `AppContextMenu` where a mouse user
  expects one.
- Check every screen at **390 · 820 · 1280** wide, portrait and landscape, light and dark, Arabic and English, 1.3× text.

## Screens

- Build a screen on `AppScaffold.body|appBar|search|all`. A hero or sliver page whose own scroll view needs the whole
  `Scaffold` may use `Scaffold` directly (the item-detail and settings pages do) — add a one-line comment why.
- Every screen defines `pagePath` and `pageName`: **relative** (`'settings'`, `'items/:id'`) for a page pushed over the
  shell, absolute (`'/splash'`) only for a top-level route. Register it as an `AppPage`.
- Decompose: screen → section → atomic widget, each non-trivial one in its own file. No big private widget classes
  inside a screen.
- A tab is not a screen: no `Scaffold`, bottom padding `AppBottomNav.listBottomPadding(context)`.

## Components

- **Buttons** are `AppButton` (`primary`, `success`, `warning`, `error`, `*Gradient`, `variant`).
  - Grey means **inactive, and only that**. "Cancel", "Exit", "Close", "Reset" are `AppButton.error` (or `primary`),
    never grey. `AppButton.variant(variant: grey, isActive: true)` fails an assertion; a test scans `lib/` for it.
  - To disable, keep the variant and pass `isActive: false` (or leave `onTap` null): the button turns grey by itself.
    `onTapWhenInactive` says why. `AppButton.grey` is for a button that is always inactive.
  - One primary button per screen. Never `ElevatedButton`/`TextButton`/a bare `GestureDetector` for an app action.
- **Dialogs and sheets**: `AppDialog` (`AppDialogAction.primary|secondary|danger|success` — `secondary`, the way out, is
  red), `AppBottomSheet.showAdaptive`.
- **Fields**: `AppReactiveTextField` (+ `.email .password .phone .decimal .integer`), `AppReactiveDropdownField`,
  `AppReactiveDateTimeField`, laid out two to a row in wide windows with `AppFormFieldGrid`. They draw their own
  container — never put a second fill inside one. Field height is 44 (40 on desktop).
- **Counts** (unread, cart): `AppCountBadge` — a circle for one digit, a pill beyond; never a hand-made `Container`.
- **Badges** (words): `AppBadge`. **Status**: `AppStatusBanner`. **Empty**: `EmptyStateWidget`. **Error**: `FailedStateWidget`.
- A reusable piece goes in `lib/common/widgets/` (check `lib/common/common_folder_guide.md` first); a piece used by one
  feature stays in that feature.

## Icons and images

- Lucide SVGs: `AppIcon(AppIcons.x)` (or `IconSource.svg(AppIcons.x)` where a widget takes an `IconSource`).
  A missing glyph: add the SVG to `assets/svgIcons/` and a constant to `AppIcons`. Never `Icons.*` or an icon font.
- Directional glyphs follow the text direction (`context.chevronStart` / `chevronEnd`).
- Assets: generated `Assets` (FlutterGen) after `dart run build_runner build`; no raw path strings.
- Reserve an image's space before it loads (`AppCover`, `AppThumbnail`).

## Loading, empty, error

- Content loading: `SkeletonWidget` — `.success(...)` and `.loading()` over **one** `buildBody`, leaves wrapped in
  `SkeletonText` / `SkeletonBox`. Never a second "skeleton version". A new `.loading()` needs a line in
  `test/common/widgets/ds/skeleton_parity_test.dart`.
- The next page of a list: `SkeletonMore`. A section that loads on its own: `AppLazySection`.
- Async state in a screen: `StatusBuilder<T>` over a `BlocStatus<T>`.
- Spinners (`LoadingDots` in a button, `MainLoadingProgress` for a blocking action) mean "an action is running".
  No raw `CircularProgressIndicator` in feature UI.
- Empty and error states say what happened and offer one action, in words a person would use.

## Motion

- Use the motion kit first: `.revealOnScroll()` / `ScrollReveal`, `AppIntro` + `AppIntroSlot`, `AppCountUp`,
  `AppAccentLine`, `AppGlint`, `AppKenBurns`, `AppParallax`, `AppPopIn`, `AppRefresh`, `AppBackToTop`.
  Then implicit animations; then `flutter_animate`; an `AnimationController` last, with a comment saying why.
- Every animation is finite and honours `MediaQuery.disableAnimations`; anything that repeats stops when unseen.
- No decorative motion on admin, dashboard or table screens.

## Accessibility

- Every icon-only control has a label (`Semantics` / `Tooltip`). Never signal by colour alone — badges carry words.
- Text contrast: primary ≥ 7:1, secondary ≥ 4.5:1; the edge of a control ≥ 3:1 (asserted in `app_theme_test.dart`).
