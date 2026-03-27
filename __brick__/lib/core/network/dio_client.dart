import 'package:dio/dio.dart';
import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:flutter/foundation.dart';

import '../../utils/helpers/colored_print.dart';
import '../../utils/helpers/jwt_token_utils.dart';
import '../network/api_config.dart';
import '../network/api_endpoints.dart';
import '../network/interceptors/custom_dio_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/localization_interceptor.dart';
import '../network/interceptors/memory_aware_interceptor.dart';
import '../services/session/auth_manager.dart';
import '../services/session/auth_token_model.dart';
import '../services/session/jwt_token_storage.dart';

/// Builds the global [Dio] instance used by the app.
///
/// This function is intentionally pure: it does not know about GetIt or
/// Injectable. All collaborators (interceptors, auth, token storage) are
/// passed in from the composition root so that this file stays focused on
/// HTTP configuration.
///
/// High-level pipeline:
/// //! 1) Create [BaseOptions] (baseUrl, timeouts, default headers).
/// //! 2) Attach [MemoryAwareInterceptor] to guard against huge responses.
/// //! 3) Wire JWT + refresh flow.
/// //! 4) Attach cross-cutting interceptors:
///     - [LocalizationInterceptor] → language / timezone headers.
///     - [CustomDioInterceptor] → pretty colored logging (debug only).
///     - [ErrorInterceptor] → map all errors to [AppException].
Dio createDioClient({
  required MemoryAwareInterceptor memoryAwareInterceptor,
  required LocalizationInterceptor localizationInterceptor,
  required ErrorInterceptor errorInterceptor,
  required CustomDioInterceptor logInterceptor,
  required AuthManager authManager,
  required JwtTokenStorage tokenStorage,
}) {
  return _initDio(
    baseUrl: ApiConfig.baseUrl,
    memoryAwareInterceptor: memoryAwareInterceptor,
    localizationInterceptor: localizationInterceptor,
    errorInterceptor: errorInterceptor,
    logInterceptor: logInterceptor,
    authManager: authManager,
    tokenStorage: tokenStorage,
    useRefresh: true,
  );
}

/// Builds a [Dio] instance without automatic token refresh.
///
/// It still attaches the cached JWT token if it exists, but will not attempt
/// to refresh it if it expires or if a 401 is received.
///
/// Unlike [createDioClient], this function requires a [baseUrl] to be passed
/// explicitly.
Dio createSimpleDioClient({
  required String baseUrl,
  required MemoryAwareInterceptor memoryAwareInterceptor,
  required LocalizationInterceptor localizationInterceptor,
  required ErrorInterceptor errorInterceptor,
  required CustomDioInterceptor logInterceptor,
  required JwtTokenStorage tokenStorage,
}) {
  return _initDio(
    baseUrl: baseUrl,
    memoryAwareInterceptor: memoryAwareInterceptor,
    localizationInterceptor: localizationInterceptor,
    errorInterceptor: errorInterceptor,
    logInterceptor: logInterceptor,
    tokenStorage: tokenStorage,
    useRefresh: false,
  );
}

/// Internal helper to assemble the [Dio] pipeline.
Dio _initDio({
  required String baseUrl,
  required MemoryAwareInterceptor memoryAwareInterceptor,
  required LocalizationInterceptor localizationInterceptor,
  required ErrorInterceptor errorInterceptor,
  required CustomDioInterceptor logInterceptor,
  required JwtTokenStorage tokenStorage,
  AuthManager? authManager,
  required bool useRefresh,
}) {
  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    followRedirects: true,
    maxRedirects: 3,
    headers: <String, Object?>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options);

  //! 1) Memory guard – always first
  dio.interceptors.add(memoryAwareInterceptor);

  //! 2) Auth flow
  if (useRefresh && authManager != null) {
    _configureJwtFlow(
      dio: dio,
      authManager: authManager,
      tokenStorage: tokenStorage,
      logInterceptor: logInterceptor,
    );
  } else {
    _configureTokenOnlyFlow(dio: dio, tokenStorage: tokenStorage);
  }

  //! 3) Cross-cutting interceptors
  dio.interceptors.addAll(<Interceptor>[
    localizationInterceptor,
    if (kDebugMode) logInterceptor,
    errorInterceptor,
  ]);

  printC('[DioClient] Created Dio (refresh=$useRefresh), baseUrl: $baseUrl');

  return dio;
}

