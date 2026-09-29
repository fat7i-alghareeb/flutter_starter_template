import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../utils/constants/design_constants.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic =
        theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

    return Scaffold(
      backgroundColor: semantic.photoScrim,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _controller,
              itemCount: widget.urls.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: AppThumbnail(
                    imageUrl: widget.urls[index],
                    iconKey: 'image',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: AppSpacing.sm,
              start: AppSpacing.sm,
              child: Semantics(
                button: true,
                label: AppStrings.actionClose,
                excludeSemantics: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(AppRadii.full),
                    child: SizedBox(
                      width: AppIconSizes.minTouchTarget,
                      height: AppIconSizes.minTouchTarget,
                      child: Center(
                        child: AppIcon(
                          AppIcons.close,
                          size: AppIconSizes.bar,
                          color: semantic.onPhoto,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.urls.length > 1)
              PositionedDirectional(
                bottom: AppSpacing.lg,
                start: 0,
                end: 0,
                child: Center(
                  child: Text(
                    AppStrings.a11yPositionOf(
                      AppFormats.number(context, _index + 1),
                      AppFormats.number(context, widget.urls.length),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: semantic.onPhotoMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
