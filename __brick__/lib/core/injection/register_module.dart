import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';

import '../network/dio_client.dart';
import '../network/interceptors/custom_dio_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/localization_interceptor.dart';
import '../network/interceptors/memory_aware_interceptor.dart';
import '../services/session/auth_manager.dart';
import '../services/session/jwt_token_storage.dart';
import '../services/storage/storage_service.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<StorageService> get storageService => StorageService.createDefault();

  @singleton
  Dio dio(
    MemoryAwareInterceptor memoryAwareInterceptor,
    LocalizationInterceptor localizationInterceptor,
    ErrorInterceptor errorInterceptor,
    CustomDioInterceptor logInterceptor,
    AuthManager authManager,
    JwtTokenStorage tokenStorage,
  ) => createDioClient(
    memoryAwareInterceptor: memoryAwareInterceptor,
    localizationInterceptor: localizationInterceptor,
    errorInterceptor: errorInterceptor,
    logInterceptor: logInterceptor,
    authManager: authManager,
    tokenStorage: tokenStorage,
  );
}
