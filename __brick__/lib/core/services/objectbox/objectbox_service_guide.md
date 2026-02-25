# ObjectBox Service (core/services/objectbox)

This folder owns the **app-wide ObjectBox database** integration.

Design goals (current project style):

- Keep **one Store** open for the entire app lifecycle (performance).
- Keep ObjectBox usage **behind data-layer abstractions** (Clean Architecture).
- Use **`injectable` only** for dependency injection (no manual registrations).
- Use existing error patterns:
  - `rethrowAsAppException(() async { ... })` inside data sources.
  - `runAsResult(() async { ... })` inside repositories.

## What does `Store` mean?

In ObjectBox, a **`Store`** is the main database handle for your app:

- **Owns the database connection** (opens the DB files in a directory).
- **Knows the model** (entities + properties) from the generated `objectbox.g.dart`.
- **Creates `Box<T>` instances**.

A `Box<T>` is like a table/collection for a single entity type `T`.

So the relationship is:

- `Store` (database) -> `Box<T>` (entity storage) -> `ObjectBoxDao<T>` (typed CRUD/query wrapper)

## Files in this folder (what each file does)

### `objectbox_service.dart`

Owns the single ObjectBox `Store` instance for the whole application.

- Created once during startup via `@preResolve` in `RegisterModule`.
- Provides `box<T>()` for DAOs.
- Provides transaction helpers (`runWriteTxAsync` / `runReadTxAsync`).

## `ObjectBoxService` vs `ObjectBoxDao` (the difference)

Think of it in 2 layers:

- **`ObjectBoxService` (database layer)**
  - Owns the **Store** (open/close/lifecycle).
  - Knows **where** the database directory is.
  - Exposes `box<T>()` to give you an entity `Box<T>`.
  - Exposes transaction helpers (`runReadTxAsync` / `runWriteTxAsync`).

- **`ObjectBoxDao<T>` (data-access layer)**
  - Wraps an entity `Box<T>` and provides **CRUD + query helpers**.
  - Depends on `ObjectBoxService` to obtain the box.
  - Is what your local datasource should use (instead of directly using `Store`).

### How they use each other

Flow:

1. `injectable` creates `ObjectBoxService` once (opens the Store).
2. A DAO (or local datasource) receives `ObjectBoxService` via DI.
3. The DAO calls `objectBox.box<T>()` to get the `Box<T>`.
4. The DAO performs reads/writes/queries using that box.

So: **Service provides the database connection; DAO provides the entity API.**

## How to use `ObjectBoxService`

### 1) Register it once in DI (already done)

`ObjectBoxService` is intended to be a single app-wide instance.

You register it using `injectable` as a pre-resolved singleton (because opening the store is async):

```dart
@module
abstract class RegisterModule {
  @preResolve
  Future<ObjectBoxService> get objectBoxService =>
      ObjectBoxService.createDefault();
}
```

### 2) Use it inside the data layer (DAO or local datasource)

Keep `Store`/`Box` usage in the **data layer**.

#### Option A: Use `box<T>()` directly in a local datasource

```dart
@lazySingleton
class ProductLocalDataSource {
  ProductLocalDataSource(this._objectBox);

  final ObjectBoxService _objectBox;

  Box<ProductEntity> get _box => _objectBox.box<ProductEntity>();

  Future<void> put(ProductEntity entity) async {
    _box.put(entity);
  }
}
```

#### Option B: Use it through `ObjectBoxDao<T>`

This keeps all CRUD/query logic inside a DAO and keeps the datasource small.

```dart
@lazySingleton
class ProductDao extends ObjectBoxDao<ProductEntity> {
  ProductDao(super.objectBox);
}
```

### 3) Run background transactions when needed

For heavier reads/writes that you want off the UI isolate, use:

- `runReadTxAsync`
- `runWriteTxAsync`

Example:

```dart
final count = await objectBox.runReadTxAsync<int, void>(
  (store, _) => store.box<ProductEntity>().count(),
  null,
);
```

### 4) When to call `close()`

In most Flutter apps you **do not** call `close()`.

Only close the store if you have a controlled shutdown scenario (tests, explicit logout flow where you also delete the database directory, etc.).

### `objectbox_entity.dart`

A minimal interface (`objId` getter/setter) used to strongly-type the generic DAO.

### `objectbox_dao.dart`

Generic DAO with common CRUD:

- `getById`, `getAll`
- `put`, `putMany`
- `removeById`, `removeAll`
- `query(...)`, `withQuery(...)`, `watchQuery(...)`

