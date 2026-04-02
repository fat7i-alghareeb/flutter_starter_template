# 🧩 Utilities & Design Tokens Guide (`lib/utils/`)

## 🛑 AI AGENT MANDATE (READ BEFORE PROCEEDING)

This document is an **Exhaustive Technical Encyclopedia** for the utilities layer. You **MUST** refer to this document before using any constant, extension, or helper in the application.

- **Global Protocol**: [.ai/project-rules.md](.ai/project-rules.md)
- **Hierarchy Protocol**: [lib/features/features_overview.md](lib/features/features_overview.md)

Failure to use the existing tools described here and instead duplicating logic is a protocol violation.

---

## 🏛️ 1. Constants Encyclopedia (`lib/utils/constants/`)

### `app_flow_constants.dart`

Contains global switches and storage keys for application-level flows.

- **`OnboardingStorageKeys`**: `finished` (tracks if onboarding is done).
- **`SplashConfig`**: `initialDelay` (4s minimum splash).
- **`AppFlowConfig`**: `onboardingEnabled`, `authEnabled` (toggle core flows).
- **`RouterLogTags`**: Standardized tags for routing logs.

### `auth_constants.dart` (HARD PATH)

The single source of truth for Authentication infrastructure.

- **`AuthStorageKeys`**: `user`, `guestFlag`, `jwtToken`.
- **`OAuthConstants`**:
  - `authBaseUrl`: `https://nsyuser.i-myapp.com`
  - `clientId`: `PostmanLocal`
  - `scope`: `openid profile offline_access local_app_api`
- **`AuthLogTags`**: Use these for all `colored_print` calls in the auth layer.

### `design_constants.dart` (DESIGN SYSTEM)

Mandatory tokens for layout. No raw `double` literals allowed.

- **`AppSpacing`**: `xs(4)`, `sm(8)`, `md(12)`, `lg(16)`, `xl(24)`, `xxl(32)`.
- **`AppRadii`**: Standard corner rounding tokens. Use `.lg` (16) for cards.
- **`AppDurations`**: `fast(150ms)`, `normal(250ms)`, `slow(350ms)`.

---

## 🧩 2. Extensions Encyclopedia (`lib/utils/extensions/`)

### `context_extensions.dart`

Ergonomic shortcuts for `BuildContext`.

- **Theme**: `context.theme`, `context.colorScheme`.
- **Colors**: `context.primary`, `context.surface`, `context.onSurfaceError`.
- **Typography**: `context.displayLarge` through `context.bodyMedium`.

### `date_time_extensions.dart` (MANDATORY FORMATTING)

Every date in the UI must use these extensions to ensure Arabic-to-English digit normalization via `toLatinDigits()`.

- **Formatting**: `toYmd()`, `toTime24()`, `toTime12Compact()`, `toSmartDateTime()`.
- **Calendar**: `isToday`, `startOfDay`, `copyWith()`.
- **Parsing**: `String.toDateTimeOrNull()`.

### `string_extensions.dart`

- **Nullable**: `isNullOrEmpty`, `isNullOrBlank`.
- **Transform**: `capitalizeFirst()`, `capitalizeWords()`, `ellipsis(length)`.
- **Color**: `toColor()` (Parses hex strings like `#FF0000` to Flutter `Color`).

### `widget_extensions.dart`

- **Spacing**: `widget.paddingAll(8.w)`, `widget.paddingOnly(bottom: 12.h)`.
- **Logic**: `.paddingSymmetric` using `.w` and `.h` responsive tokens.

### `reactive_forms_extensions.dart`

- **Access**: `formGroup.valueOf<T>(key)` - The mandatory way to extract values from reactive forms.

---

## 🏗️ 3. Generators Encyclopedia (`lib/utils/gen/`)

- **`app_strings.g.dart`**: Contains all localized strings. Access via `AppStrings.xxx`.
- **`assets.gen.dart`**: Type-safe asset access. Use `Assets.images.xxx` or `Assets.icons.xxx`.

---

## 🛠️ 4. Helpers Encyclopedia (`lib/utils/helpers/`)

### `build_svg_icon.dart`

Standard icon builder. Ensures consistent sizing and coloring for SVGs.

### `colored_print.dart` (MANDATORY LOGGING)

Never use `print()` or `debugPrint()` directly. Use the colored variants:

- `printC(msg)`: Cyan (General Info)
- `printM(msg)`: Magenta (State/Bloc)
- `printY(msg)`: Yellow (Network/API)

### `input_formatters.dart` (HARD REQUIREMENT)

Mandatory for use in `AppReactiveTextField`.

- **`ArabicToEnglishDigitsFormatter`**: Forces all numeric input to English digits.
- **`AppNumericTextFormatter`**: Standard numeric mask.

### `jwt_token_utils.dart`

Helper to parse JWT payload without validating signature. Use to check token expiry or basic user fields.

---

_For architectural integration rules, see [.ai/project-rules.md](.ai/project-rules.md)._
