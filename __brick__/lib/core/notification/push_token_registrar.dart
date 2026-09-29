import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../utils/helpers/colored_print.dart';
import '../network/api_endpoints.dart';
import '../services/session/auth_state_notifier.dart';

/// Tells the server where to push.
///
/// The FCM token names the DEVICE; the request carries the session's
/// `Authorization` when there is one (the token interceptor adds it), so the
/// server can tie the device to an account. That tie changes when the reader
/// signs in or out, so the token is sent again then — once per token and
/// account, never on every rebuild of anything.
///
/// A guest's device is registered too: broadcast alerts reach everyone,
/// with or without an account.
///
/// The contract: `POST ApiEndpoints.devices` with `{token, platform}`.
/// Wired only when FCM is enabled (`bootstrap.dart`).
@lazySingleton
class PushTokenRegistrar {
  PushTokenRegistrar(this._dio, this._session);

  final Dio _dio;
  final AuthStateNotifier _session;

  String? _token;

  /// The token and account last sent — what makes a second send pointless.
  String? _sent;
  bool _watching = false;

  /// The FCM token arrived or was refreshed.
  Future<void> tokenChanged(String token) {
    _token = token;
    if (!_watching) {
      _watching = true;
      _session.addListener(_onSession);
    }
    return _send();
  }

  void _onSession() => unawaited(_send());

  Future<void> _send() async {
    final token = _token;
    if (token == null || token.isEmpty) return;

    final account = _session.isAuthenticated ? _session.user?.id : null;
    final key = '$token|$account';
    if (key == _sent) return;
    _sent = key;

    try {
      await _dio.post<dynamic>(
        ApiEndpoints.devices,
        data: <String, dynamic>{
          'token': token,
          'platform': Platform.operatingSystem,
        },
      );
      printG('[Push] device registered (account: ${account ?? 'guest'})');
    } catch (error) {
      // Not sent: the next token, sign-in or launch tries again.
      _sent = null;
      printY('[Push] device registration failed: $error');
    }
  }
}
