# Design system

The rules every screen of {{project_title}} follows. Tokens live in code
(`lib/utils/constants/design_constants.dart`, `lib/core/theme/`); this file is
why they have the values they have. Several rules are enforced by tests
(`test/core/theme/app_theme_test.dart`, the skeleton parity test, the
`AppStrings` discipline test) — change a rule here and there together.

**Rebranding** is three files: the palette in `app_colors.dart`, the font in
`pubspec.yaml` + `app_typography.dart`, and the two splash colours in
`flutter_native_splash.yaml`. Everything else reads from them.

---

## 1. Colour

A neutral palette with one accent. Take every colour from `colorScheme` or
`context.semantic` (`AppSemanticColors`) — never a hex in a widget.

| Role | Light | Dark | Use |
| --- | --- | --- | --- |
| `primary` | `#3B5BDB` | `#9DB0FF` | The one accent: primary button, active tab, links |
| `background` (semantic) | `#F5F6F8` | `#0F1115` | The screen ground — also the native splash |
| `surface` | `#FFFFFF` | `#171A21` | Cards, sheets, the nav bar |
| `surfaceVariant` | `#EEF0F4` | `#20242D` | Fields, chips, image placeholders |
| `onSurface` | `#1B1F27` | `#E8EAF0` | Primary text |
| `onSurfaceVariant` | `#5B6272` | `#A0A7B6` | Secondary text, idle icons |
| `outline` | `#E3E6EC` | `#2A2F3A` | Dividers, dark-mode card borders |
| `error` | `#B3261E` | `#F2B8B5` | Errors only |
| `urgent` (semantic) | `#B4402A` | `#F0A48F` | Urgent badges — never an error |
| `success` · `warning` · `info` | semantic | semantic | Status banners, toasts |

**The screen ground is not the card colour.** Cards separate from the ground
by colour and a soft shadow, not by borders.

**Contrast is measured, not assumed** (`app_theme_test.dart`): primary text on
a card ≥ 7:1; secondary text ≥ 4.5:1 on the card **and** on the ground; a
button label ≥ 4.5:1; meaningful icons ≥ 3:1.

## 2. Type

**Tajawal**, bundled in `assets/fonts/` (never fetched at runtime: a network
font flashes unstyled text on first launch and falls back silently offline).
It covers Arabic and Latin with the same rhythm, so switching language does
not change the layout.

| Role | Size | Weight | Use |
| --- | ---: | ---: | --- |
| `displaySmall` | 26 | 800 | App name on the splash |
| `headlineSmall` | 22 | 800 | Detail-page title |
| `titleLarge` | 18 | 700 | App-bar title, greeting |
| `titleMedium` | 16 | 700 | Section title |
| `titleSmall` | 14 | 700 | Card title |
| `bodyLarge` | 16 | 400 | Article text |
| `bodyMedium` | 14 | 400 | General text |
| `bodySmall` | 12 | 400 | Meta: time, author |
| `labelLarge` | 14 | 700 | Buttons |
| `labelMedium` | 12 | 500 | Chips, field labels |
| `labelSmall` | 11 | 700 | Badges |

- Weights **400 / 500 / 700 / 800** only (tested).
- Body text never below **14sp**; 11sp is for badges only.
- Every number goes through `AppFormats` (one digit system app-wide).

## 3. Spacing

A 4dp scale — `AppSpacing`: `2 · 4 · 6 · 8 · 10 · 12 · 16 · 20 · 24 · 32 · 40 · 48`.

- Screen margin **16** (`screenMargin`), always.
- Between two cards **8** (`cardGap`); header → content **12**; section →
  section **24**.
- A tab list's bottom padding clears the floating bar:
  `AppBottomNav.listBottomPadding(context)`.
- Content is capped at **640dp** and centred on tablets and in landscape.

## 4. Shape

`AppRadii`: `xs 7` badges · `sm 12` icon buttons · `md 14` images, fields,
buttons · `lg 18` cards, dialogs · `xl 20` nav bar · `sheet 26` sheet tops ·
`full` chips, avatars.

- No radius off the scale (tested). Nested shapes: inner = outer − 4.
- **One shadow** in the system, at three strengths (card · nav · sheet).
- **Never a shadow and a border on the same element.** In dark mode the
  shadow is replaced by a 1px `outline` border (a shadow is invisible on a
  dark ground).
- Shadows are drawn as `BoxShadow` on the rounded rect — `Material.elevation`
  on a stadium blurs its path offscreen every frame.

## 5. Icons

- **One family: Lucide**, line, stroke 1.7, as SVGs in `assets/svgIcons/`,
  compiled by `vector_graphics`. Reach them through `AppIcons.*` and draw with
  `AppIcon` / `IconSource.svg`. No Material or FontAwesome glyphs.
