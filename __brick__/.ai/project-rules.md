# 🛑 UNIFIED AI DEVELOPER PROTOCOL — ALSULTAN PLATFORM (SINGLE-APP)

## ⚠️ MANDATORY READING — DO NOT WRITE A SINGLE LINE OF CODE BEFORE FINISHING THIS FILE

> **This document is law.** Every rule here is enforced without exception. There is no "close enough." Deviation from any rule below — no matter how minor it appears — is a project-level protocol failure. Guessing, assuming, or skipping ahead is strictly prohibited.

---

## 🔴 SECTION 0 — AI AGENT CONFIRMATION MANDATE

**In your FIRST response for every session, you MUST explicitly list every file path you have read before touching any code.** This is not optional. If you cannot confirm which files you have read, you are not permitted to write code.

**Required Format:**

```
✅ Files Read This Session:
- .ai/project-rules.md
- lib/lib_overview.md
- lib/features/features_overview.md
- lib/core/core_architecture_overview.md
- lib/common/common_folder_guide.md
- lib/utils/utils_folder_guide.md
- lib/core/services/objectbox/objectbox_service_guide.md  [if touching data/storage]
- lib/core/router/router_guide.md                        [if touching navigation]
- lib/core/services/session/session_service_guide.md     [if touching auth/session]
```

Failure to list these files = protocol violation. No exceptions.

---

## 🔴 SECTION 1 — MANDATORY READING ORDER (STRICT SEQUENCE)

You MUST read these files **in this exact order** before writing or modifying any code.

| Step | File Path                                                | Purpose                                                               |
| ---- | -------------------------------------------------------- | --------------------------------------------------------------------- |
| 1    | `.ai/project-rules.md`                                   | Protocol anchor — you are here                                        |
| 2    | `lib/lib_overview.md`                                    | App lifecycle, bootstrap sequence, complete layer map                 |
| 3    | `lib/features/features_overview.md`                      | Feature architecture, BLoC, state management                          |
| 4    | `lib/core/core_architecture_overview.md`                 | Design system, typography, theme, scaling                             |
| 5    | `lib/common/common_folder_guide.md`                      | Shared widgets, animations, UI standards                              |
| 6    | `lib/utils/utils_folder_guide.md`                        | Extensions, constants, helpers, tokens                                |
| 7    | `lib/core/services/objectbox/objectbox_service_guide.md` | Local data, persistence (read when touching storage)                  |
| 8    | `lib/core/router/router_guide.md`                        | Routing logic, guards, redirect rules (read when touching navigation) |
| 9    | `lib/core/services/session/session_service_guide.md`     | Session, Auth & JWT refresh flow                                      |

### 🗺️ Context Routing — When Working in Specific Layers

| Working in...        | MUST read FIRST...                       |
| -------------------- | ---------------------------------------- |
| `lib/core/`          | `lib/core/core_architecture_overview.md` |
| `lib/common/`        | `lib/common/common_folder_guide.md`      |
| `lib/features/`      | `lib/features/features_overview.md`      |
| `lib/utils/`         | `lib/utils/utils_folder_guide.md`        |
| `lib/core/router/`   | `lib/core/router/router_guide.md`        |
| App root / bootstrap | `lib/lib_overview.md`                    |

### 🔁 Component Duplication Rule — Zero Tolerance

Before creating ANY utility, widget, helper, or extension, you MUST audit:

- `lib/common/common_folder_guide.md`
- `lib/utils/utils_folder_guide.md`

If it already exists → **reuse it.** Creating a duplicate of an existing component is a protocol failure.

---

## 🔴 SECTION 2 — SELF-UPDATING DOCUMENTATION MANDATE

You are **co-responsible** for keeping documentation in sync with the codebase. Code changes without documentation updates are **incomplete tasks**.

**Rules:**

- If you add a new utility, widget, extension, or architecture pattern → update its `.md` file **before** finishing the task.
- If you add a major feature or dependency → update the global `README.md`.
- If you add any new component to `lib/common/` or `lib/utils/` → document it in the corresponding guide file immediately.
- Documentation must be **detailed, explanatory, and granular**. Large, comprehensive files are better than missing information.
- Never finish a task without confirming that documentation reflects all changes made.

---

## 🔴 SECTION 3 — LOCALIZATION & STRINGS (ZERO HARDCODING)

### Rule: No string may ever appear hardcoded in the UI layer. No exceptions

**Correct Workflow — Follow This Exactly:**

1. Check if the key already exists in `assets/l10n/ar.json` and `assets/l10n/en.json`. If it does → **reuse it.** Do not add duplicates.
2. If it is a new key → add it to **both** `ar.json` and `en.json`.
3. Run the generator:

   ```bash
   dart run tool/generate_app_strings.dart
   ```

4. Use the generated constant in the UI: `AppStrings.yourKey`.

**Violations — All Are FAIL States:**

- ❌ Hardcoding any string in a widget: `Text("Live")` — PROHIBITED
- ❌ Using `.tr()` directly on a raw string key: `'live'.tr()` — PROHIBITED
- ❌ Adding a new key without first checking for existing duplicates — PROHIBITED
- ❌ Adding a key to only one language file — PROHIBITED
- ❌ Running any `melos` command — melos is NOT used in this project. Use `dart run tool/generate_app_strings.dart` only.

---

## 🔴 SECTION 4 — TYPOGRAPHY RULES (AppTextStyles ONLY)

### Rule: NEVER use BuildContext text theme extensions or hardcode TextStyle properties

**Correct Usage:**

```dart
// ✅ CORRECT
Text("Title", style: AppTextStyles.s24w700)
Text("Body", style: AppTextStyles.s14w400.copyWith(color: context.primary))
Text("Label", style: AppTextStyles.s16w600.copyWith(color: context.onSurface))

// ❌ WRONG — ALL of these are violations:
Text("Title", style: context.titleMedium)             // Context text theme getter, PROHIBITED
Text("Body", style: context.bodySmall)                // Context text theme getter, PROHIBITED
Text("Label", style: context.displayLarge)            // Context text theme getter, PROHIBITED
Text("Title", style: TextStyle(fontSize: 24))         // Hardcoded TextStyle, PROHIBITED
Text("Body", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)) // Hardcoded, PROHIBITED
```

