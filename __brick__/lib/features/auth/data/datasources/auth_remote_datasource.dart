import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/global_error_handler.dart';
import '../models/auth_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<AuthModel>> getAllAuths() {
    return rethrowAsAppException(() async {
      final response = await _dio.get<dynamic>('/auth');
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AuthModel.fromMap)
            .toList();
      }
      return const <AuthModel>[];
    });
  }
}