- Sizes: 16 inline · 20 rows · 24 bars · 28 empty states.
- Touch target ≥ 44×44 (48 in the nav bar) even when the glyph is 20.
- Directional glyphs follow the text direction: `context.chevronEnd`.
- Icons are [Lucide](https://lucide.dev), ISC licence — keep the notice if you redistribute the set.
- Adding one: drop the Lucide SVG in `assets/svgIcons/`, add a constant to
  `AppIcons`, run `build_runner` (`assets.gen.dart`).

## 6. Components (`lib/common/widgets/ds/`)

| Component | Rule |
| --- | --- |
| `AppCard` | The WHOLE card is tappable; press sinks to 0.965 and springs back; one `semanticLabel` for the card |
| `AppBadge` | Always carries text — never colour alone. Tones: primary · urgent · subtle · neutral · positive · dashed (sponsored) |
| `AppChip` / `AppSectionHeader` | Active = colour **and** weight; header has an accent line that draws in and a count that counts up |
| `AppSearchField` | Floating pill; clear button only while focused and non-empty |
| `AppTopBarFrame` | Rule + soft shadow once scrolled, never a tint fill |
| `AppThumbnail` | Cached image that settles in; with no image, an icon tile — never a stock photo |
| `AppRail` · `AppPeekCarousel` | Horizontal rows as tall as their tallest card; carousel side slides scaled by distance |
| `AppLazySection` | A section asks for its data when first built near the viewport; fails alone |
| `AppHeroDetailLayout` + `AppActionCapsule` | Detail page: picture, rising sheet, floating actions that tuck away |
| `AppSettingsGroup` / `AppSettingsTile` | Settings rows; pickers are sheets, never screens |
| Buttons (`AppButton`) | One primary button per screen; loading replaces the label, same width |
| Sheets / dialogs | Sheets for choices and anything longer than two lines; dialogs only to confirm; destructive action last and in `error` |

## 7. States

### Loading — one layout, two constructors (mandatory)

Every widget with a loading state extends **`SkeletonWidget`**, with
`.success(...)` and `.loading()` over ONE `buildBody`:

```dart
class ItemCard extends SkeletonWidget {
  const ItemCard.success({super.key, required ItemEntity this.item}) : super.success();
  const ItemCard.loading({super.key}) : item = null, super.loading();

  final ItemEntity? item;

  @override
  Widget buildBody(BuildContext context) => AppCard(
    child: Row(children: <Widget>[
      SkeletonBox(width: 56, height: 56, child: AppThumbnail(imageUrl: item?.imageUrl)),
      Expanded(child: SkeletonText(item?.title, style: context.textTheme.titleSmall, maxLines: 2)),
    ]),
  );
}
```

Add a line to the card and the skeleton grows it too — there is one `Row`.

- `SkeletonText` measures from the `TextStyle`; `SkeletonBox` reserves the
  real size; `SkeletonBar` takes no space when loaded; `SkeletonMore` is the
  next page (two `.loading()` rows, never a spinner).
- The sweep is synced across the screen; nothing shows for **300ms**, then at
  least **500ms**; loaded leaves rise in.
- **A height-parity test is mandatory** for each one
  (`test/common/widgets/ds/skeleton_parity_test.dart`).
- A spinner only for an action in progress (a save), inside its button.

### Empty · error · success

- Empty: icon, a **specific** sentence («Nothing found for “garden”»), one
  action.
- Error: the cause in the user's words and «Retry». An item that is **gone**
  (404) is not a failure: no retry, a way back.
- A section's error stays in the section; the rest of the screen stands.
- Success: a `SnackBar` (`AppSnackContent`); anything undoable offers
  **Undo** in the same snackbar.

### Every word from `AppStrings`

No literal text in widgets, no hand-written `.tr()`. Keys in
`assets/l10n/{en,ar}.json` → `dart run tool/generate_app_strings.dart` →
`AppStrings.x`. A counted sentence is a plural group
(`key.one`/`key.other`…, Arabic also `two/few/many`). Tested.

## 8. Motion (`app_motion.dart`, `scroll_reveal.dart`)

| Kind | Duration | Curve |
| --- | ---: | --- |
| Press | 90ms | `easeOut` |
| Toggle | 150ms | `easeInOut` |
| Sheet in / out | 260 / 180ms | `easeOutCubic` / `easeInCubic` |
| Route in / out | 280 / 200ms | same |
| Scroll reveal | 450ms, 45ms stagger | `AppCurves.reveal` |
| Tab switch | 220ms cross-fade | |

- Exit is faster than enter. Only `transform` and `opacity` animate.
- At most two things move in a scene.
- **Every motion is finite**, interruptible, and honours
  `MediaQuery.disableAnimations` (it becomes a short fade or nothing).
- Things that repeat stop when unseen (`TickerMode`): the rotating hint, Ken
  Burns.
- Kit: `ScrollReveal` / `.revealOnScroll()`, `AppIntro` + `AppIntroSlot`
  (once-per-run opening), `AppCountUp`, `AppAccentLine`, `AppGlint`,
  `AppKenBurns`, `AppParallax`, `AppPopIn`, `AppRailNudge`, `AppBackToTop`,
  `AppRefresh`, `AppRotatingHint`.

## 9. The shell

- Floating capsule nav bar: icon **and** word on every tab; tucks into a dock
  after 24dp of scrolling down, returns on 64dp up, at either end, on a tap or
  a swipe up — never while a screen reader is on.
- Tabs own **no scaffold** (the shell does) and stay alive with their scroll
  position; switching cross-fades.
- Tapping the active tab scrolls it to the top (`reselectToken`).
- Back on another tab returns to the first; back on the first asks before
  leaving.

## 10. Layout, direction, accessibility

- `flutter_screenutil` with a 390×844 design size; nothing with text gets a
  fixed height.
- **`EdgeInsetsDirectional` and `start`/`end` only** — `left`/`right` are
  wrong in Arabic.
- Checked at 320dp wide and 1.3× text (tested), in both themes and both
  directions.
- Touch targets ≥ 44, 8dp apart; a `Semantics` label on every icon button;
  nothing carried by colour alone; screen-reader order = visual order.

## 11. Do / don't

**Do** take every colour and style from the theme · reserve an image's space
before it loads · write empty and error text for people · test both
languages with the longest string.

**Don't** write a colour or size in a widget · put a shadow and a border on
one element · use two primary buttons on a screen · show a full-screen
spinner · use an emoji as an icon · use `left`/`right` · add a package before
checking what exists.