**Naming Convention:** `s[Size]w[Weight]`

| Style     | Meaning        | Use For        |
| --------- | -------------- | -------------- |
| `s40w700` | 40sp, Bold     | Display Large  |
| `s24w700` | 24sp, Bold     | Headline Large |
| `s16w600` | 16sp, SemiBold | Title Medium   |
| `s14w400` | 14sp, Regular  | Body Medium    |

**Color Rule:** All `AppTextStyles` are intentionally built WITHOUT hardcoded colors. Apply color via `.copyWith(color: ...)` using semantic context tokens only (see Section 6).

---

## 🔴 SECTION 5 — SCALING & RESPONSIVE DIMENSIONS (MANDATORY SUFFIXES)

All dimensions MUST use the correct responsive suffix. Raw numbers are protocol failures.

| Use Case                          | Extension | Correct Example                                              |
| --------------------------------- | --------- | ------------------------------------------------------------ |
| Font sizes                        | `.sp`     | `fontSize: 16.sp`                                            |
| Button heights (scale with text)  | `.sp`     | `height: 56.sp`                                              |
| Icon containers paired with text  | `.sp`     | `size: 24.sp`                                                |
| Fixed layout heights              | `.h`      | `height: 180.h`                                              |
| Fixed layout widths               | `.w`      | `width: 120.w`                                               |
| Vertical spacing between sections | `.h`      | `SizedBox(height: AppSpacing.lg.h)`                          |
| Horizontal margins and padding    | `.w`      | `padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w)` |
| Border radius                     | `.r`      | `BorderRadius.circular(AppRadii.lg.r)`                       |
| Icon sizes                        | `.r`      | `size: 24.r`                                                 |

**Violations:**

- ❌ `height: 180` — raw double, PROHIBITED
- ❌ `width: 120` — raw double, PROHIBITED
- ❌ `fontSize: 16` — raw double for font, PROHIBITED
- ❌ `BorderRadius.circular(12)` — missing `.r`, PROHIBITED
- ❌ `size: 24` on any icon — missing `.r`, PROHIBITED
- ❌ `SizedBox(height: 16)` — hardcoded spacing, PROHIBITED (use AppSpacing tokens)

---

## 🔴 SECTION 6 — COLORS & THEME (SEMANTIC TOKENS ONLY)

### Rule: NEVER use `Colors.*`, raw hex values, or `Theme.of(context)` directly

**Correct Color Access:**

```dart
// ✅ CORRECT — Context semantic tokens
color: context.primary
color: context.surface
color: context.onSurface
color: context.onSurfaceError

// ✅ CORRECT — AppColors named constants
color: AppColors.success
color: AppColors.warning
color: AppColors.error

// ❌ WRONG — ALL violations:
color: Colors.green                                  // Standard Flutter color, PROHIBITED
color: Colors.amber                                  // Standard Flutter color, PROHIBITED
color: Colors.white                                  // Standard Flutter color, PROHIBITED
color: Colors.black                                  // Standard Flutter color, PROHIBITED
color: Color(0xFF123456)                             // Hardcoded hex, PROHIBITED
color: Theme.of(context).colorScheme.primary         // Direct Theme access, PROHIBITED
color: context.colorScheme.primary                   // Direct colorScheme access, PROHIBITED
color: context.theme.primaryColor                    // Direct theme property, PROHIBITED
```

### Color Opacity Rule — `.withValues(alpha:)` ONLY

**NEVER use `.withOpacity()`.** It is deprecated. This is a hard rule.

```dart
// ✅ CORRECT
color: context.primary.withValues(alpha: 0.5)
color: context.onSurface.withValues(alpha: 0.2)

// ❌ WRONG
color: context.primary.withOpacity(0.5)    // DEPRECATED, PROHIBITED
color: Colors.black.withOpacity(0.3)       // DEPRECATED AND wrong color source, PROHIBITED
```

---

## 🔴 SECTION 7 — PADDING, MARGINS & SPACING TOKENS

### Rule: NEVER use standard `EdgeInsets`. Use `REdgeInsets` exclusively. Never use raw numbers for spacing

```dart
// ✅ CORRECT
padding: REdgeInsets.all(AppSpacing.md)
padding: REdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg)
padding: REdgeInsets.only(top: AppSpacing.s, bottom: AppSpacing.lg)
margin:  REdgeInsets.all(AppSpacing.s)

// ❌ WRONG — ALL violations:
padding: EdgeInsets.all(16)                          // Standard EdgeInsets, PROHIBITED
padding: EdgeInsets.symmetric(horizontal: 24)        // Standard EdgeInsets, PROHIBITED
padding: const EdgeInsets.only(top: 8)               // Standard EdgeInsets, PROHIBITED
padding: EdgeInsets.all(AppSpacing.md)               // EdgeInsets (not REdgeInsets), PROHIBITED
```

### AppSpacing Tokens — The Only Allowed Spacing Values

| Token            | Value | Primary Use                         |
| ---------------- | ----- | ----------------------------------- |
| `AppSpacing.xs`  | 4.0   | Tight gaps, icon inner padding      |
| `AppSpacing.sm`  | 8.0   | Small gaps, inner component spacing |
| `AppSpacing.md`  | 12.0  | Standard content padding            |
| `AppSpacing.lg`  | 16.0  | Section gaps, list item spacing     |
| `AppSpacing.xl`  | 24.0  | Screen-level horizontal padding     |
| `AppSpacing.xxl` | 32.0  | Large section separators            |

### AppRadii Tokens — The Only Allowed Corner Radius Values

