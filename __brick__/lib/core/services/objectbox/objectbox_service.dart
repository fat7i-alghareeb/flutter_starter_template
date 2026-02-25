import 'dart:async';
import 'dart:io';

import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';

import '../../../objectbox.g.dart' hide Store;
import '../../error/app_exception.dart';

/// Owns the single ObjectBox [Store] instance for the whole application.
///
/// Lifecycle:
/// - Created once during app startup (via `injectable` pre-resolve).
/// - Kept open for the entire app lifetime for performance.
/// - Can be closed explicitly if you need a controlled shutdown.
///
/// Why this class exists:
/// - Centralizes **opening the Store** (directory + generated `openStore()` call).
/// - Provides a single, DI-managed place to access ObjectBox **boxes** (`box<T>()`).
/// - Provides safe helpers to run **background transactions** using
///   `runInTransactionAsync`.
///
/// How it is used by DAOs:
/// - A DAO depends on [ObjectBoxService].
/// - The DAO asks the service for a `Box<T>` via `box<T>()`.
/// - The DAO performs CRUD / queries on that `Box<T>`.
///
/// In other words:
/// - [ObjectBoxService] = database connection + lifecycle.
/// - `ObjectBoxDao<T>` = entity-specific access wrapper.
///
/// Typical usage (data layer only):
///
/// ```dart
/// @lazySingleton
/// class ProductLocalDataSource {
///   ProductLocalDataSource(this._objectBox);
///
///   final ObjectBoxService _objectBox;
///
///   Box<ProductEntity> get _box => _objectBox.box<ProductEntity>();
///
///   Future<void> cache(ProductEntity entity) async {
///     _box.put(entity);
///   }
/// }
/// ```
class ObjectBoxService {
  ObjectBoxService._(this._store);

  final Store _store;

  /// Creates and opens the application's ObjectBox store.
  ///
  /// Uses the generated `openStore()` from `objectbox.g.dart`.
  ///
  /// Notes:
  /// - If [directory] is not provided, it defaults to
  ///   `<app-documents>/objectbox`.
  /// - The Store is intended to be created once and reused.
  static Future<ObjectBoxService> createDefault({String? directory}) async {
    try {
      final resolvedDirectory =
          directory ??
          '${(await getApplicationDocumentsDirectory()).path}${Platform.pathSeparator}objectbox';

      final store = await openStore(directory: resolvedDirectory);
      return ObjectBoxService._(store);
    } catch (e, s) {
      throw AppException.unknown(cause: e, stackTrace: s);
    }
  }

  Store get store => _store;

  /// Returns the ObjectBox [Box] for the given entity type [T].
  ///
  /// Prefer calling this in DAOs / local data sources, not in UI.
  Box<T> box<T>() => _store.box<T>();

  /// Runs a write transaction on a background isolate and returns a result.
  ///
  /// Use this when you want multiple operations to be executed in a single
  /// transaction off the UI isolate.
  Future<R> runWriteTxAsync<R, P>(
    R Function(Store store, P param) callback,
    P param,
  ) {
    return _store.runInTransactionAsync(TxMode.write, callback, param);
  }

  /// Runs a read transaction on a background isolate and returns a result.
  ///
  /// Use this for heavy reads (e.g., large queries) you do not want to execute on
  /// the UI isolate.
  Future<R> runReadTxAsync<R, P>(
    R Function(Store store, P param) callback,
    P param,
  ) {
    return _store.runInTransactionAsync(TxMode.read, callback, param);
  }

  /// Closes the underlying store.
  ///
  /// In most Flutter apps you do not need to call this.
  Future<void> close() async {
    try {
      _store.close();
    } catch (e, s) {
      throw AppException.unknown(cause: e, stackTrace: s);
    }
  }
}
