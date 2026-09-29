import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_bar_action.dart';
import 'package:{{project_name}}/common/widgets/top_banner_slot.dart';
import 'package:{{project_name}}/core/network/api_endpoints.dart';
import 'package:{{project_name}}/core/network/offline/response_cache.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/test_app.dart';

/// The most-used lists survive a lost connection
/// (`OfflineCacheInterceptor.cacheablePaths`).
///
/// A real `Dio`: its first interceptor plays the server (or its absence),
/// the second is the real cache, as `createDioClient` orders them.
void main() {
  late _MemoryStore store;
  late OfflineNotice notice;
  late _Server server;
  late Dio dio;

  setUp(() {
    store = _MemoryStore();
    notice = OfflineNotice();
    server = _Server();
    dio = Dio()
      ..interceptors.addAll(<Interceptor>[
        server,
        OfflineCacheInterceptor(store, notice),
      ]);
  });

  Future<Response<dynamic>> get(String path, [Map<String, dynamic>? query]) =>
      dio.get<dynamic>(path, queryParameters: query);

  test('a list is kept when it arrives, and answers when the network does '
      'not', () async {
    server.answer = <String, dynamic>{'data': <String>['a', 'b']};
    await get(ApiEndpoints.showcaseFeed, <String, dynamic>{'page': 1, 'limit': 20});
    await pumpEventQueue();

    server.offline = true;
    final response = await get(
      ApiEndpoints.showcaseFeed,
      // The same list, asked in another order.
      <String, dynamic>{'limit': 20, 'page': 1},
    );

    expect(response.data, <String, dynamic>{'data': <String>['a', 'b']});
    expect(notice.isShowing, isTrue, reason: 'the reader is told it is old');
  });

  test("the first tab's sections and its list's first page are kept", () {
    for (final path in <String>[
      ApiEndpoints.showcaseFeed,
      ApiEndpoints.showcaseHighlights,
      ApiEndpoints.showcasePicks,
    ]) {
      expect(
        OfflineCacheInterceptor.isCacheable(RequestOptions(path: path)),
        isTrue,
        reason: path,
      );
    }
  });

  test('page two, a detail, a search, the account and a write are not', () {
    bool cacheable(String path, {String method = 'GET', int? page}) =>
        OfflineCacheInterceptor.isCacheable(
          RequestOptions(
            path: path,
            method: method,
            queryParameters: <String, dynamic>{'page': ?page},
          ),
        );

    expect(cacheable(ApiEndpoints.showcaseFeed, page: 2), isFalse);
    expect(cacheable(ApiEndpoints.showcaseFeedItem('item_001')), isFalse);
    expect(cacheable(ApiEndpoints.devices), isFalse);
    expect(cacheable(ApiEndpoints.login), isFalse);
    expect(cacheable(ApiEndpoints.showcaseFeed, method: 'POST'), isFalse);
  });

  test('a server that answers with an error is not hidden behind a copy', () async {
    server.answer = <String, dynamic>{'data': <String>['a']};
    await get(ApiEndpoints.showcasePicks);
    await pumpEventQueue();

    server.failWith = 500;
    await expectLater(get(ApiEndpoints.showcasePicks), throwsA(isA<DioException>()));
    expect(notice.isShowing, isFalse);
  });

  test('with no copy, the failure stands', () async {
    server.offline = true;
    await expectLater(get(ApiEndpoints.showcaseHighlights), throwsA(isA<DioException>()));
    expect(notice.isShowing, isFalse);
  });

  test('the network answering again takes the notice down', () async {
    server.answer = <String, dynamic>{'data': <String>[]};
    await get(ApiEndpoints.showcaseHighlights);
    await pumpEventQueue();
    server.offline = true;
    await get(ApiEndpoints.showcaseHighlights);
    expect(notice.isShowing, isTrue);

    server.offline = false;
    await get(ApiEndpoints.showcaseFeedItem('item_001'));
    expect(notice.isShowing, isFalse);
  });

  group('the banner', () {
    Widget app() => OfflineBannerHost(
      notice: notice,
      child: Navigator(
        onGenerateRoute: (_) =>
            MaterialPageRoute<void>(builder: (_) => const _Counter()),
      ),
    );

    testWidgets('says the lists are a saved copy, and when it was saved — '
        'without costing the app its screens', (tester) async {
      await pumpApp(tester, app(), fullScreen: true);
      await tester.tap(find.byType(_Counter));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      notice.servedFromCache(DateTime.now().subtract(const Duration(hours: 2)));
      await tester.pump();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('1'), findsOneWidget, reason: 'the Navigator survived');

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is AppBarAction && w.label == AppStrings.actionClose,
        ),
      );
      await tester.pump();
      expect(find.byType(OfflineBanner), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    forEachBrightness('fits 320dp at 1.3×', (tester, brightness) async {
      notice.servedFromCache(DateTime.now().subtract(const Duration(days: 3)));
      await pumpApp(
        tester,
        app(),
        fullScreen: true,
        brightness: brightness,
        surfaceSize: TestDevices.small,
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(OfflineBanner), findsOneWidget);
    });
  });
}

class _MemoryStore implements ResponseCacheStore {
  final Map<String, CachedResponse> _entries = <String, CachedResponse>{};

  @override
  Future<CachedResponse?> read(String key) async => _entries[key];

  @override
  Future<void> write(String key, Object? data) async {
    _entries[key] = CachedResponse(data: data, savedAt: DateTime.now());
  }
}

/// The server, as the mock plays it: an answer that runs the rest of the
/// chain, or a connection error, or an HTTP error.
class _Server extends Interceptor {
  Object? answer;
  bool offline = false;
  int? failWith;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (offline) {
      return handler.reject(
        DioException.connectionError(requestOptions: options, reason: 'x'),
        true,
      );
    }
    if (failWith != null) {
      return handler.reject(
        DioException.badResponse(
          statusCode: failWith!,
          requestOptions: options,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: failWith,
          ),
        ),
        true,
      );
    }
    handler.resolve(
      Response<dynamic>(requestOptions: options, statusCode: 200, data: answer),
      true,
    );
  }
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _taps++),
    child: ColoredBox(
      color: Colors.transparent,
      child: SizedBox.expand(child: Center(child: Text('$_taps'))),
    ),
  );
}
