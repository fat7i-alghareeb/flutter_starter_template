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

  /// Names the pipe a second launch on Windows uses to reach the running
  /// window (windows_single_instance).
  static const String singleInstanceId = '{{project_name}}_single_instance';

  /// The App Group a sandboxed macOS app gives ObjectBox
  /// (`--dart-define=MACOS_APP_GROUP=TEAMID.group.yourapp`). It starts with
  /// your Apple team id, so only you can supply it; without one ObjectBox
  /// opens as before, which is right for iOS, Android, Windows and an
  /// un-sandboxed Mac build. See `docs/DESKTOP_SETUP.md`.
  static const String macosApplicationGroup = String.fromEnvironment(
    'MACOS_APP_GROUP',
  );

  /// Windows' App User Model ID for toast notifications: `Company.App`.
  static const String windowsAppUserModelId = '{{package_name}}';

  /// The GUID Windows files this app's toasts under. Generated once for
  /// this project by `hooks/pre_gen.dart`; keep it for the app's lifetime.
  static const String windowsToastGuid = '{{windows_toast_guid}}';

  static String get apiBaseUrl => ApiConfig.baseUrl;
}
