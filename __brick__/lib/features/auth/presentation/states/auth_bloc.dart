import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/domain/user_entity.dart';
import '../../../../core/utils/bloc_status.dart';
import '../../../../core/utils/result.dart';
import '../../domain/facade/auth_facade.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._facade) : super(const AuthState()) {
    on<_Started>(_onStarted);
    on<_LoginRequested>(_onLoginRequested);
  }

  final AuthFacade _facade;

  Future<void> _onStarted(_Started event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginStatus: const BlocStatus.initial()));
  }

  Future<void> _onLoginRequested(
    _LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.loginStatus.isLoading) return;

    emit(state.copyWith(loginStatus: const BlocStatus.loading()));

    final Result<UserEntity> result = await _facade.loginDummy();
    result.when(
      success: (user) =>
          emit(state.copyWith(loginStatus: BlocStatus.success(user))),
      failure: (message) =>
          emit(state.copyWith(loginStatus: BlocStatus.failure(message))),
    );
  }
}
