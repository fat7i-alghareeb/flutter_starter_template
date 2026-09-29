import '../../../../core/domain/user_entity.dart';
import '../../../../core/utils/result.dart';
import '../../data/params/auth_params.dart';

abstract class AuthRepository {
  /// Signs in and opens an app session.
  Future<Result<UserEntity>> signIn(SignInParams params);

  /// Ends the app session.
  Future<Result<void>> signOut();

  /// Enters the app without an account (`AuthMode.guestFirst`).
  Future<Result<void>> continueAsGuest();
}
