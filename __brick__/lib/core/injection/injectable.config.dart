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
import 'package:{{project_name}}/core/injection/register_module.dart' as _i833;
import 'package:{{project_name}}/core/layout/layout_reader.dart' as _i206;
import 'package:{{project_name}}/core/network/interceptors/custom_dio_interceptor.dart'
    as _i954;
import 'package:{{project_name}}/core/network/interceptors/error_interceptor.dart' as _i6;
import 'package:{{project_name}}/core/network/interceptors/localization_interceptor.dart'
    as _i969;
import 'package:{{project_name}}/core/network/interceptors/memory_aware_interceptor.dart'
    as _i630;
import 'package:{{project_name}}/core/network/interceptors/mock_interceptor.dart'
    as _i843;
import 'package:{{project_name}}/core/network/offline/response_cache.dart' as _i447;
import 'package:{{project_name}}/core/notification/notification_coordinator.dart'
    as _i493;
import 'package:{{project_name}}/core/notification/notification_fcm_service.dart'
    as _i766;
import 'package:{{project_name}}/core/notification/notification_local_service.dart'
    as _i837;
import 'package:{{project_name}}/core/notification/notification_permission_service.dart'
    as _i599;
import 'package:{{project_name}}/core/notification/notification_timezone_service.dart'
    as _i598;
import 'package:{{project_name}}/core/notification/push_token_registrar.dart' as _i51;
import 'package:{{project_name}}/core/router/app_links.dart' as _i31;
import 'package:{{project_name}}/core/router/router_config.dart' as _i556;
import 'package:{{project_name}}/core/services/haptics/haptics_service.dart' as _i376;
import 'package:{{project_name}}/core/services/localization/locale_service.dart' as _i628;
import 'package:{{project_name}}/core/services/onboarding/onboarding_service.dart'
    as _i591;
import 'package:{{project_name}}/core/services/session/auth_manager.dart' as _i1052;
import 'package:{{project_name}}/core/services/session/auth_state_notifier.dart' as _i258;
import 'package:{{project_name}}/core/services/session/jwt_token_storage.dart' as _i1;
import 'package:{{project_name}}/core/services/session/pending_action.dart' as _i481;
import 'package:{{project_name}}/core/services/storage/storage_service.dart' as _i301;
import 'package:{{project_name}}/core/theme/theme_controller.dart' as _i29;
import 'package:{{project_name}}/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i373;
import 'package:{{project_name}}/features/auth/data/repositories/auth_repository_impl.dart'
    as _i434;
import 'package:{{project_name}}/features/auth/domain/facade/auth_facade.dart' as _i936;
import 'package:{{project_name}}/features/auth/domain/repositories/auth_repository.dart'
    as _i122;
import 'package:{{project_name}}/features/auth/presentation/states/auth_bloc.dart'
    as _i456;
import 'package:{{project_name}}/features/root/data/datasources/root_remote_datasource.dart'
    as _i909;
import 'package:{{project_name}}/features/root/data/repositories/root_repository_impl.dart'
    as _i320;
import 'package:{{project_name}}/features/root/domain/facade/root_facade.dart' as _i15;
import 'package:{{project_name}}/features/root/domain/repositories/root_repository.dart'
    as _i818;
import 'package:{{project_name}}/features/root/presentation/states/root_bloc.dart'
    as _i796;
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart'
    as _i75;
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/side_nav_controller.dart'
    as _i501;
import 'package:{{project_name}}/features/showcase_feed/data/feed_data.dart' as _i13;
import 'package:{{project_name}}/features/showcase_feed/presentation/states/feed_bloc.dart'
    as _i323;
import 'package:{{project_name}}/features/showcase_feed/presentation/states/feed_item_bloc.dart'
    as _i489;
