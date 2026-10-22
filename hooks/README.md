# Brick hooks

Mason runs these in the generated project's folder.

| File | When | Does |
| --- | --- | --- |
| `pre_gen.dart` | before anything is written | adds `windows_toast_guid` (one random GUID per project) unless you pass your own |
| `post_gen.dart` | after the brick is written | patches `windows/` and `macos/` runner files — only for the platforms that exist |
| `src/runner_patches.dart` | — | the patches themselves, as pure text functions |

Every patch is idempotent and reports a file it does not recognise instead of
half-editing it; `__brick__/docs/DESKTOP_SETUP.md` lists the same edits for
doing them by hand.

## Testing a patch

The patch functions take the file's text and return it patched, so they are
tried against a real project:

```bash
flutter create --platforms=windows,macos probe
# run each patch*() from src/runner_patches.dart on the matching file,
# twice: the second run must answer PatchOutcome.alreadyPatched
```

Re-run this after raising the Flutter version the brick targets: the runner
templates change between Flutter releases.
