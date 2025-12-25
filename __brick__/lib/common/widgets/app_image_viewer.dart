/// AppImageViewer
/// --------------
///
/// Unified image widget for rendering:
/// - Cached network images
/// - Asset images
///
/// It provides a consistent loading/error UI and can optionally open a
/// full-screen preview.
///
/// Usage:
/// ```dart
/// AppImageViewer.network(
///   url,
///   width: 120,
///   height: 120,
///   enableFullScreen: true,
/// );
///
/// AppImageViewer.asset(
///   Assets.images.logo.path,
///   borderRadius: 16,
/// );
/// ```
///
/// Notes:
/// - Network images use [CachedNetworkImage] to take advantage of caching.
/// - Fullscreen is pushed using the root navigator to avoid nested navigator
///   issues (e.g., inside dialogs/sheets).
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/extensions/context_extensions.dart';
import '../../utils/extensions/theme_extensions.dart';
import 'app_shimmer.dart';
import 'full_screen_image_screen.dart';
import 'main_loading_progress.dart';

/// How the widget should represent the loading state.
enum AppImageViewerLoading { shimmer, progress, none }

/// Supported sources for [AppImageViewer].
enum AppImageViewerSourceType { network, asset }

/// A containerized image widget with optional shadow, loading UI, and
/// full-screen preview.
class AppImageViewer extends StatelessWidget {
  const AppImageViewer._({
    super.key,
    required this.source,
    required this.sourceType,
    this.headers,
    this.width,
    this.height,
    this.percentageWidth,
    this.percentageHeight,
    this.margin,
    this.backgroundColor,
    this.borderRadius = 12,
    this.noShadow = true,
    this.customShadows,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
    this.loading = AppImageViewerLoading.shimmer,
    this.shimmerAnimate = true,
    this.shimmerEnableHighlight = true,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.progressSize = 30,
    this.progressStrokeWidth = 3,
    this.progressColor,
    this.enableFullScreen = false,
    this.fullScreenBackgroundColor,
  });

  factory AppImageViewer.network(
    String url, {
    Key? key,
    Map<String, String>? headers,
    double? width,
    double? height,
    double? percentageWidth,
    double? percentageHeight,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double borderRadius = 12,
    bool noShadow = true,
    List<BoxShadow>? customShadows,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    FilterQuality filterQuality = FilterQuality.medium,
    AppImageViewerLoading loading = AppImageViewerLoading.shimmer,
    bool shimmerAnimate = true,
    bool shimmerEnableHighlight = true,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    double progressSize = 30,
    double progressStrokeWidth = 3,
    Color? progressColor,
    bool enableFullScreen = false,
    Color? fullScreenBackgroundColor,
  }) {
    return AppImageViewer._(
      key: key,
      source: url,
      sourceType: AppImageViewerSourceType.network,
      headers: headers,
      width: width,
      height: height,
      percentageWidth: percentageWidth,
      percentageHeight: percentageHeight,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      noShadow: noShadow,
      customShadows: customShadows,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      loading: loading,
      shimmerAnimate: shimmerAnimate,
      shimmerEnableHighlight: shimmerEnableHighlight,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
      progressSize: progressSize,
      progressStrokeWidth: progressStrokeWidth,
      progressColor: progressColor,
      enableFullScreen: enableFullScreen,
      fullScreenBackgroundColor: fullScreenBackgroundColor,
    );
  }

  factory AppImageViewer.asset(
    String assetPath, {
    Key? key,
    double? width,
    double? height,
    double? percentageWidth,
    double? percentageHeight,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double borderRadius = 12,
    bool noShadow = true,
    List<BoxShadow>? customShadows,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    FilterQuality filterQuality = FilterQuality.medium,
    AppImageViewerLoading loading = AppImageViewerLoading.shimmer,
    bool shimmerAnimate = true,
    bool shimmerEnableHighlight = true,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
    double progressSize = 30,
    double progressStrokeWidth = 3,
    Color? progressColor,
    bool enableFullScreen = false,
    Color? fullScreenBackgroundColor,
  }) {
    return AppImageViewer._(
      key: key,
      source: assetPath,
      sourceType: AppImageViewerSourceType.asset,
      width: width,
      height: height,
      percentageWidth: percentageWidth,
      percentageHeight: percentageHeight,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      noShadow: noShadow,
      customShadows: customShadows,
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      loading: loading,
      shimmerAnimate: shimmerAnimate,
      shimmerEnableHighlight: shimmerEnableHighlight,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
      progressSize: progressSize,
      progressStrokeWidth: progressStrokeWidth,
      progressColor: progressColor,
      enableFullScreen: enableFullScreen,
      fullScreenBackgroundColor: fullScreenBackgroundColor,
    );
  }

  final String source;
  final AppImageViewerSourceType sourceType;
  final Map<String, String>? headers;

  final double? width;
  final double? height;
  final double? percentageWidth;
  final double? percentageHeight;

  final EdgeInsetsGeometry? margin;

  final Color? backgroundColor;

  final double borderRadius;

  final bool noShadow;
  final List<BoxShadow>? customShadows;

  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;

  final AppImageViewerLoading loading;

