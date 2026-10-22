import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:{{project_name}}/core/config/localization_config.dart';
import 'package:{{project_name}}/core/services/localization/locale_service.dart';
import 'package:{{project_name}}/core/services/storage/storage_service.dart';
import 'package:{{project_name}}/core/theme/theme_controller.dart';
import 'package:{{project_name}}/utils/constants/app_flow_constants.dart';

/// A first launch is light and Arabic — whatever the device is set to — and
/// anything the person picks later wins.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<StorageService> emptyStorage() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    return StorageService.sharedOnly(await SharedPreferences.getInstance());
  }

  test('the default theme is light', () async {
    expect(AppThemeConfig.defaultMode, ThemeMode.light);
    expect(ThemeController(await emptyStorage()).themeMode, ThemeMode.light);
  });

  test('the default language is Arabic', () {
    expect(AppLocalizationConfig.defaultLanguageCode, 'ar');
    expect(AppLocalizationConfig.fallbackLanguageCode, 'ar');
    expect(AppLocalizationConfig.followDeviceLanguageOnFirstLaunch, isFalse);
  });

  testWidgets('an English device still starts in Arabic', (tester) async {
    tester.platformDispatcher.localesTestValue = const <Locale>[Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final service = LocaleService(await emptyStorage());
    expect(service.resolveStartupLocale(), const Locale('ar'));
  });

  testWidgets('a saved theme beats the default', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'theme.mode': 'dark',
    });
    final controller = ThemeController(
      StorageService.sharedOnly(await SharedPreferences.getInstance()),
    );
    await controller.initialize();
    expect(controller.themeMode, ThemeMode.dark);
  });
}