| Token         | Value  | Primary Use            |
| ------------- | ------ | ---------------------- |
| `AppRadii.s`  | Small  | Tags, chips            |
| `AppRadii.m`  | Medium | Small cards, inputs    |
| `AppRadii.lg` | 16.0   | Standard cards, inputs |
| `AppRadii.xl` | Large  | Buttons, large cards   |

```dart
// ✅ CORRECT
BorderRadius.circular(AppRadii.lg.r)

// ❌ WRONG
BorderRadius.circular(12)           // Hardcoded number, PROHIBITED
BorderRadius.circular(16.0)         // Hardcoded number, PROHIBITED
```

### Vertical Spacing Rule

```dart
// ✅ CORRECT
SizedBox(height: AppSpacing.md.h)
AppSpacing.lg.verticalSpace         // if verticalSpace extension exists

// ❌ WRONG
SizedBox(height: 16)               // Hardcoded, PROHIBITED
SizedBox(height: 16.h)             // Raw number even with suffix, PROHIBITED
```

---

## 🔴 SECTION 8 — ICONS (FontAwesome ONLY)

### Rule: NEVER use Flutter's built-in `Icons` class or the standard `Icon` widget. Use `FaIcon` + `FontAwesomeIcons` exclusively

```dart
// ✅ CORRECT
FaIcon(FontAwesomeIcons.bell, size: 24.r)
FaIcon(FontAwesomeIcons.magnifyingGlass, size: 20.r)
FaIcon(FontAwesomeIcons.chevronRight, size: 16.r, color: context.primary)

// ❌ WRONG — ALL violations:
Icon(Icons.notifications)                        // Material Icon widget, PROHIBITED
Icon(Icons.search)                               // Material Icon widget, PROHIBITED
Icon(Icons.chevron_right, size: 16)              // Material Icon widget, PROHIBITED
FaIcon(FontAwesomeIcons.bell, size: 24)          // Missing .r on size, PROHIBITED
```

**Every `FaIcon` with a custom `size` MUST use `.r` suffix. No exceptions.**

---

## 🔴 SECTION 9 — SHADOWS & GRADIENTS (AppThemeEffects ONLY)

### Rule: NEVER define manual `BoxShadow` or `LinearGradient`. Use `AppThemeEffects` via BuildContext extensions

```dart
// ✅ CORRECT
decoration: BoxDecoration(
  boxShadow: context.shadows.primary,
  gradient: context.gradients.primary,
)
decoration: BoxDecoration(
  boxShadow: context.shadows.grey,
  gradient: context.gradients.surface,
)

// ✅ CORRECT — Fixed (theme-independent) effects, only when design explicitly requires it
decoration: BoxDecoration(
  gradient: AppThemeGradients.fixed.yourEffect,
)

// ❌ WRONG — ALL violations:
decoration: BoxDecoration(
  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]  // Manual BoxShadow, PROHIBITED
)
decoration: BoxDecoration(
  gradient: LinearGradient(colors: [Color(0xFF123456), Color(0xFF654321)])  // Manual Gradient, PROHIBITED
)
```

**Rule:** If a new effect is needed that does not exist in `AppThemeEffects`, it MUST be added to `AppThemeEffects` first — never defined ad-hoc inline.

---

## 🔴 SECTION 10 — SCAFFOLD (AppScaffold MANDATORY)

### Rule: NEVER use Flutter's standard `Scaffold` widget. Use `AppScaffold` for all screens

```dart
// ✅ CORRECT
class HomeScreen extends StatelessWidget {
  static const String pagePath = '/home';
  static const String pageName = 'HomeScreen';

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: HomeBody(),
    );
  }
}

// ✅ CORRECT — with search
AppScaffold.search(body: HomeBody())

// ❌ WRONG
Scaffold(body: HomeBody())           // Standard Scaffold, PROHIBITED
```

### Screen Routing Identifiers — Mandatory on Every Screen

Every screen MUST define these two static constants:

```dart
static const String pagePath = '/feature_name';
static const String pageName = 'FeatureNameScreen';
```

Screens without `pagePath` and `pageName` are incomplete and cannot be registered in `AppRouteRegistry`.

---

## 🔴 SECTION 11 — SCREEN & WIDGET DECOMPOSITION (HIERARCHY MANDATORY)

### Rule: Massive single-file UI trees are PROHIBITED. Every screen must follow the strict 3-tier hierarchy

**The Chain:**

```
Screen (entry point) → Section (large logical block) → Atomic Widget (smallest unit)
```

**Responsibilities per tier:**

| Tier          | Location                                 | Responsibility                                                    |
| ------------- | ---------------------------------------- | ----------------------------------------------------------------- |
| Screen        | `presentation/ui/screens/`               | Handles routing args, provides BlocProvider, wraps in AppScaffold |
| Section       | `presentation/ui/widgets/[logic_group]/` | Orchestrates atomic widgets, handles section-level layout         |
| Atomic Widget | `presentation/ui/widgets/[logic_group]/` | Renders one specific piece of data or one interaction             |

**File Isolation Rule:** Every Section and every non-trivial Atomic Widget MUST be in its own separate file. Inline private widget declarations (`class _MyWidget`) inside the same file as a Screen or Section are **strictly prohibited**.

```dart
// ✅ CORRECT file structure:
// home_screen.dart
// widgets/home_header/home_header_section.dart
// widgets/home_header/home_search_bar_widget.dart
// widgets/home_body/home_banner_section.dart
// widgets/home_body/home_product_card_widget.dart

// ❌ WRONG — everything in one file:
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(body: Column(children: [_Header(), _Body()]));
  }
}
class _Header extends StatelessWidget { ... }  // PROHIBITED — inline private widget
class _Body extends StatelessWidget { ... }    // PROHIBITED — inline private widget
```

---

## 🔴 SECTION 12 — BUTTONS (AppButton System ONLY)

### Rule: NEVER style buttons inline or use raw Flutter button widgets. Use the `AppButton` system exclusively

