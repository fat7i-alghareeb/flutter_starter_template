import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

/// Guards the mock fixtures.
///
/// The app is developed entirely against these files until the API exists, so a
/// fixture that drifts out of shape does not fail loudly — it just renders a
/// blank screen, and the hours go into debugging the widget instead.
void main() {
  test('there are fixtures to test', () {
    expect(Fixtures.all(), isNotEmpty);
  });

  group('envelope', () {
    test('every fixture carries status, message and data', () {
      for (final path in Fixtures.all()) {
        final relative = path.replaceFirst('assets/mock/', '');
        final json = Fixtures.read(relative);

        expect(json.containsKey('status'), isTrue, reason: '$path: no status');
        expect(
          json.containsKey('message'),
          isTrue,
          reason: '$path: no message',
        );
        expect(json.containsKey('data'), isTrue, reason: '$path: no data');
        expect(json['status'], isA<bool>(), reason: '$path: status not a bool');
      }
    });
  });

  group('relative dates', () {
    final pattern = RegExp(r'^([-+])(\d+)(mo|[mhdw])$');

    /// Walks a decoded fixture and collects every value under a date-ish key.
    List<String> dateValues(dynamic node, [String key = '']) {
      if (node is Map) {
        return node.entries
            .expand<String>((e) => dateValues(e.value, e.key as String))
            .toList();
      }
      if (node is List) {
        return node.expand<String>((e) => dateValues(e, key)).toList();
      }
      // Keys ENDING in `At` only. A `contains('at')` check also matches
      // `categoryName`, which is not a date.
      if (node is String && key.endsWith('At')) {
        return <String>[node];
      }
      return const <String>[];
    }

    test('dates are relative tokens, never hard-coded timestamps', () {
      // A fixed timestamp ages: six months on, every item reads "a year ago" and
      // the relative-time formatting is never exercised again.
      for (final path in Fixtures.all()) {
        final relative = path.replaceFirst('assets/mock/', '');
        final json = Fixtures.read(relative);

        for (final value in dateValues(json['data'])) {
          expect(
            pattern.hasMatch(value),
            isTrue,
            reason: '$path: "$value" is not a relative token like "-2h"',
          );
        }
      }
    });
  });

  group('ids', () {
    test('ids are stable and human-readable, not numbers', () {
      // Stable ids let a spec and a test both point at the same item.
      for (final item in Fixtures.list('showcase/feed.json')) {
        expect(item['id'], startsWith('item_'));
      }
    });

    test('no id repeats inside a list', () {
      for (final name in <String>[
        'showcase/feed.json',
        'showcase/highlights.json',
        'showcase/picks.json',
      ]) {
        final ids = Fixtures.list(name).map((e) => e['id']).toList();
        expect(
          ids.toSet().length,
          ids.length,
          reason: '$name has duplicate ids',
        );
      }
    });

    test('every highlight and pick is also in the feed, so it opens', () {
      // A card opens `/showcase/feed/{id}`, answered from feed.json. An id
      // that lives only in highlights.json would open the «gone» page.
      final feed = Fixtures.list('showcase/feed.json').map((e) => e['id']).toSet();
      for (final name in <String>['showcase/highlights.json', 'showcase/picks.json']) {
        for (final item in Fixtures.list(name)) {
          expect(feed, contains(item['id']), reason: '$name: ${item['id']}');
        }
      }
    });
  });

  group('deliberate edge cases the showcase needs', () {
    final feed = Fixtures.list('showcase/feed.json');

    test('enough items for more than one page', () {
      // The list asks for 10 a page: fewer and paging is never exercised.
      expect(feed.length, greaterThan(20));
    });

    test('some items have no picture — the no-image layout is common', () {
      expect(feed.where((e) => e['imageUrl'] == null), isNotEmpty);
      expect(feed.where((e) => e['imageUrl'] != null), isNotEmpty);
    });

    test('every item carries what the cards read', () {
      for (final item in feed) {
        for (final key in <String>[
          'title',
          'subtitle',
          'body',
          'category',
          'categoryName',
          'author',
          'publishedAt',
        ]) {
          expect(item[key], isNotNull, reason: '${item['id']}: no $key');
        }
      }
    });
  });
}
