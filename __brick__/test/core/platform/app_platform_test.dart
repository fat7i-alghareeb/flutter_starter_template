import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/platform/app_platform.dart';
import 'package:{{project_name}}/core/services/haptics/haptics_service.dart';

/// What the app runs on, named after what the code needs to know: every
/// capability answers for each platform, so a plugin with no code for one
/// is never called there.
void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  void on(TargetPlatform platform) =>
      debugDefaultTargetPlatformOverride = platform;

  test('phones: mobile, vibration, push, permission_handler', () {
    for (final platform in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
    ]) {
      on(platform);
      expect(AppPlatform.isMobile, isTrue, reason: '$platform');
      expect(AppPlatform.isDesktop, isFalse);
      expect(AppPlatform.supportsVibration, isTrue);
      expect(AppPlatform.supportsPush, isTrue);
      expect(AppPlatform.supportsPermissionHandler, isTrue);
      expect(AppPlatform.hasDesktopWindow, isFalse);
    }
  });

  test('Windows: a desktop window, no vibration, no push', () {
    on(TargetPlatform.windows);
    expect(AppPlatform.isDesktop, isTrue);
    expect(AppPlatform.isWindows, isTrue);
    expect(AppPlatform.hasDesktopWindow, isTrue);
    expect(AppPlatform.supportsVibration, isFalse);
    expect(AppPlatform.supportsPush, isFalse);
    // permission_handler lists Windows.
    expect(AppPlatform.supportsPermissionHandler, isTrue);
  });

  test('macOS: a desktop window; permission_handler has no code for it', () {
    on(TargetPlatform.macOS);
    expect(AppPlatform.isDesktop, isTrue);
    expect(AppPlatform.isMacOS, isTrue);
    expect(AppPlatform.supportsVibration, isFalse);
    expect(AppPlatform.supportsPush, isFalse);
    expect(AppPlatform.supportsPermissionHandler, isFalse);
  });

  test('flag emoji draw on Android, iOS and macOS; not on Windows or Linux', () {
    for (final platform in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    ]) {
      on(platform);
      expect(AppPlatform.rendersFlagEmoji, isTrue, reason: '$platform');
    }
    for (final platform in <TargetPlatform>[
      TargetPlatform.windows,
      TargetPlatform.linux,
    ]) {
      on(platform);
      expect(AppPlatform.rendersFlagEmoji, isFalse, reason: '$platform');
    }
  });

  test('only phones and tablets get a native splash screen', () {
    on(TargetPlatform.android);
    expect(AppPlatform.hasNativeSplash, isTrue);
    on(TargetPlatform.windows);
    expect(AppPlatform.hasNativeSplash, isFalse);
    on(TargetPlatform.macOS);
    expect(AppPlatform.hasNativeSplash, isFalse);
  });

  group('HapticsService', () {
    test('desktop gets a service that does nothing, and never throws', () {
      on(TargetPlatform.windows);
      final haptics = HapticsService.forPlatform();
      expect(haptics, isA<NoHaptics>());
      haptics
        ..press()
        ..tap();
    });

    test('a phone gets the vibration service', () {
      on(TargetPlatform.android);
      expect(HapticsService.forPlatform(), isA<VibrationHaptics>());
    });
  });
}