```dart
// ✅ CORRECT
AppButton.primaryGradient(
  label: AppStrings.submit,
  isActive: isFormValid,
  onPressed: _onSubmit,
)
AppButton.success(label: AppStrings.confirm, isActive: true, onPressed: _onConfirm)
AppButton.ghost(label: AppStrings.cancel, isActive: true, onPressed: _onCancel)

// ❌ WRONG — ALL violations:
ElevatedButton(onPressed: _onSubmit, child: Text("Submit"))  // Raw button, PROHIBITED
TextButton(onPressed: null, child: Text("Cancel"))           // Raw button, PROHIBITED
GestureDetector(onTap: _onSubmit, child: Container(...))     // Ad-hoc button, PROHIBITED
```

**Disable Rule:** Use `isActive: false` to disable a button. NEVER pass `null` to `onPressed`.

```dart
// ✅ CORRECT
AppButton.primaryGradient(isActive: false, onPressed: _onSubmit, label: AppStrings.submit)

// ❌ WRONG
AppButton.primaryGradient(isActive: true, onPressed: null, label: AppStrings.submit) // PROHIBITED
```

---

## 🔴 SECTION 13 — FORMS (Centralized Definitions MANDATORY)

### Rule: ALL `FormGroup` definitions MUST reside in an `abstract class` inside `constants/forms/`. Never inside screens or widgets

**Correct Structure:**

```dart
// ✅ CORRECT — feature_name/constants/forms/login_forms.dart
abstract class LoginForms {
  // Static constants for all field keys — prevents string typos
  static const String emailField    = 'email';
  static const String passwordField = 'password';

  // Static factory method for the FormGroup itself
  static FormGroup formGroup() => FormGroup({
    emailField: FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    passwordField: FormControl<String>(
      validators: [Validators.required, Validators.minLength(8)],
    ),
  });
}
```

**Usage in UI:**

```dart
// ✅ CORRECT
final form = LoginForms.formGroup();
final email = form.valueOf<String>(LoginForms.emailField);

// ❌ WRONG
FormGroup({'email': FormControl<String>()})           // Inline form, PROHIBITED
form.control('email').value                           // Raw string key, PROHIBITED
```

**Violations:**

- ❌ `FormGroup` defined inside a Screen widget — PROHIBITED
- ❌ `FormGroup` defined inside a BLoC — PROHIBITED
- ❌ Raw string literals used as form keys anywhere — PROHIBITED
- ❌ Multiple `FormGroup` objects defined across multiple locations for the same feature — PROHIBITED

---

## 🔴 SECTION 14 — STATE MANAGEMENT (BLoC + Freezed + BlocStatus)

### Rule: NEVER manually switch on BlocStatus enum values in the UI. ALWAYS use `StatusBuilder<T>`

**State — One `BlocStatus<T>` per async operation:**

```dart
// ✅ CORRECT
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(BlocStatus<List<ProductEntity>>.initial())
    BlocStatus<List<ProductEntity>> productsState,

    @Default(BlocStatus<void>.initial())
    BlocStatus<void> submitState,
  }) = _HomeState;
}
```

**BLoC — Correct async handler pattern:**

```dart
// ✅ CORRECT
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._facade) : super(const HomeState()) {
    on<_FetchRequested>(_onFetchRequested);
  }

  final HomeFacade _facade;

  Future<void> _onFetchRequested(_, Emitter<HomeState> emit) async {
    emit(state.copyWith(productsState: const BlocStatus.loading()));
    final result = await _facade.fetchProducts();
    result.when(
      success: (data) => emit(state.copyWith(productsState: BlocStatus.success(data))),
      failure: (msg)  => emit(state.copyWith(productsState: BlocStatus.failure(msg))),
    );
  }
}
```

**UI — `StatusBuilder<T>` is the ONLY permitted pattern:**

```dart
// ✅ CORRECT
StatusBuilder<List<ProductEntity>>(
  state: state.productsState,
  onRefresh: () async => context.read<HomeBloc>().add(const HomeEvent.fetchRequested()),
  success: (data) => ListView.builder(
    itemCount: data.length,
    itemBuilder: (_, i) => ProductCard(data[i]),
  ),
)

// ❌ WRONG — manual enum switching, PROHIBITED
if (state.productsState is BlocStatusLoading) {
  return CircularProgressIndicator();
} else if (state.productsState is BlocStatusSuccess) {
  return ProductList(state.productsState.data);
}
```

---

## 🔴 SECTION 15 — CLEAN DATA LAYER (Entities vs Models)

### Rule: The Presentation layer ONLY consumes Entities. Models must NEVER leak into UI or BLoC

**Entities (Domain Layer):**

- Pure Dart classes, immutable via `Freezed`
- **ZERO JSON logic** (`fromJson`, `toJson`, `json_serializable` annotations)
- Only consumed by BLoC/Facade and Presentation

**Models/DTOs (Data Layer):**

- Handle `fromJson` / `toJson` operations
- Mirror the API schema exactly
- **Never passed to BLoC or UI**

**Mappers (Mandatory):**

```dart
// ✅ CORRECT — Extension mapper on Model
extension ProductModelMapper on ProductModel {
  ProductEntity toEntity() => ProductEntity(
    id: id,
    name: name,
    price: price,
  );
}

// ✅ CORRECT — Usage in Repository
final models = await _dataSource.fetchProducts();
return models.map((m) => m.toEntity()).toList();
```

**Request Parameters Rule:**

```dart
// ✅ CORRECT — Dedicated RequestModel class
await _repository.updateProfile(UpdateProfileRequest(name: name, email: email));

// ❌ WRONG — Raw parameters, PROHIBITED
await _repository.updateProfile(name: name, email: email);
await _repository.updateProfile({'name': name, 'email': email});
```

---

## 🔴 SECTION 16 — ERROR HANDLING (Data Layer)

**Rule:** All async data operations MUST be wrapped with the correct utilities. Unprotected async calls are protocol failures.

