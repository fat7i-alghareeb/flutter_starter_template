# `utils/` Folder Guide

## Main idea / responsibility

`utils/` contains **shared, lightweight helpers** used across the app. It is intentionally generic and typically includes:

- App-wide constants
- Convenience extensions
- Generated-code wrappers
- Small helper functions (formatting, printing, input formatters)

This folder should stay **framework-light** where possible, and avoid feature-specific logic.

## What `utils/` currently contains

### `constants/`

- **`app_flow_constants.dart`**
  - **Now**: Constants related to app flows or flow-specific settings.
  - **Future**: Expand with more flow identifiers, deep-link mappings, or onboarding step IDs.

- **`auth_constants.dart`**
  - **Now**: Authentication-related constants (keys, constraints, etc.).
  - **Future**: Add more shared auth keys (token keys, header names, error codes).

- **`design_constants.dart`**
  - **Now**: Design tokens/constants (spacing, radii, durations, standardized paddings).
  - **Future**: Expand with more tokens (elevations, breakpoints, animation curves).

- **`localization_constants.dart`**
  - **Now**: Constants used by localization logic (e.g., keys or defaults).
  - **Future**: Add more locale metadata, fallback policies, and supported locale lists.

### `extensions/`

- **`context_extensions.dart`**
  - **Now**: Convenience extensions on `BuildContext` (commonly theme/colors/sizing helpers).
  - **Future**: Add safe, well-scoped helpers for common patterns (navigation, media query access).

- **`date_time_extensions.dart`**
  - **Now**: Date/time formatting and manipulation helpers.
  - **Future**: Expand with timezone-aware helpers and localization-friendly formatting.

- **`enum_extensions.dart`**
  - **Now**: Small helpers for enum display/serialization.
  - **Future**: Add stronger mapping utilities and localization integration.

- **`int_extensions.dart`**
  - **Now**: Integer helpers (commonly formatting, durations, ranges).
  - **Future**: Add more ergonomic helpers for time/distance formatting.

- **`iterable_extensions.dart`**
  - **Now**: Convenience methods on lists/iterables.
  - **Future**: Add safe collection helpers (grouping, stable sorting, distinct-by).

- **`reactive_forms_extensions.dart`**
  - **Now**: Extensions supporting `reactive_forms` usage patterns.
  - **Future**: More validation helpers, control accessors, and standardized error mapping.

- **`string_extensions.dart`**
  - **Now**: String helpers (formatting, parsing, validation utilities).
  - **Future**: Localization-aware formatting and stronger validation presets.

- **`text_direction_extensions.dart`**
  - **Now**: Helpers related to RTL/LTR handling.
  - **Future**: Add layout mirroring helpers and bidi-safe formatting.

- **`theme_extensions.dart`**
  - **Now**: Theme-related convenience accessors (e.g., gradients/shadows via context).
  - **Future**: Expand with more theme effect helpers and safer null-handling strategies.

- **`widget_extensions.dart`**
  - **Now**: Widget convenience methods (padding, sizing, tap helpers).
  - **Future**: Add more composition helpers while keeping readability in check.

### `gen/`

- **`app_strings.g.dart`**
  - **Now**: Generated localization strings.
  - **Future**: Will grow as localization keys increase (keep it generated-only).

- **`assets.gen.dart`**
  - **Now**: Generated asset accessors.
  - **Future**: Will grow as assets and flavors expand.

### `helpers/`

- **`app_strings.dart`**
  - **Now**: Small wrapper/helpers around app strings usage.
  - **Future**: Add convenience APIs for pluralization, interpolation, and fallback behavior.

- **`build_svg_icon.dart`**
  - **Now**: Helper to build SVG icons consistently.
  - **Future**: Add caching, theming presets, and error fallbacks.

- **`colored_print.dart`**
  - **Now**: Colored console logging helper.
  - **Future**: Add log levels, tags, and integration with a logging service.

- **`device_helper.dart`**
  - **Now**: Device identifier and device info helpers (Android/iOS) using `device_info_plus` + platform-specific identifiers.
  - **Future**: Expand with safer fallbacks and explicitly documented privacy considerations.

- **`input_formatters.dart`**
  - **Now**: Shared `TextInputFormatter` implementations.
  - **Future**: Expand with more formatters (currency, phone, OTP, ID formats).

- **`jwt_token_utils.dart`**
  - **Now**: JWT parsing/inspection utilities.
  - **Future**: Add safer validation helpers and refresh/expiry convenience methods.

## What could be added to `utils/` in the future

- More formatting helpers (numbers, currencies, file sizes)
- More safe parsing utilities (URI parsing, JSON helpers)
- A lightweight logging facade (wrapping console + optional remote logging)
- Shared testing utilities (if you choose to place them in `utils/`)
