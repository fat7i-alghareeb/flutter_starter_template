import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/ds.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/ui/widgets/feed_cards.dart';
import 'package:{{project_name}}/utils/constants/design_constants.dart';

import '../../../features/showcase_feed/feed_samples.dart';
import '../../../helpers/golden_helper.dart';

/// One image per design-system primitive, in both themes.
///
/// These are the reference for "what the system looks like". A diff here means
/// either a deliberate design change — regenerate — or an accident. The same
/// images illustrate the README (`docs/readme/`).
void main() {
  setUpAll(loadTestFonts);

  goldenTest(
    'badges',
    () => const Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        AppBadge.primary('Official'),
        AppBadge.urgent('Urgent'),
        AppBadge.subtle('Community'),
        AppBadge('Used'),
        AppBadge.positive('Found'),
        AppBadge.dashed('Sponsored'),
      ],
    ),
  );

  goldenTest(
    'chips',
    () => const Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        AppChip(label: 'All', count: '12', selected: true),
        AppChip(label: 'News', count: '7'),
        AppChip(label: 'Events', count: '5'),
      ],
    ),
  );

  goldenTest(
    'card',
    () => const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppBadge.urgent('Urgent'),
            SizedBox(height: AppSpacing.xs),
            Text('Water supply interrupted tomorrow from 8 am'),
            SizedBox(height: AppSpacing.xs),
            Text('Services team · 10 min ago'),
          ],
        ),
      ),
    ),
  );

  goldenTest(
    'feed_card',
    () => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.cardGap,
        children: <Widget>[
          FeedCard.success(item: FeedSamples.item()),
          const FeedCard.loading(),
        ],
      ),
    ),
  );

  goldenTest(
    'key_value_table',
    () => const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: AppKeyValueTable(
        title: 'Details',
        rows: <AppKeyValue>[
          AppKeyValue('Place', 'Next to the school street'),
          AppKeyValue('Date', '22 May 2026'),
          AppKeyValue('Mark', 'A blue key ring'),
        ],
      ),
    ),
  );

  goldenTest(
    'status_banners',
    () => const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.md,
        children: <Widget>[
          AppStatusBanner(
            message: 'Lost and found around the neighbourhood. Call the desk.',
          ),
          AppStatusBanner(
            message: 'This item is no longer shown',
            detail: 'Published on 22 May 2026',
            tone: AppBannerTone.muted,
          ),
        ],
      ),
    ),
  );

  // The large-font case is where spacing usually breaks first, and plenty of
  // people run their phones at a bigger system size.
  goldenTest(
    'card_large_font',
    () => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: FeedCard.success(item: FeedSamples.item()),
    ),
    textScale: 1.3,
    brightnesses: <Brightness>[Brightness.light],
  );
}
