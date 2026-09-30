# 📚 Common UI & Animation Guide (`lib/common/`)

## 🛑 AI AGENT MANDATE (READ BEFORE PROCEEDING)

This document is a **Hard Requirement** for any AI agent interacting with shared components or animations. You **MUST** ensure your internal state is synced with the following dependencies:

- **Global Rules**: [.ai/project-rules.md](../../.ai/project-rules.md)
- **Animation Constants**: [lib/utils/constants/design_constants.dart](../../lib/utils/constants/design_constants.dart)
- **Responsive Sizing**: [lib/core/core_architecture_overview.md](../../lib/core/core_architecture_overview.md)

Failure to apply the 3-Tier Animation Mandate or Responsive Sizing protocols is a protocol violation.

---

## 🎬 Motion

Rules and durations: `DESIGN_SYSTEM.md` → Motion. In order of preference:

1. **The motion kit** (`widgets/ds/app_motion.dart`, `widgets/scroll_reveal.dart`): `.revealOnScroll()` for list items, `AppIntro` + `AppIntroSlot` for a once-per-run opening, `AppCountUp`, `AppAccentLine`, `AppGlint`, `AppKenBurns`, `AppParallax`, `AppPopIn`, `AppRailNudge`, `AppRefresh`, `AppBackToTop`, `AppRotatingHint`.
2. **Implicit animations** (`AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher`) for a state toggle.
3. **`flutter_animate`** for a one-off effect the kit does not cover.
4. **`AnimationController`** last, with a comment saying why.

Every motion is finite, interruptible and honours `MediaQuery.disableAnimations`.

---

## 📐 Responsive Sizing Protocols

This project uses `flutter_screenutil` for all layout dimensions. Using raw `double` literals for anything other than `0` is a **FAIL state**.

### The .h / .w / .sp Trinity

1. **.h (Height)**: Use for vertical spacing (`AppSpacing.md.verticalSpace`), fixed-height containers, and anything that must scale vertically relative to the screen height.
2. **.w (Width)**: Use for horizontal margins, padding, and screen-relative horizontal dimensions.
3. **.sp (Scalable Pixels)**: Use for **EVERYTHING** related to text (fontSize) and any box that must grow if the user scales their system font (like button heights).

For spacing-only gaps, prefer `x.verticalSpace` and `y.horizontalSpace`.
Do not write `SizedBox(height: x)` or `SizedBox(width: y)` just to create empty space.

**Standard Padding Example**

```dart
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.xl.w,
    vertical: AppSpacing.lg.h,
  ),
  child: Text('Hello', style: AppTextStyles.s16w600.copyWith(fontSize: 16.sp)),
)
```

## 🏗️ 1. `imports/` (The Connectivity Layer)

### `imports.dart`

- **Path**: `lib/common/imports/imports.dart`
- **Responsibility**: The project's main "barrel" export.
- **Details**: Consolidates essential third-party packages (e.g., `flutter_screenutil`, `get_it`, `reactive_forms`) and our internal utility extensions (`theme_extensions.dart`, `app_spacing.dart`).
- **Usage**: Should be imported by at least 90% of feature files to avoid long import blocks.

---

## 🎨 2. `widgets/` (The Core UI Library)

### `app_affixes.dart`

- **Path**: `lib/common/widgets/app_affixes.dart`
- **Responsibility**: Standardizing input decorations.
- **Details**: Exports `AppAffixes`, which handles the layout for prefix items (icons, labels) and suffix items (clear buttons, visibility toggles) with a standardized 20% alpha on colors.

### `app_bottom_sheet.dart`

- **Path**: `lib/common/widgets/app_bottom_sheet.dart`
- **Responsibility**: Global entrance for modal overlays.
- **Details**: Provides the `AppBottomSheet` class which wraps `showModalBottomSheet`. It manages height constraints, glassy blurs, and ensures the drag-handle is consistently styled with `context.grey`.

### `app_dialog.dart`

- **Path**: `lib/common/widgets/app_dialog.dart`
- **Responsibility**: Standardized alert logic.
- **Details**: Exports the `AppDialog` widget. It enforces a maximum width to prevent layout stretching on tablets and uses `AppRadii.lg` with a glassy background for a premium feel.

### `app_icon_source.dart`

- **Path**: `lib/common/widgets/app_icon_source.dart`
- **Responsibility**: Unified icon type system.
- **Details**: Defines the `IconSource` class. It allows passing an `AppIcons` SVG path (`IconSource.svg`), an asset or a Material `IconData` as a single object, resolved at render time. App UI uses `AppIcons` SVGs only.

### `app_image_viewer.dart`

- **Path**: `lib/common/widgets/app_image_viewer.dart`
- **Responsibility**: High-performance image loading.
- **Details**: Uses `CachedNetworkImage` internally and handles placeholders and fallback icons when an image fails to load.

### `ds/` — the design system

