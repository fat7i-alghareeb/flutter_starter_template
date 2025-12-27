import '../../../../core/domain/user_entity.dart';
import '../../../../core/services/session/auth_token_model.dart';
import '../models/auth_login_response_model.dart';

extension AuthLoginResponseModelMapper on AuthLoginResponseModel {
  UserEntity toUserEntity() {
    return UserEntity(id: id);
  }

  AuthTokenModel toAuthTokenModel() {
    return AuthTokenModel(accessToken: accessToken, refreshToken: refreshToken);
  }
}
