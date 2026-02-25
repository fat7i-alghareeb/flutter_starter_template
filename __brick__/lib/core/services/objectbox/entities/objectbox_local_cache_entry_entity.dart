import 'package:objectbox/objectbox.dart';

import '../objectbox_entity.dart';

/// A small, generic key-value cache entry stored in ObjectBox.
///
/// This entity is intentionally generic so the app has at least one stable
/// ObjectBox entity from day 1 (which allows generating `objectbox.g.dart`).
///
/// You can use it for:
/// - caching API responses
/// - caching feature flags
/// - caching expensive computations
@Entity()
class ObjectBoxLocalCacheEntryEntity implements ObjectBoxEntity {
  ObjectBoxLocalCacheEntryEntity({
    this.objId = 0,
    required this.key,
    required this.value,
    int? updatedAtMillis,
  }) : updatedAtMillis =
           updatedAtMillis ?? DateTime.now().millisecondsSinceEpoch;

  @Id()
  @override
  int objId;

  @Unique()
  String key;

  String value;

  /// Unix time in milliseconds.
  int updatedAtMillis;
}
