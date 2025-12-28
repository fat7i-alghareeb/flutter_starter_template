# `lib/` Overview

## Why this folder exists

`lib/` is the root of the Flutter application’s source code. Everything that ships with the app (UI, state management, infrastructure, routing, theming, and utilities) lives here.

The goal is to keep:

- **Feature code** isolated in `features/`.
- **Cross-cutting foundations** centralized in `core/`.
- **Reusable UI building blocks** in `common/`.
- **Shared helpers and extensions** in `utils/`.

## What `lib/` currently contains

- **`main.dart`**
  - App entry point that calls `bootstrap()` and runs `App`.
  - Likely to remain intentionally small.
- **`bootstrap.dart`**
  - Startup/initialization orchestration (DI setup, services init, error handling, etc.).
  - May expand as new startup requirements are introduced.
- **`app.dart`**
  - The root widget (typically `MaterialApp`/router setup and app-level providers).
  - May grow with app-wide wrappers (theme, localization, analytics, feature flags).
- **`flavors.dart`**
  - Flavor/environment toggles (dev/staging/prod style config).
  - May expand with additional environment-specific switches and build-time flags.

### Major folders

- **`common/`**
  - Reusable, app-wide UI widgets and shared presentation utilities.
- **`core/`**
  - Infrastructure and cross-cutting services (routing, networking, theming, DI, errors, notifications, storage, etc.).
- **`features/`**
  - User-facing features organized by domain (auth, root navigation, onboarding, splash, etc.).
- **`utils/`**
  - Constants, extensions, generated code wrappers, and small helper functions.

## What could be added in the future

- **Additional features**
  - New feature folders under `features/` (e.g., profile, settings, home, search).
- **More infrastructure modules**
  - New subdirectories under `core/` (e.g., analytics, crash reporting, caching, logging).
- **More shared UI components**
  - More design-system widgets under `common/widgets/` (charts, advanced list items, skeleton loaders).
- **Tooling and code generation integrations**
  - More generated files under `utils/gen/`, and supporting wrappers in `utils/helpers/`.

## How this folder may evolve over time

As the project grows, `lib/` should remain a stable “map” of the app:

- New product areas go to `features/`.
- Anything cross-feature and foundational belongs to `core/`.
- Anything reusable UI belongs to `common/`.
- Anything small, shared, and framework-agnostic belongs to `utils/`.
