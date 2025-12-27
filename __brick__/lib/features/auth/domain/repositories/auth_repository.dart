import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Result<List<AuthEntity>>> getAllAuths();
}
