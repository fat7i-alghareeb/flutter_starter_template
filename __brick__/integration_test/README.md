# Integration tests

```bash
flutter test integration_test --dart-define=USE_MOCK=true
```

These need a connected device or a running emulator — they build and launch the
real app. `flutter test` alone does **not** pick them up, which is deliberate:
they take minutes, not milliseconds, and they are not what you run on every save.

`USE_MOCK=true` is required until your API exists: the showcase lists come from
`assets/mock/`, and the login wall's demo identity is filled in for you.

## Grant the runtime permissions first — or it hangs

```bash
ADB="$LOCALAPPDATA/Android/Sdk/platform-tools/adb.exe"   # Windows; `adb` elsewhere
P={{package_name}}
"$ADB" -s emulator-5554 shell pm grant $P android.permission.POST_NOTIFICATIONS
```

On a device where the app has never been granted it — a fresh install, or any
run after `pm clear` — Android puts its own permission dialog over the app the
first time the shell asks. It is a PLATFORM dialog, so `pumpAndSettle` cannot
see it and cannot dismiss it: the run sits on «Test starting…» until it is
killed, with no output and no failure.

`flutter test integration_test` REINSTALLS the APK, and an install that replaces
a cleared package starts with the grants revoked again — so granting once is not
permanent. When a run goes quiet for minutes with no new `+N:` line, ask the
device who has the screen before assuming the app is stuck:

```bash
"$ADB" -s emulator-5554 shell dumpsys window | grep mCurrentFocus
```

`GrantPermissionsActivity` in that line means the dialog is up. Granting the
permission from another shell lets the run continue where it stopped; the run
does not have to be restarted.

## What belongs here

Only what cannot be proven anywhere else: that the app **boots**, that bootstrap
and dependency injection and the router and storage work together, and that the
shell navigates. Everything about a single widget belongs in `test/`, where it
runs in a second.

## What the one test walks

`app_test.dart` is ONE `testWidgets` (a second would find no app — see the
file's header). It starts from a genuine **first launch**: it clears
`SharedPreferencesAsync` and the secure storage before `bootstrap()`, so there
is no onboarding flag, no guest flag and no session. Then, the way a user
would:

1. onboarding appears, and its own «Skip» is tapped;
2. `AuthMode.loginRequired`: the sign-in wall appears and «Sign in» is tapped
   with the demo identity. `AuthMode.guestFirst`: the run FAILS the moment the
   sign-in screen is on screen for one frame;
3. the feed's list arrives from the mock layer;
4. every tab switches, then back to the feed;
5. a card opens its item; the system back button returns;
6. the header's settings button opens settings; back returns;
7. a shared link (`AppLinks.shareUrlOf('item_001')`) is handed to the app as
   Android hands it to a running one — it opens over the shell, and back lands
   on the shell.

Because it clears storage, a run signs the device out and resets its language
and theme.
