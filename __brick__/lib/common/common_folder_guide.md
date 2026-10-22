# Shared widgets (`lib/common/`)

**Check here before you build a widget.** If something below does the job, use it; if it almost does, extend it. A piece used
by one feature stays in that feature; a piece two features need moves here (and into this file).

Visual rules: `DESIGN_SYSTEM.md`. How to use them: `.ai/flutter-ui-rules.md`. Window sizes: `docs/RESPONSIVE.md`.

- `imports/imports.dart` — the barrel most feature files import (DI, reactive forms, extensions, spacing tokens, the design
  system `ds/ds.dart`). Prefer it where the neighbouring files use it.
- Everything is in `lib/common/widgets/`; design-system primitives are in `widgets/ds/` (barrel `ds.dart`).

## I need… → use

### A screen and its frame

| Need | Use |
| --- | --- |
| A screen's scaffold | `AppScaffold.body` · `.appBar` · `.search` · `.all` (`custom_scaffold/`) |
| A column that stops growing on a wide window | `AppContentWidth` (`.readable` = 840) |
| A top bar with a large title that collapses | `AppTopBarFrame`, `AppBarTitle`, `AppLargeTitle`, `AppScrollAware` (`ds/app_top_bar.dart`) |
| A 44×44 icon button, with a tooltip and focus ring (and a count) | `AppBarAction` |
| A status-bar scrim over a photo | `AppStatusBarScrim` |
| Hide the floating bar while scrolling a tab | `NavBarVisibility`, `NavBarScrollWatcher` |
| A banner above the app (offline, session) | `TopBannerSlot`, `OfflineBanner` |

### Buttons

`AppButton` — `.primary`, `.success`, `.warning`, `.error`, their `*Gradient` twins, `.variant`, with `AppButtonChild.label | icon |
labelIcon`, `AppButtonLayout`, `isLoading`, `isActive`, `onTapWhenInactive`.

**Grey means inactive, and only that.** "Cancel", "Exit", "Close", "Reset" are `AppButton.error` (or `primary`). A button that
cannot be pressed keeps its variant with `isActive: false` (or no `onTap`) and is drawn grey by itself. `AppButton.grey` is for a
button that is always inactive; an active grey button fails an assertion. Details: the doc comment on `AppButton`.

### Dialogs, sheets, messages

| Need | Use |
| --- | --- |
| A dialog with actions | `AppDialog.show(context, dialog: AppDialog.basic(...))` with `AppDialogAction.primary \| secondary \| danger \| success` (`secondary`, the way out, is red; on Windows the confirming action comes first) |
| A bottom sheet that becomes a centred dialog in wide windows | `AppBottomSheet.showAdaptive`; inside it `AppSheetPresentation` says which form it is in |
| A transient toast | `showSuccessOverlay` · `showErrorOverlay` · `showLoadingOverlay` (`show_overlay.dart`) |
| Snack-bar content | `AppSnackContent` |
| A banner with a tone | `AppStatusBanner` (`AppBannerTone`) |

### Loading, empty, error

| Need | Use |
| --- | --- |
| A widget that loads | extend `SkeletonWidget` — `.success` and `.loading` over one `buildBody`; leaves `SkeletonText`, `SkeletonBox`, `SkeletonBar`, `SkeletonShape`; `SkeletonList`; `SkeletonMore` for the next page |
| A section that loads on its own | `AppLazySection` |
| A button or inline action in progress | `LoadingDots` |
| A blocking action | `MainLoadingProgress` |
| Nothing to show / it failed | `EmptyStateWidget` · `FailedStateWidget` (and `AppStateDisc` inside them) |
| Render a `BlocStatus<T>` | `StatusBuilder<T>` (`lib/core/utils/`) |

### Forms (`form/`)

