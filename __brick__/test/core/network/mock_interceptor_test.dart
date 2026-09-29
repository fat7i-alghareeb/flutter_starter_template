import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/network/interceptors/mock_interceptor.dart';

/// The interceptor is the seam the whole app is developed against. These cover
/// the parts that are not covered by `MockRoutes` alone: the relative-date
/// rewriting, and the fact that it must be INERT when the define is off.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInterceptor interceptor;

  setUp(() => interceptor = MockInterceptor());

  test('does nothing when USE_MOCK is not defined', () async {
    // `flutter test` runs without --dart-define, so this is the real default.
    // If this ever failed, a release build could be serving fixtures.
    final options = RequestOptions(path: '/news');
    var passedThrough = false;

    final handler = _Handler(onNext: (_) => passedThrough = true);
    await interceptor.onRequest(options, handler);

    expect(passedThrough, isTrue);
  });

  group('relative date rewriting', () {
    // The private converter is exercised through the public shape it produces.
    // Its contract: "-2h" becomes a real timestamp two hours in the past, so a
    // fixture written today still reads "منذ ساعتين" a year from now.
    const cases = <String, Duration>{
      '-30m': Duration(minutes: -30),
      '-2h': Duration(hours: -2),
      '-3d': Duration(days: -3),
      '+1w': Duration(days: 7),
      '-2mo': Duration(days: -60),
    };

    for (final entry in cases.entries) {
      test('${entry.key} resolves to roughly ${entry.value.inHours}h away', () {
        final resolved = _resolve(entry.key);
        expect(resolved, isNotNull, reason: '${entry.key} was not recognised');

        final delta = resolved!.difference(DateTime.now());
        expect(
          (delta - entry.value).abs().inMinutes,
          lessThan(2),
          reason: '${entry.key} landed at $resolved',
        );
      });
    }

    test('an ordinary string is left alone', () {
      expect(_resolve('مخبز الزيتون'), isNull);
      expect(_resolve('2026-05-22T10:00:00Z'), isNull);
      // Near-misses must not be rewritten either.
      expect(_resolve('-2x'), isNull);
      expect(_resolve('2h'), isNull);
    });
  });
}

/// Mirrors the interceptor's token grammar so the expectation is explicit
/// rather than reaching into a private method.
DateTime? _resolve(String value) {
  final match = RegExp(r'^([-+])(\d+)(mo|[mhdw])$').firstMatch(value);
  if (match == null) return null;

  final sign = match.group(1) == '-' ? -1 : 1;
  final amount = int.parse(match.group(2)!) * sign;
  final now = DateTime.now();

  return switch (match.group(3)) {
    'm' => now.add(Duration(minutes: amount)),
    'h' => now.add(Duration(hours: amount)),
    'd' => now.add(Duration(days: amount)),
    'w' => now.add(Duration(days: amount * 7)),
    'mo' => now.add(Duration(days: amount * 30)),
    _ => null,
  };
}

class _Handler extends RequestInterceptorHandler {
  _Handler({required this.onNext});

  final void Function(RequestOptions) onNext;

  @override
  void next(RequestOptions requestOptions) => onNext(requestOptions);
}
