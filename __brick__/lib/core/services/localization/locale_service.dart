import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../config/localization_config.dart';
import '../../services/storage/storage_service.dart';
import '../../../utils/constants/localization_constants.dart';

/// Central service for resolving and changing the app locale.
///
/// Responsibilities:
/// - Decide the initial locale on app start (saved locale > device > fallback)
/// - Persist the chosen locale using [StorageService]
/// - Provide an API to change the locale at runtime and sync EasyLocalization
@lazySingleton
class LocaleService {
  LocaleService(this._storage);

  final StorageService _storage;

  /// Resolves the locale to use on app startup.
  ///
  /// Priority:
  /// 1. Saved locale in [StorageService]
  /// 2. Device locale if supported
  /// 3. Fallback locale from [AppLocalizationConfig]
  Future<Locale> resolveInitialLocale() async {
    final savedCode = await _storage.readString(
      LocalizationStorageKeys.localeCode,
    );

    String finalCode;
    if (savedCode != null && _isSupported(savedCode)) {
      finalCode = savedCode;
    } else {
      final deviceCode = _deviceLanguageCode();
      finalCode = _isSupported(deviceCode)
          ? deviceCode
          : AppLocalizationConfig.fallbackLanguageCode;

      await _storage.writeString(LocalizationStorageKeys.localeCode, finalCode);
    }

    return Locale(finalCode);
  }

  /// Changes the current language and updates both storage and UI.
  ///
  /// You must pass a [BuildContext] from inside the widget tree wrapped by
  /// [EasyLocalization] so that [setLocale] can rebuild the app.
  Future<void> changeLanguage(
    AppLanguage language,
    BuildContext context,
  ) async {
    final code = language.code;

    await _storage.writeString(LocalizationStorageKeys.localeCode, code);
    if (context.mounted) await context.setLocale(Locale(code));
  }

  /// Returns the currently saved language code, or the fallback if none.
  Future<String> currentLanguageCode() async {
    final savedCode = await _storage.readString(
      LocalizationStorageKeys.localeCode,
    );
    if (savedCode != null && _isSupported(savedCode)) {
      return savedCode;
    }
    return AppLocalizationConfig.fallbackLanguageCode;
  }

  bool _isSupported(String code) =>
      AppLocalizationConfig.supportedLanguageCodes.contains(code);

  String _deviceLanguageCode() {
    final locale = PlatformDispatcher.instance.locale;
    return locale.languageCode.toLowerCase();
  }
}
