import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/helpers/colored_print.dart';

/// Tells Android which theme the app runs in, so the OS-drawn splash of the
/// NEXT cold start is drawn in the same one.
///
/// The Android 12+ splash is painted by the system before any Dart runs. It
/// picks `drawable-night` / `values-night-v31` from the night mode the OS holds
/// for this app — which, left alone, is the DEVICE's. The app's theme is its
/// own stored choice ([ThemeController]), so without this a dark app on a
/// light device never showed its dark splash artwork, and a light app on a
/// dark device opened on a dark splash that flipped to light.
///
/// Android persists the value (`UiModeManager.setApplicationNightMode`). The
/// handler lives in `MainActivity.kt` — paste it from
/// `docs/ANDROID_RELEASE_SETUP.md`. Until then every call fails quietly and
/// the OS splash simply follows the device. Below API 31 there is no such
/// API; the pre-12 native splash is colour only.
abstract final class NativeNightMode {
  /// Must match the channel name in `MainActivity.kt`.
  @visibleForTesting
  static const String channelName = '{{package_name}}/night_mode';

  static const MethodChannel _channel = MethodChannel(channelName);

  static Future<void> sync(ThemeMode mode) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('setNightMode', mode.name);
    } catch (e) {
      // Tests and hosts without the Android embedding have no handler. The
      // only cost of failing is a splash in the device's theme.
      printY('[NativeNightMode] sync failed: $e');
    }
  }
}
