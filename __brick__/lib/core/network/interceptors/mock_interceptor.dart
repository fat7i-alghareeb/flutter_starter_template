import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;
import 'package:injectable/injectable.dart';

import '../../config/mock_config.dart';
import '../../../utils/helpers/colored_print.dart';

/// Serves the app from local JSON instead of a server.
///
/// **Mocking happens at the network layer, not above it.**
///
/// ```text
/// Bloc → Facade → Repository → RemoteDataSource → Dio
///                                       ┌────────┴────────┐
///                                       │ MockInterceptor │ ← assets/mock/*.json
///                                       └────────┬────────┘
///                                                ▼ (when off)
///                                          real server
/// ```
///
/// Nothing above Dio knows this exists. The data source still builds a real
/// request, the model still parses real JSON, the repository still maps to an
/// entity, and errors still travel the real path. Switching to the live API is
/// a matter of turning [MockConfig.enabled] off — no code above changes, which
/// is the entire point. Mocking inside a repository would leave the parsing and
/// error handling untested until launch day.
///
/// Activated by `--dart-define=USE_MOCK=true`; a no-op otherwise. Fixtures
/// live in `assets/mock/`, routed by [MockRoutes] (`mock_config.dart`).
@lazySingleton
class MockInterceptor extends Interceptor {
  MockInterceptor();

