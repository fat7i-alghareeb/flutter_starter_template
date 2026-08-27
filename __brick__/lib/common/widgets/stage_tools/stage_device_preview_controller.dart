import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/injection/injectable.dart';
import '../../../core/services/storage/storage_service.dart';

class StageDevicePreviewController {
  StageDevicePreviewController(this._storage);

  static const String _enabledKey = 'stage_device_preview_enabled';

  final StorageService _storage;

  final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);

  bool get isSupported => AppConfig.stageToolsEnabled;

  Future<void> load() async {
    if (!isSupported) {
      enabled.value = false;
      return;
    }

    final value = await _storage.readBool(_enabledKey) ?? false;
    enabled.value = value;
  }

  Future<void> setEnabled(bool value) async {
    if (!isSupported) return;

    enabled.value = value;
    await _storage.writeBool(_enabledKey, value);
  }

  static StageDevicePreviewController? tryGet() {
    try {
      return getIt<StageDevicePreviewController>();
    } catch (_) {
      return null;
    }
  }
}
