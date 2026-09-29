# Feature spec template

Copy to `lib/features/<name>/FEATURE_<name>.md` **before** writing code, and
keep it true as the feature changes. A spec that names every state, edge case
and rule is what lets a person — or an agent — build the feature once and test
it against something.

---

# FEATURE — <Name>

## 1. Purpose

One paragraph: who uses it, what for, and what success looks like.

## 2. Behaviour

### 2.1 Main path

Numbered steps from opening the screen to the goal.

### 2.2 Interactions

| Gesture / control | Result |
| --- | --- |
| Tap a card | Opens the item (`AppPage.x`), pushed over this page |
| Pull down | Refreshes what is already on screen |
| … | … |

### 2.3 States

| State | What the user sees |
| --- | --- |
| Loading | The card's `.loading()` rows (after 300ms) |
| Loaded | … |
| Empty | Specific sentence + one action |
| Failed | Cause + Retry; a section fails alone |
| Gone (404) | «No longer available» + a way back, no retry |
| Offline | Saved copy + the offline banner (if cacheable) |

### 2.4 Edge cases

- Very long title / name (both languages)
- No image
- 0, 1, 2, 11, 100 items (Arabic plurals)
- Double tap on every action
- Guest in `guestFirst` mode touching a protected action

### 2.5 Business rules

Numbered, testable: «A saved item stays saved after sign-out», …

## 3. Architecture

| Layer | Files | Contract |
| --- | --- | --- |
| Entity | `domain/entities/x_entity.dart` | Fields and their meaning |
| Repository | `domain/repositories/…` | `Future<Result<…>> getX(...)` |
| Data source | `data/datasources/…` | Endpoint(s) in `ApiEndpoints` |
| Bloc | `presentation/states/…` | Events · one `BlocStatus` per operation |
| UI | `presentation/ui/…` | Screen · body · cards (`SkeletonWidget`) |

## 4. API

```http
GET /x?page=1&limit=10&q=…
```

```json
{ "status": true, "message": "ok", "data": [ { "id": "x_001", "createdAt": "-2h" } ], "meta": { "page": 1, "hasMore": true, "total": 30 } }
```

Errors and their user-facing sentences.

## 5. Mock data

`assets/mock/<name>/*.json`, the `MockRoutes` lines, and the edge cases the
fixtures must contain (§2.4).

## 6. Strings

Every key, both languages; which are plural groups.

## 7. Accessibility and motion

Semantic labels per card, announcements, what animates and what reduced
motion does.

## 8. Tests

- Bloc: loading → success / failure per operation; duplicate request ignored.
- Widgets: every state in §2.3, both themes, 320dp, 1.3× text.
- Height parity for each `.loading()`.
- Fixtures: the §5 edge cases are present.

## 9. Open questions

What is not decided yet, and who decides it.
