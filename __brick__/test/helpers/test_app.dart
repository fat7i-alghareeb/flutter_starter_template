// easy_localization exports its own `TextDirection` enum, which shadows the
// one from dart:ui and makes `TextDirection.rtl` a compile error. The app's
// own barrel hides it the same way.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:{{project_name}}/core/theme/app_theme.dart';
import 'package:{{project_name}}/utils/constants/design_constants.dart';

/// Shared setup for every widget test.
///
/// A widget test that builds a bare `MaterialApp` proves almost nothing here:
/// the app's widgets read colours from the theme, sizes through `ScreenUtil`,
/// text through `easy_localization`, and direction from `Directionality`. Miss
/// any of those and the test either crashes or passes against a widget that
/// looks nothing like the real one.
///
/// [pumpApp] wires all four the way the real app does.

/// Screen sizes the layout is specified against (`DESIGN_SYSTEM.md`).
class TestDevices {
  TestDevices._();

  /// The narrow end of the range — text must not overflow here.
  static const Size small = Size(320, 640);

  /// The reference device the design was drawn on.
  static const Size reference = Size(390, 844);

  /// A large phone.
  static const Size large = Size(430, 932);

  /// Tablet-width, where layouts switch to two columns.
  static const Size tablet = Size(800, 1200);
}

/// Loads the translation files so `.tr()` returns Arabic instead of the raw key.
///
/// Call it once in `setUpAll`.
Future<void> initTestLocalization() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // EasyLocalization reads the saved locale through shared_preferences, which
  // has no platform implementation in a test — without this it throws a
  // MissingPluginException before a single widget is built.
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await EasyLocalization.ensureInitialized();
}

/// Builds [child] inside the app's real theme, direction and sizing.
///
/// ```dart
/// await pumpApp(tester, const AppBadge.urgent('عاجل'));
/// ```
///
/// Defaults to RTL, the harder direction — a test that only ever
/// runs LTR would never catch a hard-coded `EdgeInsets.only(left:)`.
///
/// **No `EasyLocalization` here.** See [pumpLocalizedApp] for why, and use it
/// for the few widgets that call `.tr()` themselves. Everything in
/// `common/widgets/ds/` takes its strings as parameters, so it does not need
/// localization to be under test.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.rtl,
  Size surfaceSize = TestDevices.reference,
  double textScale = 1,
  bool disableAnimations = false,
  bool settle = true,
  bool fullScreen = false,
}) async {
  _sizeView(tester, surfaceSize);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: AppDesign.designSize,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
        builder: (context, widget) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: Directionality(textDirection: textDirection, child: widget!),
        ),
        // A COMPONENT is centred so it takes its natural size. A SCREEN is
        // handed the whole surface — centring one would leave its Stack
        // unbounded, so anything `Positioned` against an edge lands outside
        // the viewport and silently drops out of the semantics tree.
        home: fullScreen ? child : Scaffold(body: Center(child: child)),
      ),
    ),
  );

  // `settle: false` for a screen that owns a REPEATING animation — a loading
  // indicator, a shimmer. `pumpAndSettle` waits for the tree to go quiet, and
  // a repeating animation never does, so it would time out and report a
  // perfectly healthy screen as broken.
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    // Long enough to clear the longest entrance in the app (the splash logo
    // assembling, 950ms). A shorter pump leaves elements at opacity 0, and an
    // element at opacity 0 is dropped from the semantics tree — so a
    // `bySemanticsLabel` check would fail on a screen that is perfectly fine.
    await tester.pump(const Duration(milliseconds: 1200));
  }
}

/// Same as [pumpApp], but with real translations so `.tr()` resolves.
///
/// ⚠️ **One call per test FILE.** `EasyLocalization` keeps process-wide state
/// that it never resets, so a second instance in the same file renders an empty
/// tree and every `find` afterwards returns nothing — which looks like a broken
/// widget rather than a broken harness. This was measured, not assumed.
///
/// So: a widget that calls `.tr()` gets its own test file with a single
/// `testWidgets`, asserting everything it needs in that one body.
Future<void> pumpLocalizedApp(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('ar'),
  Size surfaceSize = TestDevices.reference,
}) async {
  _sizeView(tester, surfaceSize);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      path: 'assets/l10n',
      fallbackLocale: const Locale('ar'),
      startLocale: locale,
      saveLocale: false,
      useOnlyLangCode: true,
      // As `bootstrap` does: Arabic's plural forms need the real rules.
      ignorePluralRules: false,
      child: Builder(
        builder: (context) => ScreenUtilInit(
          designSize: AppDesign.designSize,
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
            localizationsDelegates: context.localizationDelegates,
            theme: brightness == Brightness.dark
                ? AppTheme.dark
                : AppTheme.light,
            builder: (context, widget) => Directionality(
              textDirection: locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: widget!,
            ),
            home: Scaffold(body: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Runs [body] once per brightness, so a widget is checked in both themes.
///
/// Dark mode is not a colour swap in this system — shadows are replaced by
/// borders (`DESIGN_SYSTEM.md`) — so a widget that is only ever tested light
/// can be visibly broken dark and nobody notices.
void forEachBrightness(
  String description,
  Future<void> Function(WidgetTester tester, Brightness brightness) body,
) {
  for (final brightness in Brightness.values) {
    testWidgets('$description (${brightness.name})', (tester) async {
      await body(tester, brightness);
    });
  }
}

/// Sizes the test view.
///
/// `binding.setSurfaceSize` is NOT enough: `ScreenUtil` reads the raw view, not
/// the ambient `MediaQuery`, so with only a surface size it keeps scaling
/// against the default 800×600 test window. Every `.sp` value then comes out
/// roughly twice too large and widgets overflow for reasons that have nothing
/// to do with the widget.
void _sizeView(WidgetTester tester, Size size) {
  const devicePixelRatio = 1.0;
  tester.view
    ..devicePixelRatio = devicePixelRatio
    ..physicalSize = size * devicePixelRatio;
  addTearDown(() {
    tester.view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });
}
