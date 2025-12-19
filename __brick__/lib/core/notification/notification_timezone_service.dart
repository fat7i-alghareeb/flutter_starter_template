import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../utils/helpers/colored_print.dart';

/// Initializes the timezone database used by scheduling APIs.
///
/// `flutter_local_notifications` scheduling is timezone-aware and uses
/// `tz.TZDateTime`. We use `flutter_timezone` to map the device timezone into
/// a TZ database location.
@lazySingleton
class NotificationTimezoneService {
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize({required bool enableDebugLogs}) async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    try {
      final localTimeZone = await FlutterTimezone.getLocalTimezone();
      final localName = localTimeZone.identifier;
      tz.setLocalLocation(tz.getLocation(localName));

      if (enableDebugLogs) {
        printG('[Notifications] timezone=$localName');
      }
    } catch (e) {
      if (enableDebugLogs) {
        printY('[Notifications] timezone init failed: $e');
      }
    }

    _initialized = true;
  }

  tz.TZDateTime toLocalTz(DateTime date) {
    return tz.TZDateTime.from(date, tz.local);
  }
}
