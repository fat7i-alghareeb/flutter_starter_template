# Tests — the contract

Every feature built from here follows this file. It is not a suggestion.

```bash
flutter test                            # everything — seconds
flutter test --update-goldens           # regenerate the reference images
flutter test --exclude-tags golden      # on CI with a different OS (see below)
flutter test integration_test --dart-define=USE_MOCK=true   # needs a device
```

---

## Layout

```
test/
├── helpers/            shared tools — read before writing your first test
│   ├── test_app.dart       pumpApp · pumpLocalizedApp · forEachBrightness
│   ├── golden_helper.dart  goldenTest · loads the real font
│   ├── fixtures.dart       reads the real assets/mock
│   └── mocks.dart          the shared fakes
├── core/               theme · network · settings · services
├── common/widgets/ds/  design-system components + reference images
├── features/<name>/    each feature tested beside its name
├── l10n/               translation parity
└── assets/             mock-data sanity

integration_test/       the whole app on a device
```

---

## The kinds of test — and when each is used

| Kind | Proves | Example |
|---|---|---|
| **Unit** | Pure logic, no UI | [`pending_action_test.dart`](core/services/pending_action_test.dart) |
| **System contract** | That the promises in `DESIGN_SYSTEM.md` still hold | [`app_theme_test.dart`](core/theme/app_theme_test.dart) |
| **Data** | That translations and mock data are sound | [`translations_test.dart`](l10n/translations_test.dart) · [`fixtures_test.dart`](assets/fixtures_test.dart) |
| **Bloc** | The state sequence and its side effect | [`auth_bloc_test.dart`](features/auth/auth_bloc_test.dart) |
| **Widget** | What appears and what responds to touch | [`app_bottom_nav_test.dart`](features/root/app_bottom_nav_test.dart) |
| **Golden** | The look itself — spacing and colour | [`ds_golden_test.dart`](common/widgets/ds/ds_golden_test.dart) |
| **Integration** | That the app actually **boots** | [`../integration_test/app_test.dart`](../integration_test/app_test.dart) |

---

## What gets tested in every feature

The working copy for each feature to come:

**Bloc** — for every operation: loading then success · loading then failure · ignoring a duplicate request while loading · the optimistic update and its rollback on failure.

**Widgets** — renders the data · the empty state · the error state · a tap calls what it should · **both light and dark** · the narrowest screen (`320`) · `1.3×` text scale · screen-reader labels.

**Mock data** — the envelope is right · dates are relative · no duplicate id · **the edge cases the spec asks for are actually present**.

**Goldens** — the feature's primary card, in both brightnesses.

**Loading state** — for every widget with a `.loading()`: **that its height matches the content height**. This test is mandatory, and it is what the "one layout, two constructors" rule rests on (`DESIGN_SYSTEM.md` → Skeletons). Add each new one to [`skeleton_parity_test.dart`](common/widgets/ds/skeleton_parity_test.dart).

---

## Rules learned the hard way — never discover them twice

**`EasyLocalization` cannot be created twice in one file.** It keeps process-level state and never resets it, so the second instance builds an empty tree and every `find` after it returns nothing — the widget looks broken when it is fine. Hence: `pumpApp` **without localisation**, and [`pumpLocalizedApp`](helpers/test_app.dart) for what needs it, **one test per file**.

**`setSurfaceSize` alone is not enough.** `ScreenUtil` reads the view directly, not `MediaQuery`, so it keeps measuring against the default `800×600` and every `.sp` comes out roughly twice too large. The result: a sound widget overflows in the test. `pumpApp` sets `tester.view` for this reason.

**A screen is pumped with `fullScreen: true`.** A component is centred so it takes its natural size, but a screen takes the whole surface — centring it leaves the `Stack` unbounded, so every `Positioned` falls outside the frame and silently disappears from the accessibility tree.

**Anything with a repeating animation is pumped with `settle: false`.** `pumpAndSettle` waits for the tree to go quiet, and a perpetual loading indicator never does.

**An element at zero opacity drops out of the accessibility tree.** A `bySemanticsLabel` test run before the entrance animation finishes fails on a perfectly good screen — which is why `settle: false` waits `1200ms`.

**`Semantics` without `container: true` can merge into a parent.** It happened: the label «جارٍ فتح التطبيق» was swallowed by the app name and never spoken.

**A rounded corner swallows the tap.** Tapping `4dp` from the corner of a card with radius `18` lands outside it. Tap at mid-height.

**A `const Set` of `double`, `Color` or `FontWeight` is a compile error** — they have no primitive equality. Use `List`.

**Auth-mode rules run only in their own mode.** `AppFlowConfig.authMode` is a compile-time switch, so the guest-first groups (`skip: !guestFirst`) and the login-wall groups (`skip: guestFirst`) take turns: flipping the switch flips which rules are checked. `flutter test` reports the other mode's tests as skipped — that is expected.

**A screen or widget with a shimmer is pumped with `settle: false`.** `SkeletonScope` wraps its tree in a repeating shimmer that never settles, exactly like `LoadingDots`.

**Never run `dart format` over `lib/utils/gen/app_strings.g.dart`.** The discipline test reads the generated file line by line and expects each template key on ONE line with its `args:`; formatting wraps the long ones and the test fails on a file that is otherwise correct. Regenerate it with `dart run tool/generate_app_strings.dart` instead.

