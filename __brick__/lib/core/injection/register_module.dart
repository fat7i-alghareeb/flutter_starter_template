import 'package:injectable/injectable.dart';

import '../services/storage/storage_service.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  StorageService get storageService => StorageService.createDefault();
}