- **Path**: `lib/common/widgets/ds/` (barrel `ds.dart`, exported by `imports.dart`)
- **Responsibility**: every visual primitive — `app_skeleton.dart` (`SkeletonWidget`, `SkeletonText`, `SkeletonBox`, `SkeletonMore`), `app_motion.dart`, `app_card`, `app_badge`, `app_chip` (+ `AppSectionHeader`), `app_icons` (`AppIcons`, `AppIcon`), `app_thumbnail`, `app_search_field`, `app_top_bar`, `app_rail`, `app_peek_carousel`, `app_lazy_section`, `app_hero_detail_layout`, `app_action_capsule`, `app_settings_tile`, `app_status_banner`, `app_state_parts`.
- **Details**: see `DESIGN_SYSTEM.md` §6–7. Loading = `SkeletonWidget`, one layout for `.success` and `.loading`.

### `empty_state_widget.dart`

- **Path**: `lib/common/widgets/empty_state_widget.dart`
- **Responsibility**: Informative UI for no-data scenarios.
- **Details**: Exports `EmptyStateWidget`. Includes parameters for an icon, title, description, and an optional "Action" button.

### `failed_state_widget.dart`

- **Path**: `lib/common/widgets/failed_state_widget.dart`
- **Responsibility**: User-friendly error recovery.
- **Details**: Displays a centered error icon and message. Automatically includes a "Retry" button that connects to the parent's refresh logic.

### `full_screen_image_screen.dart`

- **Path**: `lib/common/widgets/full_screen_image_screen.dart`
- **Responsibility**: Full-screen image inspection.
- **Details**: A specialized screen that uses a `Hero` transition and a zoom-able image area for high-res viewing.

### `loading_dots.dart`

- **Path**: `lib/common/widgets/loading_dots.dart`
- **Responsibility**: Small inline loading feedback.
- **Details**: An animated Row of three dots. Frequently used inside buttons during asynchronous submissions.

### `main_loading_progress.dart`

- **Path**: `lib/common/widgets/main_loading_progress.dart`
- **Responsibility**: Primary progress indicator.
- **Details**: A standard `CircularProgressIndicator` sized and colored to match the theme's primary accent.

### `show_overlay.dart`

- **Path**: `lib/common/widgets/show_overlay.dart`
- **Responsibility**: Transient glassy notifications.
- **Details**: The main API for toast-like feedback.
  - `showSuccessOverlay(...)`: Standard success toast.
  - `showErrorOverlay(...)`: Standard error toast.
  - `showLoadingOverlay(...)`: Persistent loading toast.
  - This file also manages the `OverlayEntry` stack to prevent overlay collision.

---

## 🔘 3. `widgets/button/` (The Interaction System)

### `app_button.dart`

- **Path**: `lib/common/widgets/button/app_button.dart`
- **Responsibility**: The project's "Workhorse" button.
- **Details**: Implements `onTapWhenInactive` (allows clicking the button when disabled to trigger a validation toast) and `isLoading` (swaps text for dots).

### `app_button_child.dart`

- **Path**: `lib/common/widgets/button/app_button_child.dart`
- **Responsibility**: Atomic layout for button content.
- **Details**: Handles the alignment and icon-text spacing logic within the `AppButton`.

### `app_button_variants.dart`

- **Path**: `lib/common/widgets/button/app_button_variants.dart`
- **Responsibility**: Style and color orchestration.
- **Details**: Defines the `AppButtonVariant` enum and its associated theme colors, gradients, and elevation settings.

---

## 🏛️ 4. `widgets/custom_scaffold/` (The Application Shell)

### `app_scaffold.dart`

- **Path**: `lib/common/widgets/custom_scaffold/app_scaffold.dart`
- **Responsibility**: Orchestrating the screen UI.
- **Details**: Provides the root layout. It manages safe areas, the persistent search bar, and ensures the end drawer is accessible across all screens.

### `app_scaffold_app_bar.dart`

- **Path**: `lib/common/widgets/custom_scaffold/app_scaffold_app_bar.dart`
- **Responsibility**: Premium navigation header.
- **Details**: Implements a glassy app bar with support for sub-titles, back buttons, and custom leading/trailing widgets.

### `app_scaffold_drawer.dart`

- **Path**: `lib/common/widgets/custom_scaffold/app_scaffold_drawer.dart`
- **Responsibility**: Side navigation menu.
- **Details**: Builds the side-menu interface, integrating it with the app's global navigation routes and user profile logic.

### `app_scaffold_search.dart`

- **Path**: `lib/common/widgets/custom_scaffold/app_scaffold_search.dart`
- **Responsibility**: Global search overlay.
- **Details**: Handles the UI and animation for searching within the scaffold. It provides debounced callbacks for real-time filtering.

### `app_scaffold_tap_area.dart`

- **Path**: `lib/common/widgets/custom_scaffold/app_scaffold_tap_area.dart`
- **Responsibility**: Global click management.
- **Details**: A special `GestureDetector` wrapper that automatically removes focus from any input when the user taps on non-interactive areas of the scaffold.