**A widget with an `InkWell` carries its own `Material`.** Pumped alone with `fullScreen: true` there is no `Scaffold` above it, and an `InkWell` with no `Material` ancestor throws. The fix is in the widget (`Material(type: MaterialType.transparency)`), not the test — the same widget will one day sit in a bottom sheet with no scaffold either.

**`intl`'s `DateFormat` needs `initializeDateFormatting` per locale, and nothing calls it.** `NumberFormat` works out of the box; `DateFormat('d MMMM', 'ar')` throws `LocaleDataException`. Month and day names come from `AppStrings` (`AppFormats`), so no initialisation is needed anywhere.

**A `flutter_animate` entrance leaves a timer pending.** A test that ends while an `EmptyStateWidget` is still animating in fails with "A Timer is still pending". Pump past it (`tester.pump(const Duration(seconds: 2))`) before the test returns.

**A widget test checks `AppStrings.x`, not the Arabic text.** That works both ways: with localisation both sides resolve to the Arabic, without it both resolve to the key — and the test cannot drift from the JSON.

**`flutter analyze` reads `test/` and `tool/` too.** A test that no longer compiles — a changed signature, a renamed widget — fails the analyzer, not just the run. Still run the suite before calling a change done: the analyzer cannot see a test that compiles and fails.

**A counted string is a plural group, and outside the app it answers with its key.** `AppStrings.timeHoursAgo(2, '2')` resolves to `time.hoursAgo.other` in a test without localisation (there is no language to choose a form by); with `pumpLocalizedApp` it is «منذ ساعتين». The Arabic forms themselves are pinned in [`l10n/arabic_plurals_test.dart`](l10n/arabic_plurals_test.dart), with `ignorePluralRules: false` as `bootstrap` sets it.

**A golden must not read the wall clock — and a fixed DATE still does.** `relativeTime` measures from now, so a sample dated `2026-09-23 11:50` drew «منذ ساعات» the day it was captured and «أمس» the next. Date samples a fixed DISTANCE before now (`DateTime.now().subtract(...)`).

**A replica of the shell is not the shell.** `tab_state_test` rebuilt its own `PageView` and passed while `RootScreen`'s transition wrapper remounted every tab on every switch. The test now builds each page inside the real `RootTabPage`. Test the widget the app uses, not a copy of its shape.

**`tester.getSemantics(find.byType(Widget))` is usually the wrong node.** It returns the node that owns the widget's render object — often a parent with an empty label — while the label sits on a node below. Find the node by its label (`find.bySemanticsLabel(RegExp('^…'))`) and read that one.

**A list item's texts merge into ONE node.** Each child of a `ListView` becomes a single semantics node unless something inside it asks for explicit children, so a whole page built as one item of a list reads as one block, carrying any flag a child set (it can be announced as a «button»). Pump the REAL page, not the content alone: pumped alone inside a `SingleChildScrollView`, every text is its own node and the bug is invisible.

**`toggled: false` is not «no toggle».** Any value, `false` included, gives the node a toggled state, and Android announces it as a switch. Pass `null` for a plain action.

**Format only the files you changed.** Formatting a whole folder rewraps files nobody touched, and every one of them shows up as a change. Name the files.

**An apostrophe in a test title can end the string.** `testWidgets('the app's …')` written through a script loses its escape and the file stops compiling. Word titles without one, or use double quotes.

---

## Goldens

They run with the rest of the tests, not excluded from them — a spacing drift or a colour that vanishes in dark mode should fail the same command a logic error fails.

The real font is loaded before the image is captured. Without it every glyph is drawn as a black box, so the image proves nothing about the Arabic text.

**On CI with a different OS:** add `--exclude-tags golden`. Text rasterisation differs slightly between platforms, so an image generated on Windows will not match Linux byte for byte even with no real change.

---

## What is not tested

- **No test written to move a coverage number.** A test asserting that a getter returns what was put into it adds maintenance and prevents no bug.
- **No test of an implementation detail.** Test what the user sees or what the caller consumes, not the private method in the middle.
- **No `pumpAndSettle` where a `pump` is enough** — it hides a real flash.

---

## Real bugs these tests caught

Written down because they are the answer to "is this worth the trouble?"

1. **A generic mock pattern shadowed a specific one** — two different screens read the same fixture. [`mock_routes_test.dart`](core/config/mock_routes_test.dart) pins the order.
2. **`AppTheme.light` crashed outside `ScreenUtilInit`** — the type scale was not inspectable without booting the whole app.
3. **The label «Opening the app» was never spoken** — it merged into the app name until the `Semantics` got `container: true`.
4. **A skeleton drifted from its card** — one line added to the card and not to the loading state; the parity test fails on exactly that.
5. **Rails with a height computed from font metrics overflowed** by 11–44dp at 320dp and at 1.3× — caught by the responsive tests, fixed by letting a `Row` size to its cards.
6. **The «See all» chevron pointed backwards in one direction** — a fixed `chevron_left`; the direction-aware `context.chevronEnd` fixed it.
7. **Signing in passed through one frame of «neither a guest nor signed in»** — the router redirected to `/login` and threw the pushed stack away. [`auth_transition_test.dart`](core/services/auth_transition_test.dart) watches every frame.
