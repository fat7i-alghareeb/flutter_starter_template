part of 'auth_bloc.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(BlocStatus<List<AuthEntity>>.initial())
    BlocStatus<List<AuthEntity>> getAllState,
  }) = _AuthState;
}
