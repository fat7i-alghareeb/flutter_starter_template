import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../utils/constants/design_constants.dart';
import 'onboarding_slide.dart';

/// Where a tile sits in the collage, and how far it leans.
///
/// Positions are fractions of the collage, never dp, so the scatter holds on
/// a 320dp phone and on a tablet alike. Neighbouring slots belong to
/// different slides, so every slide lights up tiles spread over the whole
/// area instead of one clump.
@immutable
class _Slot {
  const _Slot(this.x, this.y, this.degrees);

  final double x;
  final double y;
  final double degrees;
}

/// The top half of onboarding: a loose collage of the words every slide
/// covers.
///
/// Each slide lights up its own tiles (full colour, a little larger) and dims
/// the rest to a grey 35%, so the reader sees the whole app at once and
/// which part the slide is talking about. The tiles are the slides' support
/// words, so nothing here is invented copy.
///
/// Tiles enter once, staggered, when the screen opens. Nothing loops: a
/// first-launch screen that never settles is a battery cost and a test that
/// never settles.
class OnboardingCollage extends StatefulWidget {
  const OnboardingCollage({
    super.key,
    required this.slides,
    required this.index,
  });

  final List<OnboardingSlideData> slides;

  /// The slide showing now — its tiles are the lit ones.
  final int index;

  /// Eight slots: enough for three slides of up to three words each.
  static const List<_Slot> _slots = <_Slot>[
    // Two staggered columns, start and end, so no two tiles touch.
    _Slot(-0.8, -0.92, -3),
    _Slot(0.75, -0.7, 4),
    _Slot(0.72, -0.2, 3),
    _Slot(-0.78, -0.02, -2),
    _Slot(0.78, 0.34, -3),
    _Slot(-0.72, 0.52, 3),
    _Slot(-0.8, 0.95, -2),
    _Slot(0.75, 0.88, 3),
  ];

  @override
  State<OnboardingCollage> createState() => _OnboardingCollageState();
}

class _OnboardingCollageState extends State<OnboardingCollage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // With animations off the tiles are simply there.
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (_entrance.isDismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// The tiles in slot order: the first word of every slide, then the
  /// second of every slide, and so on — so one slide's words never sit side
  /// by side.
  List<({OnboardingSupport support, int slide})> get _tiles {
    final tiles = <({OnboardingSupport support, int slide})>[];
    final longest = widget.slides.fold<int>(
      0,
      (max, s) => math.max(max, s.supports.length),
    );
    for (var word = 0; word < longest; word++) {
      for (var slide = 0; slide < widget.slides.length; slide++) {
        final supports = widget.slides[slide].supports;
        if (word < supports.length) {
          tiles.add((support: supports[word], slide: slide));
        }
      }
    }
    return tiles.take(OnboardingCollage._slots.length).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // A tile never takes more than half the width, so two always fit on
        // one row whatever the text scale.
        final maxTileWidth = constraints.maxWidth * 0.5;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            for (var i = 0; i < tiles.length; i++)
              _positioned(
                slot: OnboardingCollage._slots[i],
                order: i,
                count: tiles.length,
                child: _OnboardingTile(
                  support: tiles[i].support,
                  isActive: tiles[i].slide == widget.index,
                  maxWidth: maxTileWidth,
                  reduceMotion: reduceMotion,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _positioned({
    required _Slot slot,
    required int order,
    required int count,
    required Widget child,
  }) {
    // Each tile's entrance starts a little after the previous one.
    final start = order / (count + 2);
    final entrance = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, math.min(1, start + 0.45), curve: AppCurves.enter),
    );

    return Align(
      alignment: AlignmentDirectional(slot.x, slot.y),
      child: FadeTransition(
        opacity: entrance,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(entrance),
          child: Transform.rotate(
            angle: slot.degrees * math.pi / 180,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// One piece of the collage: an icon in a soft square, then the word.
class _OnboardingTile extends StatelessWidget {
  const _OnboardingTile({
    required this.support,
    required this.isActive,
    required this.maxWidth,
    required this.reduceMotion,
  });

  final OnboardingSupport support;
  final bool isActive;
  final double maxWidth;
  final bool reduceMotion;

  /// Grey for the dimmed tiles — the tile keeps its shape, loses its colour.
  static const List<double> _greyscale = <double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;
    final duration = reduceMotion
        ? AppDurations.reducedMotion
        : const Duration(milliseconds: 420);

    final squareColor = support.isUrgent
        ? semantic.urgent
        : colors.primaryContainer;
    final iconColor = support.isUrgent ? semantic.onUrgent : colors.primary;

    final tile = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: squareColor,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                alignment: Alignment.center,
                child: AppIcon(support.icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  support.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Only the lit tiles are read out: the dimmed ones belong to another
    // slide, and TalkBack reading all eight words would bury the headline.
    return ExcludeSemantics(
      excluding: !isActive,
      child: AnimatedScale(
        scale: isActive ? 1.04 : 0.92,
        duration: duration,
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: isActive ? 1 : 0.35,
          duration: duration,
          curve: AppCurves.toggle,
          child: isActive
              ? tile
              : ColorFiltered(
                  colorFilter: const ColorFilter.matrix(_greyscale),
                  child: tile,
                ),
        ),
      ),
    );
  }
}