/// Configures JWT-based authentication and automatic token refresh.
///
/// This wiring is kept in a separate helper so it is easy to spot all
/// auth-related interceptors in one place.
///
/// Responsibilities:
/// //! Attach a lightweight `tokenDio` used only for the refresh call
///     to avoid recursive interceptors and noisy logs.
/// //! Use [RefreshTokenInterceptor] from dio_refresh_bot to:
///     - Decide *when* to refresh via [TokenProtocol.shouldRefresh].
///     - Attach the `Authorization` header via [tokenHeaderBuilder].
///     - Call the backend refresh endpoint and persist new tokens.
void _configureJwtFlow({
  required Dio dio,
  required AuthManager authManager,
  required JwtTokenStorage tokenStorage,
  required CustomDioInterceptor logInterceptor,
}) {
  // Lightweight Dio instance dedicated to the refresh token call to avoid
  // recursion and noisy logs.
  final tokenDio = Dio(dio.options)
    ..interceptors.addAll(<Interceptor>[if (kDebugMode) logInterceptor]);

  // Attach RefreshTokenInterceptor from dio_refresh_bot.
  dio.interceptors.add(
    RefreshTokenInterceptor<AuthTokenModel>(
      tokenStorage: tokenStorage,
      tokenDio: tokenDio,
      debugLog: kDebugMode,
      // Decide when we should refresh the token.
      tokenProtocol: TokenProtocol(
        shouldRefresh: (response, token) {
          if (!authManager.isAuthenticated) {
            printY('[DioClient] shouldRefresh=false (not authenticated)');
            return false;
          }
          if (token == null || token.accessToken.isNotEmpty == false) {
            printY('[DioClient] shouldRefresh=false (missing token)');
            return false;
          }

          final aboutToExpire = isTokenAboutToExpire(token.accessToken);
          final unauthorized = response?.statusCode == 401;

          final should = aboutToExpire || unauthorized;
          if (should) {
            printC(
              '[DioClient] shouldRefresh=true '
              '(aboutToExpire=$aboutToExpire, unauthorized=$unauthorized)',
            );
          }

          return should;
        },
      ),
      // Build Authorization header for every request when a token exists.
      tokenHeaderBuilder: (token) {
        final raw = token.accessToken;
        final preview = raw.length > 10 ? '${raw.substring(0, 10)}...' : raw;
        printG('[DioClient] Attaching Authorization: Bearer $preview');
        return <String, String>{'Authorization': 'Bearer $raw'};
      },
      // Handle revoked/invalid refresh token.
      onRevoked: (dioError) {
        printR(
          '[DioClient] Token revoked, logging out user. '
          'reason=${dioError.message}',
        );
        authManager.logout();
        return null;
      },
      refreshToken: (token, tokenDio) async {
        try {
          printC('[DioClient] Attempting token refresh');

          final user = authManager.currentUser;
          if (user?.id == null || !authManager.isAuthenticated) {
            printY(
              '[DioClient] No user ID or not authenticated for token refresh',
            );
            await authManager.logout();
            throw Exception('Not authenticated for token refresh');
          }

          if (ApiEndpoints.refreshToken.isEmpty) {
            throw Exception('ApiEndpoints.refreshToken is not configured');
          }

          final response = await tokenDio.post<dynamic>(
            ApiEndpoints.refreshToken,
            data: <String, Object?>{
              'userId': user!.id,
              'refreshToken': token.refreshToken,
            },
          );

          final data = response.data;
          if (data is! Map<String, dynamic>) {
            throw Exception('Unexpected refresh response shape: $data');
          }

          final fromApi = AuthTokenModel.fromMap(data);
          final newToken = AuthTokenModel(
            accessToken: fromApi.accessToken,
            refreshToken: fromApi.refreshToken ?? token.refreshToken,
            expiresIn: fromApi.expiresIn,
          );

          await tokenStorage.write(newToken);

          printG('[DioClient] Token refresh successful');
          return newToken;
        } catch (e) {
          printR('[DioClient] Token refresh failed: $e');
          await authManager.logout();
          throw Exception('Token refresh failed: $e');
        }
      },
    ),
  );
}

/// Attaches the Authorization header if a token exists, but does not refresh.
void _configureTokenOnlyFlow({
  required Dio dio,
  required JwtTokenStorage tokenStorage,
}) {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = tokenStorage.read();
        final raw = token?.accessToken;
        if (raw != null && raw.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $raw';
        }
        return handler.next(options);
      },
    ),
  );
}