### `entities/objectbox_local_cache_entry_entity.dart`

A small example entity used to ensure ObjectBox codegen always has at least one entity.

## Code generation (required)

ObjectBox relies on code generation.

### Must-keep files

- `lib/objectbox-model.json`
  - **KEEP THIS FILE** and commit it to git.
  - ObjectBox uses it to track IDs/Uids across schema changes.

- `lib/objectbox.g.dart`
  - Generated output.
  - Contains `openStore()` used by `ObjectBoxService`.

### How to regenerate

Run (project root):

```bash
dart run build_runner build --delete-conflicting-outputs
```

If code generation fails, check:

- `lib/objectbox-model.json` is valid JSON and contains at least `entities: []`.
- Your entities are annotated with `@Entity()` and have an `@Id()` field.
- You are not placing entities in files excluded by build (must be under `lib/`).

## How to use ObjectBox in Clean Architecture

Recommended approach per feature:

- **Domain**
  - `HomeRepository` (abstract)
  - entities used by UI (pure Dart classes)

- **Data**
  - Remote DS: talks to API via Dio
  - Local DS: talks to ObjectBox via DAO
  - Repository implementation: decides when to use remote vs local, maps API DTOs into domain entities (or directly uses domain entities if you choose), wraps errors into `Result<T>`.

ObjectBox types (Store/Box/Query) should stay in **data layer**.

## Preferred feature structure (reuse the same domain entity for remote + local)

You said you want **the same Clean Architecture entity** to be used for:

- Remote (API)
- Local (ObjectBox)

This is supported by ObjectBox as long as you:

- Keep the **remote/server id** as `id` (or any name you like).
- Add **ObjectBox internal id** as `objId` (annotated with `@Id()`).

This is exactly why the base contract is named `objId`.

### Folder rule (your preference)

- Do **not** create `features/<feature>/data/objectbox/...`.
- Create a `dao/` folder **only when you need a custom DAO**.
- Otherwise, use the **default generic DAO** directly inside the datasource.

Example paths (Home feature):

- `lib/features/home/domain/entities/product_entity.dart` (also becomes an ObjectBox entity)
- `lib/features/home/data/dao/product_dao.dart` (only if you need custom queries)
- `lib/features/home/data/datasources/product_local_datasource.dart`

## Pattern: add local ObjectBox caching to a feature entity (example: `ProductEntity`)

### 1) Update the domain entity to also be an ObjectBox entity

Example (update your existing file):

- `lib/features/home/domain/entities/product_entity.dart`

```dart
import 'package:objectbox/objectbox.dart';

import '../../../../core/services/objectbox/objectbox_entity.dart';

@Entity()
class ProductEntity implements ObjectBoxEntity {
  ProductEntity({
    this.objId = 0,
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.imageUrl,
    this.isFavorite = false,
    this.isBestSeller = false,
  });

  @Id()
  @override
  int objId;

  /// Remote/server id.
  @Index()
  String id;

  String name;
  double price;
  String currency;
  String imageUrl;
  bool isFavorite;
  bool isBestSeller;
}
```

Important notes:

- ObjectBox needs a writable `@Id()` field. The simplest ObjectBox-compatible shape is: `int objId;` (non-final).
- If you keep your domain entities `const` + `final`, ObjectBox will not be able to assign IDs.

### Keeping the ObjectBox ID field named `objId` (recommended for your use case)

If you already had an `@Id` field named `id` before, and you rename it to `objId`, ObjectBox codegen can break because the model JSON may treat it as "delete + add".

To make ObjectBox treat it as a **rename**, pin the original UID on the renamed field using `@Property(uid: ...)`.

Example:

```dart
@Id()
@Property(uid: 39472402083263112)
int objId;
```

Where do you get the UID?

- Look inside `lib/objectbox-model.json` for the old `id` property UID and reuse it.

After applying this, run build_runner again.

### 2) Regenerate ObjectBox code

After adding/changing `@Entity()` or `@Id()`, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3) DAO options (two styles)

You asked for two options:

#### Option A: Default DAO (no DAO file)

If you do not need custom queries, you do not need a DAO class at all.
Use `ObjectBoxDao<T>` directly inside your local datasource (see Example 2 below).

#### Option B: Custom DAO (adds feature-specific queries)

Same file, but add your custom queries:

