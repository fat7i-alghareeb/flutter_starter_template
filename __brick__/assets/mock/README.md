# Mock fixtures

Run with `--dart-define=USE_MOCK=true` and every request is answered from
these files by `MockInterceptor` — the first Dio interceptor — so
repositories, parsing, paging and error handling run exactly as they will
against the real API.

## Conventions

- **One folder per feature**, and **list each folder in `pubspec.yaml`**:
  Flutter does not bundle asset sub-folders recursively.
- **The envelope** every response uses:
  `{ "status": true, "message": "ok", "data": … }`.
- **Relative dates**: a value under a key ending in `At` is written `-2h`,
  `-3d`, `+1w`, `-2mo` and turned into a real timestamp at request time — a
  fixture written today still reads «2h ago» next year.
- **Stable ids** (`item_001`), so specs and tests can name an item.
- **Include the edge cases** the spec asks for: no image, very long title,
  empty list.

## Routing (`lib/core/config/mock_config.dart` → `MockRoutes`)

First match wins; `{id}` matches one path segment and fills the same name in
the fixture path.

```dart
('/items/{id}', 'assets/mock/items/list.json#id={id}'),  // ONE item of the list, 404 if absent
('/items',      'assets/mock/items/list.json'),
```

A list is paged, filtered and searched the way a server would:
`page` / `limit` slice it and add `meta`; `q` searches `title`/`name`/
`categoryName`; `sort` = `newest` · `rating` · `alphabetical` · `priceAsc` ·
`priceDesc`; any other parameter keeps items whose field equals it.

## Switches

`MOCK_DELAY_MS`, `MOCK_EMPTY=/path,…`, `MOCK_ERROR=/path,…`,
`MOCK_OFFLINE=true` — see `docs/COMMANDS.md`.

`showcase/` belongs to the showcase feed; delete it with the feature.
