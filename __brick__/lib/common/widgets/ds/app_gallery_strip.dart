import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../utils/constants/design_constants.dart';
import '../../../utils/helpers/app_formats.dart';
import '../app_gallery_screen.dart';
import 'app_thumbnail.dart';

/// A row of square picture tiles that opens the gallery viewer.
///
/// [tiles] are shown; the last carries «+N» over a dark layer when there are
/// more.
class AppGalleryStrip extends StatelessWidget {
  const AppGalleryStrip({
    super.key,
    required this.urls,
    required this.tiles,
    this.tileExtent,
  });

  final List<String> urls;
  final int tiles;

  /// A fixed square for every tile, e.g. `84`. Null shares the width out
  /// between the tiles — with only two pictures they grow large.
  final double? tileExtent;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();

    final shown = urls.take(tiles).toList();
    final extra = urls.length - shown.length;

    return Row(
      children: <Widget>[
        for (var i = 0; i < shown.length; i++) ...<Widget>[
          if (i > 0)
            SizedBox(
              width: tileExtent == null ? AppSpacing.xs2 : AppSpacing.sm,
            ),
          if (tileExtent == null)
            Expanded(child: _tile(context, shown, i, extra))
          else
            SizedBox.square(
              dimension: tileExtent,
              child: _tile(context, shown, i, extra),
            ),
        ],
      ],
    );
  }

  Widget _tile(BuildContext context, List<String> shown, int i, int extra) =>
      _GalleryTile(
        url: shown[i],
        extra: i == shown.length - 1 ? extra : 0,
        onTap: () => _openViewer(context, i),
      );

  void _openViewer(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AppGalleryScreen(urls: urls, initialIndex: index),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.url,
    required this.extra,
    required this.onTap,
  });

  final String url;
  final int extra;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                AppThumbnail(imageUrl: url, iconKey: 'image', iconSize: 20),
                if (extra > 0)
                  ColoredBox(
                    color: semantic.photoScrim.withValues(alpha: 0.55),
                    child: Center(
                      child: Text(
                        '+${AppFormats.number(context, extra)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: semantic.onPhoto,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
