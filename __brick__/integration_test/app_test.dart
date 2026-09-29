import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:{{project_name}}/app.dart';
import 'package:{{project_name}}/bootstrap.dart' as bootstrap;
import 'package:{{project_name}}/core/router/app_links.dart';
import 'package:{{project_name}}/core/injection/injectable.dart';
import 'package:{{project_name}}/features/auth/presentation/ui/screens/login_screen.dart';
import 'package:{{project_name}}/features/onboarding/presentation/ui/screens/onboarding_screen.dart';
import 'package:{{project_name}}/features/root/presentation/ui/screens/root_screen.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/app_bottom_nav.dart';
import 'package:{{project_name}}/features/settings/presentation/ui/screens/settings_screen.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/ui/screens/feed_item_screen.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/ui/widgets/feed_cards.dart';
import 'package:{{project_name}}/features/splash/presentation/ui/screens/splash_screen.dart';
import 'package:{{project_name}}/utils/constants/app_flow_constants.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end: the real app, on a real device or emulator.
///
///   flutter test integration_test --dart-define=USE_MOCK=true
///
/// `USE_MOCK=true` is not optional: the template has no server, and the
/// showcase lists come from `assets/mock/`.
///
/// What belongs here, and nowhere else: whether the whole thing BOOTS, and
/// whether a user can get from the first launch to the screens the widget
/// tests build one at a time. Only this runs bootstrap, dependency injection,
/// storage, the router and the theme together on a real engine.
///
/// **ONE `testWidgets`, on purpose.** `bootstrap()` may run once per process
/// (it calls `runApp` inside its own zone), and `EasyLocalization` cannot be
/// mounted twice. flutter_test also UNMOUNTS the tree at the end of every
/// `testWidgets`, so a second test would find no app and could not build
/// one. Every check lives in the one test that booted it.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps until [target] is on screen, and FAILS the moment [never] is —
  /// one frame of it is enough.
  ///
  /// A poll, not `pumpAndSettle`: the splash holds its minimum with a
  /// `Timer`, and a pending timer schedules no frame, so `pumpAndSettle`
  /// would report the tree settled while the splash is still up.
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder target, {
    Finder? never,
    String? neverReason,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (never != null && never.evaluate().isNotEmpty) {
        fail(neverReason ?? '$never appeared');
      }
      if (target.evaluate().isNotEmpty) return;
    }
    fail('$target never appeared within $timeout');
  }

  /// Pumps until [target] has left the tree — a popped page is still there
  /// while its exit transition runs.
  Future<void> pumpUntilGone(
    WidgetTester tester,
    Finder target, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (target.evaluate().isEmpty) return;
    }
    fail('$target was still there after $timeout');
  }

  /// The system back button, as Android sends it.
  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('a first launch reaches the shell through onboarding, and a '
      'user can walk the app from there', (tester) async {
    // ── a FIRST launch, genuinely: nothing stored — no onboarding flag, no
    //    guest flag, no session.
    await SharedPreferencesAsync().clear();
    await const FlutterSecureStorage().deleteAll();

    await bootstrap.bootstrap(() async => const App());

    const loginWall = AppFlowConfig.authMode == AuthMode.loginRequired;
    final signIn = find.byType(LoginScreen);

    await pumpUntil(
      tester,
      find.byType(OnboardingScreen),
      never: signIn,
      neverReason: 'the sign-in screen came BEFORE onboarding',
    );

    // ── onboarding's own button, the way a user leaves it
    await tester.tap(find.text(AppStrings.onboardingSkip));

    if (loginWall) {
      // ── the wall; the demo identity is filled in under USE_MOCK
      await pumpUntil(tester, signIn);
      await tester.tap(
        find.widgetWithText(FilledButton, AppStrings.authSignIn),
      );
    }
    await pumpUntil(
      tester,
      find.byType(RootScreen),
      never: loginWall ? null : signIn,
      neverReason: 'guest-first: the sign-in screen must not appear',
    );
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsNothing);

    // ── the feed's list arrives from the mock layer
    await pumpUntil(
      tester,
      find.byWidgetPredicate((w) => w is FeedCard && w.item != null),
    );

    // ── every tab switches, then back to the feed
    for (final label in <String>[
      AppStrings.navButtons,
      AppStrings.navForms,
      AppStrings.navDialogs,
      AppStrings.navAlerts,
      AppStrings.navFeed,
    ]) {
      // The word inside the NAVIGATION BAR, not the same word elsewhere.
      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomNav),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
    }

    // ── an item from the list, and back
    await tester.tap(
      find.byWidgetPredicate((w) => w is FeedCard && w.item != null).first,
    );
    await pumpUntil(tester, find.byType(FeedItemScreen));
    await back(tester);
    await pumpUntilGone(tester, find.byType(FeedItemScreen));

    // ── settings, from the header
    await tester.tap(find.bySemanticsLabel(AppStrings.settingsTitle).first);
    await pumpUntil(tester, find.byType(SettingsScreen));
    await back(tester);
    await pumpUntilGone(tester, find.byType(SettingsScreen));

    // ── a shared link, as Android hands it to a running app: it opens OVER
    //    the shell, and back lands in the app
    await getIt<LinkDispatcher>().didPushRouteInformation(
      RouteInformation(uri: Uri.parse(AppLinks.shareUrlOf('item_001'))),
    );
    await pumpUntil(tester, find.byType(FeedItemScreen));
    await back(tester);
    await pumpUntilGone(tester, find.byType(FeedItemScreen));
    expect(find.byType(RootScreen), findsOneWidget);
  });
}
