import 'package:flutter/material.dart';

/// Layout and focus utilities for [BuildContext].
///
/// Example:
/// ```dart
/// final w = context.screenWidth;
/// final h = context.screenHeight;
/// if (context.isSmallHeight) { ... }
/// context.unfocus();
/// ```
extension AppContextExtensions on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  double get topPadding => mediaQuery.viewPadding.top;

  double get bottomPadding => mediaQuery.viewPadding.bottom;

  double get bottomInset => mediaQuery.viewInsets.bottom;

  bool get isSmallHeight => screenHeight < 650;

  bool get isTablet => screenSize.shortestSide >= 600;

  void unfocus() {
    final scope = FocusScope.of(this);
    if (scope.hasFocus) {
      scope.unfocus();
    }
  }

  /// 🚨 Aggressive unfocus
  /// Clears focus history and prevents restoration
  void unfocusHard() {
    FocusScope.of(this).requestFocus(FocusNode());
  }

  bool get hasFocus => FocusScope.of(this).hasFocus;

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  bool get isLtr => !isRtl;
}
