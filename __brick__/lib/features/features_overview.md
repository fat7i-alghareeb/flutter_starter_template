# `features/` Architecture & Implementation Guide

This document defines the standardized architecture for all product features. Every new feature module must strictly adhere to this structure to ensure consistency, scalability, and predictable dependency flow across the Alsultan platform.

## 🔑 The Root Feature: Core Logic & Orchestration

The **Root** feature is the most critical module in the application, serving as the "App Shell" or primary orchestrator. Unlike standard domain features (like trading or inventory), the purpose of the Root is to provide a unified experience and bridge the gap between different product areas.

### Purpose & Responsibilities

- **Centralized Navigation**: It hosts the main navigation controllers and the `BottomNavBar`, managing the transitions and state persistence between the primary application tabs.
- **Global UI Shell**: It provides the persistent interface elements — such as the `AppScaffold`, `EndDrawer`, and specialized overlays — that must remain consistent regardless of which functional module is currently visible.
- **App-Level Side Effects**: It handles global state changes like theme switching (Light/Dark mode) and localization updates that affect the entire application context simultaneously.
- **Unified Entry Point**: After authentication, the Root feature is the landing zone that initializes the core application environment and establishes the navigation scope for all subsequent user interactions.

---

## 🏗️ State Management Standards (BLoC & Freezed)

We utilize **BLoC** with **Freezed** to ensure immutability and exhaustive pattern matching. Every feature must follow this exact state implementation pattern.

### Standard BLoC Structure (The Blueprint)

Every asynchronous operation in the BLoC must have its own dedicated `BlocStatus<T>` field in the state. This prevents UI cross-talk and allows multiple independent operations to occur simultaneously.

#### 1. The State (`feature_state.dart`)

```dart
@freezed
class FeatureState with _$FeatureState {
  const factory FeatureState({
    // One status per major async operation
    @Default(BlocStatus<List<Entity>>.initial())
    BlocStatus<List<Entity>> fetchState,

    @Default(BlocStatus<DetailEntity>.initial())
    BlocStatus<DetailEntity> detailsState,

    @Default(BlocStatus<void>.initial())
    BlocStatus<void> submissionState,
  }) = _FeatureState;
}
```

#### 2. The Event (`feature_event.dart`)

```dart
@freezed
class FeatureEvent with _$FeatureEvent {
  const factory FeatureEvent.started() = _Started;
  const factory FeatureEvent.fetchRequested() = _FetchRequested;
  const factory FeatureEvent.submitRequested(RequestModel request) = _SubmitRequested;
}
```

#### 3. The BLoC Logic (`feature_bloc.dart`)

```dart
@injectable
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc(this._facade) : super(const FeatureState()) {
    on<_FetchRequested>(_onFetchRequested);
  }

  final FeatureFacade _facade;

  Future<void> _onFetchRequested(...) async {
    emit(state.copyWith(fetchState: const BlocStatus.loading()));
    final result = await _facade.fetchData();
    result.when(
      success: (data) => emit(state.copyWith(fetchState: BlocStatus.success(data))),
      failure: (message) => emit(state.copyWith(fetchState: BlocStatus.failure(message))),
    );
  }
}
```

---

## 🎨 UI Integration: `StatusBuilder<T>`

The UI must **NEVER** manually check status enums. Instead, use the **`StatusBuilder<T>`** widget to handle state transitions. This ensures a consistent "Loading" and "Error" experience across the entire app.

### Implementation Pattern

```dart
StatusBuilder<List<Entity>>(
  state: state.fetchState,
  onRefresh: () async => context.read<FeatureBloc>().add(const FeatureEvent.fetchRequested()),
  success: (data) => ListView.builder(
    itemCount: data.length,
    itemBuilder: (context, index) => EntityWidget(data[index]),
  ),
  // Optional overrides:
  // loading: () => CustomLoadingWidget(),
  // empty: () => CustomEmptyWidget(),
)
```

### Key Responsibilities of `StatusBuilder`

- **`initial`**: Displays nothing or a placeholder (configurable via `showInitWidget`).
- **`loading`**: Displays the standard `MainLoadingProgress` overlay.
- **`success`**: Provides the type-safe `data` to the success builder. Automatically handles "Empty State" if the data is a collection.
- **`failure`**: Displays a `FailedStateWidget` with localized error messages and a "Retry" button.

---

## 📂 Feature Directory Structure

Each feature is organized into three primary layers following Clean Architecture principles:

### 1. `constants/` (Static Domain)

- Contains `forms/` (`FormGroup` helpers) and localized UI constants.

### 2. `data/` (Implementation)

- `datasources/`, `models/` (DTOs), `mappers/`, and `repositories/` (Concrete implementations).

### 3. `domain/` (Pure Logic)

- `entities/` (Business objects), `repositories/` (Interfaces), and `facade/` (Service layer).

### 4. `presentation/` (Visuals)

- `states/` (BLoCs using Freezed).
- `ui/`:
  - `screens/`: Top-level page entry points.
  - `widgets/`: Feature-specific UI components (atomic Widgets).

#### Screen Implementation Standards

Every newly created Screen MUST adhere to these scaffolding rules to ensure routing consistency and global UI integration:

- **Static Routing Identifiers**: Each screen MUST define `static const String pagePath` and `static const String pageName` to be used by the global `GoRouter` configuration.
- **Mandatory Scaffold**: All screens MUST be wrapped in the custom **`AppScaffold`** widget. This ensures the screen correctly inherits the app's global drawer, search behavior, and premium styling.

**Example Screen Boilerplate:**

```dart
class NewFeatureScreen extends StatelessWidget {
  const NewFeatureScreen({super.key});

  static const String pagePath = '/new_feature_screen';
  static const String pageName = 'NewFeatureScreen';

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: NewFeatureBody(),
    );
  }
}
```

#### Presentation Layer Construction Standards

To ensure maximum scalability and code clarity, all UI implementation must follow these structural rules:

- **Decomposed Sections**: Large screens must be divided into logical **Sections** (e.g., `HeaderSection`, `FormSection`, `ActionSection`).
- **Atomic Widgets**: Each section should be composed of multiple smaller, focused **Widgets**.
- **File Isolation**: Every single widget and section MUST be placed in its own **separate file**. In-line widget declarations within larger files are not permitted.
- **Component Reusability**: All standard UI building blocks (spacers, buttons, typography) must be sourced from the global `DesignSystem` and never duplicated locally.

---

_For detailed technical deep-dives into specific infrastructure layers, visit the internal documentation in `lib/core/`._
