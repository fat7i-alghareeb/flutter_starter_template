import 'package:flutter/widgets.dart';

import '../../../utils/constants/design_constants.dart';
import '../scroll_reveal.dart';
import 'app_motion.dart';

/// A horizontally scrolling rail of cards.
///
/// A `Row` inside a horizontal scroll view rather than a `ListView`: a list
/// must be told its height, and a height computed from font metrics is wrong
/// the day a title wraps or the system font grows. A `Row` is as tall as its
/// tallest card, whatever the card contains. Keep rails short (≤ 10 cards,
/// ending in «See all»), so nothing is lost by building them all.
///
/// The first card lines up with the screen margin, and the rail runs from the
/// start edge, so it flips with the language on its own.
class AppRail extends StatelessWidget {
  const AppRail({
    super.key,
    required this.children,
    this.spacing = AppSpacing.md,
    this.revealItems = true,
    this.nudgeId,
  });

  final List<Widget> children;
  final double spacing;

  /// Each card rises in after the one before it as the rail enters.
  /// False when the whole rail already sits inside a [ScrollReveal] — never
  /// nest one inside another.
  final bool revealItems;

  /// Set on the first rail of a page: it slides once per app run to show it
  /// scrolls sideways ([AppRailNudge]).
  final String? nudgeId;

  @override
  Widget build(BuildContext context) {
    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: spacing),
          if (revealItems)
            ScrollReveal(
              key: children[i].key == null
                  ? null
                  : ScrollRevealKey(children[i].key!),
              child: children[i],
            )
          else
            children[i],
        ],
      ],
    );
    if (nudgeId != null) row = AppRailNudge(id: nudgeId!, child: row);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Cards and chips cast shadows past the rail's own height; clipped,
      // they would be cut flat along the top and bottom.
      clipBehavior: Clip.none,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.screenMargin,
      ),
      child: row,
    );
  }
}
