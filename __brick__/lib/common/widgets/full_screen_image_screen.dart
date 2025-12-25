import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/extensions/theme_extensions.dart';

import 'app_icon_source.dart';
import 'button/app_button.dart';
import 'button/app_button_child.dart';
import 'button/app_button_variants.dart';
import 'main_loading_progress.dart';

/// FullScreenImageScreen
/// --------------------
///
/// Displays an image in full screen with a minimal back button.
///
/// This is primarily used by [AppImageViewer] when `enableFullScreen` is true.
///
/// Usage:
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(
///     builder: (_) => FullScreenImageScreen.network(url),
///   ),
/// );
/// ```
enum FullScreenImageSourceType { network, asset }

/// Simple full screen preview for network/asset images.
class FullScreenImageScreen extends StatelessWidget {
  const FullScreenImageScreen._({
    super.key,
    required this.source,
    required this.sourceType,
    this.headers,
    this.backgroundColor,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.high,
  });

  factory FullScreenImageScreen.network(
    String url, {
    Key? key,
    Map<String, String>? headers,
    Color? backgroundColor,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    FilterQuality filterQuality = FilterQuality.high,
  }) {
    return FullScreenImageScreen._(
      key: key,
      source: url,
      sourceType: FullScreenImageSourceType.network,
      headers: headers,
      backgroundColor: backgroundColor,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
    );
  }

  factory FullScreenImageScreen.asset(
    String assetPath, {
    Key? key,
    Color? backgroundColor,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    FilterQuality filterQuality = FilterQuality.high,
  }) {
    return FullScreenImageScreen._(
      key: key,
      source: assetPath,
      sourceType: FullScreenImageSourceType.asset,
      backgroundColor: backgroundColor,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
    );
  }

  final String source;
  final FullScreenImageSourceType sourceType;
  final Map<String, String>? headers;
  final Color? backgroundColor;

  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;

  bool get _isValidSource => source.trim().isNotEmpty;

  void _pop(BuildContext context) {
    // Use root navigator to ensure we pop the fullscreen route even if the
    // caller is inside nested navigators (e.g. shell routes, dialogs).
    try {
      Navigator.of(context, rootNavigator: true).maybePop();
    } catch (_) {}
  }

  Widget _buildError(BuildContext context) {
    final iconColor = context.colorScheme.onSurface.withValues(alpha: 0.7);

    return Center(
      child: Icon(Icons.broken_image_outlined, size: 40.sp, color: iconColor),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: MainLoadingProgress(size: 34, color: context.colorScheme.primary),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (!_isValidSource) return _buildError(context);

    try {
      return switch (sourceType) {
        FullScreenImageSourceType.network => Image.network(
          source,
          headers: headers,
          fit: fit,
          alignment: alignment,
          filterQuality: filterQuality,
          errorBuilder: (context, error, stackTrace) => _buildError(context),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            // Keep the loading UI consistent with the app's progress indicator.
            return _buildLoading(context);
          },
        ),
        FullScreenImageSourceType.asset => Image.asset(
          source,
          fit: fit,
          alignment: alignment,
          filterQuality: filterQuality,
          errorBuilder: (context, error, stackTrace) => _buildError(context),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            if (frame == null) return _buildLoading(context);
            return child;
          },
        ),
      };
    } catch (_) {
      return _buildError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final bg = backgroundColor ?? Colors.black;

      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(child: _buildImage(context)),
              Positioned(
                left: 12.w,
                top: 12.h,
                child: AppButton.grey(
                  noShadow: true,
                  layout: const AppButtonLayout(
                    shape: AppButtonShape.circle,
                    height: 42,
                  ),
                  child: AppButtonChild.icon(
                    IconSource.icon(Icons.arrow_back),
                    size: 18,
                  ),
                  onTap: () => _pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}
