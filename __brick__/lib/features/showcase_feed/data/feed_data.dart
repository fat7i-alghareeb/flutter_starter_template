import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/global_error_handler.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../core/utils/result.dart';
import '../domain/feed_entities.dart';

// The showcase feature keeps its data layer in one file so it is easy to read
// (and to delete). A real feature splits it the way `tool/generate_feature.dart`
// does: datasources/, models/, mappers/, repositories/.

/// What the server sends for one item.
class FeedItemModel {
  const FeedItemModel({
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

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      body: json['body'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      author: json['author'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(json['publishedAt']?.toString() ?? '') ??
          DateTime.now(),
      imageUrl: json['imageUrl'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      readMinutes: (json['readMinutes'] as num?)?.toInt(),
    );
  }

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

  FeedItemEntity toEntity() => FeedItemEntity(
    id: id,
    title: title,
    subtitle: subtitle,
    body: body,
    category: category,
    categoryName: categoryName,
    author: author,
    publishedAt: publishedAt,
    imageUrl: imageUrl,
    isFeatured: isFeatured,
    rating: rating,
    readMinutes: readMinutes,
  );
}

@lazySingleton
class FeedRemoteDataSource {
  const FeedRemoteDataSource(this._dio);

  final Dio _dio;

  Future<FeedPage> getFeed({
    required int page,
    required int limit,
    String query = '',
    String? category,
  }) {
    return rethrowAsAppException(() async {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.showcaseFeed,
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
          if (query.isNotEmpty) 'q': query,
          'category': ?category,
          'sort': 'newest',
        },
      );
      final data = response.data as Map<String, dynamic>;
      final items = (data['data'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => FeedItemModel.fromJson(e).toEntity())
          .toList();
      final meta = data['meta'] as Map<String, dynamic>?;
      return FeedPage(
        items: items,
        hasMore: meta?['hasMore'] as bool? ?? false,
        total: (meta?['total'] as num?)?.toInt() ?? items.length,
      );
    });
  }

  Future<List<FeedItemEntity>> getList(String path) {
    return rethrowAsAppException(() async {
      final response = await _dio.get<dynamic>(path);
      return (response.data['data'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => FeedItemModel.fromJson(e).toEntity())
          .toList();
    });
  }

  Future<FeedItemEntity> getItem(String id) {
    return rethrowAsAppException(() async {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.showcaseFeedItem(id),
      );
      return FeedItemModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      ).toEntity();
    });
  }
}

/// Recent searches, on the device only — the most revealing thing an app
/// holds is what a person looked for. Newest first, no duplicates, capped.
///
/// Small preferences like this go through [StorageService]; a schema entity
/// and a generator run are not worth six strings.
@lazySingleton
class FeedLocalDataSource {
  FeedLocalDataSource(this._storage);

  final StorageService _storage;

  static const String historyKey = 'showcase.feed.recentSearches';
  static const int historyLimit = 6;

  Future<List<String>> recentSearches() async {
    final raw = await _storage.readString(historyKey);
    if (raw == null || raw.isEmpty) return <String>[];
    // One value per line: no JSON to go corrupt.
    return raw.split('\n').where((e) => e.trim().isNotEmpty).toList();
  }

  /// A repeat moves to the top rather than appearing twice, and the oldest
  /// falls off the end.
  Future<List<String>> saveSearch(String query) async {
    final term = query.trim();
    final entries = await recentSearches();
    if (term.isEmpty) return entries;
    entries
      ..removeWhere((e) => e == term)
      ..insert(0, term);
    final kept = entries.take(historyLimit).toList();
    await _storage.writeString(historyKey, kept.join('\n'));
    return kept;
  }

  Future<void> clear() => _storage.writeString(historyKey, '');
}

abstract class FeedRepository {
  Future<Result<FeedPage>> getFeed({
    required int page,
    required int limit,
    String query = '',
    String? category,
  });
  Future<Result<List<FeedItemEntity>>> getHighlights();
  Future<Result<List<FeedItemEntity>>> getPicks();
  Future<Result<FeedItemEntity>> getItem(String id);
  Future<List<String>> recentSearches();
  Future<List<String>> saveSearch(String query);
}

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  const FeedRepositoryImpl(this._remote, this._local);

  final FeedRemoteDataSource _remote;
  final FeedLocalDataSource _local;

  @override
  Future<Result<FeedPage>> getFeed({
    required int page,
    required int limit,
    String query = '',
    String? category,
  }) => runAsResult(
    () => _remote.getFeed(
      page: page,
      limit: limit,
      query: query,
      category: category,
    ),
  );

  @override
  Future<Result<List<FeedItemEntity>>> getHighlights() =>
      runAsResult(() => _remote.getList(ApiEndpoints.showcaseHighlights));

  @override
  Future<Result<List<FeedItemEntity>>> getPicks() =>
      runAsResult(() => _remote.getList(ApiEndpoints.showcasePicks));

  @override
  Future<Result<FeedItemEntity>> getItem(String id) =>
      runAsResult(() => _remote.getItem(id));

  @override
  Future<List<String>> recentSearches() => _local.recentSearches();

  @override
  Future<List<String>> saveSearch(String query) => _local.saveSearch(query);
}
