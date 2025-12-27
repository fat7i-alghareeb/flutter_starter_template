import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/global_error_handler.dart';
import '../models/root_model.dart';

@lazySingleton
class RootRemoteDataSource {
  const RootRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<RootModel>> getAllRoots() {
    return rethrowAsAppException(() async {
      final response = await _dio.get<dynamic>('/root');
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(RootModel.fromMap)
            .toList();
      }
      return const <RootModel>[];
    });
  }
}
