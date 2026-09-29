import 'package:injectable/injectable.dart';

import '../../../../core/domain/user_entity.dart';
import '../../../../core/utils/result.dart';
import '../../data/params/auth_params.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class AuthFacade {
  const AuthFacade(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> signIn(SignInParams params) =>
      _repository.signIn(params);

  Future<Result<void>> signOut() => _repository.signOut();

  Future<Result<void>> continueAsGuest() => _repository.continueAsGuest();
}