import 'package:{{project_name}}/features/showcase_feed/presentation/states/feed_preloader.dart'
    as _i852;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i301.StorageService>(() => registerModule.storageService);
    gh.lazySingleton<_i376.HapticsService>(() => registerModule.haptics);
    gh.lazySingleton<_i206.LayoutReader>(
      () => _i206.LayoutReader(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i954.CustomDioInterceptor>(
      () => _i954.CustomDioInterceptor(),
    );
    gh.lazySingleton<_i6.ErrorInterceptor>(() => _i6.ErrorInterceptor());
    gh.lazySingleton<_i630.MemoryAwareInterceptor>(
      () => _i630.MemoryAwareInterceptor(),
    );
    gh.lazySingleton<_i843.MockInterceptor>(() => _i843.MockInterceptor());
    gh.lazySingleton<_i447.OfflineNotice>(() => _i447.OfflineNotice());
    gh.lazySingleton<_i766.NotificationFcmService>(
      () => _i766.NotificationFcmService(),
    );
    gh.lazySingleton<_i837.NotificationLocalService>(
      () => _i837.NotificationLocalService(),
    );
    gh.lazySingleton<_i599.NotificationPermissionService>(
      () => const _i599.NotificationPermissionService(),
    );
    gh.lazySingleton<_i598.NotificationTimezoneService>(
      () => _i598.NotificationTimezoneService(),
    );
    gh.lazySingleton<_i31.LinkDispatcher>(() => _i31.LinkDispatcher());
    gh.lazySingleton<_i556.AppRouteRegistry>(() => _i556.AppRouteRegistry());
    gh.lazySingleton<_i258.AuthStateNotifier>(() => _i258.AuthStateNotifier());
    gh.lazySingleton<_i481.PendingActionQueue>(
      () => _i481.PendingActionQueue(),
    );
    gh.lazySingleton<_i75.NavigationController>(
      () => _i75.NavigationController(),
    );
    gh.lazySingleton<_i493.NotificationCoordinator>(
      () => _i493.NotificationCoordinator(
        gh<_i599.NotificationPermissionService>(),
        gh<_i598.NotificationTimezoneService>(),
        gh<_i837.NotificationLocalService>(),
        gh<_i766.NotificationFcmService>(),
      ),
    );
    gh.lazySingleton<_i447.ResponseCacheStore>(
      () => _i447.ObjectBoxResponseCacheStore(),
    );
    gh.lazySingleton<_i628.LocaleService>(
      () => _i628.LocaleService(gh<_i301.StorageService>()),
    );
    gh.lazySingleton<_i591.OnboardingService>(
      () => _i591.OnboardingService(gh<_i301.StorageService>()),
    );
    gh.lazySingleton<_i1.JwtTokenStorage>(
      () => _i1.JwtTokenStorage(gh<_i301.StorageService>()),
    );
    gh.lazySingleton<_i29.ThemeController>(
      () => _i29.ThemeController(gh<_i301.StorageService>()),
    );
    gh.lazySingleton<_i501.SideNavController>(
      () => _i501.SideNavController(gh<_i301.StorageService>()),
    );
    gh.lazySingleton<_i13.FeedLocalDataSource>(
      () => _i13.FeedLocalDataSource(gh<_i301.StorageService>()),
    );
    gh.lazySingleton<_i447.OfflineCacheInterceptor>(
      () => _i447.OfflineCacheInterceptor(
        gh<_i447.ResponseCacheStore>(),
        gh<_i447.OfflineNotice>(),
      ),
    );
    gh.lazySingleton<_i852.FeedPreloader>(
      () => _i852.FeedPreloader(
        gh<_i258.AuthStateNotifier>(),
        gh<_i591.OnboardingService>(),
      ),
    );
    gh.lazySingleton<_i969.LocalizationInterceptor>(
      () => _i969.LocalizationInterceptor(gh<_i628.LocaleService>()),
    );
    gh.lazySingleton<_i556.AppRouterConfig>(
      () => _i556.AppRouterConfig(
        gh<_i258.AuthStateNotifier>(),
        gh<_i591.OnboardingService>(),
        gh<_i556.AppRouteRegistry>(),
        gh<_i31.LinkDispatcher>(),
      ),
    );
    gh.lazySingleton<_i1052.AuthManager>(
      () => _i1052.AuthManager(
        storage: gh<_i301.StorageService>(),
        state: gh<_i258.AuthStateNotifier>(),
        tokenStorage: gh<_i1.JwtTokenStorage>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dioClient(
        gh<_i843.MockInterceptor>(),
        gh<_i447.OfflineCacheInterceptor>(),
        gh<_i630.MemoryAwareInterceptor>(),
        gh<_i969.LocalizationInterceptor>(),
        gh<_i6.ErrorInterceptor>(),
        gh<_i954.CustomDioInterceptor>(),
        gh<_i1052.AuthManager>(),
        gh<_i1.JwtTokenStorage>(),
      ),
    );
    gh.lazySingleton<_i373.AuthRemoteDataSource>(
      () => _i373.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i909.RootRemoteDataSource>(
      () => _i909.RootRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i13.FeedRemoteDataSource>(
      () => _i13.FeedRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i122.AuthRepository>(
      () => _i434.AuthRepositoryImpl(
        gh<_i373.AuthRemoteDataSource>(),
        gh<_i1052.AuthManager>(),
      ),
    );
    gh.lazySingleton<_i13.FeedRepository>(
      () => _i13.FeedRepositoryImpl(
        gh<_i13.FeedRemoteDataSource>(),
        gh<_i13.FeedLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i818.RootRepository>(
      () => _i320.RootRepositoryImpl(gh<_i909.RootRemoteDataSource>()),
    );
    gh.lazySingleton<_i936.AuthFacade>(
      () => _i936.AuthFacade(gh<_i122.AuthRepository>()),
    );
    gh.lazySingleton<_i15.RootFacade>(
      () => _i15.RootFacade(gh<_i818.RootRepository>()),
    );
    gh.lazySingleton<_i51.PushTokenRegistrar>(
      () => _i51.PushTokenRegistrar(
        gh<_i361.Dio>(),
        gh<_i258.AuthStateNotifier>(),
      ),
    );
    gh.factory<_i323.FeedBloc>(() => _i323.FeedBloc(gh<_i13.FeedRepository>()));
    gh.factory<_i489.FeedItemBloc>(
      () => _i489.FeedItemBloc(gh<_i13.FeedRepository>()),
    );
    gh.factory<_i796.RootBloc>(() => _i796.RootBloc(gh<_i15.RootFacade>()));
    gh.factory<_i456.AuthBloc>(
      () => _i456.AuthBloc(
        gh<_i936.AuthFacade>(),
        gh<_i481.PendingActionQueue>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i833.RegisterModule {}