```dart
// ✅ CORRECT — Remote/Local DataSource
Future<List<ProductModel>> fetchProducts() async {
  return rethrowAsAppException(() async {
    final response = await _dio.get(ApiEndpoints.products);
    return (response.data as List).map(ProductModel.fromJson).toList();
  });
}

// ✅ CORRECT — Repository
Future<Result<List<ProductEntity>>> fetchProducts() async {
  return runAsResult(() async {
    final models = await _dataSource.fetchProducts();
    return models.map((m) => m.toEntity()).toList();
  });
}

// ❌ WRONG — unprotected async, PROHIBITED
Future<List<ProductModel>> fetchProducts() async {
  final response = await _dio.get(ApiEndpoints.products); // No rethrowAsAppException, PROHIBITED
  return (response.data as List).map(ProductModel.fromJson).toList();
}
```

---

## 🔴 SECTION 17 — NAVIGATION & TYPED ROUTING

**Rules:**

- Routing is centralized via `GoRouter` in `lib/core/router/`
- Every screen requiring input data MUST define a typed `Args` class in the same file as the screen
- Data MUST be passed via `.extra` — never via raw query strings or path parameters when a typed object is available

```dart
// ✅ CORRECT — Typed Args class
class ProductDetailsScreenArgs {
  final int productId;
  final String categoryName;
  const ProductDetailsScreenArgs({required this.productId, required this.categoryName});
}

// ✅ CORRECT — Navigating with typed extra
context.pushNamed(
  ProductDetailsScreen.pageName,
  extra: ProductDetailsScreenArgs(productId: 42, categoryName: 'Food'),
);

// ✅ CORRECT — Receiving in destination screen
final args = GoRouterState.of(context).extra as ProductDetailsScreenArgs;

// ❌ WRONG
context.go('/product-details?id=42&category=Food')              // Raw query string, PROHIBITED
context.pushNamed(ProductDetailsScreen.pageName, extra: 42)     // Raw ID when Args exists, PROHIBITED
```

**Bootstrap Sequence Note:** Do NOT manually navigate during app startup. The `AppRouteGuard` drives startup via state — `AuthStateNotifier`, `OnboardingService`, and the splash delay timer. Modifying startup navigation logic requires reading `lib/core/router/router_guide.md` first.

---

## 🔴 SECTION 18 — ANIMATIONS (Mandatory for All UI)

Every screen section and major list widget MUST have a meaningful entry animation. Static, unanimated UI is a failure state.

**Tier 1 — `flutter_animate` (Primary Choice, Required for ~90% of cases):**

```dart
// ✅ CORRECT — Staggered list entry
ListView.builder(
  itemBuilder: (_, i) => ProductCard(data[i])
    .animate(delay: (i * 50).ms)
    .fadeIn(duration: 300.ms)
    .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),
)

// ✅ CORRECT — Section entry
HomeHeaderSection()
  .animate()
  .fadeIn(duration: 400.ms)
  .slideY(begin: -0.05, end: 0, duration: 400.ms)
```

**Tier 2 — Built-in Flutter Animations (Fallback for simple state-driven changes):**

- `AnimatedContainer` — when a container's size/color changes on a boolean
- `AnimatedOpacity` — when visibility toggles based on state
- `AnimatedPadding` — when spacing adjusts based on state

**Tier 3 — `AnimationController` (Advanced, last resort only):**

- Use ONLY when `flutter_animate` is provably insufficient or unreadable
- MUST document in code comments exactly why Tier 1 or 2 was insufficient

**Timing Tokens (AppDurations):**

| Token                 | Value | Use For                           |
| --------------------- | ----- | --------------------------------- |
| `AppDurations.fast`   | 150ms | Micro-interactions, hover effects |
| `AppDurations.normal` | 250ms | Standard transitions              |
| `AppDurations.slow`   | 350ms | Large section entries             |

---

## 🔴 SECTION 19 — IMPORTS & CODE QUALITY

**Barrel Import Rule:**

```dart
// ✅ CORRECT — Use centralized barrel import
import 'package:alsultan/common/imports/imports.dart';

// ✅ CORRECT — Package-level imports when barrel not used
import 'package:alsultan/features/home/domain/entities/product_entity.dart';

// ❌ WRONG — relative imports when package import is available
import '../../domain/entities/product_entity.dart';   // PROHIBITED
```

**Logging Rule — `colored_print.dart` ONLY:**

```dart
// ✅ CORRECT
printC('HomeBloc: Fetching products for category $categoryId');
printM('Navigation: Pushing ProductDetails with id $id');
printY('API: GET ${ApiEndpoints.products} — response ${response.statusCode}');

// ❌ WRONG
print('fetching products');        // PROHIBITED
debugPrint('going to details');    // PROHIBITED
log('api response');               // PROHIBITED
```

Use `printC` for general info, `printM` for state/BLoC events, `printY` for network/API calls.

**Comments Rule:**

- Write architectural comments that explain **WHY** — not what
- Explain data flow, edge cases, non-obvious decisions
- NEVER write obvious comments: `// returns a widget`, `// builds the UI`, `// creates a button`

**Code Cleanliness:**

- No unused imports — remove them before finishing any task
- No unused variables or methods
- No commented-out dead code left in final output

---

## 🔴 SECTION 20 — GLOBAL PROMOTION RULE

**Rule:** While working inside a feature, if you write a widget, helper, or logic block that COULD be useful in other features or globally — you MUST extract it.

- If reusable UI component → move to `lib/common/widgets/` and document in `common_folder_guide.md`
- If a pure utility or extension → move to `lib/utils/` and document in `utils_folder_guide.md`
- If feature-specific with zero reuse potential → leave it in the feature folder

Do NOT leave globally useful code buried inside one feature. This rule applies **proactively during development**, not just at review time.

---

## 🔴 SECTION 21 — WEBVIEW SECURITY

