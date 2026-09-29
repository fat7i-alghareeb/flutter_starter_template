import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/utils/result.dart';
import 'package:{{project_name}}/features/showcase_feed/domain/feed_entities.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/states/feed_bloc.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/ui/widgets/feed_body.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_controller.dart';
import 'package:{{project_name}}/features/root/presentation/ui/widgets/nav_bar/navigation_scope.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_app.dart';
import '../showcase_feed/feed_samples.dart';

/// Tapping the ACTIVE tab scrolls that tab's list to the top.
///
/// `setIndex` returning early on the active index would leave nothing to
/// tell a tab it had been tapped — `reselectToken` exists for exactly this.
/// The mechanism is shared, so it is proven once here: the controller bumps
/// the token, and a tab that sees a bump goes home.
void main() {
  group('NavigationController', () {
    test('tapping the ACTIVE tab bumps the reselect token, not the index', () {
      final controller = NavigationController();
      addTearDown(controller.dispose);

      var notified = 0;
      controller.addListener(() => notified++);

      final before = controller.reselectToken;
      controller.setIndex(controller.currentIndex);

      expect(controller.reselectToken, before + 1);
      expect(controller.currentIndex, 0);
      // The tab has to hear about it: the index did not change, so a listener
      // comparing indexes alone would see nothing at all.
      expect(notified, 1);
    });

    test('tapping ANOTHER tab moves, and leaves the token alone', () {
      final controller = NavigationController();
      addTearDown(controller.dispose);

      final before = controller.reselectToken;
      controller.setIndex(2);

      expect(controller.currentIndex, 2);
      expect(controller.reselectToken, before);
    });
  });

  group('a tab that sees the bump', () {
    late MockFeedRepository repository;

    setUp(() {
      repository = MockFeedRepository();
      when(
        () => repository.getFeed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          query: any(named: 'query'),
          category: any(named: 'category'),
        ),
      ).thenAnswer(
        (_) async => Result<FeedPage>.success(
          FeedPage(items: FeedSamples.items(20), hasMore: false, total: 20),
        ),
      );
      when(repository.getHighlights).thenAnswer(
        (_) async => Result<List<FeedItemEntity>>.success(FeedSamples.items(3)),
      );
      when(repository.getPicks).thenAnswer(
        (_) async => Result<List<FeedItemEntity>>.success(FeedSamples.items(4)),
      );
      when(repository.recentSearches).thenAnswer((_) async => <String>[]);
    });

    testWidgets('scrolls its list back to the top', (tester) async {
      final controller = NavigationController();
      addTearDown(controller.dispose);

      await pumpApp(
        tester,
        NavigationScope(
          controller: controller,
          child: Scaffold(
            body: BlocProvider<FeedBloc>(
              create: (_) =>
                  FeedBloc(repository)..add(const FeedEvent.started()),
              child: const FeedBody(),
            ),
          ),
        ),
        fullScreen: true,
        settle: false,
      );

      // The list's own — the search field in the header has one too.
      final scrollable = find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first;
      // Let the first page land, so there is something to scroll.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pump();
      expect(
        tester.widget<Scrollable>(scrollable).controller!.offset,
        greaterThan(0),
      );

      // The feed is the first tab: tapping it again is the reselect.
      controller.setIndex(0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.widget<Scrollable>(scrollable).controller!.offset, 0);

      // The rows animate in; a test that returns mid-entrance fails with a
      // pending timer on a perfectly good screen.
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
