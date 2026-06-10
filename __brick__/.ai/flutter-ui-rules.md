# Flutter UI Rules

Read this file when touching UI, widgets, screens, theme, visual states, assets, or animations.

## Typography

- Use `AppTextStyles.sXXwXXX` only.
- Do not create inline `TextStyle(fontSize: ..., fontWeight: ...)` in widgets.
- Do not use context text-theme shortcuts such as `context.titleMedium` or `context.bodySmall`.
- Apply colors with `.copyWith(color: context.semanticColor)` when needed.
- Text styles should not introduce hardcoded colors.

## Dimensions, Spacing, and Radius

- Avoid raw layout numbers.
- Use `AppSpacing` for gaps, padding, and margins.
- Use `AppRadii` for corner radius.
- Use `flutter_screenutil` suffixes for UI dimensions:
  - `.sp` for font sizes and text-scaled controls.
  - `.h` for vertical layout sizes.
  - `.w` for horizontal layout sizes.
  - `.r` for icon sizes and radius values.
- Use `x.verticalSpace` and `y.horizontalSpace` for simple gaps.
- Do not use `SizedBox(height: x)` or `SizedBox(width: y)` for spacing-only gaps.
- Use `REdgeInsets` instead of standard `EdgeInsets` for responsive padding and margin.

Reasonable exceptions are allowed for values that are not visual layout dimensions:

- `0`
- `1` pixel borders or dividers
- flex values
- opacity values
- indexes, counts, and item lengths
- animation curve/tween values
- `double.infinity`

## Colors and Effects

- Use semantic context colors such as `context.primary`, `context.surface`, `context.onSurface`, and `context.onSurfaceError`.
- Use named `AppColors` constants only for approved fixed meanings such as success, warning, or error.
- Do not use `Colors.*`, raw `Color(0x...)`, direct `Theme.of(context)`, or direct `context.colorScheme.*` in UI.
- Use `.withValues(alpha: ...)`; do not use `.withOpacity()`.
- Use `context.shadows.*` and `context.gradients.*` from the theme effects system.
- If a new reusable shadow or gradient is needed, add it to the theme effects layer instead of defining it inline.

## Screens and Decomposition

- Every screen uses `AppScaffold`, never standard `Scaffold`.
- Every screen defines:

```dart
static const String pagePath = '/feature_name';
static const String pageName = 'FeatureNameScreen';
```

- UI should follow the hierarchy: Screen -> Section -> Atomic Widget.
- Put sections and non-trivial widgets in separate files.
- Avoid inline private widget classes inside screens or large sections.

## Buttons and Interactions

- Use `AppButton` variants for buttons.
- Do not use raw `ElevatedButton`, `TextButton`, or ad-hoc tappable containers for app actions.
- Disable buttons with `isActive: false`; do not pass `null` to `onPressed`.

## Icons

- Use `FaIcon` with `FontAwesomeIcons`.
- Do not use Flutter's `Icons.*` in app UI.
- Any explicit icon size must use `.r`.

## Loading, Empty, and Error States

- Content loading states should use shimmer components based on `AppShimmer`.
- Full-screen blocking loading should use `MainLoadingProgress`.
- Inline or button loading should use `LoadingDots`.
- Do not use raw `CircularProgressIndicator` directly in feature UI.
- Empty states use `EmptyStateWidget`.
- Error states use `FailedStateWidget`.
- Do not create ad-hoc inline empty/error columns.

## Animations

- Use animations where they improve UX and clarity.
- Screen/list entry animations are required when appropriate for user-facing content.
- Prefer `flutter_animate` for entry effects.
- Use built-in implicit animations for simple state-driven transitions.
- Avoid useless animations on static, admin, dashboard, or table-heavy screens.
- If using a manual `AnimationController`, document why simpler options were not enough.

## Assets

- Use generated FlutterGen `Assets` references.
- Do not use raw string asset paths in app code.
- After adding assets, run:

```bash
dart run build_runner build
```
