# `common/` Folder Guide

## Main idea / responsibility

`common/` contains **shared presentation-layer code** that is reused across multiple features.

This typically includes:

- Reusable UI widgets (buttons, dialogs, scaffolds, form fields)
- Shared UI primitives (icon sources, loading widgets, empty/failed states)
- Import “barrels” that reduce repetitive imports

## What `common/` currently contains

### `imports/`

- **`imports.dart`**
  - **Now**: A barrel file that re-exports frequently used Flutter/Dart packages and app-wide utilities/widgets.
  - **Future**:
    - Add more curated exports as the design system grows.
    - Potentially split into multiple barrels (e.g., `imports_ui.dart`, `imports_domain.dart`) if it becomes too broad.

### `widgets/`

This is the main library of reusable UI widgets.

#### Top-level widget files

- **`app_affixes.dart`**
  - **Now**: Shared “affix” UI pieces (typically prefix/suffix content used inside inputs/components).
  - **Future**: More standardized affixes (clear buttons, counters, badges, status icons).

- **`app_bottom_sheet.dart`**
  - **Now**: A reusable bottom-sheet API (wrapping modal sheets with consistent styling/behavior).
  - **Future**: Additional variants (full-screen sheets, nested navigation, advanced header layouts).

- **`app_dialog.dart`**
  - **Now**: A standardized dialog widget API for consistent dialogs across the app.
  - **Future**: More dialog types (confirmation, destructive, multi-step, custom animations).

- **`app_icon_source.dart`**
  - **Now**: A unified way to represent icons (material icon / svg / asset) to keep widgets flexible.
  - **Future**: Add support for remote icons, theming variants, caching, and accessibility metadata.

- **`app_image_viewer.dart`**
  - **Now**: Common image viewing widget(s) with app styling.
  - **Future**: Support galleries, zoom/gestures, placeholders, error fallbacks, and caching integration.

- **`app_shimmer.dart`**
  - **Now**: Shimmer loading presentation widget.
  - **Future**: More shimmer presets (list, card, avatar), and performance tuning options.

- **`empty_state_widget.dart`**
  - **Now**: A reusable empty-state widget for “no data” UIs.
  - **Future**: More templates and actions (CTA button support, illustrations).

- **`failed_state_widget.dart`**
  - **Now**: A reusable error/failed-state widget for “something went wrong” UIs.
  - **Future**: Recovery presets (retry strategies), error reporting links, and contextual messaging.

- **`full_screen_image_screen.dart`**
  - **Now**: A shared full-screen image screen.
  - **Future**: Add hero transitions, image carousels, and share/download actions.

- **`loading_dots.dart`**
  - **Now**: A small animated loading indicator.
  - **Future**: More loading indicator styles and size/color presets.

- **`main_loading_progress.dart`**
  - **Now**: A main progress/loading widget for blocking states.
  - **Future**: Variants for overlay loading, skeleton-first loading, and branded animations.

- **`show_error_overlay.dart`**
  - **Now**: Toast-like overlay banners (success/error/loading/custom) with a glassy blur effect.
  - **Future**: Add richer templates (actions, stacking rules, and accessibility presets).

#### `widgets/button/`

- **`app_button.dart`**
  - **Now**: The primary reusable button widget with consistent behavior and styling.
  - **Now**: Supports `onTapWhenInactive` for handling taps when `isActive` is false (without affecting normal `onTap`).
  - **Future**: Add more presets (icon-only tool buttons, segmented buttons), and enhanced accessibility.

- **`app_button_child.dart`**
  - **Now**: Abstractions for button content (label, icon, label+icon, etc.).
  - **Future**: Richer children (badges, async progress, multi-line labels).

- **`app_button_variants.dart`**
  - **Now**: Button variants/fills/layout configuration and style resolution.
  - **Future**: More theme-driven customization and additional brand variants.

#### `widgets/custom_scaffold/`

- **`app_scaffold.dart`**
  - **Now**: A reusable scaffold wrapper that standardizes app screen layout.
  - **Future**: Add more configuration knobs (safe-area policies, background patterns, per-screen transitions).

- **`app_scaffold_app_bar.dart`**
  - **Now**: App-wide app bar implementation used by `AppScaffold`.
  - **Future**: More app bar variants (search mode, segmented titles, collapsing behavior).

- **`app_scaffold_drawer.dart`**
  - **Now**: Drawer widget integration for `AppScaffold`.
  - **Future**: Multi-section navigation, dynamic menu, role-based entries.

