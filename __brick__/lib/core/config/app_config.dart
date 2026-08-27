import '../network/api_config.dart';

class AppConfig {
  AppConfig._();

  /// Enables the in-app stage tools overlay (device preview, locale and theme
  /// sheets).
  ///
  /// Pass `--dart-define=STAGE_TOOLS=true` when running or building:
  ///
  /// ```bash
  /// flutter run --dart-define=STAGE_TOOLS=true
  /// ```
  ///
  /// This is a compile-time constant, so builds that do not define it drop the
  /// stage tools code entirely during tree shaking.
  static const bool stageToolsEnabled = bool.fromEnvironment('STAGE_TOOLS');

  static const String appTitle = '{{project_title}}';

  static String get apiBaseUrl => ApiConfig.baseUrl;
}
