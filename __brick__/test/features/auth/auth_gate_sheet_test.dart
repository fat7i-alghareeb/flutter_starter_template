import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/domain/user_entity.dart';
import 'package:{{project_name}}/core/injection/injectable.dart';
import 'package:{{project_name}}/core/services/session/auth_state_notifier.dart';
import 'package:{{project_name}}/core/services/session/pending_action.dart';
import 'package:{{project_name}}/core/utils/result.dart';
import 'package:{{project_name}}/features/auth/data/params/auth_params.dart';
import 'package:{{project_name}}/features/auth/presentation/states/auth_bloc.dart';
import 'package:{{project_name}}/features/auth/presentation/ui/screens/login_screen.dart';
import 'package:{{project_name}}/features/auth/presentation/ui/widgets/auth_gate_sheet.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_app.dart';

/// The sheet a guest sees when they touch a protected action
/// (`AuthMode.guestFirst`).
void main() {
  late MockAuthFacade facade;
  late AuthStateNotifier session;

  setUpAll(() {
    registerFallbackValue(const SignInParams(email: '', password: ''));
  });

  setUp(() async {
    await getIt.reset();
    facade = MockAuthFacade();
    session = AuthStateNotifier();
    getIt
      ..registerSingleton<AuthStateNotifier>(session)
      ..registerLazySingleton<PendingActionQueue>(PendingActionQueue.new)
      ..registerFactory<AuthBloc>(
        () => AuthBloc(facade, getIt<PendingActionQueue>()),
      );
  });

  tearDown(() => getIt.reset());

  Widget opener(ProtectedAction action, void Function(bool) onResult,
      {Future<void> Function()? onGranted}) {
    return Builder(
      builder: (context) => TextButton(
        onPressed: () async => onResult(
          await AuthGateSheet.show(
            context,
            action: action,
            onGranted: onGranted ?? () async {},
          ),
        ),
        child: const Text('open'),
      ),
    );
  }

  testWidgets('names the action, says what signing in gives, and «Later» '
      'backs out without leaving the action armed', (tester) async {
    bool? granted;
    await pumpApp(tester, opener(ProtectedAction.follow, (g) => granted = g));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text(ProtectedAction.follow.prompt), findsOneWidget);
    expect(find.text(ProtectedAction.follow.benefit), findsOneWidget);

    await tester.tap(find.text(AppStrings.authLater));
    await tester.pumpAndSettle();

    expect(find.byType(AuthGateSheet), findsNothing);
    expect(granted, isFalse);
    expect(getIt<PendingActionQueue>().hasPending, isFalse);
  });

  testWidgets('«Sign in» opens the sign-in page; signing in there runs the '
      'action and closes the sheet as granted', (tester) async {
    bool? granted;
    var resumed = 0;
    when(() => facade.signIn(any())).thenAnswer((_) async {
      // What `AuthManager.login` does behind the real repository.
      session
        ..setUser(const UserEntity(id: 'usr_001'))
        ..setAuthStatus(AuthStatus.authenticated());
      return const Result<UserEntity>.success(UserEntity(id: 'usr_001'));
    });

    await pumpApp(
      tester,
      opener(
        ProtectedAction.save,
        (g) => granted = g,
        onGranted: () async => resumed++,
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, AppStrings.authSignIn));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    // The demo identity is filled in: no backend in a test.
    await tester.tap(find.widgetWithText(FilledButton, AppStrings.authSignIn));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(AuthGateSheet), findsNothing);
    expect(granted, isTrue);
    expect(resumed, 1);
  });

  test('every protected action has a benefit line of its own', () {
    for (final action in ProtectedAction.values) {
      expect(action.benefit, isNot(action.prompt), reason: action.name);
    }
  });
}
