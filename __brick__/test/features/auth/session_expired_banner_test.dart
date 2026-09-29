import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_bar_action.dart';
import 'package:{{project_name}}/core/services/session/auth_state_notifier.dart';
import 'package:{{project_name}}/features/auth/presentation/ui/widgets/session_expired_banner.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/test_app.dart';

/// In guest-first mode an expired session is a banner over the app, not a
/// screen — and above all it must not cost the user the screen they were
/// on.
void main() {
  late AuthStateNotifier session;
  late int signIns;

  setUp(() {
    session = AuthStateNotifier();
    signIns = 0;
  });

  /// The host exactly as `App` uses it: around a whole `Navigator`, with a
  /// page pushed on it that keeps state of its own.
  Widget app() => SessionBannerHost(
    session: session,
    onSignIn: () => signIns++,
    child: Navigator(
      onGenerateRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => const _Counter()),
    ),
  );

  testWidgets('no banner while the session is fine', (tester) async {
    await pumpApp(tester, app(), fullScreen: true);
    expect(find.text(AppStrings.authSessionExpired), findsNothing);
  });

  testWidgets('appearing and going never rebuilds the app under it', (
    tester,
  ) async {
    await pumpApp(tester, app(), fullScreen: true);
    await tester.tap(find.byType(_Counter));
    await tester.tap(find.byType(_Counter));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    session.setSessionExpired(true);
    await tester.pump();
    expect(find.text(AppStrings.authSessionExpired), findsOneWidget);
    expect(
      find.text('2'),
      findsOneWidget,
      reason: 'a banner that re-parents the Navigator throws every open '
          'screen away',
    );

    session.setSessionExpired(false);
    await tester.pump();
    expect(find.text(AppStrings.authSessionExpired), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('«تسجيل الدخول» puts it away and opens sign-in', (tester) async {
    session.setSessionExpired(true);
    await pumpApp(tester, app(), fullScreen: true);

    await tester.tap(find.text(AppStrings.authSignIn));
    await tester.pump();

    expect(signIns, 1);
    expect(session.sessionExpired, isFalse);
    expect(find.text(AppStrings.authSessionExpired), findsNothing);
  });

  testWidgets('✕ puts it away', (tester) async {
    session.setSessionExpired(true);
    await pumpApp(tester, app(), fullScreen: true);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is AppBarAction && widget.label == AppStrings.actionClose,
      ),
    );
    await tester.pump();

    expect(session.sessionExpired, isFalse);
    expect(signIns, 0);
  });

  forEachBrightness('fits 320dp at 1.3×', (tester, brightness) async {
    session.setSessionExpired(true);
    await pumpApp(
      tester,
      app(),
      fullScreen: true,
      brightness: brightness,
      surfaceSize: TestDevices.small,
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.authSessionExpired), findsOneWidget);
  });
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _taps++),
    child: ColoredBox(
      color: Colors.transparent,
      child: SizedBox.expand(child: Center(child: Text('$_taps'))),
    ),
  );
}