**Rule:** After every authentication cycle that uses a WebView, you MUST clear the WebView session (both cookies AND cache). Failure to do so leaks session state and is a security violation.

This is non-negotiable and applies to every authentication WebView regardless of flow type.

---

## 🔴 SECTION 22 — CODE GENERATION COMMANDS

**Only two commands are valid. All others are PROHIBITED.**

| Task                                         | Command                                                    |
| -------------------------------------------- | ---------------------------------------------------------- |
| Generate AppStrings from JSON files          | `dart run tool/generate_app_strings.dart`                  |
| Run build_runner (Freezed, injectable, etc.) | `dart run build_runner build --delete-conflicting-outputs` |

**PROHIBITED:**

- ❌ Any `melos` command — melos is not used in this project
- ❌ `flutter pub run build_runner build` — use the `dart run` form above
- ❌ Running build_runner without `--delete-conflicting-outputs`
- ❌ `dart run build_runner watch` in a one-off task context

---

## 🔴 SECTION 23 — FEATURE DIRECTORY STRUCTURE

Every feature MUST follow this exact directory structure. Adding files in non-standard locations is a violation.

```
lib/features/feature_name/
├── constants/
│   └── forms/
│       └── feature_forms.dart            # All FormGroup definitions (abstract class + static keys)
├── data/
│   ├── datasources/
│   │   ├── feature_remote_datasource.dart    # Wrapped in rethrowAsAppException
│   │   └── feature_local_datasource.dart
│   ├── models/
│   │   └── feature_model.dart                # DTOs: fromJson / toJson ONLY
│   ├── mappers/
│   │   └── feature_mapper.dart               # model.toEntity() extension or mapper class
│   └── repositories/
│       └── feature_repository_impl.dart      # Wrapped in runAsResult
├── domain/
│   ├── entities/
│   │   └── feature_entity.dart               # Pure Freezed class — ZERO JSON logic
│   ├── repositories/
│   │   └── feature_repository.dart           # Abstract interface only
│   └── facade/
│       └── feature_facade.dart               # Optional: orchestrates repository calls
└── presentation/
    ├── states/
    │   ├── feature_bloc.dart
    │   ├── feature_event.dart
    │   └── feature_state.dart                # Freezed + BlocStatus<T> per async op
    └── ui/
        ├── screens/
        │   └── feature_screen.dart           # One screen per file, AppScaffold, pagePath/pageName
        └── widgets/
            └── [logic_group]/
                ├── feature_header_section.dart
                ├── feature_body_section.dart
                └── feature_card_widget.dart  # One widget per file — no inline classes
```

---

## 🔴 SECTION 24 — DATE & INPUT FORMATTING

### Date Formatting Rule

Every date displayed in the UI MUST use the mandatory date extensions from `lib/utils/extensions/date_time_extensions.dart`. These extensions ensure Arabic-to-English digit normalization via `toLatinDigits()`.

```dart
// ✅ CORRECT
Text(myDate.toYmd())
Text(myDate.toSmartDateTime())
Text(myDate.toTime12Compact())

// ❌ WRONG
Text(DateFormat('yyyy-MM-dd').format(myDate))   // Direct DateFormat, PROHIBITED
Text(myDate.toString())                          // Raw toString, PROHIBITED
```

### Numeric Input Rule

Every numeric text input MUST use `ArabicToEnglishDigitsFormatter` from `lib/utils/helpers/input_formatters.dart`. This prevents Arabic numeral submission to the API.

```dart
// ✅ CORRECT
AppReactiveTextField(
  inputFormatters: [ArabicToEnglishDigitsFormatter()],
)
```

---

## 🔴 SECTION 25 — LOADING STATES & PREMIUM POLISH

### Rule: Mandatory Shimmer for Asynchronous States

Every screen or section that fetches data MUST provide a **Shimmer Effect** (skeleton loading) for its loading state. Static "Loading..." text or raw `CircularProgressIndicator` are strictly PROHIBITED for premium content areas.

```dart
// ✅ CORRECT
StatusBuilder<List<ProductEntity>>(
  state: state.productsState,
  loading: () => const ProductsListShimmer(), // Dedicated shimmer component
  success: (data) => ProductsList(data),
)

// ❌ WRONG
StatusBuilder<List<ProductEntity>>(
  state: state.productsState,
  loading: () => const CircularProgressIndicator(), // Raw spinner, PROHIBITED for list/content
  success: (data) => ProductsList(data),
)
```

Each shimmer component MUST mirror the approximate shape and layout of the content it replaces. Use `AppShimmer` from `lib/common/widgets/app_shimmer.dart` as the base.

---

## 🔴 SECTION 26 — ASSET MANAGEMENT (FlutterGen MANDATORY)

### Rule: NEVER use raw string paths for assets. Use the generated `Assets` class exclusively

```dart
// ✅ CORRECT
Image.asset(Assets.images.logo.path)
SvgPicture.asset(Assets.svgIcons.home.path)

// ❌ WRONG
Image.asset('assets/images/logo.png')      // Raw string path, PROHIBITED
SvgPicture.asset('assets/svgIcons/home.svg') // Raw string path, PROHIBITED
```

After adding any new asset file, you MUST run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

to regenerate the `Assets` class before referencing the new asset.

---

## 🔴 SECTION 27 — ATOMIC UI CONSISTENCY (MANDATORY PLATFORM COMPONENTS)

### Rule: No Inline Empty or Error State Widgets

Every "Empty" or "Error" state MUST use the standard platform components from `lib/common/widgets/`. Creating ad-hoc inline `Column(children: [Icon, Text])` blocks for these states is PROHIBITED.

```dart
// ✅ CORRECT — Standard error state
FailedStateWidget(
  message: AppStrings.somethingWentWrong,
  onRetry: () => _fetchData(),
)

// ✅ CORRECT — Standard empty state
EmptyStateWidget(
  message: AppStrings.noDataFound,
)

// ❌ WRONG — Ad-hoc inline states, PROHIBITED
Column(
  children: [
    Icon(Icons.warning_amber),              // PROHIBITED — uses Icons.*, AND ad-hoc
    Text("Something went wrong"),           // PROHIBITED — hardcoded string
    TextButton(onPressed: _fetchData, child: Text("Retry")), // PROHIBITED — raw button
  ],
)
```

