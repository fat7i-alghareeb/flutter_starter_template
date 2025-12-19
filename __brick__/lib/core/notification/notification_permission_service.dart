import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/helpers/colored_print.dart';

/// Handles notification permission using `permission_handler`.
///
/// This is used to ensure permission is requested **before** any notification
/// work (including FCM setup) so the app has a single, predictable permission
/// flow.
@lazySingleton
class NotificationPermissionService {
  const NotificationPermissionService();

  Future<bool> isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<bool> requestNotificationPermission({
    required bool enableDebugLogs,
    bool openSettingsIfPermanentlyDenied = false,
  }) async {
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
