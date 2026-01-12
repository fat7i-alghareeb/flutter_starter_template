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
  EdgeInsets get paddingOf => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsetsOf => MediaQuery.viewInsetsOf(this);

  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  double get topPadding => paddingOf.top;

  double get bottomPadding => paddingOf.bottom;

  double get bottomInset => viewInsetsOf.bottom;

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