### Rule: No Inline Loading Indicators

Use `MainLoadingProgress` from `lib/common/widgets/main_loading_progress.dart` for full-screen blocking loaders, and `LoadingDots` for inline/button-level loading. Never use raw `CircularProgressIndicator` directly.

```dart
// ✅ CORRECT
const MainLoadingProgress()   // Full-screen block
const LoadingDots()           // Inline / inside button

// ❌ WRONG
const CircularProgressIndicator()   // Raw spinner, PROHIBITED
```

---

## 🔴 SECTION 28 — COMPLETE VIOLATION CHECKLIST (FAIL STATES)

Before marking any task as complete, verify you have NOT committed any of the following. Each is a hard failure.

### 🌍 Localization

- [ ] ❌ Hardcoded string in UI (`Text("Submit")`)
- [ ] ❌ `.tr()` used directly on a raw key string
- [ ] ❌ New key added without checking for existing duplicates first
- [ ] ❌ Key added to only one language file
- [ ] ❌ Used any `melos` command instead of `dart run tool/generate_app_strings.dart`

### 🎨 Typography

- [ ] ❌ Used `context.titleMedium`, `context.bodySmall`, or any context text theme getter
- [ ] ❌ Used inline `TextStyle(fontSize: ..., fontWeight: ...)` definition
- [ ] ❌ Used color directly inside `AppTextStyles` without `.copyWith(color: ...)`

### 📐 Scaling

- [ ] ❌ Raw `double` for height/width without suffix (`height: 180`)
- [ ] ❌ Font size without `.sp` (`fontSize: 16`)
- [ ] ❌ Icon size without `.r` (`size: 24`)
- [ ] ❌ BorderRadius without `.r` and AppRadii token (`BorderRadius.circular(12)`)
- [ ] ❌ `SizedBox(height: 16)` — raw spacing instead of AppSpacing token

### 🎨 Colors

- [ ] ❌ Used `Colors.green`, `Colors.white`, `Colors.black`, etc.
- [ ] ❌ Used raw hex `Color(0xFF...)`
- [ ] ❌ Used `Theme.of(context).colorScheme.*`
- [ ] ❌ Used `context.colorScheme.*` directly
- [ ] ❌ Used `.withOpacity()` instead of `.withValues(alpha: ...)`

### 📦 Padding & Spacing

- [ ] ❌ Used `EdgeInsets.*` instead of `REdgeInsets.*`
- [ ] ❌ Used hardcoded `SizedBox(height: N)` instead of `AppSpacing` token
- [ ] ❌ Used `BorderRadius.circular(N)` instead of `AppRadii` + `.r`

### 🖼️ Icons

- [ ] ❌ Used `Icon(Icons.*)` anywhere in the codebase
- [ ] ❌ Used `FaIcon` without `.r` on the size parameter

### 💫 Shadows & Gradients

- [ ] ❌ Used manual `BoxShadow(...)` definition
- [ ] ❌ Used manual `LinearGradient(...)` definition
- [ ] ❌ Did not use `context.shadows.*` / `context.gradients.*`

### 🏗️ Architecture & Structure

- [ ] ❌ Used standard `Scaffold` instead of `AppScaffold`
- [ ] ❌ Screen missing `static const pagePath` or `static const pageName`
- [ ] ❌ Declared inline private widgets (`class _Widget`) inside a Screen file
- [ ] ❌ Used `ElevatedButton`, `TextButton`, or raw `GestureDetector` instead of `AppButton`
- [ ] ❌ Passed `null` to `onPressed` to disable a button — use `isActive: false`
- [ ] ❌ Placed `FormGroup` definition inside a Screen, Widget, or BLoC file
- [ ] ❌ Used raw string literals as form field keys (`form.control('email')`)
- [ ] ❌ Manually switched on `BlocStatus` enum in UI instead of `StatusBuilder<T>`
- [ ] ❌ Exposed a `Model` (DTO) to the Presentation or BLoC layer
- [ ] ❌ Passed raw parameters to Repository instead of a `RequestModel` class

### 💾 Data Layer

- [ ] ❌ DataSource method not wrapped in `rethrowAsAppException()`
- [ ] ❌ Repository method not wrapped in `runAsResult()`
- [ ] ❌ No Mapper defined between Model and Entity

### 📝 Code Quality

- [ ] ❌ Used `print()` or `debugPrint()` instead of `printC` / `printM` / `printY`
- [ ] ❌ Left unused imports in any file
- [ ] ❌ Used relative imports where package imports are available
- [ ] ❌ Left commented-out dead code in final output
- [ ] ❌ Failed to update documentation `.md` after adding a new component

### 📅 Formatting

- [ ] ❌ Used raw `DateFormat` instead of date extension methods
- [ ] ❌ Numeric input missing `ArabicToEnglishDigitsFormatter`

### 🖼️ Assets

- [ ] ❌ Used a raw string path for an asset instead of the generated `Assets` class

### 🔄 Loading & Empty States

- [ ] ❌ Content area uses raw `CircularProgressIndicator` instead of a shimmer component
- [ ] ❌ Error state uses an ad-hoc inline widget instead of `FailedStateWidget`
- [ ] ❌ Empty state uses an ad-hoc inline widget instead of `EmptyStateWidget`

### 🔐 Security

- [ ] ❌ Failed to clear WebView cookies and cache after any auth cycle

### 🎬 Animations

- [ ] ❌ Any screen section or list item has no entry animation

---

## 🔴 SECTION 29 — FINAL COMPLETION CHECKLIST

Before declaring any task complete, answer YES to every item below:

