import 'package:dio/dio.dart';
import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/domain/user_entity.dart';
import 'package:{{project_name}}/core/network/api_endpoints.dart';
import 'package:{{project_name}}/core/notification/push_token_registrar.dart';
import 'package:{{project_name}}/core/services/session/auth_state_notifier.dart';

/// The device is registered for pushes once per token and account.
void main() {
  late _Server server;
  late AuthStateNotifier session;
  late PushTokenRegistrar registrar;

  setUp(() {
    server = _Server();
    session = AuthStateNotifier()..setGuest(true);
    registrar = PushTokenRegistrar(
      Dio()..interceptors.add(server),
      session,
    );
  });

  test('a guest\'s device is registered, once', () async {
    await registrar.tokenChanged('tok_1');
    await registrar.tokenChanged('tok_1');

    expect(server.sent, hasLength(1));
    expect(server.sent.single.path, ApiEndpoints.devices);
    expect(
      (server.sent.single.data as Map<String, dynamic>)['token'],
      'tok_1',
    );
  });

  test('signing in sends it again — the device now has an account', () async {
    await registrar.tokenChanged('tok_1');

    session
      ..setUser(const UserEntity(id: 'usr_001', name: 'أحمد', email: 'a@b'))
      ..setAuthStatus(AuthStatus.authenticated())
      ..setGuest(false);
    await pumpEventQueue();

    expect(server.sent, hasLength(2));
  });

  test('a new token is sent; a failed send is tried again next time', () async {
    server.failNext = true;
    await registrar.tokenChanged('tok_1');
    expect(server.sent, hasLength(1));

    await registrar.tokenChanged('tok_1');
    expect(server.sent, hasLength(2), reason: 'the failure was not remembered');

    await registrar.tokenChanged('tok_2');
    expect(server.sent, hasLength(3));
  });
}

class _Server extends Interceptor {
  final List<RequestOptions> sent = <RequestOptions>[];
  bool failNext = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    sent.add(options);
    if (failNext) {
      failNext = false;
      return handler.reject(
        DioException.connectionError(requestOptions: options, reason: 'x'),
      );
    }
    handler.resolve(Response<dynamic>(requestOptions: options, statusCode: 200));
  }
}
