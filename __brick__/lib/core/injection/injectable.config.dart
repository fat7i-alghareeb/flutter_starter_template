// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:testNameToDelete/core/injection/register_module.dart' as _i585;
import 'package:testNameToDelete/core/services/session/auth_state_notifier.dart'
    as _i409;
import 'package:testNameToDelete/core/services/session/jwt_token_storage.dart'
    as _i285;
import 'package:testNameToDelete/core/services/storage/storage_service.dart'
    as _i339;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i339.StorageService>(
      () => registerModule.storageService,
      preResolve: true,
    );
    gh.lazySingleton<_i409.AuthStateNotifier>(() => _i409.AuthStateNotifier());
    gh.lazySingleton<_i285.JwtTokenStorage>(
      () => _i285.JwtTokenStorage(gh<_i339.StorageService>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i585.RegisterModule {}