```dart
import 'package:injectable/injectable.dart';

import '../../../../core/services/objectbox/objectbox_dao.dart';
import '../../../../core/services/objectbox/objectbox_service.dart';
import '../../domain/entities/product_entity.dart';

@lazySingleton
class ProductDao extends ObjectBoxDao<ProductEntity> {
  ProductDao(super.objectBox);

  ProductEntity? findByRemoteId(String id) {
    return findFirst((b) => b..equal(ProductEntity_.id, id));
  }

  Stream<ProductEntity?> watchByRemoteId(String id) {
    return watchQuery(
      (b) => b..equal(ProductEntity_.id, id),
      triggerImmediately: true,
    ).map((q) {
      try {
        return q.findFirst();
      } finally {
        q.close();
      }
    });
  }
}
```

### 4) Local datasource examples (two styles)

#### Example 1: Local datasource using the **custom DAO**

Create:

- `lib/features/home/data/datasources/product_local_datasource.dart`

```dart
import 'package:injectable/injectable.dart';

import '../../../../core/error/global_error_handler.dart';
import '../dao/product_dao.dart';
import '../../domain/entities/product_entity.dart';

@lazySingleton
class ProductLocalDataSource {
  const ProductLocalDataSource(this._dao);

  final ProductDao _dao;

  Future<ProductEntity?> getByRemoteId(String id) {
    return rethrowAsAppException(() async {
      return _dao.findByRemoteId(id);
    });
  }

  Future<void> upsert(ProductEntity entity) {
    return rethrowAsAppException(() async {
      _dao.put(entity);
    });
  }
}
```

#### Example 2: Local datasource using the **default DAO** (no custom DAO)

In this style you do not create a DAO file.
You use the generic `ObjectBoxDao<T>` directly.

```dart
import 'package:injectable/injectable.dart';

import '../../../../core/error/global_error_handler.dart';
import '../../../../core/services/objectbox/objectbox_dao.dart';
import '../../../../core/services/objectbox/objectbox_service.dart';
import '../../domain/entities/product_entity.dart';

@lazySingleton
class ProductLocalDataSource {
  ProductLocalDataSource(this._objectBox)
      : _dao = ObjectBoxDao<ProductEntity>(_objectBox);

  final ObjectBoxService _objectBox;
  final ObjectBoxDao<ProductEntity> _dao;

  Future<ProductEntity?> getByRemoteId(String id) {
    return rethrowAsAppException(() async {
      return _dao.findFirst((b) => b..equal(ProductEntity_.id, id));
    });
  }

  Future<void> upsert(ProductEntity entity) {
    return rethrowAsAppException(() async {
      _dao.put(entity);
    });
  }
}
```

### 5) Repository use case (online/offline)

Your repository decides the strategy:

- If online: fetch remote, persist locally, return mapped domain entity.
- If offline: read local, return mapped domain entity.

Keep your existing error handling pattern:

- Local DS uses `rethrowAsAppException`.
- Repository uses `runAsResult`.

## Query patterns (best practices)

### Use `withQuery()` to avoid leaks

When you build a `Query`, always `close()` it.
The base DAO provides `withQuery(...)` to guarantee closure.

### Use `@Unique()` for lookup keys

For cache tables, use `@Unique()` on a `cacheKey` property.
This makes reads/writes deterministic and fast.

### Use indexes for frequent filters

If you do frequent searches/filters on a property, index it (`@Index()`) to speed up queries.

## Watching (reactive streams)

ObjectBox supports watching queries.

- `watchQuery(...)` returns `Stream<Query<T>>`.
- Each emitted `Query` must be closed after reading results.

Pattern:

```dart
dao.watchQuery((b) => b..equal(Entity_.field, value), triggerImmediately: true)
  .map((q) {
    try { return q.find(); } finally { q.close(); }
  });
```

## Transactions and isolates

- Most simple Box operations are fast.
- For heavier work (batch updates, expensive queries), prefer using:

- `ObjectBoxService.runWriteTxAsync(...)`
- `ObjectBoxService.runReadTxAsync(...)`

This runs in a background isolate and avoids UI jank.

## Versioning strategy for local cache

When you store JSON blobs or derived structures, version your keys:

- `home_v1`, `home_v2`, ...

When the API response or mapping changes, bump the key to avoid decoding old data.

## Troubleshooting

- **`Target of URI hasn't been generated: objectbox.g.dart`**
  - Run build_runner.
  - Ensure at least one `@Entity()` exists under `lib/`.

- **Generator crashes reading `objectbox-model.json`**
  - Ensure it is valid JSON and contains required keys like `entities`.

- **`openStore` missing**
  - Codegen hasn’t been run or `objectbox.g.dart` is not generated.
  - Ensure you ran `build_runner` successfully.
