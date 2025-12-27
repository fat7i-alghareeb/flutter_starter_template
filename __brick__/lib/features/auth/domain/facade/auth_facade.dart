import 'package:injectable/injectable.dart';
import '../../../../core/domain/user_entity.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class AuthFacade {
  const AuthFacade(this._repository);

  final AuthRepository _repository;

  Future<Result<UserEntity>> loginDummy() {
    return _repository.loginDummy();
  }
}
