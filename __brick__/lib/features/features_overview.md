# `features/` Overview

## Main idea / responsibility

`features/` contains **product/domain-focused modules**. Each feature folder should own its:

- UI (screens/widgets)
- State management
- Domain logic (entities/use-cases)
- Data layer (repositories/data sources)

This structure keeps the project scalable by preventing cross-feature coupling and keeping changes localized.

## What `features/` currently contains

### `auth/`

Authentication feature module.

- **Now**:
  - Organized into common layers such as `data/`, `domain/`, `presentation/`, and `constants/`.
  - Typically contains login/register flows, token handling integration points, and auth-related UI.
- **Future**:
  - Add password reset, social login, MFA, biometric auth, and session recovery flows.

### `root/`

Root navigation / app shell feature.

- **Now**:
  - Owns the app’s main “root screen” and navigation presentation (e.g., bottom navigation, tab pages).
  - Contains `data/`, `domain/`, `presentation/`, and `constants/`.
- **Future**:
  - Expand with more shell capabilities (global banners, in-app messaging, deep-link entry handling).

### `onboarding/`

Onboarding UI/flow feature.

- **Now**:
  - Presentation-only structure (currently contains `presentation/`).
- **Future**:
  - Add domain and data layers if onboarding becomes dynamic (remote-config driven onboarding).

### `splash/`

Splash/startup UI feature.

- **Now**:
  - Presentation-only structure (currently contains `presentation/`).
- **Future**:
  - Add routing decisions, animation variations, and conditional startup checks.

## What could be added in the future

- Additional domain features (profile, settings, home/dashboard, search, notifications UI)
- Shared feature conventions (e.g., `di/` subfolder per feature for feature-local injection modules)
- More consistent “feature boundaries” (explicit public API exports per feature)

## How `features/` may evolve

As the app grows, each feature can scale independently by:

- Adding more feature areas under the same domain folder
- Growing from presentation-only to include domain/data
- Exposing only the minimal public API needed by routing/shell code
