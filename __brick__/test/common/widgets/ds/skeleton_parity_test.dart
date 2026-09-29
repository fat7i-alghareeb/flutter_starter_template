import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_peek_carousel.dart';
import 'package:{{project_name}}/features/showcase_feed/domain/feed_entities.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/ui/widgets/feed_cards.dart';

import '../../../features/showcase_feed/feed_samples.dart';
import '../../../helpers/test_app.dart';

/// Height parity: every widget with a `.loading()` takes the SAME room as
/// the real thing, so nothing jumps when the data lands.
///
/// Mandatory for every `SkeletonWidget` (`DESIGN_SYSTEM.md` → Skeletons).
/// Add a line here with each new one — this file is the one answer to
/// "which widgets are checked".
///
/// **Centred, never `fullScreen`.** A screen is handed the whole surface, so
/// both constructors would measure the viewport and the assertion would
/// compare it to itself.
void main() {
  Future<void> expectSameHeight(
    WidgetTester tester, {
    required Widget loaded,
    required Widget loading,
    required Type type,
    double tolerance = 1,
  }) async {
    await pumpApp(tester, loaded, settle: false);
    final loadedHeight = tester.getSize(find.byType(type)).height;

    await pumpApp(tester, loading, settle: false);
    final loadingHeight = tester.getSize(find.byType(type)).height;

    expect(
      loadingHeight,
      closeTo(loadedHeight, tolerance),
      reason: '$type: loading $loadingHeight vs loaded $loadedHeight',
    );
  }

  testWidgets('FeedCard', (tester) async {
    await expectSameHeight(
      tester,
      loaded: SizedBox(
        width: 358,
        child: FeedCard.success(item: FeedSamples.item()),
      ),
      loading: const SizedBox(width: 358, child: FeedCard.loading()),
      type: FeedCard,
    );
  });

  testWidgets('FeedPickCard', (tester) async {
    await expectSameHeight(
      tester,
      loaded: FeedPickCard.success(item: FeedSamples.item()),
      loading: const FeedPickCard.loading(),
      type: FeedPickCard,
    );
  });

  testWidgets('AppPeekCarousel', (tester) async {
    await expectSameHeight(
      tester,
      loaded: SizedBox(
        width: 390,
        child: AppPeekCarousel<FeedItemEntity>(
          items: FeedSamples.items(3),
          itemBuilder: (context, item, isActive) =>
              FeedHighlightSlide(item: item, isActive: isActive),
        ),
      ),
      loading: const SizedBox(
        width: 390,
        child: AppPeekCarousel<FeedItemEntity>.loading(),
      ),
      type: AppPeekCarousel<FeedItemEntity>,
    );
  });
}
