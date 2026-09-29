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
import 'package:{{project_name}}/core/injection/register_module.dart' as _i292;
import 'package:{{project_name}}/core/network/interceptors/custom_dio_interceptor.dart'
    as _i391;
import 'package:{{project_name}}/core/network/interceptors/error_interceptor.dart'
    as _i676;
import 'package:{{project_name}}/core/network/interceptors/localization_interceptor.dart'
    as _i18;
import 'package:{{project_name}}/core/network/interceptors/memory_aware_interceptor.dart'
    as _i655;
import 'package:{{project_name}}/core/network/interceptors/mock_interceptor.dart'
    as _i625;
import 'package:{{project_name}}/core/network/offline/response_cache.dart' as _i648;
import 'package:{{project_name}}/core/notification/notification_coordinator.dart'
    as _i797;
import 'package:{{project_name}}/core/notification/notification_fcm_service.dart'
    as _i94;
import 'package:{{project_name}}/core/notification/notification_local_service.dart'
    as _i97;
import 'package:{{project_name}}/core/notification/notification_permission_service.dart'
    as _i301;
import 'package:{{project_name}}/core/notification/notification_timezone_service.dart'
    as _i503;
import 'package:{{project_name}}/core/notification/push_token_registrar.dart' as _i148;
import 'package:{{project_name}}/core/router/app_links.dart' as _i1028;
import 'package:{{project_name}}/core/router/router_config.dart' as _i252;
import 'package:{{project_name}}/core/services/localization/locale_service.dart'
    as _i296;
import 'package:{{project_name}}/core/services/onboarding/onboarding_service.dart'
    as _i209;
import 'package:{{project_name}}/core/services/session/auth_manager.dart' as _i937;
import 'package:{{project_name}}/core/services/session/auth_state_notifier.dart'
    as _i671;
import 'package:{{project_name}}/core/services/session/jwt_token_storage.dart' as _i850;
import 'package:{{project_name}}/core/services/session/pending_action.dart' as _i854;
import 'package:{{project_name}}/core/services/storage/storage_service.dart' as _i108;
import 'package:{{project_name}}/core/theme/theme_controller.dart' as _i494;
import 'package:{{project_name}}/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i732;
import 'package:{{project_name}}/features/auth/data/repositories/auth_repository_impl.dart'
    as _i691;
import 'package:{{project_name}}/features/auth/domain/facade/auth_facade.dart' as _i857;
import 'package:{{project_name}}/features/auth/domain/repositories/auth_repository.dart'
    as _i931;
import 'package:{{project_name}}/features/auth/presentation/states/auth_bloc.dart'
    as _i285;
import 'package:{{project_name}}/features/root/data/datasources/root_remote_datasource.dart'
    as _i746;
import 'package:{{project_name}}/features/root/data/repositories/root_repository_impl.dart'
    as _i216;
import 'package:{{project_name}}/features/root/domain/facade/root_facade.dart' as _i319;
import 'package:{{project_name}}/features/root/domain/repositories/root_repository.dart'
    as _i119;
import 'package:{{project_name}}/features/root/presentation/states/root_bloc.dart'
    as _i579;
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart'
    as _i403;
import 'package:{{project_name}}/features/showcase_feed/data/feed_data.dart' as _i20;
import 'package:{{project_name}}/features/showcase_feed/presentation/states/feed_bloc.dart'
    as _i57;
import 'package:{{project_name}}/features/showcase_feed/presentation/states/feed_item_bloc.dart'
    as _i984;
