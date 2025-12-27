import '../../../../core/domain/user_entity.dart';
import '../../../../core/utils/result.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> loginDummy();
}
