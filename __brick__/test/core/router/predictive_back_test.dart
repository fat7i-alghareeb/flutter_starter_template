import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:{{project_name}}/core/router/app_navigator.dart';
import 'package:{{project_name}}/core/router/router_config.dart';
import 'package:{{project_name}}/core/theme/app_theme.dart';

/// Android's predictive back — the back gesture previews the page
/// underneath.
///
/// It had none, on a current Flutter, because of two choices of the app's
/// own: every route was a `CustomTransitionPage` (which ignores the theme)
/// and the theme gave Android a custom builder. Either one alone switches
/// the preview off, so both are pinned here.
void main() {
  test('the theme gives Android the predictive back builder', () {
    for (final theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
      expect(
        theme.pageTransitionsTheme.builders[TargetPlatform.android],
        isA<PredictiveBackPageTransitionsBuilder>(),
      );
    }
  });

  testWidgets('every page in the tree is a MaterialPage, so it takes the '
      "theme's transition", (tester) async {
    late BuildContext shellContext;
    final pages = <Page<Object?>>[];

    final router = GoRouter(
      initialLocation: '/root',
      routes: <RouteBase>[
        AppRouteTree.build(
          shell: (_) => Builder(
            builder: (context) {
              shellContext = context;
              return const Text('shell');
            },
          ),
          builder: (page, _, _) => Builder(
            builder: (context) {
              final settings = ModalRoute.of(context)!.settings;
              if (settings is Page<Object?>) pages.add(settings);
              return Text(page.name);
            },
          ),
        ).route,
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    for (final page in <AppPage>[AppPage.settings, AppPage.feedItem]) {
      AppNavigator.push<void>(
        shellContext,
        page,
        params: const <String, String>{'id': 'x'},
      );
      await tester.pumpAndSettle();
    }

    expect(pages, isNotEmpty);
    expect(pages, everyElement(isA<MaterialPage<Object?>>()));
  });
}
