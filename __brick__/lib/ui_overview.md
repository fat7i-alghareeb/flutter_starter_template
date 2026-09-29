# UI overview

How a screen is put together. Visual rules: `DESIGN_SYSTEM.md`.

```text
RootScreen (the shell — owns the Scaffold, the floating AppBottomNav, the back guard)
└── RootTabStack (cross-fade, every tab kept alive, HeroMode off when hidden)
    └── a tab: BlocProvider + Body — NO Scaffold of its own
        └── Body: header + CustomScrollView
            ├── AppLazySection  → a section that loads when it scrolls near
            ├── AppRail / AppPeekCarousel → cards
            └── SliverList → XxxCard.success(...).revealOnScroll()

A pushed page (AppNavigator.push): its own Scaffold, no nav bar
└── e.g. AppHeroDetailLayout(image, body, actions: AppActionCapsule)
```

## Layers of a screen

| Level | Lives in | Holds |
| --- | --- | --- |
| Screen | `features/x/presentation/ui/screens/` | `pagePath`, `pageName`, the `BlocProvider` |
| Body | `…/ui/widgets/x_body.dart` | States (loading · loaded · empty · failed), scroll, refresh |
| Sections / cards | `…/ui/widgets/` | One job each; cards are `SkeletonWidget`s |
| Primitives | `lib/common/widgets/ds/` | Everything visual that is reused |

## In a tab

- Bottom padding `AppBottomNav.listBottomPadding(context)` so the last row clears the bar.
- `physics: AlwaysScrollableScrollPhysics()` so pull-to-refresh works on a short list.
- Listen to `NavigationScope.maybeOf(context)?.reselectToken` to scroll to the top when the active tab is tapped again.
- `AppBackToTop` in a `Stack` over long lists.
- Content capped at 640dp and centred on wide screens.

## Reference

`lib/features/showcase_feed/` does all of the above; the Buttons, Forms, Dialogs and Alerts tabs show each component.
