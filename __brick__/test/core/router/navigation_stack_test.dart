import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:{{project_name}}/core/router/router_config.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/ui/widgets/feed_navigation.dart';

/// ONE stack, and a path that grows with it.
///
/// Every page is pushed as a child of the page it was opened from, so the
/// path reads the way the user walked — `/root/items/a/items/b` — and back
/// pops one page and one segment. A «related» rail that REPLACED the page it
/// sat on would lose the walk; one that pushed at the top of the tree would
/// keep the stack but leave the path one page long.
///
/// The real route tree, with a plain page standing in for each screen:
/// what is under test is the stack and the paths, not the screens.
void main() {
  late GoRouter router;
  late BuildContext pageContext;

  Widget page(GoRouterState state) => Builder(
    builder: (context) {
      pageContext = context;
      return Text(state.uri.path);
    },
  );

  Future<void> pumpRouter(WidgetTester tester) async {
    router = GoRouter(
      initialLocation: '/root',
      routes: <RouteBase>[
        AppRouteTree.build(
          shell: (_) => Builder(
            builder: (context) {
              pageContext = context;
              return const Text('/root');
            },
          ),
          builder: (_, state, _) => page(state),
        ).route,
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  /// Walks [steps] forward, checking the path after each, then back.
  Future<void> expectWalk(
    WidgetTester tester,
    List<(void Function(BuildContext context), String path)> steps,
  ) async {
    await pumpRouter(tester);

    for (final (open, path) in steps) {
      open(pageContext);
      await tester.pumpAndSettle();
      expect(find.text(path), findsOneWidget);
    }

    for (final (_, path) in steps.reversed.skip(1)) {
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text(path), findsOneWidget);
    }
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('/root'), findsOneWidget);
  }

  testWidgets('related items nest — «More like this»', (tester) async {
    await expectWalk(tester, <(void Function(BuildContext), String)>[
      ((c) => FeedNavigation.openItem(c, 'a'), '/root/items/a'),
      ((c) => FeedNavigation.openItem(c, 'b'), '/root/items/a/items/b'),
      (
        (c) => FeedNavigation.openItem(c, 'c'),
        '/root/items/a/items/b/items/c',
      ),
    ]);
  });

  testWidgets('a page its parent does not open starts again under the '
      'shell — still pushed, still popped', (tester) async {
    // An item has no settings child in the graph.
    await expectWalk(tester, <(void Function(BuildContext), String)>[
      ((c) => FeedNavigation.openItem(c, 'i'), '/root/items/i'),
      ((c) => FeedNavigation.openSettings(c), '/root/settings'),
    ]);
  });

  testWidgets('past the tree\'s depth the path restarts, the stack does not', (
    tester,
  ) async {
    await pumpRouter(tester);
    final ids = <String>[
      for (var i = 0; i <= AppRouteTree.maxDepth; i++) 'n$i',
    ];
    for (final id in ids) {
      FeedNavigation.openItem(pageContext, id);
      await tester.pumpAndSettle();
    }

    // The last one did not fit: it opened under the shell.
    expect(find.text('/root/items/${ids.last}'), findsOneWidget);

    // And back still walks every page in reverse.
    router.pop();
    await tester.pumpAndSettle();
    final deepest = ids
        .take(AppRouteTree.maxDepth)
        .map((id) => 'items/$id')
        .join('/');
    expect(find.text('/root/$deepest'), findsOneWidget);
  });

  test('every parent owns its children, under names of their own', () {
    final root = AppRouteTree.build();
    final names = <String>{};
    var count = 0;

    void walk(AppRouteNode node) {
      count++;
      expect(names.add(node.name), isTrue, reason: 'duplicate ${node.name}');
      for (final child in node.children.values) {
        expect(child.depth, node.depth + 1);
        walk(child);
      }
    }

    walk(root);

    // An item opened from an item is its own route, not the shell's.
    final nested = root.children[AppPage.feedItem]!.children[AppPage.feedItem]!;
    expect(nested.name, 'RootScreen.feedItem.feedItem');
    expect(nested.segment, 'items/:id2');
    expect(root.children[AppPage.feedItem]!.name, 'RootScreen.feedItem');

    // Sign-in hangs under every page.
    expect(nested.children, contains(AppPage.login));

    // Big enough to cover real walks, small enough to build at start-up.
    expect(count, lessThan(2500));
  });
}
