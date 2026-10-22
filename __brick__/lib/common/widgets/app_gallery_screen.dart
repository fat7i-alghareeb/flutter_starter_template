import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/layout/app_layout_scope.dart';

import '../../core/theme/app_colors.dart';
import '../../utils/constants/design_constants.dart';
import '../../utils/extensions/context_extensions.dart';
import '../../utils/helpers/app_formats.dart';
import '../../utils/helpers/app_strings.dart';
import 'ds/ds.dart';

/// The gallery viewer — a paged, zoomable list of pictures.
///
/// `FullScreenImageScreen` already exists but shows **one** picture; a
/// gallery opens at the tile that was pressed and pages between the rest, so
/// this wraps that idea in a `PageView` rather than changing a widget six
/// other screens will use. Nothing here is a new dependency — the zoom is
/// Flutter's own `InteractiveViewer`.
///
/// It takes a plain list of urls, so the pictures may be an article's or a
/// shop's without this screen knowing which.
class AppGalleryScreen extends StatefulWidget {
  const AppGalleryScreen({
    super.key,
    required this.urls,
    this.initialIndex = 0,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<AppGalleryScreen> createState() => _AppGalleryScreenState();
}

class _AppGalleryScreenState extends State<AppGalleryScreen> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  /// The zoom of the picture on screen; a new page starts unzoomed.
  final TransformationController _zoom = TransformationController();
  Size _viewport = Size.zero;

  static const double _maxScale = 4;

  @override
  void dispose() {
    _controller.dispose();
    _zoom.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final target = _index + delta;
    if (target < 0 || target >= widget.urls.length) return;
    _controller.animateToPage(
      target,
      duration: AppDurations.normal,
      curve: AppCurves.enter,
    );
  }

  /// Zooms about the middle of the picture, between 1× and [_maxScale].
  void _zoomBy(double factor) {
    final current = _zoom.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(1.0, _maxScale);
    final dx = -(next - 1) * _viewport.width / 2;
    final dy = -(next - 1) * _viewport.height / 2;
    _zoom.value = Matrix4.diagonal3Values(next, next, 1)
      ..setTranslationRaw(dx, dy, 0);
  }

  /// ← and → follow the reading direction: in Arabic → goes back.
  Map<ShortcutActivator, VoidCallback> _keys(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
          _go(rtl ? -1 : 1),
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
          _go(rtl ? 1 : -1),
      const SingleActivator(LogicalKeyboardKey.escape): () =>
          Navigator.of(context).maybePop(),
      const SingleActivator(LogicalKeyboardKey.equal): () => _zoomBy(1.5),
      const SingleActivator(LogicalKeyboardKey.minus): () => _zoomBy(1 / 1.5),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;
    // Pointer controls in big windows: a mouse cannot swipe, and a picture
    // across a desktop window wants arrows, zoom buttons and thumbnails.
    final pointer = AppLayoutScope.maybeOf(context)?.isExpandedUp ?? false;
    final many = widget.urls.length > 1;

    Widget control(String icon, String label, VoidCallback? onTap) {
      return _GalleryButton(
        icon: icon,
        label: label,
        color: semantic.onPhoto,
        onTap: onTap,
      );
    }

    return CallbackShortcuts(
      bindings: _keys(context),
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: semantic.photoScrim,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          _viewport = constraints.biggest;
                          return PageView.builder(
                            controller: _controller,
                            itemCount: widget.urls.length,
                            onPageChanged: (index) {
                              _zoom.value = Matrix4.identity();
                              setState(() => _index = index);
                            },
                            itemBuilder: (context, index) => InteractiveViewer(
                              // The wheel zooms too: InteractiveViewer reads it.
                              transformationController: index == _index
                                  ? _zoom
                                  : null,
                              minScale: 1,
                              maxScale: _maxScale,
                              child: Center(
                                child: AppThumbnail(
                                  imageUrl: widget.urls[index],
                                  iconKey: 'image',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      PositionedDirectional(
                        top: AppSpacing.sm,
                        start: AppSpacing.sm,
                        child: control(
                          AppIcons.close,
                          AppStrings.actionClose,
                          () => Navigator.of(context).pop(),
                        ),
                      ),
                      if (pointer)
                        PositionedDirectional(
                          top: AppSpacing.sm,
                          end: AppSpacing.sm,
                          child: Row(
                            children: <Widget>[
                              control(
                                AppIcons.zoomOut,
                                AppStrings.actionZoomOut,
                                () => _zoomBy(1 / 1.5),
                              ),
                              control(
                                AppIcons.zoomIn,
                                AppStrings.actionZoomIn,
                                () => _zoomBy(1.5),
                              ),
                            ],
                          ),
                        ),
                      if (pointer && many) ...<Widget>[
                        PositionedDirectional(
                          start: AppSpacing.md,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: control(
                              context.chevronStart,
                              AppStrings.galleryPrevious,
                              _index > 0 ? () => _go(-1) : null,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          end: AppSpacing.md,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: control(
                              context.chevronEnd,
                              AppStrings.galleryNext,
                              _index < widget.urls.length - 1
                                  ? () => _go(1)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                      if (many && !pointer)
                        PositionedDirectional(
                          bottom: AppSpacing.lg,
                          start: 0,
                          end: 0,
                          child: Center(child: _position(context, semantic)),
                        ),
                    ],
                  ),
                ),
                if (pointer && many) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  _position(context, semantic),
                  _Thumbnails(
                    urls: widget.urls,
                    index: _index,
                    onSelect: (i) => _controller.jumpToPage(i),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _position(BuildContext context, AppSemanticColors semantic) {
    return Text(
      AppStrings.a11yPositionOf(
        AppFormats.number(context, _index + 1),
        AppFormats.number(context, widget.urls.length),
      ),
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: semantic.onPhotoMuted),
    );
  }
}

/// A round control over the photo. Disabled (null [onTap]) it fades.
class _GalleryButton extends StatelessWidget {
  const _GalleryButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: label,
        excludeSemantics: true,
        child: Opacity(
          opacity: onTap == null ? AppStates.disabled : 1,
          child: Material(
            color: color.withValues(alpha: 0.12),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox.square(
                dimension: AppIconSizes.minTouchTarget,
                child: Center(
                  child: AppIcon(icon, size: AppIconSizes.bar, color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The strip of thumbnails under the picture in a big window.
class _Thumbnails extends StatelessWidget {
  const _Thumbnails({
    required this.urls,
    required this.index,
    required this.onSelect,
  });

  final List<String> urls;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 72,
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          itemCount: urls.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, i) => Semantics(
            button: true,
            selected: i == index,
            label: AppStrings.a11yPositionOf(
              AppFormats.number(context, i + 1),
              AppFormats.number(context, urls.length),
            ),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedOpacity(
                  opacity: i == index ? 1 : 0.55,
                  duration: AppDurations.toggle,
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(
                        color: i == index ? colors.surface : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.sm - 2),
                      child: AppThumbnail(imageUrl: urls[i], iconKey: 'image'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
