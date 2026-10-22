import 'package:flutter_test/flutter_test.dart';

import '../../tool/widget_catalog.dart';

/// The duplicate check Claude runs before building a widget, so it has to
/// find public classes, summarise them, and skip private ones.
void main() {
  test('finds public classes with the first sentence of their doc', () {
    const source = '''
/// A count in a coloured dot: an unread number on a tab.
///
/// More detail that is not the summary.
class AppCountBadge extends StatelessWidget {}

/// Hidden helper.
class _Private extends StatelessWidget {}

@immutable
/// A pill. With an annotation between the doc and the class.
abstract class AppPill {}

enum NoDoc { a }
''';
    final found = parseCatalog('lib/common/widgets/x.dart', source);
    expect(found.map((e) => e.name), <String>['AppCountBadge', 'AppPill', 'NoDoc']);
    expect(found[0].summary, 'A count in a coloured dot: an unread number on a tab.');
    expect(found[2].summary, isEmpty);
  });

  test('a code fence ends the summary', () {
    const source = '''
/// A row of the feed list.
///
/// ```text
/// ┌────┐
/// ```
class FeedCard {}
''';
    expect(parseCatalog('p.dart', source).single.summary, 'A row of the feed list.');
  });
}
