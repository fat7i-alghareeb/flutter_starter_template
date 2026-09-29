import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/common/widgets/ds/app_icons.dart';
import 'package:{{project_name}}/core/theme/app_theme.dart';
import 'package:{{project_name}}/core/utils/result.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/app_bottom_nav.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_scope.dart';
import 'package:{{project_name}}/features/showcase_feed/domain/feed_entities.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/states/feed_bloc.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/ui/widgets/feed_body.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/ui/widgets/feed_header.dart';
import 'package:{{project_name}}/utils/constants/design_constants.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/golden_helper.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_app.dart';
import 'feed_samples.dart';

/// The whole first tab — header, carousel, rail, list and the floating bar —
/// as a golden. These images are the README's screenshots (`docs/readme/`),
/// so the README never shows a screen the code no longer draws.
///
/// One `EasyLocalization` per FILE (`test/README.md`), so each language and
/// theme is its own small test file calling [feedScreenshot].
void feedScreenshot({required Locale locale, required Brightness brightness}) {
  setUpAll(() async {
    await initTestLocalization();
    await loadTestFonts();
    // «Good morning», whatever time the test runs at.
    FeedHeader.clock = () => DateTime(2026, 1, 1, 9);
  });
  tearDownAll(() => FeedHeader.clock = DateTime.now);

  final name = 'feed_screen.${locale.languageCode}.${brightness.name}';
  testWidgets(name, (tester) async {
    final repository = MockFeedRepository();
    final items = <FeedItemEntity>[
      FeedSamples.item(),
      FeedSamples.item(
        id: 'item_002',
        title: 'Open-air cinema returns to the park',
        rating: 4.8,
      ),
      FeedSamples.item(
        id: 'item_003',
        title: 'Why rounded corners feel friendlier',
        rating: 4.2,
      ),
      FeedSamples.item(
        id: 'item_004',
        title: 'A practical guide to offline-first apps',
      ),
    ];
    when(
      () => repository.getFeed(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        query: any(named: 'query'),
        category: any(named: 'category'),
      ),
    ).thenAnswer(
      (_) async => Result<FeedPage>.success(
        FeedPage(items: items, hasMore: false, total: items.length),
      ),
    );
    when(repository.getHighlights).thenAnswer(
      (_) async => Result<List<FeedItemEntity>>.success(items.take(3).toList()),
    );
    when(
      repository.getPicks,
    ).thenAnswer((_) async => Result<List<FeedItemEntity>>.success(items));
    when(
      repository.recentSearches,
    ).thenAnswer((_) async => <String>['garden', 'cinema']);

    final controller = NavigationController();
    addTearDown(controller.dispose);

    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = TestDevices.reference;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
        path: 'assets/l10n',
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        saveLocale: false,
        useOnlyLangCode: true,
        ignorePluralRules: false,
        child: Builder(
          builder: (context) => ScreenUtilInit(
            designSize: AppDesign.designSize,
            builder: (context, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
              localizationsDelegates: context.localizationDelegates,
              theme: brightness == Brightness.dark
                  ? AppTheme.dark
                  : AppTheme.light,
              // Still: a golden of a half-played entrance is a flaky golden.
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              ),
              home: NavigationScope(
                controller: controller,
                child: Scaffold(
                  extendBody: true,
                  bottomNavigationBar: Builder(
                    builder: (context) => AppBottomNav(
                      controller: controller,
                      destinations: <AppNavDestination>[
                        AppNavDestination(
                          icon: AppIcons.home,
                          label: AppStrings.navFeed,
                        ),
                        AppNavDestination(
                          icon: AppIcons.grid,
                          label: AppStrings.navButtons,
                        ),
                        AppNavDestination(
                          icon: AppIcons.edit,
                          label: AppStrings.navForms,
                        ),
                        AppNavDestination(
                          icon: AppIcons.comment,
                          label: AppStrings.navDialogs,
                        ),
                        AppNavDestination(
                          icon: AppIcons.bell,
                          label: AppStrings.navAlerts,
                        ),
                      ],
                    ),
                  ),
                  body: BlocProvider<FeedBloc>(
                    create: (_) =>
                        FeedBloc(repository)..add(const FeedEvent.started()),
                    child: const FeedBody(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );

    // Let every timer (the rotating hint, the entrance clocks) go.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  }, tags: <String>['golden']);
}
