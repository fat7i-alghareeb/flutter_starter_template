# Architecture Rules

Read this file when touching features, BLoC, repositories, datasources, models, entities, forms, routing, services, storage, or session behavior.

## Feature Structure

Each feature follows this shape:

```text
lib/features/feature_name/
├── constants/
│   └── forms/
├── data/
│   ├── datasources/
│   ├── models/
│   ├── mappers/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── facade/
└── presentation/
    ├── states/
    └── ui/
        ├── screens/
        └── widgets/
```

Existing template features may contain transitional folders such as `data/params/`. For new API input payloads, use a dedicated RequestModel naming pattern unless a local feature convention already exists and should be migrated deliberately.

## State Management

- Use BLoC and Freezed for feature state.
- Each meaningful async operation gets its own `BlocStatus<T>` field.
- Do not manually switch on status enums in UI.
- Use `StatusBuilder<T>` for async UI states.
- BLoC events should accept typed entities or request models, not raw maps or loosely related primitives.

## Clean Data Layer

- Domain entities are pure app/business objects.
- Data models/DTOs contain API serialization such as `fromJson` and `toJson`.
- Mappers convert Models to Entities.
- Models must not leak into BLoC or Presentation.
- Repositories expose domain-facing contracts and return `Result<T>` patterns.
- Remote/local datasources perform IO only and do not own presentation logic.
- Every API call should use a dedicated request model instead of raw maps or scattered primitive parameters.

## Error Handling

- Datasource methods wrap throwing IO work with `rethrowAsAppException(() async { ... })`.
- Repository methods wrap operations with `runAsResult(() async { ... })`.
- Keep mapping and error boundaries explicit.

## Forms

- `FormGroup` definitions belong in `constants/forms/`.
- Use an `abstract class` with static field keys and a static factory for the form.
- Do not define form field keys as raw strings in widgets, screens, or BLoCs.
- Use `formGroup.valueOf<T>(key)` where available.

## Routing

- Every screen defines `pagePath` and `pageName`.
- Register screens in the central route registry.
- Pass route data with typed argument classes through GoRouter `extra`.
- Destination screens must cast `extra` to the expected typed argument.
- Read `lib/core/router/router_guide.md` before changing navigation, route guards, redirects, splash flow, onboarding flow, or deep links.

## Services

- Read `lib/core/services/session/session_service_guide.md` before changing auth, JWT, token refresh, logout, guest mode, or session state.
- Read `lib/core/services/objectbox/objectbox_service_guide.md` before changing local persistence or ObjectBox entities.
- Keep cross-cutting services in `lib/core/services/`.
- Feature-specific orchestration belongs in feature facades, repositories, or BLoCs.

## Dependency Injection

- Use the existing GetIt and Injectable patterns.
- Prefer constructor injection for services, repositories, facades, datasources, and BLoCs.
- Do not introduce manual service locators outside existing project patterns.
