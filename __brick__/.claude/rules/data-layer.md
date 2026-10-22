---
paths:
  - "lib/features/**/data/**"
  - "lib/features/**/domain/**"
  - "lib/features/**/presentation/states/**"
  - "lib/core/network/**"
  - "lib/core/services/**"
---

# Data, state and services (loads when you touch these)

- Entity (pure) ← Mapper ← Model (`fromJson`/`toJson`) ← DataSource. Repository returns `Result<T>`; Facade orchestrates. Models never
  reach a bloc or a widget. Every API call takes a `…Params` class in `data/params/`.
- DataSource wraps IO in `rethrowAsAppException`; repository wraps in `runAsResult`.
- Bloc + Freezed; one `BlocStatus<T>` per async operation; UI uses `StatusBuilder<T>`. A bloc is a DI factory — provide it with
  `BlocProvider(create: (_) => getIt<X>())`, never `getIt` inside `build`.
- Session: change it through `AuthManager`, observe it through `AuthStateNotifier`. ObjectBox: open the store once and share it.
- Develop on mock data (`USE_MOCK=true`); new endpoints get fixtures in `assets/mock/`.

Full text: `.ai/architecture-rules.md`, `lib/features/features_overview.md`, the session and ObjectBox guides.
