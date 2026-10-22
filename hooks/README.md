# Brick hooks

Mason runs these in the generated project's folder.

| File | When | Does |
| --- | --- | --- |
| `pre_gen.dart` | before anything is written | adds `windows_toast_guid` (one random GUID per project) unless you pass your own |
| `post_gen.dart` | after the brick is written | patches `windows/` and `macos/` runner files — only for the platforms that exist |
| `src/runner_patches.dart` | — | the patches themselves, as pure text functions |

## The patches

| Function | File | Why |
| --- | --- | --- |
| `patchWindowsCMake` | `windows/CMakeLists.txt` | defines `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` so `permission_handler_windows` builds on Visual Studio 2026 |
| `patchWindowsCMakePolicy` | same | `CMAKE_POLICY_DEFAULT_CMP0169 OLD` — `objectbox_flutter_libs` calls `FetchContent_Populate` the old way |
| `patchWindowsLinkerNoise` | same | `/ignore:4099 /ignore:4078` — two harmless linker messages from prebuilt libraries |
| `patchWindowsAwaitFlag` | same | removes the deprecated `/await` from `permission_handler_windows_plugin` (it already asks for C++20); `/wd9047` does **not** work — `/wd` takes compiler warning numbers only |
| `patchWindowsFlutterWindow`, `patchWindowsMain` | `windows/runner/` | hidden window until the first frame; a launch with a link goes to the running copy |
| `patchMacosMainWindow`, `patchMacosEntitlements`, `patchMacosInfoPlist` | `macos/` | hidden window at launch, entitlements, URL scheme |

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

## Before you push a change here

`mason make` compiles the hooks, and a hook that does not compile stops **every** generation — so run it for real:

```bash
cd hooks && dart pub get && dart analyze
flutter create --platforms=android,windows,macos probe && cd probe
mason make flutter_app_template --on-conflict overwrite   # the hook must say what it patched
flutter build windows --debug                              # 0 warnings, 0 errors
```
