class AppLocalizationConfig {
  /// Path where JSON localization files live.
  static const String translationsPath = 'assets/l10n';

  /// Fallback language code used by the app and generator.
  static const String fallbackLanguageCode = 'en';

  /// All supported language codes. Add new languages here only
  /// (e.g. 'tr', 'fr'), and both EasyLocalization and the
  /// AppStrings generator will pick them up.
  static const List<String> supportedLanguageCodes = <String>['en', 'ar'];
}
