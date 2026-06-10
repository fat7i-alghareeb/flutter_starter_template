import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_udid/flutter_udid.dart';

class DeviceHelper {
  static Future<String?> getDeviceIdentifier() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final udid = await FlutterUdid.consistentUdid;
      if (udid.isNotEmpty) return udid;

      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final udid = await FlutterUdid.consistentUdid;
      if (udid.isNotEmpty) return udid;

      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }

    return null;
  }

  // static Future<String?> getDeviceToken() async {
  //   return await PushNotification.getDeviceToken();
  // }

  static Future<String> getDeviceInfoString() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return "${android.manufacturer} ${android.model} - Android ${android.version.release}";
    }

    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return "${ios.name} - ${ios.systemName} ${ios.systemVersion}";
    }

    return "Unknown Device";
  }
}
