import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/services/onboarding/onboarding_service.dart';
import 'package:{{project_name}}/core/services/session/auth_manager.dart';
import 'package:{{project_name}}/features/onboarding/presentation/ui/screens/onboarding_screen.dart';
import 'package:{{project_name}}/features/onboarding/presentation/ui/widgets/onboarding_slide.dart';
import 'package:{{project_name}}/utils/constants/app_flow_constants.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_app.dart';

class _MockOnboardingService extends Mock implements OnboardingService {}

/// ONE `testWidgets` on purpose.
///
/// This screen calls `.tr()`, so it needs [pumpLocalizedApp] — and
/// `EasyLocalization` cannot be instantiated twice in a single test process.
/// A second pump renders an empty tree and every `find` returns nothing, which
/// looks exactly like a broken widget. So the whole flow is walked once.
/// See `test/README.md`.
void main() {
  late _MockOnboardingService service;
  late MockAuthManager auth;

  setUp(() {
    service = _MockOnboardingService();
    auth = MockAuthManager();
    when(service.setOnboardingFinished).thenAnswer((_) async {});
    when(() => auth.isAuthenticated).thenReturn(false);
    when(auth.continueAsGuest).thenAnswer((_) async {});
    GetIt.I
      ..registerSingleton<OnboardingService>(service)
      ..registerSingleton<AuthManager>(auth);
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('walks the three slides and finishes', (tester) async {
    await pumpLocalizedApp(tester, const OnboardingScreen());

    // ── slide 1
    expect(find.text('كل جديد أولًا بأول'), findsOneWidget);
    expect(find.byType(OnboardingDots), findsOneWidget);

    // `تخطّي` is present from the very first slide — onboarding is never a
    // wall.
    expect(find.text('تخطّي'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
    expect(find.text('ابدأ'), findsNothing);

    // Nothing here asks who the user is: sign-in, when there is one, comes
    // after onboarding.
    expect(find.byType(TextField), findsNothing);

    // ── slide 2
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('اعثر على ما تحتاجه بسرعة'), findsOneWidget);
    expect(find.text('ابدأ'), findsNothing);

    // ── slide 3: the button changes to «ابدأ», and skip is STILL there
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('احفظ ما يهمّك وأكمل من حيث توقفت'), findsOneWidget);
    expect(find.text('ابدأ'), findsOneWidget);
    expect(find.text('التالي'), findsNothing);
    expect(find.text('تخطّي'), findsOneWidget);

    // ── finishing marks it done — once. In guest-first mode it makes the
    // user a GUEST first, so no frame reads «finished, and neither a guest
    // nor signed in» (which the router sends to the sign-in page). With the
    // login wall that is exactly where they should go, so no guest.
    await tester.tap(find.text('ابدأ'));
    await tester.pumpAndSettle();
    if (AppFlowConfig.authMode == AuthMode.guestFirst) {
      verifyInOrder(<VoidCallback>[
        auth.continueAsGuest,
        service.setOnboardingFinished,
      ]);
    } else {
      verify(service.setOnboardingFinished).called(1);
      verifyNever(auth.continueAsGuest);
    }
    verifyNoMoreInteractions(service);

    // And it does NOT navigate: the router listens to the service and decides
    // where the user goes. Two places deciding is how a redirect loop starts.
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
