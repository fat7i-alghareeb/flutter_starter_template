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
import 'package:{{project_name}}/core/injection/register_module.dart' as _i21;
import 'package:{{project_name}}/core/network/interceptors/custom_dio_interceptor.dart'
    as _i65;
import 'package:{{project_name}}/core/network/interceptors/error_interceptor.dart'
    as _i571;
import 'package:{{project_name}}/core/network/interceptors/localization_interceptor.dart'
    as _i557;
import 'package:{{project_name}}/core/network/interceptors/memory_aware_interceptor.dart'
    as _i709;
import 'package:{{project_name}}/core/notification/notification_coordinator.dart'
    as _i602;
import 'package:{{project_name}}/core/notification/notification_fcm_service.dart'
    as _i722;
import 'package:{{project_name}}/core/notification/notification_local_service.dart'
    as _i879;
import 'package:{{project_name}}/core/notification/notification_permission_service.dart'
    as _i491;
import 'package:{{project_name}}/core/notification/notification_timezone_service.dart'
    as _i286;
import 'package:{{project_name}}/core/router/router_config.dart' as _i881;
import 'package:{{project_name}}/core/services/localization/locale_service.dart'
    as _i490;
import 'package:{{project_name}}/core/services/onboarding/onboarding_service.dart'
    as _i435;
import 'package:{{project_name}}/core/services/session/auth_manager.dart' as _i679;
import 'package:{{project_name}}/core/services/session/auth_state_notifier.dart'
    as _i972;
import 'package:{{project_name}}/core/services/session/jwt_token_storage.dart'
    as _i407;
import 'package:{{project_name}}/core/services/storage/storage_service.dart'
    as _i630;
import 'package:{{project_name}}/core/theme/theme_controller.dart' as _i399;
import 'package:{{project_name}}/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i679;
import 'package:{{project_name}}/features/auth/data/repositories/auth_repository_impl.dart'
    as _i342;
import 'package:{{project_name}}/features/auth/domain/facade/auth_facade.dart'
    as _i161;
import 'package:{{project_name}}/features/auth/domain/repositories/auth_repository.dart'
    as _i106;
import 'package:{{project_name}}/features/auth/presentation/states/auth_bloc.dart'
    as _i541;
import 'package:{{project_name}}/features/root/data/datasources/root_remote_datasource.dart'
    as _i978;
import 'package:{{project_name}}/features/root/data/repositories/root_repository_impl.dart'
    as _i908;
import 'package:{{project_name}}/features/root/domain/facade/root_facade.dart'
    as _i285;
import 'package:{{project_name}}/features/root/domain/repositories/root_repository.dart'
    as _i1016;
import 'package:{{project_name}}/features/root/presentation/states/root_bloc.dart'
    as _i591;
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart'
    as _i614;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.factory<_i614.NavigationController>(() => _i614.NavigationController());
    gh.lazySingleton<_i630.StorageService>(() => registerModule.storageService);
    gh.lazySingleton<_i65.CustomDioInterceptor>(
      () => _i65.CustomDioInterceptor(),
    );
    gh.lazySingleton<_i571.ErrorInterceptor>(() => _i571.ErrorInterceptor());
    gh.lazySingleton<_i709.MemoryAwareInterceptor>(
      () => _i709.MemoryAwareInterceptor(),
    );
    gh.lazySingleton<_i722.NotificationFcmService>(
      () => _i722.NotificationFcmService(),
    );
    gh.lazySingleton<_i879.NotificationLocalService>(
      () => _i879.NotificationLocalService(),
    );
    gh.lazySingleton<_i491.NotificationPermissionService>(
      () => const _i491.NotificationPermissionService(),
    );
    gh.lazySingleton<_i286.NotificationTimezoneService>(
      () => _i286.NotificationTimezoneService(),
    );
    gh.lazySingleton<_i881.AppRouteRegistry>(
      () => const _i881.AppRouteRegistry(),
    );
    gh.lazySingleton<_i972.AuthStateNotifier>(() => _i972.AuthStateNotifier());
    gh.lazySingleton<_i490.LocaleService>(
      () => _i490.LocaleService(gh<_i630.StorageService>()),
    );
    gh.lazySingleton<_i435.OnboardingService>(
      () => _i435.OnboardingService(gh<_i630.StorageService>()),
    );
    gh.lazySingleton<_i407.JwtTokenStorage>(
      () => _i407.JwtTokenStorage(gh<_i630.StorageService>()),
    );
    gh.lazySingleton<_i399.ThemeController>(
      () => _i399.ThemeController(gh<_i630.StorageService>()),
    );
    gh.lazySingleton<_i557.LocalizationInterceptor>(
      () => _i557.LocalizationInterceptor(gh<_i490.LocaleService>()),
    );
    gh.lazySingleton<_i881.AppRouterConfig>(
      () => _i881.AppRouterConfig(
        gh<_i972.AuthStateNotifier>(),
        gh<_i435.OnboardingService>(),
        gh<_i881.AppRouteRegistry>(),
      ),
    );
    gh.lazySingleton<_i602.NotificationCoordinator>(
      () => _i602.NotificationCoordinator(
        gh<_i491.NotificationPermissionService>(),
        gh<_i286.NotificationTimezoneService>(),
        gh<_i879.NotificationLocalService>(),
        gh<_i722.NotificationFcmService>(),
      ),
    );
    gh.lazySingleton<_i679.AuthManager>(
      () => _i679.AuthManager(
        storage: gh<_i630.StorageService>(),
        state: gh<_i972.AuthStateNotifier>(),
        tokenStorage: gh<_i407.JwtTokenStorage>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dioClient(
        gh<_i709.MemoryAwareInterceptor>(),
        gh<_i557.LocalizationInterceptor>(),
        gh<_i571.ErrorInterceptor>(),
        gh<_i65.CustomDioInterceptor>(),
        gh<_i679.AuthManager>(),
        gh<_i407.JwtTokenStorage>(),
      ),
    );
    gh.lazySingleton<_i679.AuthRemoteDataSource>(
      () => _i679.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i978.RootRemoteDataSource>(
      () => _i978.RootRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i106.AuthRepository>(
      () => _i342.AuthRepositoryImpl(
        gh<_i679.AuthRemoteDataSource>(),
        gh<_i679.AuthManager>(),
      ),
    );
    gh.lazySingleton<_i1016.RootRepository>(
      () => _i908.RootRepositoryImpl(gh<_i978.RootRemoteDataSource>()),
    );
    gh.lazySingleton<_i285.RootFacade>(
      () => _i285.RootFacade(gh<_i1016.RootRepository>()),
    );
    gh.lazySingleton<_i161.AuthFacade>(
      () => _i161.AuthFacade(gh<_i106.AuthRepository>()),
    );
    gh.factory<_i541.AuthBloc>(() => _i541.AuthBloc(gh<_i161.AuthFacade>()));
    gh.factory<_i591.RootBloc>(() => _i591.RootBloc(gh<_i285.RootFacade>()));
    return this;
  }
}

class _$RegisterModule extends _i21.RegisterModule {}
