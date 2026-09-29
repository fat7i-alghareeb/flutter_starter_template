import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/domain/user_entity.dart';
import 'package:{{project_name}}/core/services/session/pending_action.dart';
import 'package:{{project_name}}/core/utils/bloc_status.dart';
import 'package:{{project_name}}/core/utils/result.dart';
import 'package:{{project_name}}/features/auth/data/params/auth_params.dart';
import 'package:{{project_name}}/features/auth/presentation/states/auth_bloc.dart';

import '../../helpers/mocks.dart';

const String _email = 'demo@example.com';
const String _password = 'secret123';

void main() {
  setUpAll(() {
    registerFallbackValue(const SignInParams(email: '', password: ''));
  });

  late MockAuthFacade facade;
  late RecordingPendingActionQueue queue;

  setUp(() {
    facade = MockAuthFacade();
    queue = RecordingPendingActionQueue();
  });

  AuthBloc build() => AuthBloc(facade, queue);

  group('AuthBloc — sign in', () {
    blocTest<AuthBloc, AuthState>(
      'goes loading then success',
      setUp: () => when(() => facade.signIn(any())).thenAnswer(
        (_) async =>
            const Result<UserEntity>.success(UserEntity(id: 'usr_001')),
      ),
      build: build,
      act: (bloc) => bloc.add(const AuthEvent.signInRequested(email: _email, password: _password)),
      expect: () => <Matcher>[
        isA<AuthState>().having(
          (s) => s.signInStatus.isLoading,
          'loading',
          isTrue,
        ),
        isA<AuthState>().having(
          (s) => s.signInStatus.isSuccess,
          'success',
          isTrue,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'resumes the pending action once signed in',
      setUp: () {
        when(() => facade.signIn(any())).thenAnswer(
          (_) async =>
              const Result<UserEntity>.success(UserEntity(id: 'usr_001')),
        );
        queue.remember(ProtectedAction.save, () async {});
      },
      build: build,
      act: (bloc) => bloc.add(const AuthEvent.signInRequested(email: _email, password: _password)),
      verify: (_) {
        // The whole reason the gate exists: the user lands back on what they
        // were doing, with it done.
        expect(queue.resumed, <ProtectedAction>[ProtectedAction.save]);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a real failure surfaces as a failure',
      setUp: () => when(() => facade.signIn(any())).thenAnswer(
        (_) async => const Result<UserEntity>.failure('server unreachable'),
      ),
      build: build,
      act: (bloc) => bloc.add(const AuthEvent.signInRequested(email: _email, password: _password)),
      expect: () => <Matcher>[
        isA<AuthState>().having(
          (s) => s.signInStatus.isLoading,
          'loading',
          isTrue,
        ),
        isA<AuthState>()
            .having((s) => s.signInStatus.isFailed, 'failed', isTrue)
            .having((s) => s.wasCancelled, 'cancelled', isFalse),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a CANCELLED sign-in is not a failure',
      setUp: () => when(() => facade.signIn(any())).thenAnswer(
        (_) async =>
            const Result<UserEntity>.failure(PendingActionMessages.cancelled),
      ),
      build: build,
      act: (bloc) => bloc.add(const AuthEvent.signInRequested(email: _email, password: _password)),
      expect: () => <Matcher>[
        isA<AuthState>().having(
          (s) => s.signInStatus.isLoading,
          'loading',
          isTrue,
        ),
        // Backing out is a choice. Showing it in red tells a user they did
        // something wrong when they simply changed their mind.
        isA<AuthState>()
            .having((s) => s.signInStatus.isFailed, 'failed', isFalse)
            .having((s) => s.signInStatus.isInit, 'back to initial', isTrue)
            .having((s) => s.wasCancelled, 'cancelled', isTrue),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'cancelling disarms the pending action',
      setUp: () {
        when(() => facade.signIn(any())).thenAnswer(
          (_) async =>
              const Result<UserEntity>.failure(PendingActionMessages.cancelled),
        );
        queue.remember(ProtectedAction.save, () async {});
      },
      build: build,
      act: (bloc) => bloc.add(const AuthEvent.signInRequested(email: _email, password: _password)),
      verify: (_) {
        // Left armed, it would fire on some later, unrelated sign-in.
        expect(queue.hasPending, isFalse);
        expect(queue.resumed, isEmpty);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'ignores a second tap while already signing in',
      setUp: () => when(() => facade.signIn(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return const Result<UserEntity>.success(UserEntity(id: 'usr_001'));
      }),
      build: build,
      act: (bloc) => bloc
        ..add(const AuthEvent.signInRequested(email: _email, password: _password))
        ..add(const AuthEvent.signInRequested(email: _email, password: _password)),
      wait: const Duration(milliseconds: 60),
      verify: (_) {
        // Two sign-in requests racing each other is a real bug when the
        // button is double-tapped on a slow phone.
        verify(() => facade.signIn(any())).called(1);
      },
    );
  });

  group('AuthBloc — sign out', () {
    blocTest<AuthBloc, AuthState>(
      'returns to a clean state',
      setUp: () => when(
        facade.signOut,
      ).thenAnswer((_) async => const Result<void>.success(null)),
      build: build,
      seed: () => const AuthState(
        signInStatus: BlocStatus<UserEntity>.success(UserEntity(id: 'x')),
      ),
      act: (bloc) => bloc.add(const AuthEvent.signOutRequested()),
      expect: () => <Matcher>[
        isA<AuthState>().having(
          (s) => s.signOutStatus.isLoading,
          'loading',
          isTrue,
        ),
        // A stale success must not survive a sign-out, or the UI still believes
        // someone is signed in.
        isA<AuthState>().having(
          (s) => s.signInStatus.isInit,
          'sign-in reset',
          isTrue,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a failed sign-out is reported',
      setUp: () => when(
        facade.signOut,
      ).thenAnswer((_) async => const Result<void>.failure('network')),
      build: build,
      act: (bloc) => bloc.add(const AuthEvent.signOutRequested()),
      expect: () => <Matcher>[
        isA<AuthState>().having(
          (s) => s.signOutStatus.isLoading,
          'loading',
          isTrue,
        ),
        isA<AuthState>().having(
          (s) => s.signOutStatus.isFailed,
          'failed',
          isTrue,
        ),
      ],
    );
  });

  group('AuthBloc — guest', () {
    blocTest<AuthBloc, AuthState>(
      'entering as a guest asks the facade and resets',
      setUp: () => when(
        facade.continueAsGuest,
      ).thenAnswer((_) async => const Result<void>.success(null)),
      build: build,
      act: (bloc) => bloc.add(const AuthEvent.continueAsGuestRequested()),
      verify: (_) => verify(facade.continueAsGuest).called(1),
    );
  });
}