| Need | Use |
| --- | --- |
| A text field | `AppReactiveTextField` — `.text .email .password .phone .decimal .integer .stringOnly`. The phone field shows a flag picture where the system font has no flag emoji (`AppPlatform.rendersFlagEmoji`) |
| A dropdown | `AppReactiveDropdownField` — `.menu .dialog .bottomSheet`, options `AppDropdownOption` |
| A date, time, range, month, year | `AppReactiveDateTimeField` — see `form/date_time_field/app_reactive_date_time.md` |
| Two fields to a row in wide windows | `AppFormFieldGrid` (`fullWidth: {…}` for a field that keeps a row) |
| Prefix/suffix items | `AppAffixes` |
| Localised validation messages | `AppReactiveValidationMessages` |
| Colours, height and padding of a field | `AppFormFieldDefaults` — the only place; fields are the card colour with a 3:1 border, 44dp tall (40 on desktop) |

A field draws its own container and fill; never put a second fill inside one.

### Lists, cards, content

| Need | Use |
| --- | --- |
| A card | `AppCard` (hover, focus ring, `menuActions`) · `AppPressable` for anything else that presses like one |
| A horizontal rail of cards / a peeking carousel | `AppRail` · `AppPeekCarousel<T>` |
| A detail page that opens on a photo | `AppHeroDetailLayout` (side by side in wide windows) + `AppActionCapsule` |
| A section title · filter chips · a filter pill | `AppSectionHeader` · `AppChip`, `AppChipRail` · `AppFilterPill` |
| A word label · a count | `AppBadge` (`AppBadgeTone`) · `AppCountBadge` (a circle for one digit, a pill beyond) |
| Label/value rows | `AppKeyValueTable` · settings rows `AppSettingsGroup`, `AppSettingsTile` |
| A search box | `AppSearchField` |
| Pictures | `AppCover` (generated fallback), `AppThumbnail`, `AppAvatar`, `AppLogoTile`, `AppGalleryStrip` → `AppGalleryScreen` / `FullScreenImageScreen`, `AppImageViewer` |
| The app's mark | `AppMark` |
| Icons | `AppIcon(AppIcons.x)`; `IconSource` where a widget takes either an SVG or an asset |

### Motion (`ds/app_motion.dart`, `scroll_reveal.dart`)

In order of preference: the motion kit — `.revealOnScroll()` / `ScrollReveal`, `AppIntro` + `AppIntroSlot`, `AppCountUp`,
`AppAccentLine`, `AppGlint`, `AppKenBurns`, `AppParallax`, `AppPopIn`, `AppRailNudge`, `AppRefresh`, `AppBackToTop`,
`AppRotatingHint`; then implicit animations; then `flutter_animate`; an `AnimationController` last, with a comment saying why.
Every motion is finite, interruptible and honours `MediaQuery.disableAnimations`.

### Pointer and keyboard

`AppFocusRing` (visible for keyboard use only), `AppContextMenu` / `AppMenuAction` (right click or long press),
`AppPointerArrows` and `AppDragScroll` (rails and carousels with a mouse). Shortcuts are `core/shortcuts/`, not here.

### Shell-wide behaviour

`RebuildOnLocaleChange` (rebuilds in place when the language changes), `ScrollReveal`, and in `stage_tools/` the QA overlay
(device preview, language, theme) — compiled out without `--dart-define=STAGE_TOOLS=true`.

## Sizes, spacing and layout

Plain logical pixels from `AppSpacing`, `AppRadii`, `AppIconSizes` — no `flutter_screenutil`, no `.sp .h .w .r`. What follows the
window comes from `AppLayout`:

| Need | Use |
| --- | --- |
| Side margin | `context.layout.gutter` — 16 · 24 · 32 |
| Cards per row | `AppLayout.columnsFor(width)` — 1 · 2 · 3 |
| A different subtree per size class | `AdaptiveLayout(compact:, medium:, expanded:)` |
| Spacing-only gaps | `AppSpacing.md.verticalSpace` / `.horizontalSpace` |

```dart
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: context.layout.gutter,
    vertical: AppSpacing.lg,
  ),
  child: Text('…', style: Theme.of(context).textTheme.titleMedium),
)
```

## Adding to this folder

1. Check the tables above; extend before you add.
2. Take colours from the theme, strings from `AppStrings`, sizes from tokens; support RTL, both themes, 1.3× text and a mouse.
3. Add it to `ds/ds.dart` if it is a design-system primitive.
4. Add a test (`test/common/widgets/…`, goldens in `ds_golden_test.dart` for a visual primitive), then add a row to this file.
