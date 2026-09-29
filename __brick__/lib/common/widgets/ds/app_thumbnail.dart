import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/design_constants.dart';
import 'app_icons.dart';

/// A picture, or the tile that stands in for one — `DESIGN_SYSTEM.md`.
///
/// There is no stock photo and no substitute picture anywhere in this app: an
/// item with no image shows a `surfaceVariant` tile carrying its category icon
/// in `primary`. Borrowing the shop's logo for a product it does not have a
/// photo of would be a small lie told at scale.
///
/// The space is reserved before the picture loads, so nothing on the card moves
/// when it arrives.
class AppThumbnail extends StatelessWidget {
  const AppThumbnail({
    super.key,
    required this.imageUrl,
    this.iconKey,
    this.iconSize = AppIconSizes.emptyState,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.iconAlignment = Alignment.center,
  });

  final String? imageUrl;

  /// Resolved through [AppIcons.fromKey], which falls back to a grid glyph.
  final String? iconKey;

  final double iconSize;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit fit;
  final String? semanticLabel;

  /// Where the stand-in glyph sits. Centred, except where text is laid over
  /// the tile — the pinned banner lifts it clear of its title.
  final AlignmentGeometry iconAlignment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = imageUrl;

    Widget fallback() => ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Align(
        alignment: iconAlignment,
        child: AppIcon(
          AppIcons.fromKey(iconKey),
          size: iconSize,
          color: colors.primary,
        ),
      ),
    );

    Widget child;
    if (url == null || url.isEmpty) {
      child = fallback();
    } else {
      child = CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        // A grey field, not a spinner: the picture is decoration, and a
        // spinner inside a 70dp tile reads as an error.
        placeholder: (_, _) =>
            ColoredBox(color: colors.surfaceContainerHighest),
        errorWidget: (_, _, _) => fallback(),
        // The picture settles in — fades up while easing from 106% to 100%
        // — instead of the package's slow
        // 500ms cross-fade.
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        imageBuilder: (_, image) => _SettleIn(
          child: Image(
            image: image,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      );
    }

    if (semanticLabel != null) {
      child = Semantics(label: semanticLabel, image: true, child: child);
    } else {
      child = ExcludeSemantics(child: child);
    }

    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }
}

/// A picture arriving: opacity 0 → 1 while the scale eases 1.06 → 1.
class _SettleIn extends StatefulWidget {
  const _SettleIn({required this.child});

  final Widget child;

  @override
  State<_SettleIn> createState() => _SettleInState();
}

class _SettleInState extends State<_SettleIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settle.isAnimating || _settle.isCompleted) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _settle.value = 1;
    } else {
      _settle.forward();
    }
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settle,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_settle.value);
        return Opacity(
          opacity: t,
          child: Transform.scale(scale: 1.06 - 0.06 * t, child: child),
        );
      },
    );
  }
}
