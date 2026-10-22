---
paths:
  - "lib/common/**"
  - "lib/features/**/presentation/**"
  - "lib/core/theme/**"
---

# UI (loads when you touch UI code)

- Type: a theme role (`Theme.of(context).textTheme.x`), change colour only. No `TextStyle(fontSize:)`; `AppTextStyles` is legacy.
- Colour: `colorScheme` / `context.semantic`; never `Colors.*` or a hex. Secondary text `onSurfaceVariant`; a control's edge
  `outlineVariant` (`context.grey`); never `outline` for text or icons. Page = `semantic.background`, card = `surface`.
- Tokens: `AppSpacing`, `AppRadii`, `AppIconSizes`; gaps `AppSpacing.md.verticalSpace`. No `.sp .h .w .r`. No fixed height on text.
- Icons `AppIcon(AppIcons.x)`. Loading = `SkeletonWidget` over one layout (+ a parity-test line); spinners only for an action.
- Buttons `AppButton`. **Grey = inactive only**: Cancel/Exit/Close/Reset are `error` (or `primary`); disable with `isActive: false`.
- Counts `AppCountBadge`; fields `AppReactive*Field` in `AppFormFieldGrid`; sheets `AppBottomSheet.showAdaptive`.
- Layout by window size (`context.layout`, `AdaptiveLayout`), never device/orientation/`Platform.isX`; cap width with `AppContentWidth`.
- Pointer + keyboard: hover, tooltips on icon buttons, `AppFocusRing`. Check 390 / 820 / 1280, RTL + LTR, light + dark, 1.3× text.

Full text: `.ai/flutter-ui-rules.md`, `DESIGN_SYSTEM.md`. Before a new widget run `dart run tool/widget_catalog.dart <word>`;
a near-duplicate is a question for the owner. A new design from Figma → `DESIGN_SYSTEM.md` §12.
