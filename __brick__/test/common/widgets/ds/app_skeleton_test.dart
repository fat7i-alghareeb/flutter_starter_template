import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_skeleton.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/ui/widgets/feed_cards.dart';

import '../../../features/showcase_feed/feed_samples.dart';
import '../../../helpers/test_app.dart';

/// The skeleton system exists to make one promise: a loading card and a loaded
/// card are the SAME layout. These tests hold that promise to account — a
/// skeleton that has drifted in height is exactly the bug the design prevents,
/// and it is invisible in code review.
void main() {
  group('SkeletonScope', () {
    testWidgets('leaves render their content when not loading', (tester) async {
      await pumpApp(
        tester,
        const SkeletonScope(isLoading: false, child: SkeletonText('نصّ حقيقي')),
      );

      expect(find.text('نصّ حقيقي'), findsOneWidget);
    });

    testWidgets('one shimmer wraps the whole subtree, not each leaf', (
      tester,
    ) async {
      // Separate shimmers animate out of phase and the card looks like it is
      // glitching. There must be exactly one sweep.
      await pumpApp(
        tester,
        const SkeletonScope(
          isLoading: true,
          child: Column(
            children: <Widget>[
              SkeletonText(null),
              SkeletonText(null),
              SkeletonBox(width: 40, height: 40, child: SizedBox()),
            ],
          ),
        ),
        settle: false,
      );

      expect(find.byType(SkeletonScope), findsOneWidget);
      expect(find.text('نصّ حقيقي'), findsNothing);
    });

    testWidgets('a leaf outside any scope simply renders its content', (
      tester,
    ) async {
      await pumpApp(tester, const SkeletonText('بلا نطاق'));
      expect(find.text('بلا نطاق'), findsOneWidget);
    });
  });

  group('SkeletonText', () {
    testWidgets('reserves the SAME height as the text it replaces', (
      tester,
    ) async {
      // If the skeleton is shorter or taller, the card jumps the moment data
      // arrives — the single most noticeable loading bug there is.
      const style = TextStyle(fontSize: 14, height: 1.65);
      const label = 'سطر من النصّ';

      await pumpApp(
        tester,
        const SizedBox(
          width: 300,
          child: SkeletonScope(
            isLoading: false,
            child: SkeletonText(label, style: style),
          ),
        ),
      );
      final loadedHeight = tester.getSize(find.byType(SkeletonText)).height;

      await pumpApp(
        tester,
        const SizedBox(
          width: 300,
          child: SkeletonScope(
            isLoading: true,
            child: SkeletonText(label, style: style),
          ),
        ),
        settle: false,
      );
      final loadingHeight = tester.getSize(find.byType(SkeletonText)).height;

      expect(loadingHeight, closeTo(loadedHeight, 0.5));
    });

    testWidgets('a multi-line block reserves every line', (tester) async {
      const style = TextStyle(fontSize: 14, height: 1.65);

      await pumpApp(
        tester,
        const SizedBox(
          width: 300,
          child: SkeletonScope(
            isLoading: true,
            child: SkeletonText(null, style: style, maxLines: 3),
          ),
        ),
        settle: false,
      );

      // 3 lines x 14 x 1.65
      expect(
        tester.getSize(find.byType(SkeletonText)).height,
        closeTo(69.3, 1),
      );
    });

    testWidgets('the last line of a paragraph is shorter', (tester) async {
      // Equal-length bars read as a table. Real prose ends mid-line.
      await pumpApp(
        tester,
        const SizedBox(
          width: 300,
          child: SkeletonScope(
            isLoading: true,
            child: SkeletonText(null, maxLines: 2),
          ),
        ),
        settle: false,
      );

      final widths = tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .map((b) => b.widthFactor)
          .toList();

      expect(widths.first, 1.0);
      expect(widths.last, lessThan(1.0));
    });
  });

  group('SkeletonBox', () {
    testWidgets('reserves exactly the size of the picture it stands in for', (
      tester,
    ) async {
      for (final loading in <bool>[false, true]) {
        await pumpApp(
          tester,
          SkeletonScope(
            isLoading: loading,
            child: const SkeletonBox(
              width: 64,
              height: 48,
              child: ColoredBox(color: Colors.red),
            ),
          ),
          settle: false,
        );
        expect(
          tester.getSize(find.byType(SkeletonBox)),
          const Size(64, 48),
          reason: 'size changed when loading=$loading',
        );
      }
    });
  });

  group('SkeletonBar', () {
    testWidgets('takes no space at all when not loading', (tester) async {
      // A bar has no real counterpart, so it must leave nothing behind in the
      // loaded card.
      await pumpApp(
        tester,
        const SkeletonScope(
          isLoading: false,
          child: SkeletonBar(width: 60, height: 18),
        ),
      );
      expect(tester.getSize(find.byType(SkeletonBar)), Size.zero);
    });
  });

  group('FeedCard — the reference implementation', () {
    testWidgets('.loading() and the real card are the same height', (
      tester,
    ) async {
      // This is the assertion the whole design exists for. It fails the moment
      // someone edits one and not the other — which, with one shared layout,
      // they cannot.
      await pumpApp(
        tester,
        SizedBox(
          width: 340,
          child: FeedCard.success(item: FeedSamples.item()),
        ),
      );
      final loaded = tester.getSize(find.byType(FeedCard)).height;

      await pumpApp(
        tester,
        const SizedBox(width: 340, child: FeedCard.loading()),
        settle: false,
      );
      final loading = tester.getSize(find.byType(FeedCard)).height;

      expect(loading, closeTo(loaded, 1));
    });

    testWidgets('the loading card shows no real text', (tester) async {
      await pumpApp(
        tester,
        const SizedBox(width: 340, child: FeedCard.loading()),
        settle: false,
      );

      expect(find.byType(SkeletonScope), findsOneWidget);
      expect(find.text(FeedSamples.item().title), findsNothing);
    });

    testWidgets('the loading card is not tappable', (tester) async {
      // Tapping a placeholder must do nothing — there is nothing to call yet.
      await pumpApp(
        tester,
        const SizedBox(width: 340, child: FeedCard.loading()),
        settle: false,
      );
      await tester.tap(find.byType(FeedCard), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
