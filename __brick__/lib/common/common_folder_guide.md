# `common/` Folder Guide: Technical Encyclopedia

This document provides a granular, file-by-file breakdown of every shared component in the library. Use this to understand the internal logic and specific API of each utility.

---

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
- **Details**: Exports `AppTextFieldAffix` which handles the layout for prefix items (icons, labels) and suffix items (clear buttons, visibility toggles) with a standardized 20% alpha on colors.

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
- **Details**: Defines the `IconSource` class and `IconSourceWidget`. It allows passing `IconData`, SVG paths, or Asset paths as a single object, resolving them correctly at render time.

### `app_image_viewer.dart`

- **Path**: `lib/common/widgets/app_image_viewer.dart`
- **Responsibility**: High-performance image loading.
- **Details**: Uses `CachedNetworkImage` internally and handles placeholders (`AppShimmer`) and fallback icons when an image fails to load.

### `app_shimmer.dart`

- **Path**: `lib/common/widgets/app_shimmer.dart`
- **Responsibility**: Skeleton loading effect.
- **Details**: A flexible `AppShimmer` widget that creates a moving linear gradient. It can be shaped as a circle or rectangle to mimic different UI components during loading.

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
- **Details**: Provides the root layout. It manages safe areas, the persistent search bar, and ensures the `EndDrawer` is accessible across all screens.

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
- **Details**: Defines the various modes (e.g., `Standard`, `NoAppBar`, `SearchOnly`) and their respective visual configurations.

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
- **Details**: Defines the `ReactiveTextFieldMixin` which provides core focus and validation behaviors shared across multiple input types.

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
- **Details**: A static mapping of `ValidationMessages` keys to their localized `AppStrings` values.

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
- **Details**: An overlay that provides a "performance hud", feature flag toggles, and environment switcher (Prod vs Staging). Only active in Non-Release builds.

---

_For help with styling, spacing, or colors, always consult `lib/utils/constants/`._
