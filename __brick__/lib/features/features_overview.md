# Features overview

How a product feature is built: structure, state, UI, data and navigation. Rules in short: `.ai/architecture-rules.md` and
`.ai/flutter-ui-rules.md`. Start a new one with the spec (`docs/FEATURE_SPEC_TEMPLATE.md`) and the generator
(`dart run tool/generate_feature.dart <name> --mock`).

## The features in this app

| Feature | Role |
| --- | --- |
| `splash`, `onboarding` | First-run screens |
| `auth` | Sign-in (a wall, or a page pushed over the app), the sign-in sheet for protected actions, the session-expired banner. **The full-structure example** |
| `root` | The shell — see below |
| `settings` | Language, theme, shortcuts, account |
| `showcase_feed` | The **behaviour** reference: lazy sections, paging, search, detail page, skeletons, mock data, tests. Its layers are condensed into one file each; copy how it behaves, not its folder layout |

### The `root` feature is the shell

`RootScreen` owns the `Scaffold` and the navigation, and chooses its shape from the window size (`AppLayoutScope.navOf`): the
floating capsule (`AppBottomNav`), the 80dp rail, or the collapsible sidebar (`AppSideNav`). It keeps every tab alive
(`RootTabStack`), asks for the notification permission once the reader is in, guards the back button (`RootBackGuard`), and
hosts the demo tabs in `widgets/showcase/`. A tab has no `Scaffold`; it gets its padding from the shell.

## Structure

```text
lib/features/<name>/
├── constants/                # route constants; forms/ (FormGroup + static field keys)
├── data/
│   ├── datasources/          # IO only
│   ├── models/               # DTOs: fromJson / toJson
│   ├── mappers/              # Model → Entity
│   ├── params/               # one `…Params` per API call
│   └── repositories/         # implementations
├── domain/
│   ├── entities/             # pure objects
│   ├── repositories/         # contracts (return Result<T>)
│   └── facade/               # orchestration used by the bloc
└── presentation/
    ├── states/               # bloc, event, state
    └── ui/{screens,widgets}/
```

## State: bloc + Freezed

One `BlocStatus<T>` per async operation, so independent operations cannot disturb each other.

```dart
@freezed
class FeatureState with _$FeatureState {
  const factory FeatureState({
    @Default(BlocStatus<List<Entity>>.initial()) BlocStatus<List<Entity>> fetchState,
    @Default(BlocStatus<void>.initial()) BlocStatus<void> submitState,
  }) = _FeatureState;
}

@freezed
class FeatureEvent with _$FeatureEvent {
  const factory FeatureEvent.fetchRequested() = _FetchRequested;
  const factory FeatureEvent.submitRequested(SubmitParams params) = _SubmitRequested;
}

@injectable
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc(this._facade) : super(const FeatureState()) {
    on<_FetchRequested>(_onFetchRequested);
  }
  final FeatureFacade _facade;

  Future<void> _onFetchRequested(_FetchRequested event, Emitter<FeatureState> emit) async {
    emit(state.copyWith(fetchState: const BlocStatus.loading()));
    final result = await _facade.fetch();
    result.when(
      success: (data) => emit(state.copyWith(fetchState: BlocStatus.success(data))),
      failure: (message) => emit(state.copyWith(fetchState: BlocStatus.failure(message))),
    );
  }
}
```

A bloc is a DI **factory**: provide it with `BlocProvider(create: (_) => getIt<FeatureBloc>())`. Never ask `getIt` for one inside
`build` — each rebuild would create a new bloc and a result would land on one nobody listens to.

## UI: `StatusBuilder<T>`

Never switch on a status by hand.

```dart
StatusBuilder<List<Entity>>(
  state: state.fetchState,
  onRefresh: () async => context.read<FeatureBloc>().add(const FeatureEvent.fetchRequested()),
  success: (data) => /* the loaded UI */,
  // optional: loading: () => …, empty: () => …, isEmpty: (data) => …, init: () => …
)
```

`initial` shows nothing (or `init`), `loading` the standard progress (or `loading`), `success` your builder (an empty collection
gets the empty state), `failure` a `FailedStateWidget` with a localised message and Retry. For content that has its own layout,
render a `SkeletonWidget` while loading instead of the default progress.

## Screens

- Build on `AppScaffold.body|appBar|search|all` (a hero or sliver page may use `Scaffold`; say why in a comment).
- Define `static const String pagePath` and `pageName`, and register an `AppPage`. Pushed pages use a **relative** path
  (`'orders/:id'`); only top-level routes are absolute (`'/splash'`).

  ```dart
  class OrderScreen extends StatelessWidget {
    const OrderScreen({super.key});
    static const String pagePath = 'orders/:id';
    static const String pageName = 'OrderScreen';

    @override
    Widget build(BuildContext context) => AppScaffold.body(child: const OrderBody());
  }
  ```

- Decompose: **screen** (route arguments, `BlocProvider`, scaffold) → **section** (one block, its layout) → **atomic widget**
  (one piece of data or one control). Each non-trivial one in its own file; no large private widget classes inside a screen.
- Pull standard pieces from the design system (`DESIGN_SYSTEM.md`, `lib/common/common_folder_guide.md`) instead of duplicating them.
- Adapt to the window: gutter, columns, content width, side-by-side detail (`docs/RESPONSIVE.md`).

## Navigation

1. Every screen is an `AppPage`, opened with `AppNavigator.push(context, AppPage.x, params: {...})`; it nests under the page that
   opens it.
2. Ids travel in the path (`orders/:id`); the screen re-reads by id, so a deep link or a restored stack works.
3. `extra` only for what a page cannot re-read by id: a typed arguments class, cast back explicitly.
4. `context.go` replaces the whole stack — sign-out and the login wall only.

Details and how to add a page: `lib/core/router/router_guide.md`.

## Data layer

1. **Entity** — pure business object. No JSON, no API field names.
2. **Model** — what the API sends; `fromJson` / `toJson`. Never leaves `data/`.
3. **Params** — the typed input of one call (`SignInParams`), never a raw map.
4. **Mapper** — `Model → Entity` (`toEntity()` or a mapper class).
5. **DataSource** — IO only, wrapped in `rethrowAsAppException`.
6. **Repository** — contract in `domain/`, implementation in `data/`, returns `Result<T>` via `runAsResult`.
7. **Facade** — turns repository calls into one business result for the bloc.

## Forms

Field keys are constants. A form used by more than one file is an `abstract class` in `constants/forms/` with static keys and a
static factory for the `FormGroup`; one owned by a single screen may keep private constants in that file. Fields are
`AppReactiveTextField` / dropdown / date-time, laid out with `AppFormFieldGrid`.
