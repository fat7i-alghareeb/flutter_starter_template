import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Global controller responsible for managing the current [ThemeMode].
///
/// It is registered as a [lazySingleton] via Injectable so the same
/// instance is reused across the app. Widgets can listen to this
/// controller to rebuild when the theme changes.
@lazySingleton
class ThemeController extends ChangeNotifier {
  ThemeController() : _themeMode = ThemeMode.system;

  ThemeMode _themeMode;

  /// Current theme mode used by the app.
  ThemeMode get themeMode => _themeMode;

  /// Whether the current theme mode resolves to dark.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Sets a new [ThemeMode] and notifies listeners if it changed.
  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
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
