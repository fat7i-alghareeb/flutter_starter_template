import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../injection/injectable.dart';
import 'storage_service.dart';

/// When the reader last opened a screen — so a section can say «2 new» for
/// the items that arrived since.
///
/// ```dart
/// final visit = LastVisit('feed');
/// unawaited(visit.load());                       // in initState
/// visit.countNewer(items.map((i) => i.publishedAt));
/// ```
///
/// Read ONCE per app run: the value is the PREVIOUS visit, and this run's
/// visit is written straight away for the next one. Reading it again later in
/// the same run would make everything look old after the first frame.
///
/// [previous] is a `ValueNotifier`: storage answers a moment after the screen
/// opens, and a badge built on it appears when it does.
class LastVisit {
  LastVisit(this.id);

  /// One key per screen, e.g. `feed`.
  final String id;

  static final Map<String, ValueNotifier<DateTime?>> _previous =
      <String, ValueNotifier<DateTime?>>{};
  static final Set<String> _loaded = <String>{};

  String get storageKey => 'lastVisit.$id';

  /// The previous visit; null on a first visit, before [load] finishes, or
  /// when storage is unavailable (a test).
  ValueNotifier<DateTime?> get previous =>
      _previous.putIfAbsent(id, () => ValueNotifier<DateTime?>(null));

  Future<void> load() async {
    if (_loaded.contains(id)) return;
    _loaded.add(id);
    if (!getIt.isRegistered<StorageService>()) return;
    final storage = getIt<StorageService>();
    try {
      final raw = await storage.readString(storageKey);
      previous.value = raw == null ? null : DateTime.tryParse(raw);
      unawaited(
        storage.writeString(storageKey, DateTime.now().toIso8601String()),
      );
    } on Object {
      // No storage, no badge — never a crash.
    }
  }

  /// How many of [dates] are newer than the previous visit.
  int countNewer(Iterable<DateTime> dates) {
    final since = previous.value;
    if (since == null) return 0;
    return dates.where((d) => d.isAfter(since)).length;
  }

  @visibleForTesting
  static void reset() {
    _loaded.clear();
    for (final notifier in _previous.values) {
      notifier.value = null;
    }
  }
}