1. ✅ Did I read ALL mandatory files in the correct order and list them in my first response?
2. ✅ Did I audit `common_folder_guide.md` and `utils_folder_guide.md` before creating anything new?
3. ✅ Are ALL user-visible strings in `AppStrings` constants (no hardcoding, no `.tr()`)?
4. ✅ Are ALL text styles from `AppTextStyles.sXXwXXX` with `.copyWith(color:)` for colors?
5. ✅ Are ALL dimensions using `.sp`, `.h`, `.w`, `.r` suffixes — zero raw doubles?
6. ✅ Are ALL colors from `AppColors` or `context.*` semantic tokens?
7. ✅ Are ALL paddings using `REdgeInsets` with `AppSpacing` tokens?
8. ✅ Are ALL icons using `FaIcon(FontAwesomeIcons.*)` with `.r` on size?
9. ✅ Are ALL shadows and gradients via `context.shadows.*` / `context.gradients.*`?
10. ✅ Is every screen using `AppScaffold` with `pagePath` and `pageName`?
11. ✅ Is every widget in its own file — no inline private classes?
12. ✅ Is every button using `AppButton` system with `isActive` (not null `onPressed`)?
13. ✅ Is every `FormGroup` in `constants/forms/` as an `abstract class` with static keys?
14. ✅ Is every async UI state handled via `StatusBuilder<T>`?
15. ✅ Is every DataSource call wrapped in `rethrowAsAppException()`?
16. ✅ Is every Repository call wrapped in `runAsResult()`?
17. ✅ Is every Model → Entity conversion done via a Mapper?
18. ✅ Did I use `dart run tool/generate_app_strings.dart` (NOT melos, NOT flutter pub run)?
19. ✅ Did I use `dart run build_runner build --delete-conflicting-outputs`?
20. ✅ Did I use `printC` / `printM` / `printY` for all debug logging?
21. ✅ Did I update all relevant `.md` documentation files?
22. ✅ Did every screen section and list widget get a `flutter_animate` entry animation?
23. ✅ Is `.withValues(alpha:)` used — not `.withOpacity()`?
24. ✅ Did I clear WebView session (cookies + cache) after any auth cycle?
25. ✅ Are all dates rendered via the mandatory date extension methods?
26. ✅ Do all numeric inputs use `ArabicToEnglishDigitsFormatter`?
27. ✅ Are all assets referenced via the generated `Assets` class (not raw strings)?
28. ✅ Do all loading states use shimmer / `MainLoadingProgress` / `LoadingDots`?
29. ✅ Do all error and empty states use `FailedStateWidget` / `EmptyStateWidget`?

---

_End of Unified Project Rules — Single-App Flutter Project. This file supersedes all previous partial documentation. When in conflict with older `.md` files, this file takes precedence._

### 🔐 Security

- [ ] ❌ Failed to clear WebView cookies and cache after any auth cycle

### 🎬 Animations

- [ ] ❌ Any screen section or list item has no entry animation

---

## 🔴 SECTION 29 — FINAL COMPLETION CHECKLIST

Before declaring any task complete, answer YES to every item below:

1. ✅ Did I read ALL mandatory files in the correct order and list them in my first response?
2. ✅ Did I audit `common_folder_guide.md` and `utils_folder_guide.md` before creating anything new?
3. ✅ Are ALL user-visible strings in `AppStrings` constants (no hardcoding, no `.tr()`)?
4. ✅ Are ALL text styles from `AppTextStyles.sXXwXXX` with `.copyWith(color:)` for colors?
5. ✅ Are ALL dimensions using `.sp`, `.h`, `.w`, `.r` suffixes — zero raw doubles?
6. ✅ Are ALL colors from `AppColors` or `context.*` semantic tokens?
7. ✅ Are ALL paddings using `REdgeInsets` with `AppSpacing` tokens?
8. ✅ Are ALL icons using `FaIcon(FontAwesomeIcons.*)` with `.r` on size?
9. ✅ Are ALL shadows and gradients via `context.shadows.*` / `context.gradients.*`?
10. ✅ Is every screen using `AppScaffold` with `pagePath` and `pageName`?
11. ✅ Is every widget in its own file — no inline private classes?
12. ✅ Is every button using `AppButton` system with `isActive` (not null `onPressed`)?
13. ✅ Is every `FormGroup` in `constants/forms/` as an `abstract class` with static keys?
14. ✅ Is every async UI state handled via `StatusBuilder<T>`?
15. ✅ Is every DataSource call wrapped in `rethrowAsAppException()`?
16. ✅ Is every Repository call wrapped in `runAsResult()`?
17. ✅ Is every Model → Entity conversion done via a Mapper?
18. ✅ Did I use `dart run tool/generate_app_strings.dart` (NOT melos, NOT flutter pub run)?
19. ✅ Did I use `dart run build_runner build --delete-conflicting-outputs`?
20. ✅ Did I use `printC` / `printM` / `printY` for all debug logging?
21. ✅ Did I update all relevant `.md` documentation files?
22. ✅ Did every screen section and list widget get a `flutter_animate` entry animation?
23. ✅ Is `.withValues(alpha:)` used — not `.withOpacity()`?
24. ✅ Did I clear WebView session (cookies + cache) after any auth cycle?
25. ✅ Are all dates rendered via the mandatory date extension methods?
26. ✅ Do all numeric inputs use `ArabicToEnglishDigitsFormatter`?
27. ✅ Are all assets referenced via the generated `Assets` class (not raw strings)?
28. ✅ Do all loading states use shimmer / `MainLoadingProgress` / `LoadingDots`?
29. ✅ Do all error and empty states use `FailedStateWidget` / `EmptyStateWidget`?

---

_End of Unified Project Rules — Single-App Flutter Project. This file supersedes all previous partial documentation. When in conflict with older `.md` files, this file takes precedence._

_End of Unified Project Rules — Single-App Flutter Project. This file supersedes all previous partial documentation. When in conflict with older `.md` files, this file takes precedence._
