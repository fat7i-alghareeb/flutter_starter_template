# Decisions

This file records durable project decisions so agents can follow the architecture without rediscovering the reasoning each task.

## AppStrings for User Text

All user-visible text goes through generated `AppStrings` constants. This keeps Arabic and English coverage synchronized and prevents raw `.tr()` keys or duplicated localization strings from spreading through UI code.

## AppTextStyles for Typography

Typography is centralized in `AppTextStyles` so screens share scale, weight, and responsive behavior. Widgets may customize color with semantic theme tokens, but should not define ad-hoc text styles.

## StatusBuilder for Async UI

Async UI state is rendered through `StatusBuilder<T>` backed by `BlocStatus<T>`. This keeps loading, error, empty, and success rendering consistent and avoids repeated status-switching logic in widgets.

## Entity, Model, Mapper Separation

Data models represent API/storage shapes. Domain entities represent app meaning. Mappers keep those layers separate so API details do not leak into BLoC or UI.

## No Melos

This is not a Melos workspace. Agents must use direct project commands such as `dart run tool/generate_app_strings.dart` and `dart run build_runner build`.
