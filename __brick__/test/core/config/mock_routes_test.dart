import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/config/mock_config.dart';

/// The fixture matcher decides which JSON answers which request. It is easy to
/// get subtly wrong — a generic pattern shadowing a specific one, or a query
/// string defeating the match — and the failure mode is silent: the app just
/// shows the wrong data.
void main() {
  group('MockRoutes.assetFor', () {
    test('matches a collection path', () {
      expect(
        MockRoutes.assetFor('/showcase/feed', const <String, dynamic>{}),
        'assets/mock/showcase/feed.json',
      );
      expect(
        MockRoutes.assetFor('/showcase/highlights', const <String, dynamic>{}),
        'assets/mock/showcase/highlights.json',
      );
    });

    test('an id segment picks ONE item of the list — `#id=`', () {
      // No file per item: the interceptor answers with the item whose id
      // matches, and a 404 when there is none (the «gone» state).
      expect(
        MockRoutes.assetFor('/showcase/feed/item_002', const <String, dynamic>{}),
        'assets/mock/showcase/feed.json#id=item_002',
      );
    });

    test('a leading slash is optional', () {
      expect(
        MockRoutes.assetFor('showcase/picks', const <String, dynamic>{}),
        'assets/mock/showcase/picks.json',
      );
    });

    test('a query string does not defeat the match', () {
      expect(
        MockRoutes.assetFor('/showcase/feed', const <String, dynamic>{
          'page': 2,
          'limit': 10,
          'q': 'garden',
        }),
        'assets/mock/showcase/feed.json',
      );
    });

    test('an unknown path returns null so the request falls through', () {
      expect(
        MockRoutes.assetFor('/nowhere', const <String, dynamic>{}),
        isNull,
      );
    });
  });

  group('MockConfig', () {
    test('is off unless the define is passed', () {
      expect(MockConfig.enabled, isFalse);
    });

    test('the default delay clears the 300ms threshold that hides loaders', () {
      expect(MockConfig.delay.inMilliseconds, greaterThan(300));
    });
  });
}