  /// Parsed files, kept so a list is not re-read on every scroll.
  final Map<String, dynamic> _cache = <String, dynamic>{};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!MockConfig.enabled) {
      return handler.next(options);
    }

    final path = options.path;

    // ── forced failure modes, so error states can actually be seen
    if (MockConfig.offline) {
      return handler.reject(
        DioException.connectionError(
          requestOptions: options,
          reason: 'mockOffline',
        ),
        true,
      );
    }

    if (MockConfig.errorPaths.any(path.contains)) {
      return handler.reject(
        DioException.badResponse(
          statusCode: 500,
          requestOptions: options,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: 500,
            data: _envelope(<dynamic>[], message: 'mockErrorPaths'),
          ),
        ),
        true,
      );
    }

    if (MockConfig.delay > Duration.zero) {
      await Future<void>.delayed(MockConfig.delay);
    }

    if (MockConfig.emptyPaths.any(path.contains)) {
      return handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
          data: _envelope(<dynamic>[]),
        ),
        true,
      );
    }

    // ── a write: echo the body back as the created thing
    //
    // A server answers a write with the record it stored; the mock answers
    // with the body it was sent plus an id and a timestamp, which is the same
    // shape. No fixture is needed per action, and the optimistic-update paths
    // are exercised for real. Give a write its own fixture in [MockRoutes] if
    // it must return something else.
    if (options.method.toUpperCase() != 'GET') {
      printG('[Mock] ${options.method} $path ← echo');
      return handler.resolve(
        Response<dynamic>(
          requestOptions: options,
          statusCode: 200,
          data: _envelope(_echo(options.data)),
        ),
      );
    }

    // ── the normal path: find a file for this request
    final asset = MockRoutes.assetFor(path, options.queryParameters);
    if (asset == null) {
      printY('[Mock] no fixture for "$path" — falling through to the network');
      return handler.next(options);
    }

    try {
      // `file.json#id=42`: the one item of the list whose `id` is 42.
      final hash = asset.indexOf('#');
      if (hash > 0) {
        final file = asset.substring(0, hash);
        final item = itemOf(await _load(file), asset.substring(hash + 1));
        if (item == null) {
          printY('[Mock] $path ← $asset: no such item → 404');
          return handler.reject(
            DioException.badResponse(
              statusCode: 404,
              requestOptions: options,
              response: Response<dynamic>(
                requestOptions: options,
                statusCode: 404,
                // No message: the error interceptor's own
                // `AppStrings.clientNotFound` is what screens compare to.
                data: <String, dynamic>{
                  'status': false,
                  'message': null,
                  'data': null,
                },
              ),
            ),
            true,
          );
        }
        printG('[Mock] $path ← $asset');
        return handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 200,
            data: _envelope(item),
          ),
          true,
        );
      }

      final data = _applyQuery(await _load(asset), options.queryParameters);
      printG('[Mock] $path ← $asset');
      // `true`: the interceptors after this one see the answer as they would
      // a server's — the offline cache keeps its copy of a list from here.
      return handler.resolve(
        Response<dynamic>(requestOptions: options, statusCode: 200, data: data),
        true,
      );
    } catch (error) {
      printR('[Mock] failed to read "$asset": $error');
      return handler.next(options);
    }
  }

  /// The item of a list fixture selected by [selector] (`field=value`), or
  /// null when there is none.
  @visibleForTesting
  static Map<String, dynamic>? itemOf(dynamic payload, String selector) {
    final equals = selector.indexOf('=');
    if (equals <= 0) return null;
    final field = selector.substring(0, equals);
    final value = Uri.decodeComponent(selector.substring(equals + 1));
    final data = payload is Map<String, dynamic> ? payload['data'] : null;
    if (data is! List) return null;
    for (final item in data.whereType<Map<String, dynamic>>()) {
      if (item[field]?.toString() == value) return item;
    }
    return null;
  }

  /// The request body as a stored record: its own fields, an id and a date.
  static Map<String, dynamic> _echo(Object? body) {
    final now = DateTime.now();
    return <String, dynamic>{
      if (body is Map) ...body.cast<String, dynamic>(),
      'id': 'mock_${now.microsecondsSinceEpoch}',
      'createdAt': now.toIso8601String(),
    };
  }

  /// Pages, filters, searches and sorts a list the way the server would.
  ///
  /// `page` and `limit` slice the list and rewrite `meta`; any other parameter
  /// keeps only the items whose field of that name equals it, compared as
  /// text (`?type=official` · `?isUrgent=true`). A fixture holds the whole
  /// archive once; the filter chips and infinite scroll then behave as they
  /// will against the real API instead of ignoring their own parameters.
  ///
  /// Four parameters are not field matches and are handled on their own:
  ///
  /// * `q` — a free-text search. Equality cannot serve one: «bake» would have
  ///   to equal «Olive Bakery» to match it. It is a case-insensitive substring
  ///   test against the item's `name`, `title` and `categoryName`.
  /// * `sort` — a named order, applied after filtering.
  /// * `minPrice` · `maxPrice` — a range over `price`, inclusive at both
  ///   ends: a price equal to the bound the reader typed is inside the range
  ///   they asked for.
  static dynamic _applyQuery(dynamic payload, Map<String, dynamic> query) {
    if (query.isEmpty || payload is! Map<String, dynamic>) return payload;
    final data = payload['data'];
    if (data is! List) return payload;

    var items = data;
    for (final entry in query.entries) {
      if (const <String>[
        'page',
        'limit',
        'q',
        'sort',
        'minPrice',
        'maxPrice',
      ].contains(entry.key)) {
        continue;
      }
      final wanted = entry.value?.toString();
      items = items.where((item) {
        if (item is! Map) return false;
        final field = item[entry.key];
        // A field that is an option rather than a word — a content item's
        // `status: {key, label, tone}` — is matched on its key, which is
        // what the chip sends (`?status=lost`).
        if (field is Map) return field['key']?.toString() == wanted;
        return field?.toString() == wanted;
      }).toList();
    }

    final minPrice = num.tryParse(query['minPrice']?.toString() ?? '');
    final maxPrice = num.tryParse(query['maxPrice']?.toString() ?? '');
    if (minPrice != null || maxPrice != null) {
      items = items.where((item) {
        final price = item is Map ? item['price'] as num? : null;
        if (price == null) return false;
        if (minPrice != null && price < minPrice) return false;
        if (maxPrice != null && price > maxPrice) return false;
        return true;
      }).toList();
    }

    final term = query['q']?.toString().trim().toLowerCase();
    if (term != null && term.isNotEmpty) {
      items = items.where((item) {
        if (item is! Map) return false;
        final haystack = '${item['name'] ?? item['title'] ?? ''} '
            '${item['categoryName'] ?? ''}';
        return haystack.toLowerCase().contains(term);
      }).toList();
    }

    items = _sorted(items, query['sort']?.toString());

    final page = int.tryParse(query['page']?.toString() ?? '') ?? 1;
    final limit = int.tryParse(query['limit']?.toString() ?? '') ?? items.length;
    final start = ((page - 1) * limit).clamp(0, items.length);
    final end = (start + limit).clamp(0, items.length);

    return <String, dynamic>{
      ...payload,
      'data': items.sublist(start, end),
      'meta': <String, dynamic>{
        'page': page,
        'limit': limit,
        'total': items.length,
        'hasMore': end < items.length,
      },
    };
  }

  /// Named orders: `rating`, `newest`, `priceAsc`, `priceDesc`,
  /// `alphabetical`. Add yours here.
  ///
  /// An unknown name leaves the fixture's own order alone — the server's
  /// order is the default everywhere, and a list that silently reshuffles on
  /// a typo in a parameter is worse than one that ignores it.
  static List<dynamic> _sorted(List<dynamic> items, String? sort) {
    if (sort == null || sort.isEmpty) return items;

    num priceOf(dynamic item) =>
        (item is Map ? item['price'] as num? : null) ?? 0;

    // An item is dated by `publishedAt` or `createdAt`; both are ISO strings
    // by the time they get here, so text order is time order.
    String dateOf(dynamic item) =>
        (item is Map ? (item['publishedAt'] ?? item['createdAt']) : null)
            ?.toString() ??
        '';

    final sorted = List<dynamic>.from(items);
    switch (sort) {
      case 'rating':
        sorted.sort((a, b) {
          final left = (a is Map ? a['rating'] as num? : null) ?? 0;
          final right = (b is Map ? b['rating'] as num? : null) ?? 0;
          return right.compareTo(left);
        });
      case 'newest':
        sorted.sort((a, b) => dateOf(b).compareTo(dateOf(a)));
      case 'priceAsc':
        sorted.sort((a, b) => priceOf(a).compareTo(priceOf(b)));
      case 'priceDesc':
        sorted.sort((a, b) => priceOf(b).compareTo(priceOf(a)));
      case 'alphabetical':
        sorted.sort((a, b) {
          final left = (a is Map ? a['name']?.toString() : null) ?? '';
          final right = (b is Map ? b['name']?.toString() : null) ?? '';
          return left.compareTo(right);
        });
      default:
        return items;
    }
    return sorted;
  }

  Future<dynamic> _load(String asset) async {
    final cached = _cache[asset];
    if (cached != null) return _resolveDates(cached);

    final raw = await rootBundle.loadString(asset);
    final decoded = jsonDecode(raw);
    _cache[asset] = decoded;
    return _resolveDates(decoded);
  }

  /// Turns relative timestamps into real ones at request time.
  ///
  /// Fixtures store `"-2h"` or `"+4d"` rather than a fixed date, so a list
  /// still reads as "2h ago" months after it was written. Without this,
  /// every mock would age into "a year ago" and the relative-time formatting would
  /// never be exercised.
  dynamic _resolveDates(dynamic node) {
    if (node is Map) {
      return <String, dynamic>{
        for (final entry in node.entries)
          entry.key as String: _resolveDates(entry.value),
      };
    }
    if (node is List) {
      return node.map(_resolveDates).toList();
    }
    if (node is String) {
      final resolved = _relativeToIso(node);
      return resolved ?? node;
    }
    return node;
  }

  /// `-2h` · `+4d` · `-30m` · `+1w` → an ISO-8601 string. Null if not a token.
  static String? _relativeToIso(String value) {
    final match = _relativePattern.firstMatch(value);
    if (match == null) return null;

    final sign = match.group(1) == '-' ? -1 : 1;
    final amount = int.parse(match.group(2)!) * sign;

    final now = DateTime.now();
    final result = switch (match.group(3)) {
      'm' => now.add(Duration(minutes: amount)),
      'h' => now.add(Duration(hours: amount)),
      'd' => now.add(Duration(days: amount)),
      'w' => now.add(Duration(days: amount * 7)),
      'mo' => now.add(Duration(days: amount * 30)),
      _ => null,
    };
    return result?.toIso8601String();
  }

  static final RegExp _relativePattern = RegExp(r'^([-+])(\d+)(mo|[mhdw])$');

  /// The response shape every endpoint returns.
  static Map<String, dynamic> _envelope(
    Object? data, {
    String message = 'ok',
    Map<String, dynamic>? meta,
  }) {
    return <String, dynamic>{
      'status': true,
      'message': message,
      'data': data,
      'meta': ?meta,
    };
  }
}
