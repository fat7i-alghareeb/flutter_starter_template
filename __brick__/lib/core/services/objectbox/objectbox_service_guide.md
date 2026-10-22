# ObjectBox guide (`lib/core/services/objectbox/`)

Read this before you add local persistence, an ObjectBox entity, or a DAO. Layer rules: `.ai/architecture-rules.md`.

ObjectBox is the app's on-device database. It runs on Android, iOS, macOS and Windows (kept on every platform on purpose).
Keep **ObjectBox types (`Store`, `Box`, `Query`) in the data layer** — never in a bloc or a widget.

## The pieces

| File | What it is |
| --- | --- |
| `objectbox_service.dart` | `ObjectBoxService` — owns the one `Store`. `createDefault()` opens it in `<app-documents>/objectbox`; `box<T>()` gives a `Box<T>`; `runReadTxAsync` / `runWriteTxAsync` run a transaction on a background isolate |
| `objectbox_dao.dart` | `ObjectBoxDao<T extends ObjectBoxEntity>` — typed CRUD and queries over one box: `getById`, `getAll`, `put`, `putMany`, `removeById`, `removeAll`, `findFirst`, `query`, `withQuery`, `watchQuery` |
| `objectbox_entity.dart` | The small interface (`objId`) that types the DAO |
| `entities/objectbox_local_cache_entry_entity.dart` | A generic key/value entity (`key` unique, `value`, `updatedAtMillis`). It also guarantees code generation always has an entity |
| `lib/objectbox-model.json` | **Commit it.** ObjectBox tracks ids and UIDs across schema changes with it |
| `lib/objectbox.g.dart` | Generated (`openStore()`); committed |

Relationship: `Store` (the database) → `Box<T>` (one entity type) → `ObjectBoxDao<T>` (typed API). The service provides the
connection; the DAO provides the entity API.

## What uses it today

Only the **offline response cache** (`lib/core/network/offline/response_cache.dart`, `ObjectBoxResponseCacheStore`): it keeps
cacheable responses in the generic cache entity so the app can show a saved copy and the offline banner. The tests use an
in-memory `ResponseCacheStore`, because a widget test has no native library.

## Open the store once

The store is opened asynchronously, so it is **not** registered at start-up (nothing on the first-frame path opens it). Whoever needs it first
calls `ObjectBoxService.createDefault()`. ObjectBox offers `Store.isOpen(directory)` and `Store.attach(...)` for a store that is
already open ([`Store` API](https://pub.dev/documentation/objectbox/latest/objectbox/Store-class.html)) — so do not call
`createDefault()` a second time for the same directory. If a second place needs the database, share the opened service: hold the
`Future<ObjectBoxService>` in one `@lazySingleton` and inject it into both (and point the response cache at it).

`close()` is almost never called. Only close the store in a controlled shutdown (a test, or a sign-out that also deletes the database folder).

## Add local persistence to a feature

1. **The entity.** Either a dedicated local entity in `data/models/`, or the domain entity itself when you want one class for
   remote and local. ObjectBox needs a writable `@Id() int objId` (non-final), so the second option makes that entity non-`const`:

   ```dart
   @Entity()
   class ProductEntity implements ObjectBoxEntity {
     ProductEntity({this.objId = 0, required this.id, required this.name});

     @Id()
     @override
     int objId;

     /// The server's id.
     @Index()
     String id;

     String name;
   }
   ```

2. **Regenerate**: `dart run build_runner build` (the entity must be under `lib/`, annotated `@Entity()` with an `@Id()`).
3. **Access**, in the data layer, with the default DAO or a custom one:

   ```dart
   @lazySingleton
   class ProductDao extends ObjectBoxDao<ProductEntity> {
     ProductDao(super.objectBox);

     ProductEntity? findByRemoteId(String id) =>
         findFirst((b) => b..equal(ProductEntity_.id, id));
   }
   ```

   A `dao/` folder only when you need a custom DAO; otherwise use `ObjectBoxDao<T>` straight in the data source.
4. **The local data source** wraps IO in `rethrowAsAppException`; the **repository** decides online / offline, maps, and wraps in
   `runAsResult`:

   ```dart
   Future<ProductEntity?> getByRemoteId(String id) =>
       rethrowAsAppException(() async => _dao.findByRemoteId(id));
   ```

5. **Offline strategy** (repository): online → fetch, store, return the mapped entity; offline → read the stored one.

### Renaming an `@Id` field

Renaming `id` to `objId` looks like "delete + add" to the generator. Pin the old UID so it is a rename:
`@Id() @Property(uid: <the old property's uid from lib/objectbox-model.json>) int objId;`, then regenerate.

## Queries

- A `Query` must be `close()`d. Use `dao.withQuery(...)`, which closes it for you.
- `@Unique()` on a lookup key (a cache key) makes reads and writes deterministic; `@Index()` on a property you filter on often.
- `watchQuery(...)` returns `Stream<Query<T>>`; each emitted query must be closed after reading:

  ```dart
  dao.watchQuery((b) => b..equal(Entity_.field, value), triggerImmediately: true)
     .map((q) { try { return q.find(); } finally { q.close(); } });
  ```

## Transactions

Single `Box` operations are fast. For batches or heavy queries use `runWriteTxAsync` / `runReadTxAsync` (a background isolate, no UI jank):

```dart
final count = await objectBox.runReadTxAsync<int, void>((store, _) => store.box<ProductEntity>().count(), null);
```

## Desktop

On macOS a **sandboxed** app must name an App Group so ObjectBox can open its store: set `MACOS_APP_GROUP` (read as
`AppConfig.macosApplicationGroup`) and the matching entitlement; `ObjectBoxService.createDefault` passes it only on macOS. Windows
needs nothing. The build notes (including a CMake message from the plugin that the setup script hides) are in `docs/DESKTOP_SETUP.md`.

## Versioning cached data

When you store JSON or a derived structure, put a version in the key (`home_v1`, `home_v2`). When the API or the mapping changes,
bump it so old data is never decoded.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `Target of URI hasn't been generated: objectbox.g.dart` | Run `dart run build_runner build`; make sure at least one `@Entity()` exists under `lib/` |
| The generator crashes reading `objectbox-model.json` | The file must be valid JSON with an `entities` key |
| `openStore` is missing | Code generation has not run, or failed |
| A second place cannot open the store | Share the opened `ObjectBoxService` (see "Open the store once") |
nges, bump the key to avoid decoding old data.

## Troubleshooting

- **`Target of URI hasn't been generated: objectbox.g.dart`**
  - Run build_runner.
  - Ensure at least one `@Entity()` exists under `lib/`.

- **Generator crashes reading `objectbox-model.json`**
  - Ensure it is valid JSON and contains required keys like `entities`.

- **`openStore` missing**
  - Codegen hasn’t been run or `objectbox.g.dart` is not generated.
  - Ensure you ran `build_runner` successfully.
