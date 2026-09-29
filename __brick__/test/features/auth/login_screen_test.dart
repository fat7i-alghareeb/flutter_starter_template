import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/common/widgets/ds/app_bar_action.dart';
import 'package:{{project_name}}/core/config/mock_config.dart';
import 'package:{{project_name}}/core/domain/user_entity.dart';
import 'package:{{project_name}}/core/injection/injectable.dart';
import 'package:{{project_name}}/core/services/session/pending_action.dart';
import 'package:{{project_name}}/core/theme/app_theme.dart';
import 'package:{{project_name}}/core/utils/result.dart';
import 'package:{{project_name}}/features/auth/data/params/auth_params.dart';
import 'package:{{project_name}}/features/auth/presentation/states/auth_bloc.dart';
import 'package:{{project_name}}/features/auth/presentation/ui/screens/login_screen.dart';
import 'package:{{project_name}}/utils/constants/design_constants.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/mocks.dart';

/// The sign-in screen, pushed over a page: every way out returns to the
/// page underneath, and nothing reaches the server that the form did not
/// validate first.
void main() {
  late MockAuthFacade facade;

  setUpAll(() {
    registerFallbackValue(const SignInParams(email: '', password: ''));
  });

  setUp(() async {
    await getIt.reset();
    facade = MockAuthFacade();
    getIt
      ..registerLazySingleton<PendingActionQueue>(PendingActionQueue.new)
      ..registerFactory<AuthBloc>(
        () => AuthBloc(facade, getIt<PendingActionQueue>()),
      );
  });

  tearDown(() => getIt.reset());

  Future<GoRouter> pumpOverPage(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
    Brightness brightness = Brightness.light,
  }) async {
    final router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => const Text('underneath'),
          // Sign-in is a child of whatever page opened it.
          routes: <RouteBase>[
            GoRoute(
              path: LoginScreen.pagePath,
              builder: (_, _) => const LoginScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = size;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppDesign.designSize,
        builder: (_, _) => MaterialApp.router(
          theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    router.push('/${LoginScreen.pagePath}');
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    return router;
  }

  Finder signInButton() => find.widgetWithText(FilledButton, AppStrings.authSignIn);

  testWidgets('✕ closes it — back to the page underneath', (tester) async {
    await pumpOverPage(tester);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppBarAction && widget.label == AppStrings.actionClose,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('underneath'), findsOneWidget);
  });

  testWidgets('with no backend the demo identity is filled in, and signing '
      'in closes the page — no welcome screen after', (tester) async {
    when(() => facade.signIn(any())).thenAnswer(
      (_) async => const Result<UserEntity>.success(
        UserEntity(id: 'usr_demo', email: MockConfig.userEmail),
      ),
    );
    await pumpOverPage(tester);

    await tester.tap(signInButton());
    await tester.pumpAndSettle();

    final sent =
        verify(() => facade.signIn(captureAny())).captured.single
            as SignInParams;
    expect(sent.email, MockConfig.userEmail);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('underneath'), findsOneWidget);
  });

  testWidgets('an empty email never reaches the server', (tester) async {
    await pumpOverPage(tester);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(signInButton());
    await tester.pumpAndSettle();

    verifyNever(() => facade.signIn(any()));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('a failed sign-in stays on the page and says so', (tester) async {
    when(() => facade.signIn(any())).thenAnswer(
      (_) async => const Result<UserEntity>.failure('wrong password'),
    );
    await pumpOverPage(tester);

    await tester.tap(signInButton());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text(AppStrings.authFailed), findsOneWidget);
  });

  testWidgets('the title, two fields, the button and the terms', (
    tester,
  ) async {
    await pumpOverPage(tester);

    expect(find.text(AppStrings.authTitle), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(signInButton(), findsOneWidget);
    expect(find.text(AppStrings.authTerms), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('fits 320dp at 1.3× (${brightness.name})', (tester) async {
      await pumpOverPage(
        tester,
        size: const Size(320, 640),
        textScale: 1.3,
        brightness: brightness,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
