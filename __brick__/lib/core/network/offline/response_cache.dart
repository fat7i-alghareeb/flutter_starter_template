import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../objectbox.g.dart';
import '../../../utils/helpers/colored_print.dart';
import '../../services/objectbox/entities/objectbox_local_cache_entry_entity.dart';
import '../../services/objectbox/objectbox_service.dart';
import '../api_endpoints.dart';

/// Where the last good copy of a list is kept.
///
/// An interface so the interceptor can be tested without a database: the
/// ObjectBox store needs its native library, which a widget test has not.
abstract class ResponseCacheStore {
  /// The stored copy for [key] and when it was saved, or null.
  Future<CachedResponse?> read(String key);

  Future<void> write(String key, Object? data);
}

/// One saved answer: the body as the server sent it, and when.
class CachedResponse {
  const CachedResponse({required this.data, required this.savedAt});

  final Object? data;
  final DateTime savedAt;
}

/// The copies live in ObjectBox, in the generic cache entity the template
/// ships for caching API responses — no new package.
///
/// The store is opened on the first read or write, not at start-up: opening
/// it is async and most launches have a network. Every failure is swallowed
/// and logged — a cache that breaks a request is worse than no cache.
@LazySingleton(as: ResponseCacheStore)
class ObjectBoxResponseCacheStore implements ResponseCacheStore {
  Future<ObjectBoxService>? _service;

  Future<Box<ObjectBoxLocalCacheEntryEntity>> _box() async {
    final service = await (_service ??= ObjectBoxService.createDefault());
    return service.box<ObjectBoxLocalCacheEntryEntity>();
  }

  ObjectBoxLocalCacheEntryEntity? _find(
    Box<ObjectBoxLocalCacheEntryEntity> box,
    String key,
  ) {
    final query = box
        .query(ObjectBoxLocalCacheEntryEntity_.key.equals(key))
        .build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  @override
  Future<CachedResponse?> read(String key) async {
    try {
      final entry = _find(await _box(), key);
      if (entry == null) return null;
      return CachedResponse(
        data: json.decode(entry.value),
        savedAt: DateTime.fromMillisecondsSinceEpoch(entry.updatedAtMillis),
      );
    } catch (error) {
      printY('[OfflineCache] read failed for $key: $error');
      return null;
    }
  }

  @override
  Future<void> write(String key, Object? data) async {
    try {
      final box = await _box();
      // The key is unique: an existing copy is REPLACED, never duplicated.
      final existing = _find(box, key);
      box.put(
        ObjectBoxLocalCacheEntryEntity(
          objId: existing?.objId ?? 0,
          key: key,
          value: json.encode(data),
        ),
      );
    } catch (error) {
      printY('[OfflineCache] write failed for $key: $error');
    }
  }
}

/// «You are looking at the last saved copy» — set by the interceptor, read by
/// the banner the app draws above itself (`OfflineBanner`).
///
/// It goes up the moment a list is answered from the cache, and down the
/// moment any request reaches the network again: being online is not a
/// state the reader has to dismiss.
@lazySingleton
class OfflineNotice extends ChangeNotifier {
  DateTime? _savedAt;

  /// When the copy on screen was saved; null while the app is online.
  DateTime? get savedAt => _savedAt;

  bool get isShowing => _savedAt != null;

  /// A list was answered from a copy saved at [savedAt]. The OLDEST copy on
  /// screen is the one worth naming.
  void servedFromCache(DateTime savedAt) {
    final current = _savedAt;
    if (current != null && !savedAt.isBefore(current)) return;
    _savedAt = savedAt;
    notifyListeners();
  }

  /// The network answered.
  void online() {
    if (_savedAt == null) return;
    _savedAt = null;
    notifyListeners();
  }

  /// The reader put the banner away. The next copy served raises it again.
  void dismiss() => online();
}

/// Keeps the app's most-used lists for when there is no network.
///
/// Without it every screen shows its error state with no connection, even
/// for a list read a minute before. With it, the first page of each list in
/// [cacheablePaths] is saved whenever it arrives, and a request that fails
/// for want of a network is answered with that copy — every feature above
/// Dio reads it as an ordinary answer — while [OfflineNotice] tells the
/// reader it is not fresh.
///
/// Keep lists, not details or search or the account: a detail read offline
/// is one the reader never opened online, and the account is a reader's own
/// data.
@lazySingleton
class OfflineCacheInterceptor extends Interceptor {
  OfflineCacheInterceptor(this._store, this._notice);

  final ResponseCacheStore _store;
  final OfflineNotice _notice;

  static const String _fromCache = 'offlineCache.fromCache';

  /// The list endpoints worth keeping. A path listed here, or any path under
  /// one ending in `/` (a prefix), is saved on its first page.
  static final Set<String> cacheablePaths = <String>{
    ApiEndpoints.showcaseFeed,
    ApiEndpoints.showcaseHighlights,
    ApiEndpoints.showcasePicks,
  };

  /// Whether [options] asks for a list worth keeping: a GET of one of
  /// [cacheablePaths], on its first page.
  @visibleForTesting
  static bool isCacheable(RequestOptions options) {
    if (options.method.toUpperCase() != 'GET') return false;
    final path = options.path;
    final isList =
        cacheablePaths.contains(path) ||
        cacheablePaths.any((p) => p.endsWith('/') && path.startsWith(p));
    if (!isList) return false;
    final page = options.queryParameters['page'];
    return page == null || page.toString() == '1';
  }

  /// The path with its query in a fixed order — `?type=event&page=1` and
  /// `?page=1&type=event` are one list.
  @visibleForTesting
  static String keyOf(RequestOptions options) {
    final entries = options.queryParameters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final query = entries.map((e) => '${e.key}=${e.value}').join('&');
    return 'http:${options.path}${query.isEmpty ? '' : '?$query'}';
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    if (options.extra[_fromCache] != true) {
      _notice.online();
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && isCacheable(options)) {
        unawaited(_store.write(keyOf(options), response.data));
      }
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (!_isOffline(err) || !isCacheable(options)) return handler.next(err);

    final cached = await _store.read(keyOf(options));
    if (cached == null) return handler.next(err);

    printY('[OfflineCache] offline — ${options.path} from the saved copy');
    options.extra[_fromCache] = true;
    _notice.servedFromCache(cached.savedAt);
    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: cached.data,
        extra: <String, dynamic>{_fromCache: true},
      ),
    );
  }

  /// No network — not a server that answered with an error. A 500 is the
  /// server's to explain; an old copy would hide it.
  static bool _isOffline(DioException err) => switch (err.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => true,
    DioExceptionType.unknown => err.error is SocketException,
    _ => false,
  };
}