- **`app_scaffold_search.dart`**
  - **Now**: Search UI integration used by scaffold variants.
  - **Future**: Advanced filtering UI, debounced search patterns, and search analytics hooks.

- **`app_scaffold_tap_area.dart`**
  - **Now**: Standardized tap area widget for consistent hit targets.
  - **Future**: Richer semantics helpers and interaction feedback presets.

- **`app_scaffold_types.dart`**
  - **Now**: Type definitions or shared scaffold contracts (currently empty, reserved).
  - **Future**: Central place for scaffold enums, interfaces, and shared config models.

- **`app_scaffold_variants.dart`**
  - **Now**: Definitions for scaffold variants and presets.
  - **Future**: Additional screen templates (wizard, tabbed, master-detail).

#### `widgets/form/`

- **`app_reactive_text_field.dart`**
  - **Now**: Reactive text field with app styling and validation behavior.
  - **Future**: More input modes (OTP, currency), and richer formatting/masking support.

- **`app_reactive_text_field_internal_widgets.dart`**
  - **Now**: Internal building blocks used by the reactive text field.
  - **Future**: Extract reusable internal pieces into standalone widgets if needed.

- **`app_reactive_text_field_mixins.dart`**
  - **Now**: Mixins/helpers shared by reactive text field implementations.
  - **Future**: Additional shared logic for new form field families.

- **`app_reactive_text_field_phone.dart`**
  - **Now**: Phone-specific reactive input behavior.
  - **Future**: Country picker integration, stronger validation, and formatting strategies.

- **`app_reactive_text_field_state.dart`**
  - **Now**: State management/state helpers for the reactive text field.
  - **Future**: Broader shared state patterns for complex form components.

- **`app_reactive_text_field_variants.dart`**
  - **Now**: Configuration/variants for reactive text fields.
  - **Future**: Expandable variant system aligned with design tokens.

- **`app_reactive_validation_messages.dart`**
  - **Now**: Centralized validation messages mapping.
  - **Future**: Localization integration and app-specific validation rules.

##### `widgets/form/date_time_field/`

- **`app_reactive_date_time.md`**
  - **Now**: Documentation for the date/time field behavior and usage.
  - **Future**: Expand with examples, edge cases, and integration guidance.

- **`app_reactive_date_time_field.dart`**
  - **Now**: Date/time reactive field public widget API.
  - **Future**: More variants (timezone selection, presets like “next business day”).

- **`app_reactive_date_time_field_internal_widgets.dart`**
  - **Now**: Internal widgets used by the date/time field.
  - **Future**: Extract reusable pickers into separate components.

- **`app_reactive_date_time_field_pickers_mixin.dart`**
  - **Now**: Picker orchestration logic.
  - **Future**: Add more picker strategies and platform-specific behavior.

- **`app_reactive_date_time_field_state.dart`**
  - **Now**: State layer for date/time field interaction.
  - **Future**: Better caching and derived state for complex range inputs.

- **`app_reactive_date_time_field_value_mixin.dart`**
  - **Now**: Value parsing/formatting helpers.
  - **Future**: Stronger type support and formatting configuration.

- **`app_reactive_date_time_field_variants.dart`**
  - **Now**: Variants/config models.
  - **Future**: Extended variant set aligned with app UX rules.

##### `widgets/form/dropdown_field/`

- **`app_reactive_dropdown_field.dart`**
  - **Now**: Dropdown reactive field public widget API.
  - **Future**: Searchable dropdowns, async data sources, and pagination.

- **`app_reactive_dropdown_field_internal_widgets.dart`**
  - **Now**: Internal dropdown rendering widgets.
  - **Future**: More presentation styles (chips, multi-select).

- **`app_reactive_dropdown_field_state.dart`**
  - **Now**: Dropdown state and interaction orchestration.
  - **Future**: Better selection logic, keyboard navigation, and accessibility.

- **`app_reactive_dropdown_field_types.dart`**
  - **Now**: Types/models used by the dropdown field.
  - **Future**: More option representations (grouped options, remote options).

#### `widgets/stage_tools/`

- **`stage_tools_overlay.dart`**
  - **Now**: A developer/staging overlay for in-app tools (debug helpers, toggles, etc.).
  - **Future**: Expand with diagnostics panels, network inspector hooks, and feature flag UI.

## What could be added to `common/` in the future

- More reusable UI components (cards, list tiles, chips, avatars)
- Animation primitives and standard transitions
- More form field types (multi-select, file picker, sliders)
- Unified error/empty/loading UX presets for consistency across features
