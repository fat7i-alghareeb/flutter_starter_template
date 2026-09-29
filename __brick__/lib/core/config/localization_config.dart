class AppLocalizationConfig {
  /// Path where JSON localization files live.
  static const String translationsPath = 'assets/l10n';

  /// Fallback language code used by EasyLocalization for missing keys and by
  /// the AppStrings generator as the key source.
  static const String fallbackLanguageCode = 'en';

  /// Language the app starts in when nothing has been saved yet and the
  /// device's language is not one of [supportedLanguageCodes] (or
  /// [followDeviceLanguageOnFirstLaunch] is off).
  static const String defaultLanguageCode = 'en';

  /// On the very first launch, start in the device's language when the app
  /// ships it. Set to false to always start in [defaultLanguageCode].
  static const bool followDeviceLanguageOnFirstLaunch = true;

  /// All supported language codes. Add new languages here only
  /// (e.g. 'tr', 'fr'), and both EasyLocalization and the
  /// AppStrings generator will pick them up.
  static const List<String> supportedLanguageCodes = <String>['en', 'ar'];
}

/// High-level language enum used across the app.
///
/// Keep this in sync with [AppLocalizationConfig.supportedLanguageCodes].
enum AppLanguage { ar, en }

extension AppLanguageX on AppLanguage {
  /// Returns the language code as used in JSON files and headers.
  String get code {
    switch (this) {
      case AppLanguage.ar:
        return 'ar';
      case AppLanguage.en:
        return 'en';
    }
  }
}
