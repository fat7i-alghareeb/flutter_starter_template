// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:test_name_to_delete/core/injection/register_module.dart'
    as _i937;
import 'package:test_name_to_delete/core/network/interceptors/custom_dio_interceptor.dart'
    as _i763;
import 'package:test_name_to_delete/core/network/interceptors/error_interceptor.dart'
    as _i129;
import 'package:test_name_to_delete/core/network/interceptors/localization_interceptor.dart'
    as _i1004;
import 'package:test_name_to_delete/core/network/interceptors/memory_aware_interceptor.dart'
    as _i462;
import 'package:test_name_to_delete/core/notification/notification_coordinator.dart'
    as _i577;
import 'package:test_name_to_delete/core/notification/notification_fcm_service.dart'
    as _i668;
import 'package:test_name_to_delete/core/notification/notification_local_service.dart'
    as _i296;
import 'package:test_name_to_delete/core/notification/notification_permission_service.dart'
    as _i747;
import 'package:test_name_to_delete/core/notification/notification_timezone_service.dart'
    as _i525;
import 'package:test_name_to_delete/core/router/app_routes.dart' as _i490;
import 'package:test_name_to_delete/core/router/router_config.dart' as _i112;
import 'package:test_name_to_delete/core/services/localization/locale_service.dart'
    as _i870;
import 'package:test_name_to_delete/core/services/onboarding/onboarding_service.dart'
    as _i175;
import 'package:test_name_to_delete/core/services/session/auth_state_notifier.dart'
    as _i949;
import 'package:test_name_to_delete/core/services/session/jwt_token_storage.dart'
    as _i1051;
import 'package:test_name_to_delete/core/services/storage/storage_service.dart'
    as _i841;
import 'package:test_name_to_delete/core/theme/theme_controller.dart' as _i247;
import 'package:test_name_to_delete/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i847;
import 'package:test_name_to_delete/features/auth/data/repositories/auth_repository_impl.dart'
    as _i1058;
import 'package:test_name_to_delete/features/auth/domain/facade/auth_facade.dart'
    as _i890;
import 'package:test_name_to_delete/features/auth/domain/repositories/auth_repository.dart'
    as _i217;
import 'package:test_name_to_delete/features/auth/presentation/states/auth_bloc.dart'
    as _i512;
import 'package:test_name_to_delete/features/root/data/datasources/root_remote_datasource.dart'
    as _i544;
import 'package:test_name_to_delete/features/root/data/repositories/root_repository_impl.dart'
    as _i943;
import 'package:test_name_to_delete/features/root/domain/facade/root_facade.dart'
    as _i174;
import 'package:test_name_to_delete/features/root/domain/repositories/root_repository.dart'
    as _i825;
import 'package:test_name_to_delete/features/root/presentation/states/root_bloc.dart'
    as _i244;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i841.StorageService>(
      () => registerModule.storageService,
      preResolve: true,
    );
    gh.lazySingleton<_i763.CustomDioInterceptor>(
      () => _i763.CustomDioInterceptor(),
    );
    gh.lazySingleton<_i129.ErrorInterceptor>(() => _i129.ErrorInterceptor());
    gh.lazySingleton<_i462.MemoryAwareInterceptor>(
      () => _i462.MemoryAwareInterceptor(),
    );
    gh.lazySingleton<_i668.NotificationFcmService>(
      () => _i668.NotificationFcmService(),
    );
    gh.lazySingleton<_i296.NotificationLocalService>(
      () => _i296.NotificationLocalService(),
    );
    gh.lazySingleton<_i747.NotificationPermissionService>(
      () => const _i747.NotificationPermissionService(),
    );
    gh.lazySingleton<_i525.NotificationTimezoneService>(
      () => _i525.NotificationTimezoneService(),
    );
    gh.lazySingleton<_i490.AppRouteRegistry>(
      () => const _i490.AppRouteRegistry(),
    );
    gh.lazySingleton<_i949.AuthStateNotifier>(() => _i949.AuthStateNotifier());
    gh.lazySingleton<_i247.ThemeController>(() => _i247.ThemeController());
    gh.lazySingleton<_i870.LocaleService>(
      () => _i870.LocaleService(gh<_i841.StorageService>()),
    );
    gh.lazySingleton<_i175.OnboardingService>(
      () => _i175.OnboardingService(gh<_i841.StorageService>()),
    );
    gh.lazySingleton<_i1051.JwtTokenStorage>(
      () => _i1051.JwtTokenStorage(gh<_i841.StorageService>()),
    );
    gh.lazySingleton<_i847.AuthRemoteDataSource>(
      () => _i847.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i544.RootRemoteDataSource>(
      () => _i544.RootRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i217.AuthRepository>(
      () => _i1058.AuthRepositoryImpl(gh<_i847.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i1004.LocalizationInterceptor>(
      () => _i1004.LocalizationInterceptor(gh<_i870.LocaleService>()),
    );
    gh.lazySingleton<_i112.AppRouterConfig>(
      () => _i112.AppRouterConfig(
        gh<_i949.AuthStateNotifier>(),
        gh<_i175.OnboardingService>(),
        gh<_i490.AppRouteRegistry>(),
      ),
    );
    gh.lazySingleton<_i577.NotificationCoordinator>(
      () => _i577.NotificationCoordinator(
        gh<_i747.NotificationPermissionService>(),
        gh<_i525.NotificationTimezoneService>(),
        gh<_i296.NotificationLocalService>(),
        gh<_i668.NotificationFcmService>(),
      ),
    );
    gh.lazySingleton<_i890.AuthFacade>(
      () => _i890.AuthFacade(gh<_i217.AuthRepository>()),
    );
    gh.lazySingleton<_i825.RootRepository>(
      () => _i943.RootRepositoryImpl(gh<_i544.RootRemoteDataSource>()),
    );
    gh.lazySingleton<_i174.RootFacade>(
      () => _i174.RootFacade(gh<_i825.RootRepository>()),
    );
    gh.factory<_i512.AuthBloc>(() => _i512.AuthBloc(gh<_i890.AuthFacade>()));
    gh.factory<_i244.RootBloc>(() => _i244.RootBloc(gh<_i174.RootFacade>()));
    return this;
  }
}

class _$RegisterModule extends _i937.RegisterModule {}
