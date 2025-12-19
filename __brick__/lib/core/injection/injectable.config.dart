// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:testNameToDelete/core/injection/register_module.dart' as _i13;
import 'package:testNameToDelete/core/network/interceptors/custom_dio_interceptor.dart'
    as _i616;
import 'package:testNameToDelete/core/network/interceptors/error_interceptor.dart'
    as _i97;
import 'package:testNameToDelete/core/network/interceptors/localization_interceptor.dart'
    as _i727;
import 'package:testNameToDelete/core/network/interceptors/memory_aware_interceptor.dart'
    as _i1017;
import 'package:testNameToDelete/core/notification/notification_coordinator.dart'
    as _i944;
import 'package:testNameToDelete/core/notification/notification_fcm_service.dart'
    as _i140;
import 'package:testNameToDelete/core/notification/notification_local_service.dart'
    as _i468;
import 'package:testNameToDelete/core/notification/notification_permission_service.dart'
    as _i312;
import 'package:testNameToDelete/core/notification/notification_timezone_service.dart'
    as _i615;
import 'package:testNameToDelete/core/router/app_routes.dart' as _i685;
import 'package:testNameToDelete/core/router/router_config.dart' as _i1040;
import 'package:testNameToDelete/core/services/localization/locale_service.dart'
    as _i510;
import 'package:testNameToDelete/core/services/onboarding/onboarding_service.dart'
    as _i555;
import 'package:testNameToDelete/core/services/session/auth_state_notifier.dart'
    as _i539;
import 'package:testNameToDelete/core/services/session/jwt_token_storage.dart'
    as _i746;
import 'package:testNameToDelete/core/services/storage/storage_service.dart'
    as _i658;
import 'package:testNameToDelete/core/theme/theme_controller.dart' as _i845;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i658.StorageService>(
      () => registerModule.storageService,
      preResolve: true,
    );
    gh.lazySingleton<_i97.ErrorInterceptor>(() => _i97.ErrorInterceptor());
    gh.lazySingleton<_i312.NotificationPermissionService>(
      () => const _i312.NotificationPermissionService(),
    );
    gh.lazySingleton<_i615.NotificationTimezoneService>(
      () => _i615.NotificationTimezoneService(),
    );
    gh.lazySingleton<_i468.NotificationLocalService>(
      () => _i468.NotificationLocalService(),
    );
    gh.lazySingleton<_i140.NotificationFcmService>(
      () => _i140.NotificationFcmService(),
    );
    gh.lazySingleton<_i944.NotificationCoordinator>(
      () => _i944.NotificationCoordinator(
        gh<_i312.NotificationPermissionService>(),
        gh<_i615.NotificationTimezoneService>(),
        gh<_i468.NotificationLocalService>(),
        gh<_i140.NotificationFcmService>(),
      ),
    );
    gh.lazySingleton<_i685.AppRouteRegistry>(
      () => const _i685.AppRouteRegistry(),
    );
    gh.lazySingleton<_i539.AuthStateNotifier>(() => _i539.AuthStateNotifier());
    gh.lazySingleton<_i845.ThemeController>(() => _i845.ThemeController());
    gh.lazySingleton<_i1017.MemoryAwareInterceptor>(
      () => _i1017.MemoryAwareInterceptor(maxResponseSizeBytes: gh<int>()),
    );
    gh.lazySingleton<_i510.LocaleService>(
      () => _i510.LocaleService(gh<_i658.StorageService>()),
    );
    gh.lazySingleton<_i555.OnboardingService>(
      () => _i555.OnboardingService(gh<_i658.StorageService>()),
    );
    gh.lazySingleton<_i746.JwtTokenStorage>(
      () => _i746.JwtTokenStorage(gh<_i658.StorageService>()),
    );
    gh.lazySingleton<_i727.LocalizationInterceptor>(
      () => _i727.LocalizationInterceptor(gh<_i510.LocaleService>()),
    );
    gh.lazySingleton<_i616.CustomDioInterceptor>(
      () => _i616.CustomDioInterceptor(
        logRequestHeaders: gh<bool>(),
        logRequestBody: gh<bool>(),
        logResponseHeaders: gh<bool>(),
        logResponseBody: gh<bool>(),
        logErrors: gh<bool>(),
        maxBodyChars: gh<int>(),
        redactedHeaders: gh<List<String>>(),
        boxStyle: gh<_i616.BoxStyle>(),
      ),
    );
    gh.lazySingleton<_i1040.AppRouterConfig>(
      () => _i1040.AppRouterConfig(
        gh<_i539.AuthStateNotifier>(),
        gh<_i555.OnboardingService>(),
        gh<_i685.AppRouteRegistry>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i13.RegisterModule {}
