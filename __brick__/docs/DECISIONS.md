# Decisions

This file records durable project decisions so agents can follow the architecture without rediscovering the reasoning each task.

## AppStrings for User Text

All user-visible text goes through generated `AppStrings` constants. This keeps Arabic and English coverage synchronized and prevents raw `.tr()` keys or duplicated localization strings from spreading through UI code.

## AppTextStyles for Typography

Typography is centralized in `AppTextStyles` so screens share scale, weight, and responsive behavior. Widgets may customize color with semantic theme tokens, but should not define ad-hoc text styles.

## StatusBuilder for Async UI

Async UI state is rendered through `StatusBuilder<T>` backed by `BlocStatus<T>`. This keeps loading, error, empty, and success rendering consistent and avoids repeated status-switching logic in widgets.

## Fast First Frame

Startup should do only the work required to render the first correct Flutter frame. Storage is sync-injected, but saved locale/theme, onboarding cache load, auth/session restore, stage preview state, and notification initialization run after the first frame. Permission prompts must never appear before the custom splash duration has completed.

## Showcase Stays

The root showcase remains in the generated app by design, even though it has runtime/demo cost. App teams can delete it after cloning when they no longer need the component examples.

## Entity, Model, Mapper Separation

Data models represent API/storage shapes. Domain entities represent app meaning. Mappers keep those layers separate so API details do not leak into BLoC or UI.

## No Melos

This is not a Melos workspace. Agents must use direct project commands such as `dart run tool/generate_app_strings.dart` and `dart run build_runner build`.
