import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:unique_identifier/unique_identifier.dart';


class DeviceHelper {
  static Future<String?> getDeviceIdentifier() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      String? mobileDeviceIdentifier, identifier;
      try {
        mobileDeviceIdentifier = await MobileDeviceIdentifier().getDeviceId();
      } catch (_) {}
      try {
        identifier = await UniqueIdentifier.serial;
      } on PlatformException {
        identifier = '';
      }
      final iosInfo = await deviceInfo.iosInfo;

      final String deviceId = (mobileDeviceIdentifier ?? identifier) ??
          (iosInfo.identifierForVendor ?? "");
      return deviceId;
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
