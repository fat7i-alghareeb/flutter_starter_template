# `core/` Architecture Overview

## 🛑 AI AGENT MANDATE (READ BEFORE PROCEEDING)

This document is a **Hard Requirement** for any AI agent interacting with the core layer. You **MUST** ensure your internal state is synced with the following dependencies:

- **Global Rules**: [.ai/project-rules.md](.ai/project-rules.md)
- **Design Tokens**: [lib/utils/constants/design_constants.dart](lib/utils/constants/design_constants.dart)
- **Text Styles**: [lib/core/theme/app_text_styles.dart](lib/core/theme/app_text_styles.dart)

Failure to apply the scaling protocols (`.sp`, `.h`, `.w`) defined here is a protocol violation.

---

## Main idea / responsibility

`core/` is the foundation layer of the app. It holds **cross-cutting concerns** that are not owned by any single feature.

Typical responsibilities include:

- App configuration and environment setup
- Dependency injection
- Networking setup
- Global error handling
- Routing/navigation infrastructure
- Notifications infrastructure
- Theming and design tokens
- Cross-app services (storage, session, localization, etc.)

This folder should remain **feature-agnostic**. If code is specific to one product area, it usually belongs in `features/`.

## What `core/` currently contains (subfolder-level)

- **`config/`**
  - Central configuration objects (e.g., app configuration, localization configuration).

- **`domain/`**
  - Core domain entities/models that are shared across the application (e.g., common `User` entity).

- **`error/`**
  - Global error types and the app-wide error handling strategy.

- **`injection/`**
  - Dependency injection setup and registration (e.g., `injectable` configuration, module registration).

- **`network/`**
  - HTTP client setup and network configuration (e.g., Dio client, endpoints, interceptors).

- **`notification/`**
  - Push/local notification infrastructure, configuration, payload normalization, and background hooks.
  - Includes dedicated documentation files already present in this folder.

- **`router/`**
  - App routing/navigation setup (routes, router config, transitions).
  - Includes a routing guide markdown already present in this folder.

- **`services/`**
  - Cross-feature services such as:
    - localization
    - session/auth state management
    - onboarding coordination
    - persistent storage
    - memory/cache management

- **`theme/`**
  - Design system foundation: colors, typography, text styles, theme composition, system UI overlay setup.
  - Includes a dedicated theme effects layer (gradients/shadows) exposed via theme/context extensions.

### 📚 Typography Encyclopedia (`AppTextStyles`)

The application's typography is strictly controlled via `AppTextStyles`. Manually defining `TextStyle` is a protocol violation.

#### Naming Convention `s[size]w[weight]`

Styles are named after their logical size and font weight for transparency:

- `s40w700`: Display Large (40sp, Bold)
- `s24w700`: Headline Large (24sp, Bold)
- `s16w600`: Title Medium (16sp, Semi-Bold)
- `s14w400`: Body Medium (14sp, Regular)

#### Mandatory Rules for Typography

1. **Color Inheritance**: All `AppTextStyles` are built to **NOT** carry a color by default. You **MUST** apply colors using `.copyWith(color: ...)` or rely on the `DefaultTextStyle` provided by the theme.
2. **Theme Synchronization**: Use `context.onSurface`, `context.primary`, etc., for text colors. NEVER use raw hex codes.
3. **Scaling Precision (.sp)**: Every font size in the `AppTypography` and `AppTextStyles` is defined using `.sp`.

### 📏 Scaling Precision (.sp) Protocol

To ensure a premium, accessible experience, the application uses `flutter_screenutil`'s `.sp` (Scalable Pixels) for all text-related dimensions.

#### Where .sp MUST be used

1. **All Font Sizes**: No exceptions.
2. **Button Heights**: Ensuring the touch target scales with the text size.
3. **Icon Containers**: If an icon is paired with text, it must scale proportionally.
4. **Text-Dense Containers**: Any padding or margin that is conceptually tied to text flow.

#### Where .h / .w MUST be used

- **.h**: Vertical spacing between sections, image heights, and screen-relative vertical dimensions.
- **.w**: Horizontal margins, sidebar widths, and screen-relative horizontal dimensions.

**VIOLATION**: Using raw `double` literals (e.g., `height: 50`) instead of `50.h` or `50.sp` will fail the protocol verification.

- **`utils/`**
  - Core-level utility types and patterns shared across infrastructure (e.g., result types, status types).

## What could be added to `core/` in the future

- **Analytics & monitoring**
  - Crash reporting integration, event tracking, performance monitoring.

- **Caching layer**
  - Offline-first caching strategies, repository caching helpers.

- **Security infrastructure**
  - Secure storage, encryption helpers, certificate pinning policies.

- **Feature flagging**
  - Remote config integration and feature flag evaluation.

- **App lifecycle and platform services**
  - Deep link handling, app update prompts, background tasks.

## How `core/` may evolve

As the codebase grows, `core/` should remain:

- **Stable and boring** (in a good way): foundational APIs used by features.
- **Clearly layered**: features depend on core; core should not depend on feature implementation details.
- **Well-documented**: guides can live beside the infrastructure they document.
