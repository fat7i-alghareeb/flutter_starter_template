import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/root_tab_stack.dart';

import '../../helpers/test_app.dart';

/// **Every tab stays alive**, with their scroll position,
/// their filters and their loaded data intact — and the cross-fade between
/// them must not cost that.
///
/// The symptom of getting it wrong — a tab that quietly reloads and forgets
/// where the reader was — looks like a bloc bug, not a shell one, so these
/// tests pin it at the shell.
void main() {
  late NavigationController controller;

  setUp(() => controller = NavigationController());
  tearDown(() => controller.dispose());

  Widget shell() => RootTabStack(
    controller: controller,
    tabs: <WidgetBuilder>[
      for (var i = 0; i < 4; i++) (_) => _CountingTab(index: i),
    ],
  );

  testWidgets('a tab is built on its first visit and never again — H1', (
    tester,
  ) async {
    _CountingTabState.creations.clear();
    await pumpApp(tester, shell(), fullScreen: true);

    // Only the tab on screen exists at first: the others ask nothing of the
    // server until the reader opens them.
    expect(_CountingTabState.creations, <int>[0]);

    controller.setIndex(3);
    await tester.pumpAndSettle();
    controller.setIndex(0);
    await tester.pumpAndSettle();
    controller.setIndex(3);
    await tester.pumpAndSettle();

    expect(_CountingTabState.creations, <int>[0, 3]);
  });

  testWidgets('both tabs are on screen during the handover, one after it', (
    tester,
  ) async {
    await pumpApp(tester, shell(), fullScreen: true);

    controller.setIndex(1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    // Mid-fade: the tab being left is still painted, fading out.
    expect(find.byKey(const ValueKey<String>('tab-0')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('tab-1')), findsOneWidget);

    await tester.pumpAndSettle();

    // At rest only the active tab is on stage; the other is kept offstage.
    expect(find.byKey(const ValueKey<String>('tab-0')), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('tab-0'), skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('tab-1')), findsOneWidget);
  });

  testWidgets('a tap on the active tab switches nothing', (tester) async {
    _CountingTabState.creations.clear();
    await pumpApp(tester, shell(), fullScreen: true);

    final token = controller.reselectToken;
    controller.setIndex(0);
    await tester.pumpAndSettle();

    expect(controller.reselectToken, token + 1);
    expect(_CountingTabState.creations, <int>[0]);
  });
}

/// Records which tabs get created, which is what "kept alive" means here.
class _CountingTab extends StatefulWidget {
  const _CountingTab({required this.index});

  final int index;

  @override
  State<_CountingTab> createState() => _CountingTabState();
}

class _CountingTabState extends State<_CountingTab> {
  /// The index of every tab created since the list was last cleared.
  static final List<int> creations = <int>[];

  @override
  void initState() {
    super.initState();
    creations.add(widget.index);
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox.expand(key: ValueKey<String>('tab-${widget.index}'));
}
