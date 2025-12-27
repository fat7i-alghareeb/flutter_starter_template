import 'package:injectable/injectable.dart';

import '../../../../core/error/global_error_handler.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/root_entity.dart';
import '../../domain/repositories/root_repository.dart';
import '../datasources/root_remote_datasource.dart';
import '../mappers/root_model_mapper.dart';

@LazySingleton(as: RootRepository)
class RootRepositoryImpl implements RootRepository {
  const RootRepositoryImpl(this._remote);

  final RootRemoteDataSource _remote;

  @override
  Future<Result<List<RootEntity>>> getAllRoots() {
    return runAsResult(() async {
      final models = await _remote.getAllRoots();
      return models.map((e) => e.toEntity).toList();
    });
  }
}
