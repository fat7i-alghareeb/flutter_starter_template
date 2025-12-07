import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../utils/constants/app_flow_constants.dart';
import '../../../utils/helpers/colored_print.dart';
import '../storage/storage_service.dart';

/// * OnboardingService
///
/// Persists whether the user has completed onboarding and exposes a
/// simple async API that can be used from anywhere via DI.
@lazySingleton
class OnboardingService extends ChangeNotifier {
  OnboardingService(this._storage);

  final StorageService _storage;

  bool? _finishedCache;

  /// * Returns true when onboarding was completed at least once.
  Future<bool> isOnboardingFinished() async {
    if (_finishedCache != null) return _finishedCache!;

    final flag = await _storage.readBool(
      OnboardingStorageKeys.finished,
      area: StorageArea.persistent,
    );

    _finishedCache = flag ?? false;
    printC('[OnboardingService] isOnboardingFinished => $_finishedCache');
    return _finishedCache!;
  }

  /// * Marks onboarding as finished and notifies listeners so routers
  ///   and widgets can react.
  Future<void> setOnboardingFinished() async {
    await _storage.writeBool(
      OnboardingStorageKeys.finished,
      true,
      area: StorageArea.persistent,
    );

    _finishedCache = true;
    printG('[OnboardingService] setOnboardingFinished => true');
    notifyListeners();
  }
}
