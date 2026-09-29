import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/loading_dots.dart';
import 'package:{{project_name}}/core/theme/app_colors.dart';
import 'package:{{project_name}}/features/splash/presentation/ui/screens/splash_screen.dart';
import 'package:{{project_name}}/utils/constants/app_flow_constants.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/test_app.dart';

/// [pumpApp], then long enough for the entrance to finish — before that the
/// name, the tagline and the dots are still at opacity 0 and drop out of the
/// semantics tree.
Future<void> _pumpSplash(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  Size surfaceSize = TestDevices.reference,
  double textScale = 1,
}) async {
  await pumpApp(
    tester,
    const SplashScreen(),
    brightness: brightness,
    surfaceSize: surfaceSize,
    textScale: textScale,
    settle: false,
    fullScreen: true,
  );
  await tester.pump(SplashConfig.entrance);
}

void main() {
  group('SplashScreen', () {
    testWidgets('shows the name and the tagline — and no logo', (
      tester,
    ) async {
      await _pumpSplash(tester);

      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.appTagline), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows the three pulsing dots', (tester) async {
      await _pumpSplash(tester);
      expect(find.byType(LoadingDots), findsOneWidget);
    });

    testWidgets('announces that it is loading', (tester) async {
      // A screen that only shows a name tells a screen-reader user nothing.
      await _pumpSplash(tester);
      expect(find.bySemanticsLabel(AppStrings.appLoading), findsOneWidget);
    });

    testWidgets('draws on the native splash colour, so the hand-over is '
        'invisible', (tester) async {
      await _pumpSplash(tester);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      // flutter_native_splash.yaml `color:` — keep the two equal.
      expect(scaffold.backgroundColor, AppColors.backGroundLight);
    });

    testWidgets('renders on the narrowest screen without overflowing', (
      tester,
    ) async {
      await _pumpSplash(tester, surfaceSize: TestDevices.small);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at a 1.3x system font without overflowing', (
      tester,
    ) async {
      await _pumpSplash(tester, textScale: 1.3);
      expect(tester.takeException(), isNull);
    });

    forEachBrightness('renders in both themes', (tester, brightness) async {
      await _pumpSplash(tester, brightness: brightness);
      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('SplashConfig', () {
    test('the minimum is the entrance plus a hold, so the name is read', () {
      expect(
        SplashConfig.initialDelay,
        SplashConfig.entrance + SplashConfig.holdAfterEntrance,
      );
    });

    test('there is a hard ceiling so a stalled bootstrap cannot hang', () {
      // Without it a network stall during token refresh strands the user on
      // a screen that never ends.
      expect(SplashConfig.maxWait, greaterThan(SplashConfig.initialDelay));
      expect(SplashConfig.maxWait.inSeconds, lessThanOrEqualTo(10));
    });

    test('the timeout has a message for the user', () {
      expect(SplashConfig.timeoutMessage, isNotEmpty);
    });
  });
}
