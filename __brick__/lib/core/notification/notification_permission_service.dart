import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/helpers/colored_print.dart';
import '../platform/app_platform.dart';

/// Handles notification permission.
///
/// This is used to ensure permission is requested **before** any notification
/// work (including FCM setup) so the app has a single, predictable permission
/// flow.
///
/// - Android and iOS: `permission_handler`.
/// - macOS: flutter_local_notifications' own request — permission_handler
///   has no macOS code.
/// - Windows: toast notifications need no runtime permission; the user
///   switches them off in Windows Settings.
@lazySingleton
class NotificationPermissionService {
  const NotificationPermissionService();

  MacOSFlutterLocalNotificationsPlugin? get _mac =>
      FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();

  /// Whether the OS can ask again, or only its settings can change it.
  /// Desktop never says «permanently».
  Future<bool> isPermanentlyDenied() async {
    if (!AppPlatform.isMobile) return false;
    return (await Permission.notification.status).isPermanentlyDenied;
  }

  Future<bool> isNotificationPermissionGranted() async {
    if (AppPlatform.isMacOS) {
      final options = await _mac?.checkPermissions();
      return options?.isEnabled ?? false;
    }
    if (!AppPlatform.isMobile) return true;
    final status = await Permission.notification.status;
    return status.isGranted || status.isProvisional;
  }

  Future<bool> requestNotificationPermission({
    required bool enableDebugLogs,
    bool openSettingsIfPermanentlyDenied = false,
  }) async {
    if (AppPlatform.isMacOS) {
      final granted =
          await _mac?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      if (enableDebugLogs) printC('[Notifications] macOS permission=$granted');
      return granted;
    }
    if (!AppPlatform.isMobile) return true;

    final current = await Permission.notification.status;
    if (current.isGranted) return true;

    final result = await Permission.notification.request();

    if (result.isPermanentlyDenied && openSettingsIfPermanentlyDenied) {
      await openAppSettings();
    }

    if (enableDebugLogs) {
      printC('[Notifications] permission=${result.name}');
    }

    return result.isGranted;
  }
}
