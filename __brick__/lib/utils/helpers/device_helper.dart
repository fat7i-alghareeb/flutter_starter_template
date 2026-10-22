import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_udid/flutter_udid.dart';

import '../../core/platform/app_platform.dart';

class DeviceHelper {
  /// A stable id for this device, or null when none can be read.
  ///
  /// flutter_udid on every platform it ships for — Android, iOS, Windows,
  /// macOS, Linux — so a desktop install has an id too. On Android and iOS
  /// the platform's own id is the fallback.
  static Future<String?> getDeviceIdentifier() async {
    if (AppPlatform.isWeb) return null;
    try {
      final udid = await FlutterUdid.consistentUdid;
      if (udid.isNotEmpty) return udid;
    } catch (_) {
      // Fall through to the platform's own id.
    }

    final deviceInfo = DeviceInfoPlugin();
    if (AppPlatform.isAndroid) return (await deviceInfo.androidInfo).id;
    if (AppPlatform.isIOS) {
      return (await deviceInfo.iosInfo).identifierForVendor;
    }
    return null;
  }

  static Future<String> getDeviceInfoString() async {
    final deviceInfo = DeviceInfoPlugin();

    if (AppPlatform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return "${android.manufacturer} ${android.model} - Android ${android.version.release}";
    }

    if (AppPlatform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return "${ios.name} - ${ios.systemName} ${ios.systemVersion}";
    }

    if (AppPlatform.isWindows) {
      final windows = await deviceInfo.windowsInfo;
      return "${windows.computerName} - ${windows.productName}";
    }

    if (AppPlatform.isMacOS) {
      final mac = await deviceInfo.macOsInfo;
      return "${mac.model} - macOS ${mac.osRelease}";
    }

    return "Unknown Device";
  }
}
