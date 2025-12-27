import 'package:injectable/injectable.dart';

import '../../../../core/domain/user_entity.dart';
import '../../../../core/error/global_error_handler.dart';
import '../../../../core/injection/injectable.dart' show getIt;
import '../../../../core/services/session/auth_manager.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_model_mapper.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Result<UserEntity>> loginDummy() {
    return runAsResult(() async {
      final response = await _remote.loginDummy();

      final user = response.toUserEntity();
      final token = response.toAuthTokenModel();

      final authManager = getIt<AuthManager>();
      await authManager.login(user: user, token: token);
      return user;
    });
  }
}
