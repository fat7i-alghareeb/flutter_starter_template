import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/notification/notification_payload.dart';
import 'package:{{project_name}}/core/router/app_links.dart';
import 'package:{{project_name}}/core/router/router_config.dart';

/// What a link from outside the app opens (`AppLinks`).
void main() {
  final host = AppLinks.hosts.first;
  const scheme = AppLinks.scheme;

  group('AppLinks.locationOf', () {
    test('the link the app SHARES opens the page it was shared from', () {
      final shared = AppLinks.shareUrlOf('item_008');
      expect(shared, 'https://$host/items/item_008');
      expect(AppLinks.locationOf(Uri.parse(shared)), '/items/item_008');
    });

    test('a bare location and a custom-scheme link read the same', () {
      expect(AppLinks.locationOf(Uri.parse('/items/item_001')), '/items/item_001');
      expect(
        AppLinks.locationOf(Uri.parse('$scheme://items/item_004')),
        '/items/item_004',
      );
      expect(
        AppLinks.locationOf(Uri.parse('https://$host/items/item_001/')),
        '/items/item_001',
        reason: 'a trailing slash is the same page',
      );
    });

    test('nothing else opens from outside', () {
      for (final link in <String>[
        'https://$host/',
        'https://$host/items',
        'https://$host/items/a/b',
        'https://$host/settings',
        'https://$host/login',
        'https://evil.example/items/item_001',
        '/root',
      ]) {
        expect(AppLinks.locationOf(Uri.parse(link)), isNull, reason: link);
      }
    });

    test('targetOf hands back the page and its parameters', () {
      final target = AppLinks.targetOf('/items/item_042');
      expect(target?.page, AppPage.feedItem);
      expect(target?.params, <String, String>{'id': 'item_042'});
    });
  });

  group('AppLinks.locationOfTarget — what a notification opens', () {
    test('an item has its page', () {
      expect(
        AppLinks.locationOfTarget(type: 'item', id: 'i1'),
        '/items/i1',
      );
    });

    test('no id, or an unknown type, is no page', () {
      expect(AppLinks.locationOfTarget(type: 'item', id: ''), isNull);
      expect(AppLinks.locationOfTarget(type: 'weather', id: 'x'), isNull);
    });
  });

  group('a tapped notification', () {
    test('with a WEB link opens its page — the host is not a path segment', () {
      final payload = AppNotificationPayload(
        data: const <String, dynamic>{},
        deepLink: 'https://$host/items/item_008',
      );
      expect(payload.toGoRouterLocation, '/items/item_008');
    });

    test('with only a target opens the target\'s page', () {
      const payload = AppNotificationPayload(
        data: <String, dynamic>{'targetType': 'item', 'targetId': 'item_001'},
      );
      expect(payload.toGoRouterLocation, '/items/item_001');
    });

    test('a page that does not exist is nothing', () {
      const nowhere = AppNotificationPayload(
        data: <String, dynamic>{},
        route: '/orders/123',
      );
      expect(nowhere.toGoRouterLocation, isNull);
    });
  });
}
