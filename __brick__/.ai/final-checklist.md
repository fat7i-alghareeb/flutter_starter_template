# Final checklist

Walk this before you say a task is done. Tick only what applies; for each item you skip, be ready to say why.
Every line is checkable — if you cannot check it, the task is not finished.

## Text and language

- [ ] Every visible string is an `AppStrings.x`, present in both `ar.json` and `en.json` (no literal in a widget).
- [ ] You searched for an existing key before adding one; no sentence sits under two keys.
- [ ] `dart run tool/generate_app_strings.dart` ran after editing the JSON.
- [ ] Counted sentences are plural groups; numbers go through `AppFormats`; numeric inputs use `ArabicToEnglishDigitsFormatter`.
- [ ] Looked at in Arabic (RTL) **and** English; start/end used, never left/right.

## Look and layout

- [ ] Type is a theme role (`Theme.of(context).textTheme.x`); colour changed with `copyWith(color:)` only.
- [ ] Colour is from `colorScheme` / `context.semantic`; no `Colors.*`, no hex, `.withValues(alpha:)` not `.withOpacity()`.
- [ ] Spacing, radius and icon size are tokens (`AppSpacing`, `AppRadii`, `AppIconSizes`); no `.sp .h .w .r`; gaps are `x.verticalSpace`.
- [ ] Icons are `AppIcon(AppIcons.x)`; no `Icons.*`.
- [ ] Layout follows the window size class (`context.layout`, `AdaptiveLayout`), not a device, orientation or `Platform.isX`.
- [ ] Platform-only plugins are called behind `AppPlatform` or a DI service.
- [ ] Checked at **390 · 820 · 1280** wide, portrait and landscape, light and dark, 1.3× text — no overflow, nothing cut off.
- [ ] Wide windows: content is capped (`AppContentWidth`); forms use `AppFormFieldGrid`.
- [ ] With a mouse and the keyboard: hover, tooltips on icon buttons, a visible focus ring, shortcuts still work, Tab order is sane.
- [ ] Text-holding boxes have no fixed height.
- [ ] A screen is `AppScaffold.*` (or `Scaffold` with a comment why) and has `pagePath` and `pageName`.

## Components

- [ ] Buttons are `AppButton`. **No grey on an active button** — "Cancel", "Exit", "Close", "Reset" are `error` (or `primary`).
      Unavailable buttons use `isActive: false`.
- [ ] A count is `AppCountBadge`; fields are `AppReactive*Field`; empty and error states are `EmptyStateWidget` / `FailedStateWidget`.
- [ ] Content loading is a `SkeletonWidget` over one layout, with a line in `skeleton_parity_test.dart`; no spinner for content.
- [ ] Animations are finite, honour reduced motion, and are absent where they only add noise.
- [ ] Assets come from the generated `Assets`; nothing reserved by a raw path.
- [ ] A reusable piece is in `lib/common/` (or `lib/utils/`), not copied into a feature.

## Architecture and data

- [ ] Files sit where `.ai/architecture-rules.md` says; entity / model / mapper / params / data source / repository / facade are separate.
- [ ] Models never reach a bloc or a widget; every API call takes a `…Params` class.
- [ ] Data sources wrap IO in `rethrowAsAppException`; repositories wrap in `runAsResult`.
- [ ] One `BlocStatus<T>` per async operation, rendered with `StatusBuilder<T>`.
- [ ] Forms keep field keys as constants (`constants/forms/` when shared).
- [ ] A new page is an `AppPage` opened with `AppNavigator.push`; ids travel in the path; `context.go` only replaces the stack.
- [ ] Guard, session or onboarding changes were checked against `router_guide.md` / `session_service_guide.md`; storage changes
      against `objectbox_service_guide.md`.
- [ ] Nothing new runs before `runApp` unless the first frame cannot render without it.

## Verification

- [ ] `flutter analyze` → **No issues found**, no new `// ignore`.
- [ ] `flutter test` → green. New behaviour has tests; a visual change has re-recorded goldens that you looked at.
- [ ] Works with `--dart-define=USE_MOCK=true`; new endpoints have fixtures in `assets/mock/`.
- [ ] Generated files were regenerated, not edited, and are included in the change.
- [ ] No `melos`, `flutter pub run`, or `build_runner watch` was used.

## Code and docs

- [ ] No unused imports, variables or commented-out code; logs use the coloured helpers, never `print`.
- [ ] Comments explain why.
- [ ] Docs updated for anything reusable: `lib/common/common_folder_guide.md`, `lib/utils/utils_folder_guide.md`,
      `docs/COMMANDS.md`, `docs/PROJECT_MAP.md`, `docs/DECISIONS.md` (durable decisions), `DESIGN_SYSTEM.md` (visual rules).

## Security

- [ ] No secret, token or personal data in code, logs or fixtures.
- [ ] A WebView sign-in clears cookies **and** cache afterwards.
- [ ] Signing files, `google-services.json`, keystores and `.env` files are not committed.
