import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:injectable/injectable.dart';

import '../network/dio_client.dart';
import '../network/interceptors/custom_dio_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/localization_interceptor.dart';
import '../network/interceptors/memory_aware_interceptor.dart';
import '../services/session/auth_manager.dart';
import '../services/session/auth_state_notifier.dart';
import '../services/session/jwt_token_storage.dart';
import '../services/storage/storage_service.dart';
import 'injectable.config.dart';

/// Global GetIt instance used across the app.
final GetIt getIt = GetIt.instance;

/// Configures dependency injection using Injectable + GetIt.
///
/// This function registers low-level primitives like [StorageService]
/// manually, then delegates the rest of the wiring to the generated
/// `GetItInjectableX.init()` extension.
@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
}

/// Registers a single [AuthManager] instance based on the desired [mode].
///
/// Call this after [configureDependencies] but before using [AuthManager].
void registerAuthManager(AuthMode mode) {
  if (getIt.isRegistered<AuthManager>()) {
    return;
  }

  final storage = getIt<StorageService>();
  final state = getIt<AuthStateNotifier>();

  late final AuthManager manager;
  if (mode == AuthMode.withJwt) {
    final jwtStorage = getIt<JwtTokenStorage>();
    manager = AuthManager.withJwt(
      storage: storage,
      state: state,
      tokenStorage: jwtStorage,
    );
  } else {
    manager = AuthManager.withoutJwt(storage: storage, state: state);
  }

  getIt.registerSingleton<AuthManager>(manager);
}

/// Registers a global [Dio] client configured according to the given
/// [AuthMode]. If a [Dio] instance is already registered, it is returned as-is.
Dio registerDioClient(AuthMode mode) {
  if (getIt.isRegistered<Dio>()) {
    return getIt<Dio>();
  }

  final memoryAware = getIt<MemoryAwareInterceptor>();
  final localization = getIt<LocalizationInterceptor>();
  final errorInterceptor = getIt<ErrorInterceptor>();
  final logInterceptor = getIt<CustomDioInterceptor>();

  // Auth-related collaborators are only required when JWT mode is enabled.
  final authManager = mode == AuthMode.withJwt ? getIt<AuthManager>() : null;
  final jwtStorage = mode == AuthMode.withJwt ? getIt<JwtTokenStorage>() : null;

  final dio = createDioClient(
    mode: mode,
    memoryAwareInterceptor: memoryAware,
    localizationInterceptor: localization,
    errorInterceptor: errorInterceptor,
    logInterceptor: logInterceptor,
    authManager: authManager,
    tokenStorage: jwtStorage,
  );
  getIt.registerSingleton<Dio>(dio);
  return dio;
}
