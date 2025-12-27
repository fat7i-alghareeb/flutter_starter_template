import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class AuthFacade {
  const AuthFacade(this._repository);

  final AuthRepository _repository;

  Future<Result<List<AuthEntity>>> getAllAuths() {
    return _repository.getAllAuths();
  }
}
