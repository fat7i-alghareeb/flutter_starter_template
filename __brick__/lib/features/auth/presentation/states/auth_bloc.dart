import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/domain/user_entity.dart';
import '../../../../core/services/session/pending_action.dart';
import '../../../../core/utils/bloc_status.dart';
import '../../../../core/utils/result.dart';
import '../../data/params/auth_params.dart';
import '../../domain/facade/auth_facade.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

/// Owns sign-in for the whole app.
///
/// In guest-first mode it is provided ABOVE `MaterialApp` rather than per
/// screen: a protected action can be triggered from anywhere, and the sheet
/// that asks for sign-in is not a route.
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._facade, this._pendingActions) : super(const AuthState()) {
    on<_Started>(_onStarted);
    on<_SignInRequested>(_onSignInRequested);
    on<_SignOutRequested>(_onSignOutRequested);
    on<_ContinueAsGuestRequested>(_onContinueAsGuest);
  }

  final AuthFacade _facade;
  final PendingActionQueue _pendingActions;

  Future<void> _onStarted(_Started event, Emitter<AuthState> emit) async {
    emit(const AuthState());
  }

  Future<void> _onSignInRequested(
    _SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.signInStatus.isLoading) return;

    emit(
      state.copyWith(
        signInStatus: const BlocStatus.loading(),
        wasCancelled: false,
      ),
    );

    final result = await _facade.signIn(
      SignInParams(email: event.email, password: event.password),
    );

    await result.when(
      success: (user) async {
        emit(state.copyWith(signInStatus: BlocStatus.success(user)));
        // Whatever the user was trying to do before the gate appeared now
        // happens on its own — they should land back exactly where they were.
        await _pendingActions.runPending();
      },
      failure: (message) async {
        final cancelled = message == PendingActionMessages.cancelled;
        emit(
          state.copyWith(
            signInStatus: cancelled
                ? const BlocStatus.initial()
                : BlocStatus.failure(message),
            wasCancelled: cancelled,
          ),
        );
        if (cancelled) _pendingActions.clear();
      },
    );
  }

  Future<void> _onSignOutRequested(
    _SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(signOutStatus: const BlocStatus.loading()));

    final result = await _facade.signOut();
    result.when(
      success: (_) => emit(const AuthState()),
      failure: (message) =>
          emit(state.copyWith(signOutStatus: BlocStatus.failure(message))),
    );
  }

  Future<void> _onContinueAsGuest(
    _ContinueAsGuestRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _facade.continueAsGuest();
    emit(const AuthState());
  }
}
