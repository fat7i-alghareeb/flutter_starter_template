import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../utils/constants/app_flow_constants.dart';
import '../services/storage/storage_service.dart';
import 'native_night_mode.dart';

/// Global controller responsible for managing the current [ThemeMode].
///
/// It is registered as a [lazySingleton] via Injectable so the same
/// instance is reused across the app. Widgets can listen to this
/// controller to rebuild when the theme changes.
@lazySingleton
class ThemeController extends ChangeNotifier {
  /// Starts at [AppThemeConfig.defaultMode]. Only a value the user saved
  /// overrides it.
  ThemeController(this._storage) : _themeMode = AppThemeConfig.defaultMode;

  static const String _themeModeStorageKey = 'theme.mode';

  final StorageService _storage;

  ThemeMode _themeMode;

  /// Current theme mode used by the app.
  ThemeMode get themeMode => _themeMode;

  /// Whether the current theme mode resolves to dark.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Sets a new [ThemeMode] and notifies listeners if it changed.
  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _storage.writeString(_themeModeStorageKey, _serialize(mode));
    unawaited(NativeNightMode.sync(mode));
    notifyListeners();
  }

  Future<void> initialize() async {
    final saved = await _storage.readString(_themeModeStorageKey);
    final parsed = _deserialize(saved);

    if (saved == null || saved.isEmpty) {
      await _storage.writeString(_themeModeStorageKey, _serialize(_themeMode));
    } else if (parsed != null && parsed != _themeMode) {
      _themeMode = parsed;
      notifyListeners();
    }

    // Every launch, not only on change: the OS value is lost when the app's
    // data is cleared, and a first install has never been told at all.
    unawaited(NativeNightMode.sync(_themeMode));
  }

  static String _serialize(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };
  }

  static ThemeMode? _deserialize(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return null;
    }
  }

  /// Convenience method to toggle between [ThemeMode.light] and
  /// [ThemeMode.dark], leaving [ThemeMode.system] unchanged.
  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      // When in system mode, default toggle behavior is to go to dark.
      setThemeMode(ThemeMode.dark);
    }
  }
}
