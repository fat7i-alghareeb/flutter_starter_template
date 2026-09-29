import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/services/storage/storage_service.dart';
import 'package:{{project_name}}/core/theme/native_night_mode.dart';
import 'package:{{project_name}}/core/theme/theme_controller.dart';
import 'package:{{project_name}}/utils/constants/app_flow_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Android 12+ splash is drawn by the OS from the night mode it holds for
/// the app. Unless the app reports its own theme, that is the DEVICE's — and
/// a dark app on a light device opened on a light splash.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(NativeNightMode.channelName);
  late List<MethodCall> calls;

  Future<ThemeController> controller(Map<String, Object> saved) async {
    SharedPreferences.setMockInitialValues(saved);
    return ThemeController(
      StorageService.sharedOnly(await SharedPreferences.getInstance()),
    );
  }

  setUp(() {
    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('a first launch reports the default (AppThemeConfig)', () async {
    final theme = await controller(<String, Object>{});
    await theme.initialize();
    await pumpEventQueue();

    expect(calls.single.method, 'setNightMode');
    expect(calls.single.arguments, AppThemeConfig.defaultMode.name);
  });

  test('every launch reports the saved theme, even when unchanged', () async {
    // The OS forgets it when the app's data is cleared.
    final theme = await controller(<String, Object>{'theme.mode': 'dark'});
    await theme.initialize();
    await pumpEventQueue();

    expect(calls.single.arguments, 'dark');
  });

  test('picking a theme reports it at once', () async {
    final theme = await controller(<String, Object>{'theme.mode': 'light'});
    await theme.initialize();
    await pumpEventQueue();
    calls.clear();

    theme.setThemeMode(ThemeMode.system);
    await pumpEventQueue();

    // «System» must hand the splash back to the device, not pin it.
    expect(calls.single.arguments, 'system');
  });

  test('a host without the channel does not throw', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    final theme = await controller(<String, Object>{});

    await expectLater(theme.initialize(), completes);
    theme.setThemeMode(ThemeMode.dark);
    await pumpEventQueue();
  });
}
