import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/global_error_handler.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_login_response_model.dart';
import '../params/auth_params.dart';

@lazySingleton
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// Trades credentials for the app's own session.
  Future<AuthLoginResponseModel> signIn(SignInParams params) {
    return rethrowAsAppException(() async {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.login,
        data: params.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthLoginResponseModel.fromJson(data);
    });
  }
}
