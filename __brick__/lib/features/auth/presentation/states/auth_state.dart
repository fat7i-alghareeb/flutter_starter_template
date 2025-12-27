part of 'auth_bloc.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(BlocStatus<UserEntity>.initial())
    BlocStatus<UserEntity> loginStatus,
  }) = _AuthState;
}
