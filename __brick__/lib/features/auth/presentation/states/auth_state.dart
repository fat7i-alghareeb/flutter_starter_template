part of 'auth_bloc.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    /// A `BlocStatus` per operation, as `features_overview.md` requires — one
    /// shared status would make a sign-out spinner appear on the sign-in button.
    @Default(BlocStatus<UserEntity>.initial())
    BlocStatus<UserEntity> signInStatus,
    @Default(BlocStatus<void>.initial()) BlocStatus<void> signOutStatus,

    /// True when the user dismissed a platform sign-in dialog.
    ///
    /// Kept apart from a failure on purpose: cancelling is a choice, not an
    /// error, and must not be shown in red.
    @Default(false) bool wasCancelled,
  }) = _AuthState;
}
