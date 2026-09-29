part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.started() = _Started;

  /// Signs in and, on success, resumes the [PendingActionQueue]'s action if
  /// one is waiting.
  const factory AuthEvent.signInRequested({
    @Default('') String email,
    @Default('') String password,
  }) = _SignInRequested;

  const factory AuthEvent.signOutRequested() = _SignOutRequested;

  const factory AuthEvent.continueAsGuestRequested() =
      _ContinueAsGuestRequested;
}
