# UI overview

How a screen is put together. The visual rules are in `DESIGN_SYSTEM.md`; the UI rules for agents in `.ai/flutter-ui-rules.md`;
window sizes and desktop in `docs/RESPONSIVE.md`.

```text
App (title bar on desktop, banners, shortcuts)
└── RootScreen — the shell: owns the Scaffold, the back guard, and picks the navigation by window size
    ├── compact  : AppBottomNav (floating capsule)      ┐ NavLayout, from AppLayoutScope
    ├── medium   : AppSideNav as an 80dp rail           │ (also a phone on its side)
    ├── expanded+: AppSideNav as a collapsible sidebar  ┘
    └── RootTabStack (cross-fade, every tab kept alive, HeroMode off when hidden)
        └── a tab: BlocProvider + Body — NO Scaffold of its own
            └── Body: header + CustomScrollView
                ├── AppLazySection       → a section that loads when it scrolls near
                ├── AppRail / AppPeekCarousel → cards
                └── SliverList           → XxxCard.success(...).revealOnScroll()

A pushed page (AppNavigator.push): its own AppScaffold or Scaffold, no navigation
└── e.g. AppHeroDetailLayout(image, body, actions: AppActionCapsule) — side by side in wide windows
```

## Layers of a screen

| Level | Lives in | Holds |
| --- | --- | --- |
| Screen | `features/x/presentation/ui/screens/` | `pagePath`, `pageName`, the `BlocProvider` |
| Body | `…/ui/widgets/x_body.dart` | States (loading · loaded · empty · failed), scroll, refresh |
| Sections / cards | `…/ui/widgets/` | One job each; cards are `SkeletonWidget`s |
| Primitives | `lib/common/widgets/ds/` | Everything visual that is reused |

## In a tab

- Bottom padding `AppBottomNav.listBottomPadding(context)` so the last row clears the capsule (with the rail or the sidebar showing
  it is only `AppSpacing.lg` plus the home-indicator inset).
- Side margin `context.layout.gutter`; content in `AppContentWidth` so it stops growing on a wide window (lists 640–1200, forms 840).
- `physics: AlwaysScrollableScrollPhysics()` so pull-to-refresh works on a short list.
- Listen to `NavigationScope.maybeOf(context)?.reselectToken` to scroll to the top when the active tab is tapped again.
- `AppBackToTop` in a `Stack` over long lists.
- Cards per row: `AppLayout.columnsFor(width)` (1 · 2 · 3).

## References

- `lib/features/showcase_feed/` does all of the above on mock data.
- The Buttons, Forms, Dialogs and Alerts tabs (`lib/features/root/presentation/ui/widgets/showcase/`) show each component; they
  share `ShowcasePage` / `ShowcaseSection`.
