---
paths:
  - "lib/core/window/**"
  - "lib/core/shortcuts/**"
  - "lib/core/layout/**"
  - "lib/core/platform/**"
  - "windows/**"
  - "macos/**"
---

# Layout, window and desktop (loads when you touch them)

- Size classes by window width: compact < 600 · medium < 840 · expanded < 1200 · large < 1600 · extra-large. Navigation: capsule →
  80dp rail → 256dp sidebar. Text grows ×1.05 / ×1.10 / ×1.15 from 840dp (`AppTextScaleHost`).
- Platform capability checks only through `AppPlatform` (`supportsPush`, `supportsVibration`, `isDesktop`, `rendersFlagEmoji`).
  A plugin with no code for a platform throws at run time — guard every call.
- The title bar sits above the Navigator: it needs its own `Overlay`. The window stays hidden until its first frame.
- `windows/CMakeLists.txt` and the runners carry hook patches; a clean Windows build prints 0 warnings — keep it that way.

Full text: `docs/RESPONSIVE.md`, `docs/DESKTOP_SETUP.md`.
