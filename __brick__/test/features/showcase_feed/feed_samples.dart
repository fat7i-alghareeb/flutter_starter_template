import 'package:{{project_name}}/features/showcase_feed/domain/feed_entities.dart';

/// Showcase items for widget tests — built in code, so a test never waits on
/// the mock layer or the network.
class FeedSamples {
  FeedSamples._();

  static FeedItemEntity item({
    String id = 'item_001',
    String title = 'Community garden opens its doors this weekend',
    String? imageUrl,
    double? rating = 4.6,
    int? readMinutes = 3,
  }) => FeedItemEntity(
    id: id,
    title: title,
    subtitle: 'Free seedlings for the first hundred visitors.',
    body: 'Free seedlings for the first hundred visitors.\n\nDemo content.',
    category: 'news',
    categoryName: 'News',
    author: 'Maya Chen',
    publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
    imageUrl: imageUrl,
    rating: rating,
    readMinutes: readMinutes,
  );

  static List<FeedItemEntity> items(int count) => <FeedItemEntity>[
    for (var i = 1; i <= count; i++)
      item(id: 'item_${i.toString().padLeft(3, '0')}', title: 'Item number $i'),
  ];
}
