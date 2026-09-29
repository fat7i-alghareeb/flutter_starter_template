import 'package:flutter/material.dart';

import '../../../utils/constants/design_constants.dart';
import 'app_icons.dart';
import 'app_thumbnail.dart';

/// How an item is pictured when it has sent no cover picture.
///
/// Many items never get a cover, while card layouts assume one exists. The
/// answer is a **generated** cover, never a stock photograph: a cheerful
/// stock scene under an item that has none is a small lie, told once per
/// card.

/// A cover drawn from the category rather than photographed.
///
/// The gradient is derived from [categoryId], so every bakery carries the
/// same one and the colour becomes a marker for the category instead of
/// noise. All three palettes are pairs from `colorScheme`, so they follow the
/// theme into dark without a second definition.
///
/// It carries no information a reader could need, so it is kept out of the
/// accessibility tree entirely.
class AppCoverFallback extends StatelessWidget {
  const AppCoverFallback({
    super.key,
    required this.categoryId,
    this.iconKey,
    this.iconSize = 64,
  });

  final String categoryId;

  /// Resolved through [AppIcons.fromKey], which falls back rather than
  /// leaving a hole.
  final String? iconKey;

  final double iconSize;

  /// The share of the cover the glyph takes. Faint enough to stay a texture:
  /// a solid icon would read as the shop's own logo.
  static const double _iconOpacity = 0.12;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final palette = switch (categoryId.hashCode.abs() % 3) {
      0 => <Color>[colors.tertiary, colors.primary],
      1 => <Color>[colors.primaryContainer, colors.secondary],
      _ => <Color>[colors.secondary, colors.primary],
    };

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Directional, so the diagonal runs with the reading direction.
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: palette,
          ),
        ),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
            child: Opacity(
              opacity: _iconOpacity,
              child: AppIcon(
                AppIcons.fromKey(iconKey),
                size: iconSize,
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The cover itself: the photograph when there is one, the generated fallback
/// when there is not.
class AppCover extends StatelessWidget {
  const AppCover({
    super.key,
    required this.imageUrl,
    required this.categoryId,
    this.iconKey,
    this.iconSize = 64,
    this.borderRadius,
  });

  final String? imageUrl;
  final String categoryId;
  final String? iconKey;
  final double iconSize;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final Widget child = url == null || url.isEmpty
        ? AppCoverFallback(
            categoryId: categoryId,
            iconKey: iconKey,
            iconSize: iconSize,
          )
        : AppThumbnail(imageUrl: url, iconKey: iconKey, iconSize: iconSize);

    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }
}

/// A logo on a ground of its own.
///
/// Two shapes, for two places. In a compact row the logo is a **square on
/// white with a hairline border**: a transparent or pale logo disappears
/// against `surfaceVariant`, and a white ground makes it read like a shop
/// sign. In the page header it is a **circle inside a `surface` ring**, where
/// the ring plays exactly the same part at 72dp and a circle suits the
/// centring.
///
/// The border sits on the LOGO, never on the card: the card already carries
/// the system's one shadow, and the two may not meet on one element
class AppLogoTile extends StatelessWidget {
  const AppLogoTile({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
  }) : _isCircle = false,
       ringWidth = 0;

  /// The header shape: a circle inside a [ringWidth] ring of `surface`.
  const AppLogoTile.circle({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 72,
    this.ringWidth = 3,
  }) : _isCircle = true;

  final String name;
  final String? imageUrl;
  final double size;
  final double ringWidth;
  final bool _isCircle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final url = imageUrl;

    // The first letter of the name — never an icon standing in for a shop,
    // which would make every logo-less shop look like the same shop.
    final trimmed = name.trim();
    final Widget content = url == null || url.isEmpty
        ? ColoredBox(
            color: colors.primaryContainer,
            child: Center(
              child: Text(
                trimmed.isEmpty ? '' : trimmed.characters.first,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontSize: size * 0.42,
                  height: 1,
                ),
              ),
            ),
          )
        : AppThumbnail(
            imageUrl: url,
            iconKey: 'store',
            iconSize: size * 0.4,
          );

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: _isCircle
            ? BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: ringWidth),
              )
            : BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: colors.outline),
              ),
        child: content,
      ),
    );
  }
}