import 'package:{{project_name}}/features/showcase_feed/presentation/states/feed_preloader.dart'
    as _i827;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i108.StorageService>(() => registerModule.storageService);
    gh.lazySingleton<_i391.CustomDioInterceptor>(
      () => _i391.CustomDioInterceptor(),
    );
    gh.lazySingleton<_i676.ErrorInterceptor>(() => _i676.ErrorInterceptor());
    gh.lazySingleton<_i655.MemoryAwareInterceptor>(
      () => _i655.MemoryAwareInterceptor(),
    );
    gh.lazySingleton<_i625.MockInterceptor>(() => _i625.MockInterceptor());
    gh.lazySingleton<_i648.OfflineNotice>(() => _i648.OfflineNotice());
    gh.lazySingleton<_i94.NotificationFcmService>(
      () => _i94.NotificationFcmService(),
    );
    gh.lazySingleton<_i97.NotificationLocalService>(
      () => _i97.NotificationLocalService(),
    );
    gh.lazySingleton<_i301.NotificationPermissionService>(
      () => const _i301.NotificationPermissionService(),
    );
    gh.lazySingleton<_i503.NotificationTimezoneService>(
      () => _i503.NotificationTimezoneService(),
    );
    gh.lazySingleton<_i1028.LinkDispatcher>(() => _i1028.LinkDispatcher());
    gh.lazySingleton<_i252.AppRouteRegistry>(() => _i252.AppRouteRegistry());
    gh.lazySingleton<_i671.AuthStateNotifier>(() => _i671.AuthStateNotifier());
    gh.lazySingleton<_i854.PendingActionQueue>(
      () => _i854.PendingActionQueue(),
    );
    gh.lazySingleton<_i403.NavigationController>(
      () => _i403.NavigationController(),
    );
    gh.lazySingleton<_i296.LocaleService>(
      () => _i296.LocaleService(gh<_i108.StorageService>()),
    );
    gh.lazySingleton<_i209.OnboardingService>(
      () => _i209.OnboardingService(gh<_i108.StorageService>()),
    );
    gh.lazySingleton<_i850.JwtTokenStorage>(
      () => _i850.JwtTokenStorage(gh<_i108.StorageService>()),
    );
    gh.lazySingleton<_i494.ThemeController>(
      () => _i494.ThemeController(gh<_i108.StorageService>()),
    );
    gh.lazySingleton<_i20.FeedLocalDataSource>(
      () => _i20.FeedLocalDataSource(gh<_i108.StorageService>()),
    );
    gh.lazySingleton<_i827.FeedPreloader>(
      () => _i827.FeedPreloader(
        gh<_i671.AuthStateNotifier>(),
        gh<_i209.OnboardingService>(),
      ),
    );
    gh.lazySingleton<_i937.AuthManager>(
      () => _i937.AuthManager(
        storage: gh<_i108.StorageService>(),
        state: gh<_i671.AuthStateNotifier>(),
        tokenStorage: gh<_i850.JwtTokenStorage>(),
      ),
    );
    gh.lazySingleton<_i648.ResponseCacheStore>(
      () => _i648.ObjectBoxResponseCacheStore(),
    );
    gh.lazySingleton<_i797.NotificationCoordinator>(
      () => _i797.NotificationCoordinator(
        gh<_i301.NotificationPermissionService>(),
        gh<_i503.NotificationTimezoneService>(),
        gh<_i97.NotificationLocalService>(),
        gh<_i94.NotificationFcmService>(),
      ),
    );
    gh.lazySingleton<_i252.AppRouterConfig>(
      () => _i252.AppRouterConfig(
        gh<_i671.AuthStateNotifier>(),
        gh<_i209.OnboardingService>(),
        gh<_i252.AppRouteRegistry>(),
        gh<_i1028.LinkDispatcher>(),
      ),
    );
    gh.lazySingleton<_i18.LocalizationInterceptor>(
      () => _i18.LocalizationInterceptor(gh<_i296.LocaleService>()),
    );
    gh.lazySingleton<_i648.OfflineCacheInterceptor>(
      () => _i648.OfflineCacheInterceptor(
        gh<_i648.ResponseCacheStore>(),
        gh<_i648.OfflineNotice>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dioClient(
        gh<_i625.MockInterceptor>(),
        gh<_i648.OfflineCacheInterceptor>(),
        gh<_i655.MemoryAwareInterceptor>(),
        gh<_i18.LocalizationInterceptor>(),
        gh<_i676.ErrorInterceptor>(),
        gh<_i391.CustomDioInterceptor>(),
        gh<_i937.AuthManager>(),
        gh<_i850.JwtTokenStorage>(),
      ),
    );
    gh.lazySingleton<_i148.PushTokenRegistrar>(
      () => _i148.PushTokenRegistrar(
        gh<_i361.Dio>(),
        gh<_i671.AuthStateNotifier>(),
      ),
    );
    gh.lazySingleton<_i732.AuthRemoteDataSource>(
      () => _i732.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i746.RootRemoteDataSource>(
      () => _i746.RootRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i20.FeedRemoteDataSource>(
      () => _i20.FeedRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i20.FeedRepository>(
      () => _i20.FeedRepositoryImpl(
        gh<_i20.FeedRemoteDataSource>(),
        gh<_i20.FeedLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i931.AuthRepository>(
      () => _i691.AuthRepositoryImpl(
        gh<_i732.AuthRemoteDataSource>(),
        gh<_i937.AuthManager>(),
      ),
    );
    gh.factory<_i57.FeedBloc>(() => _i57.FeedBloc(gh<_i20.FeedRepository>()));
    gh.factory<_i984.FeedItemBloc>(
      () => _i984.FeedItemBloc(gh<_i20.FeedRepository>()),
    );
    gh.lazySingleton<_i119.RootRepository>(
      () => _i216.RootRepositoryImpl(gh<_i746.RootRemoteDataSource>()),
    );
    gh.lazySingleton<_i319.RootFacade>(
      () => _i319.RootFacade(gh<_i119.RootRepository>()),
    );
    gh.lazySingleton<_i857.AuthFacade>(
      () => _i857.AuthFacade(gh<_i931.AuthRepository>()),
    );
    gh.factory<_i579.RootBloc>(() => _i579.RootBloc(gh<_i319.RootFacade>()));
    gh.factory<_i285.AuthBloc>(
      () => _i285.AuthBloc(
        gh<_i857.AuthFacade>(),
        gh<_i854.PendingActionQueue>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i292.RegisterModule {}
