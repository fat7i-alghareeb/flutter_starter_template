# `core/` Architecture Overview

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
