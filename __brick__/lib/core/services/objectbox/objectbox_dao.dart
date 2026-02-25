import 'package:objectbox/objectbox.dart';

import 'objectbox_entity.dart';
import 'objectbox_service.dart';

typedef ObjectBoxBoxQuery<T> = QueryBuilder<T> Function(Box<T> box);

/// Generic DAO with common CRUD operations for ObjectBox.
///
/// How this relates to [ObjectBoxService]:
/// - [ObjectBoxService] owns the **Store** (database connection + lifecycle).
/// - [ObjectBoxDao] owns the **data access API** for one entity type [T].
/// - The DAO obtains its [Box] via `objectBox.box<T>()`.
///
/// When to use a DAO:
/// - You want a single place for CRUD + queries for one entity type.
/// - You want local datasources to stay small and just call DAO methods.
///
/// When you can skip creating a custom DAO file:
/// - If you only need basic CRUD, you can instantiate/use `ObjectBoxDao<T>`
///   directly in your local datasource.
///
/// Using background transactions (advanced):
///
/// `ObjectBoxService` offers `runReadTxAsync` / `runWriteTxAsync` which run the
/// callback in a background isolate.
///
/// Use this for heavy work (large queries, batch writes) that you don't want on
/// the UI isolate.
///
/// Example inside a concrete DAO:
///
/// ```dart
/// @lazySingleton
/// class ProductDao extends ObjectBoxDao<ProductEntity> {
///   ProductDao(super.objectBox);
///
///   Future<int> countAsync() {
///     return objectBox.runReadTxAsync<int, void>(
///       (store, _) => store.box<ProductEntity>().count(),
///       null,
///     );
///   }
///
///   Future<void> putManyInTxAsync(List<ProductEntity> entities) {
///     return objectBox.runWriteTxAsync<void, List<ProductEntity>>(
///       (store, list) {
///         store.box<ProductEntity>().putMany(list);
///       },
///       entities,
///     );
///   }
/// }
/// ```
///
/// Create a concrete DAO per entity only when you need custom queries and
/// register it with `injectable`:
///
/// ```dart
/// @lazySingleton
/// class UserDao extends ObjectBoxDao<UserEntity> {
///   UserDao(super.objectBox);
///
///   // Add custom queries here.
/// }
/// ```
class ObjectBoxDao<T extends ObjectBoxEntity> {
  ObjectBoxDao(this.objectBox);

  /// The app-wide database service (owns the Store).
  final ObjectBoxService objectBox;

  /// The entity-specific Box used by this DAO.
  Box<T> get box => objectBox.box<T>();


  T? getById(int objId) => box.get(objId);

  Future<T?> getByIdAsync(int objId) => box.getAsync(objId);

  List<T> getAll() => box.getAll();

  Future<List<T>> getAllAsync() => box.getAllAsync();

  int put(T entity, {PutMode mode = PutMode.put}) =>
      box.put(entity, mode: mode);

  Future<int> putAsync(T entity, {PutMode mode = PutMode.put}) {
    return box.putAsync(entity, mode: mode);
  }

  List<int> putMany(List<T> entities, {PutMode mode = PutMode.put}) {
    return box.putMany(entities, mode: mode);
  }

  Future<List<int>> putManyAsync(
    List<T> entities, {
    PutMode mode = PutMode.put,
  }) {
    return box.putManyAsync(entities, mode: mode);
  }

  bool removeById(int objId) => box.remove(objId);

  int removeMany(List<int> ids) => box.removeMany(ids);

  int removeAll() => box.removeAll();

  int count({int limit = 0}) => box.count(limit: limit);

  QueryBuilder<T> query([Condition<T>? condition]) => box.query(condition);

  /// Builds and closes a query safely.
  R withQuery<R>(QueryBuilder<T> builder, R Function(Query<T> query) action) {
    final q = builder.build();
    try {
      return action(q);
    } finally {
      q.close();
    }
  }

  List<T> find(ObjectBoxBoxQuery<T> builder) {
    return withQuery(builder(box), (q) => q.find());
  }

  T? findFirst(ObjectBoxBoxQuery<T> builder) {
    return withQuery(builder(box), (q) => q.findFirst());
  }

  /// Watch a query for changes.
  ///
  /// Note: ObjectBox query watch streams are single-subscription.
  /// Call `close()` on the emitted [Query] when you no longer need the stream.
  Stream<Query<T>> watchQuery(
    ObjectBoxBoxQuery<T> builder, {
    bool triggerImmediately = false,
  }) {
    return builder(box).watch(triggerImmediately: triggerImmediately);
  }
}
