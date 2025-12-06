import 'package:injectable/injectable.dart';

import '../services/storage/storage_service.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<StorageService> get storageService => StorageService.createDefault();
}
