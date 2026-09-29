import 'package:flutter/material.dart';

import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/helpers/app_formats.dart';
import '../../../../../utils/helpers/app_strings.dart';
import '../../../domain/feed_entities.dart';
import 'feed_navigation.dart';

/// Hero tags of the feed, in one place: a tag typed twice by hand is how two
/// heroes end up flying to the same page.
class FeedHeroTags {
  FeedHeroTags._();

  static String image(String id) => 'feed-image-$id';
}

/// A row of the feed list.
///
/// ```text
/// ┌──────────────────────────────────┐
/// │ ┌──────┐ [Design]                │
/// │ │ img  │ Title on up to two      │
/// │ │ 84²  │ lines                   │
/// │ └──────┘ Author · 2h ago         │
/// │          One line of subtitle…   │
/// └──────────────────────────────────┘
/// ```
///
/// One layout, two constructors: `.loading()` swaps the leaves and nothing
/// else, so a line added here grows the skeleton with it — and the
/// height-parity test (`test/features/showcase_feed/`) keeps it that way.
class FeedCard extends SkeletonWidget {
  const FeedCard.success({super.key, required FeedItemEntity this.item})
    : super.success();

  const FeedCard.loading({super.key}) : item = null, super.loading();

  final FeedItemEntity? item;

  static const double thumbnail = 84;

  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final data = item;

    return AppCard(
      onTap: data == null ? null : () => FeedNavigation.openItem(context, data.id),
      semanticLabel: data == null
          ? null
          : <String>[
              data.categoryName,
              data.title,
              data.author,
              AppFormats.relativeTime(context, data.publishedAt),
            ].join(AppStrings.a11ySeparator),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SkeletonBox(
            width: thumbnail,
            height: thumbnail,
            child: data == null
                ? const SizedBox.shrink()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    // A gentle drift while the list moves.
                    child: AppParallax(
                      factor: 0.25,
                      overscan: 0.18,
                      child: Hero(
                        tag: FeedHeroTags.image(data.id),
                        child: AppThumbnail(
                          imageUrl: data.imageUrl,
                          iconKey: data.category,
                          iconSize: 26,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (data == null)
                  const AppBadge.skeleton()
                else
                  AppBadge(data.categoryName),
                const SizedBox(height: AppSpacing.xs),
                SkeletonText(
                  data?.title,
                  style: theme.textTheme.titleSmall,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xxs),
                SkeletonText(
                  data == null
                      ? null
                      : AppFormats.line(<String>[
                          data.author,
                          AppFormats.relativeTime(context, data.publishedAt),
                        ]),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  loadingWidthFactor: 0.6,
                ),
                SkeletonText(
                  data?.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A card of the «Picks» rail: picture on top, title and rating under it.
class FeedPickCard extends SkeletonWidget {
  const FeedPickCard.success({super.key, required FeedItemEntity this.item})
    : super.success();

  const FeedPickCard.loading({super.key}) : item = null, super.loading();

  final FeedItemEntity? item;

  static const double width = 156;

  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final data = item;

    return SizedBox(
      width: width,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: data == null
            ? null
            : () => FeedNavigation.openItem(context, data.id),
        semanticLabel: data?.title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SkeletonBox(
              width: width,
              height: width * 0.72,
              radius: 0,
              child: data == null
                  ? const SizedBox.shrink()
                  : AppThumbnail(
                      imageUrl: data.imageUrl,
                      iconKey: data.category,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SkeletonText(
                    data?.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: <Widget>[
                      SkeletonBox(
                        width: 14,
                        height: 14,
                        radius: AppRadii.full,
                        child: AppIcon(
                          AppIcons.star,
                          size: 14,
                          color: colors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: SkeletonText(
                          data?.rating == null
                              ? '—'
                              : AppFormats.number(context, data!.rating!),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          loadingWidthFactor: 0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A slide of the highlights carousel: the picture with the title over a
/// dark scrim, and a slow zoom while it is the one on screen.
class FeedHighlightSlide extends StatelessWidget {
  const FeedHighlightSlide({
    super.key,
    required this.item,
    required this.isActive,
  });

  final FeedItemEntity item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;

    return GestureDetector(
      onTap: () => FeedNavigation.openItem(context, item.id),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x2A101217),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              AppKenBurns(
                active: isActive,
                child: AppThumbnail(
                  imageUrl: item.imageUrl,
                  iconKey: item.category,
                  iconSize: 40,
                  iconAlignment: const Alignment(0, -0.4),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      semantic.photoScrim.withValues(alpha: 0),
                      semantic.photoScrim,
                    ],
                    stops: const <double>[0.35, 1],
                  ),
                ),
              ),
              PositionedDirectional(
                start: AppSpacing.lg,
                end: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // A one-shot glint the first time the badge is shown.
                    AppGlint(
                      child: AppBadge.urgent(AppStrings.feedHighlightBadge),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: semantic.onPhoto,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      AppFormats.relativeTime(context, item.publishedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: semantic.onPhotoMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ??
      AppSemanticColors.light;
}
