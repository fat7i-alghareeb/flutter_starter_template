import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_icons.dart';

/// `AppIcons.fromKey` takes a key from the server — and, from news, an asset
/// path the app resolved itself.
void main() {
  test('a known key resolves to its glyph', () {
    expect(AppIcons.fromKey('store'), AppIcons.store);
    expect(AppIcons.fromKey('electronics'), AppIcons.power);
  });

  test('an unknown key falls back to the grid glyph, never to nothing', () {
    expect(AppIcons.fromKey('a-section-invented-next-year'), AppIcons.grid);
    expect(AppIcons.fromKey(null), AppIcons.grid);
  });

  test('an asset path passes straight through', () {
    // News hands the type's own icon (`NewsType.iconKey`) to `AppThumbnail`,
    // which resolves whatever it is given. Looked up as a key, every path
    // missed the map and drew the grid glyph — on every news item with no
    // picture, which is five of the twelve in the corpus.
    expect(AppIcons.fromKey(AppIcons.alert), AppIcons.alert);
    expect(AppIcons.fromKey(AppIcons.calendar), AppIcons.calendar);
    expect(AppIcons.fromKey(AppIcons.news), AppIcons.news);
  });
}