### `app_scaffold_types.dart` & `app_scaffold_variants.dart`

- **Path**: `lib/common/widgets/custom_scaffold/...`
- **Responsibility**: Strategy and Configuration.
- **Details**: Defines the scaffold's options: the `AppScaffold.body` / `.appBar` / `.search` constructors, `ScaffoldFeature`, `AppScaffoldTitleAlignment` and `AppScaffoldSafeArea`.

---

## 📝 5. `widgets/form/` (Reactive Input Platform)

### `app_form_field_defaults.dart`

- **Path**: `lib/common/widgets/form/app_form_field_defaults.dart`
- **Responsibility**: **Central Visual Authority**.
- **Details**: Static class providing all metric constants (padding, border radius, stroke width) and theme-colored decorations used by both text inputs and pickers.

### `app_reactive_text_field.dart`

- **Path**: `lib/common/widgets/form/app_reactive_text_field.dart`
- **Responsibility**: Standardized reactive input.
- **Details**: The main text input widget. It provides built-in support for localized validation messages, character counters, and suffix clear buttons.

### `app_reactive_text_field_internal_widgets.dart`

- **Path**: `lib/common/widgets/form/app_reactive_text_field_internal_widgets.dart`
- **Responsibility**: Private UI logic.
- **Details**: Contains internal layout pieces for labels and error messages that are not meant for external use.

### `app_reactive_text_field_mixins.dart`

- **Path**: `lib/common/widgets/form/app_reactive_text_field_mixins.dart`
- **Responsibility**: Shared form logic.
- **Details**: Holds the private mixins (`_AppReactiveTextFieldDebounceMixin`, `_AppReactiveTextFieldHelpersMixin`) that keep `AppReactiveTextField`'s debounce and helper behaviour out of its state class.

### `app_reactive_text_field_phone.dart`

- **Path**: `lib/common/widgets/form/app_reactive_text_field_phone.dart`
- **Responsibility**: Mobile number handler.
- **Details**: A customized input with a persistent country-prefix and numerical masking.

### `app_reactive_text_field_state.dart` & `app_reactive_text_field_variants.dart`

- **Path**: `lib/common/widgets/form/...`
- **Responsibility**: Interaction configuration.
- **Details**: Manages localized states (Loading, Error, Neutral) and visual variants (Filled, Outlined, Underlined) for text fields.

### `app_reactive_validation_messages.dart`

- **Path**: `lib/common/widgets/form/app_reactive_validation_messages.dart`
- **Responsibility**: Localized error strings.
- **Details**: `AppReactiveValidationMessages`: maps reactive_forms' `ValidationMessage` keys to localized strings.

### 🏗️ 5a. `date_time_field/` (Detailed Sub-Library)

- **`app_reactive_date_time_field.dart`**: The main public widget for date/time selection.
- **`app_reactive_date_time_field_internal_widgets.dart`**: Custom picker dialogs and day-selection grids.
- **`app_reactive_date_time_field_pickers_mixin.dart`**: Logic for triggering system pickers vs custom glassy pickers.
- **`app_reactive_date_time_field_state.dart`**: Live state for date selection ranges and formatting.
- **`app_reactive_date_time_field_value_mixin.dart`**: Utility for parsing raw `DateTime` objects into localized string formats.
- **`app_reactive_date_time_field_variants.dart`**: Visual modes (Date only, Time only, Range).

### 🏗️ 5b. `dropdown_field/` (Detailed Sub-Library)

- **`app_reactive_dropdown_field.dart`**: Public widget for reactive selection from a list.
- **`app_reactive_dropdown_field_internal_widgets.dart`**: Custom scrollable menu logic with glassy backgrounds.
- **`app_reactive_dropdown_field_state.dart`**: Manages the open/closed state of the menu and the current selection index.
- **`app_reactive_dropdown_field_types.dart`**: Data models for dropdown choices (Label/Value pairs).

---

## 🛠️ 6. `widgets/stage_tools/`

### `stage_tools_overlay.dart`

- **Path**: `lib/common/widgets/stage_tools/stage_tools_overlay.dart`
- **Responsibility**: In-app development suite.
- **Details**: An overlay that renders three draggable buttons opening bottom sheets for device preview, locale switching, and theme switching. Only one sheet can be open at a time.
- **Gate**: Rendered only when `AppConfig.stageToolsEnabled` is `true`, which comes from `--dart-define=STAGE_TOOLS=true`. Because that is a compile-time constant, builds without the flag drop this code during tree shaking.

### `stage_device_preview_controller.dart`

- **Path**: `lib/common/widgets/stage_tools/stage_device_preview_controller.dart`
- **Responsibility**: Persisted on/off toggle for the `device_preview_plus` wrapper.
- **Details**: Hand-registered in `bootstrap.dart` (not `@injectable`) and only when stage tools are enabled. Use `StageDevicePreviewController.tryGet()` to read it safely.

---

_For help with styling, spacing, or colors, always consult `lib/utils/constants/`._