  final bool shimmerAnimate;
  final bool shimmerEnableHighlight;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  final double progressSize;
  final double progressStrokeWidth;
  final Color? progressColor;

  final bool enableFullScreen;
  final Color? fullScreenBackgroundColor;

  bool get _isValidSource => source.trim().isNotEmpty;

  bool get _isValidNetworkUrl {
    final raw = source.trim();
    final uri = Uri.tryParse(raw);
    if (uri == null) return false;
    if (uri.host.isEmpty) return false;
    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  bool get _isRenderableSource {
    // When the url is invalid, CachedNetworkImage can throw or spam error
    // builders. This early guard keeps UI predictable.
    if (!_isValidSource) return false;
    if (sourceType == AppImageViewerSourceType.network) {
      return _isValidNetworkUrl;
    }
    return true;
  }

  double? _resolveWidth(BuildContext context) {
    // Supports declarative layouts where the image takes a percentage of the
    // current screen width (useful for cards/grids).
    if (percentageWidth != null) return context.screenWidth * percentageWidth!;
    return width?.w;
  }

  double? _resolveHeight(BuildContext context) {
    // Same as width: allow sizing relative to the screen height.
    if (percentageHeight != null) {
      return context.screenHeight * percentageHeight!;
    }
    return height?.h;
  }

  Widget _buildLoading(BuildContext context) {
    if (loading == AppImageViewerLoading.none) return const SizedBox.shrink();

    final foreground = progressColor ?? context.colorScheme.primary;

    final base = Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor ?? context.colorScheme.surfaceContainerHighest,
    );

    if (loading == AppImageViewerLoading.progress) {
      return Center(
        child: MainLoadingProgress(
          size: progressSize,
          strokeWidth: progressStrokeWidth,
          color: foreground,
        ),
      );
    }

    return AppShimmer(
      animate: shimmerAnimate,
      enableHighlight: shimmerEnableHighlight,
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: base,
    );
  }

  Widget _buildError(BuildContext context) {
    final iconColor = context.colorScheme.onSurface.withValues(alpha: 0.6);

    return Center(
      child: Icon(Icons.broken_image_outlined, size: 26.sp, color: iconColor),
    );
  }

  PageRoute<void> _fullScreenRoute() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        final screen = switch (sourceType) {
          AppImageViewerSourceType.network => FullScreenImageScreen.network(
            source,
            headers: headers,
            backgroundColor: fullScreenBackgroundColor,
          ),
          AppImageViewerSourceType.asset => FullScreenImageScreen.asset(
            source,
            backgroundColor: fullScreenBackgroundColor,
          ),
        };

        return screen;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );

        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  void _onTap(BuildContext context) {
    if (!enableFullScreen) return;
    if (!_isRenderableSource) return;

    try {
      Navigator.of(context, rootNavigator: true).push(_fullScreenRoute());
    } catch (_) {}
  }

  Widget _maybeWrapTap(BuildContext context, Widget child) {
    if (!enableFullScreen) return child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(context),
        child: child,
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (!_isRenderableSource) return _buildError(context);

    try {
      return switch (sourceType) {
        AppImageViewerSourceType.network => CachedNetworkImage(
          // CachedNetworkImage gives us memory/disk caching and a predictable
          // placeholder/error API.
          imageUrl: source,
          httpHeaders: headers,
          fit: fit,
          alignment: alignment,
          filterQuality: filterQuality,
          fadeInDuration: const Duration(milliseconds: 180),
          fadeOutDuration: const Duration(milliseconds: 120),
          placeholderFadeInDuration: const Duration(milliseconds: 120),
          placeholder: (context, url) => _buildLoading(context),
          errorWidget: (context, url, error) => _buildError(context),
        ),
        AppImageViewerSourceType.asset => Image.asset(
          source,
          fit: fit,
          alignment: alignment,
          filterQuality: filterQuality,
          errorBuilder: (context, error, stackTrace) => _buildError(context),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;

            final isLoaded = frame != null;
            // AnimatedSwitcher avoids a harsh transition from loading to image.
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: isLoaded
                  ? KeyedSubtree(key: const ValueKey('image'), child: child)
                  : KeyedSubtree(
                      key: const ValueKey('loading'),
                      child: _buildLoading(context),
                    ),
            );
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
      final w = _resolveWidth(context);
      final h = _resolveHeight(context);

      final radius = BorderRadius.circular(borderRadius.r);

      final effectiveShadows =
          customShadows ??
          <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 14.r,
              offset: Offset(0, 6.h),
            ),
          ];

      final decoration = BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        boxShadow: noShadow ? null : effectiveShadows,
      );

      final content = ClipRRect(
        // Clip is applied at the widget level to ensure the image, placeholder
        // and error widgets all respect the same radius.
        borderRadius: radius,
        child: _buildImage(context),
      );

      final child = Container(
        width: w,
        height: h,
        margin: margin,
        decoration: decoration,
        // This enables anti-aliased clipping for rounded corners.
        clipBehavior: Clip.antiAlias,
        child: content,
      );

      return enableFullScreen ? _maybeWrapTap(context, child) : child;
    } catch (_) {
      return _buildError(context);
    }
  }
}
