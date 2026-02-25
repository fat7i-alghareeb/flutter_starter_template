/// Minimal contract for ObjectBox entities used by the generic DAO layer.
///
/// Note:
/// - ObjectBox (Dart/Flutter) still requires each `@Entity()` to declare its own
///   `@Id()` field.
/// - This interface exists to make the repository/DAO layer strongly typed and
///   consistent across the codebase.
abstract interface class ObjectBoxEntity {
  /// ObjectBox internal primary key.
  ///
  /// This is intentionally **not** annotated here.
  /// Each concrete `@Entity()` must declare its own writable `@Id()` field.
  int get objId;

  set objId(int id);
}
