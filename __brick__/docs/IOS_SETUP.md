# iOS setup

What the iOS side needs beyond `flutter create`: the permission compile flags,
push notifications, links from the web, the display name and 120 Hz. Every
file is complete and ready to paste. Needs a Mac with Xcode (or Codemagic —
`docs/CODEMAGIC.md` builds and signs without one).

---

## 1. `ios/Podfile` — permissions compiled in on purpose

`permission_handler` compiles **every** permission out unless it is opted in.
The app asks for exactly one: notifications. Enabling a permission the app
never requests is what gets a build rejected at App Store review — add a line
only when you add a request in Dart.

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '13.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        # One line per permission the app ACTUALLY requests.
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

Then `cd ios && pod install`.

> Newer Flutter versions build iOS plugins with **Swift Package Manager**
> instead of CocoaPods. With SwiftPM the `post_install` block does not run;
> permission_handler then reads the same flags from the
> `GCC_PREPROCESSOR_DEFINITIONS` build setting of the Runner target (Xcode →
> Runner → Build Settings).

## 2. `ios/Runner/Info.plist` additions

Add inside the top-level `<dict>`:

```xml
<!-- The name under the icon. -->
<key>CFBundleDisplayName</key>
<string>{{project_title}}</string>

<!-- ProMotion: without it iPhones cap the app at 60 Hz. -->
<key>CADisableMinimumFrameDurationOnPhone</key>
<true/>

<!-- Only the languages the app ships (AppLocalizationConfig). -->
<key>CFBundleLocalizations</key>
<array>
  <string>en</string>
  <string>ar</string>
</array>

<!-- Pushes (only with FCM on): wake the app for remote notifications. -->
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>

<!-- The custom scheme (AppLinks.scheme): myapp://items/42 -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>

<!-- Let go_router receive links. -->
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

Why no `NS…UsageDescription` keys: the template requests no camera, photos,
location or microphone. Add the matching key **with a real sentence** the day
you add such a request — Apple rejects both a missing key and a vague one.

## 3. Push notifications (FCM)

Only when you turn FCM on (`bootstrap.dart` → `_fcmEnabled = true`).

1. Apple Developer → Keys → **+** → «Apple Push Notifications service» →
   download the `.p8` (once — keep it safe). Note the Key ID and Team ID.
2. Firebase console → Project settings → Cloud Messaging → Apple app →
   upload the `.p8` with its Key ID and Team ID.
3. Firebase → add an iOS app with bundle id `{{package_name}}` → download
   `GoogleService-Info.plist` → drag it into `ios/Runner/` in Xcode («Copy
   items if needed», target Runner).
4. Xcode → Runner → **Signing & Capabilities** → **+ Capability** → «Push
   Notifications», and «Background Modes» → tick «Remote notifications».
5. `flutterfire configure` (optional) writes `lib/firebase_options.dart`;
   without it `Firebase.initializeApp()` reads the plist.

Local notifications need none of this.

## 4. Universal links

1. Xcode → Runner → Signing & Capabilities → **+ Associated Domains** →
   `applinks:example.com` (your `AppLinks.hosts` host).
2. Host `https://example.com/.well-known/apple-app-site-association` (no
   extension, `application/json`):

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["TEAMID.{{package_name}}"],
        "components": [{ "/": "/items/*" }]
      }
    ]
  }
}
```

One component per `AppLinks.linkable` page. The link then reaches
`LinkDispatcher`, which opens the page over the shell.

## 5. `ios/Runner/AppDelegate.swift`

The file `flutter create` writes is right; nothing to add for this template.
If you use `flutter_local_notifications` foreground presentation on iOS < 14,
its README asks for one delegate line — the template targets 13+ and the
plugin handles it.

## 6. Build

```bash
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
open build/ios/archive/Runner.xcarchive      # or upload with Transporter
```

Keep `build/symbols/*.symbols`: an obfuscated crash is unreadable without
them (`flutter symbolize -i trace.txt -d build/symbols/app.ios-arm64.symbols`).

## 7. Launch screen and icon

Generated — never hand-edited: `flutter_native_splash.yaml` writes
`LaunchScreen.storyboard` + `LaunchBackground` images, and
`flutter_launcher_icons.yaml` writes `Assets.xcassets/AppIcon.appiconset`
(`remove_alpha_ios: true`: App Store rejects an icon with transparency).
