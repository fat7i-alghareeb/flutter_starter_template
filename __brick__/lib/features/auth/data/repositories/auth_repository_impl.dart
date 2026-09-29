import 'package:injectable/injectable.dart';

import '../../../../core/config/mock_config.dart';
import '../../../../core/domain/user_entity.dart';
import '../../../../core/error/global_error_handler.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/services/session/auth_manager.dart';
import '../../../../core/utils/result.dart';
import '../../../../utils/helpers/colored_print.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_model_mapper.dart';
import '../models/auth_login_response_model.dart';
import '../params/auth_params.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._authManager);

  final AuthRemoteDataSource _remote;
  final AuthManager _authManager;

  /// Credentials → server → app session.
  ///
  /// Two stand-ins keep a fresh app usable before a backend exists:
  /// - `USE_MOCK=true`: the fixed identity from [MockConfig]. This is the one
  ///   seam where mocking happens above the network — put a platform sign-in
  ///   dialog (Google, Apple…) here too, since a dialog is not an HTTP call.
  /// - no base URL configured (`ApiConfig`): a demo session, logged loudly.
  ///
  /// A cancelled platform dialog should throw
  /// `Exception(PendingActionMessages.cancelled)`: `AuthBloc` turns it into a
  /// quiet, non-red state.
  @override
  Future<Result<UserEntity>> signIn(SignInParams params) {
    return runAsResult(() async {
      final AuthLoginResponseModel response;

      if (MockConfig.enabled || ApiConfig.baseUrl.isEmpty) {
        if (!MockConfig.enabled) {
          printY('[Auth] No base URL configured — signing in with a demo session');
        }
        response = const AuthLoginResponseModel(
          id: MockConfig.userId,
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
          name: MockConfig.userName,
          email: MockConfig.userEmail,
        );
      } else {
        response = await _remote.signIn(params);
      }

      final user = response.toUserEntity();
      await _authManager.login(user: user, token: response.toAuthTokenModel());
      return user;
    });
  }

  @override
  Future<Result<void>> signOut() {
    // A platform provider must be signed out as well, here — clearing only
    // the app session silently signs the same account back in next time.
    return runAsResult(() => _authManager.logout());
  }

  @override
  Future<Result<void>> continueAsGuest() {
    return runAsResult(() => _authManager.continueAsGuest());
  }
}
