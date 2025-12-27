import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/global_error_handler.dart';
import '../models/auth_login_response_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);
  final Dio _dio;
  Future<AuthLoginResponseModel> loginDummy() {
    return rethrowAsAppException(() async {
  
      _dio.options;
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return const AuthLoginResponseModel(
        id: '1',
        accessToken: 'dummy_access_token',
        refreshToken: 'dummy_refresh_token',
      );
    });
  }
}
