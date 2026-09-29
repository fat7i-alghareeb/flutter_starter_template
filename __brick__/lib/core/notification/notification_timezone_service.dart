import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
// `latest_10y`, not `latest`: a notification is scheduled days ahead, never
// decades, and the 10-year window (5 years back, 5 ahead of the package
// release) is ~1/4 of the full database — ~190 KB less in the binary and less
// to parse at startup. It moves forward whenever `timezone` is upgraded.
import 'package:timezone/data/latest_10y.dart' as tz_data;
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
