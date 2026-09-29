/// One item of the showcase feed.
class FeedItemEntity {
  const FeedItemEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.category,
    required this.categoryName,
    required this.author,
    required this.publishedAt,
    this.imageUrl,
    this.isFeatured = false,
    this.rating,
    this.readMinutes,
  });

  final String id;
  final String title;
  final String subtitle;
  final String body;
  final String category;
  final String categoryName;
  final String author;
  final DateTime publishedAt;
  final String? imageUrl;
  final bool isFeatured;
  final double? rating;
  final int? readMinutes;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

/// One page of the feed, and whether another follows.
class FeedPage {
  const FeedPage({
    required this.items,
    required this.hasMore,
    required this.total,
  });

  final List<FeedItemEntity> items;
  final bool hasMore;
  final int total;
}

/// The independent sections of the feed page. Each loads on its own
/// (`AppLazySection`), so a slow one never holds up the rest.
enum FeedSection { highlights, picks }
