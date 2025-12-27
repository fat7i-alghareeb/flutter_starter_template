import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/bloc_status.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/facade/auth_facade.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._facade) : super(const AuthState()) {
    on<_Started>(_onStarted);
    on<_GetAllRequested>(_onGetAllRequested);
  }

  final AuthFacade _facade;

  Future<void> _onStarted(_Started event, Emitter<AuthState> emit) {
    return _onGetAllRequested(const _GetAllRequested(), emit);
  }

  Future<void> _onGetAllRequested(
    _GetAllRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(getAllState: const BlocStatus.loading()));

    final result = await _facade.getAllAuths();
    result.when(
      success: (data) => emit(state.copyWith(getAllState: BlocStatus.success(data))),
      failure: (message) => emit(state.copyWith(getAllState: BlocStatus.failure(message))),
    );
  }
}
