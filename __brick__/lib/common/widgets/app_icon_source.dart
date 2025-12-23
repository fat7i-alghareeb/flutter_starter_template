import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/helpers/build_svg_icon.dart';

typedef IconSourceBuilder =
    Widget Function(
      BuildContext context, {
      required Color color,
      required double size,
    });

/// Icon abstraction used by [AppButtonChild].
///
/// This allows button content to accept many icon sources (Material icons,
/// assets, SVGs, or custom widgets) while keeping [AppButtonChild] simple.
abstract class IconSource {
  const IconSource();

  Widget build(
    BuildContext context, {
    required Color color,
    required double size,
  });

  /// Material icon.
  factory IconSource.icon(IconData icon, {double? size}) {
    return _IconButtonIconSource(icon, size: size);
  }

  /// Asset image (png/jpg/etc).
  factory IconSource.asset(
    String assetPath, {
    double? size,
    bool applyColor = false,
    BoxFit fit = BoxFit.contain,
  }) {
    return _AssetIconSource(
      assetPath,
      size: size,
      applyColor: applyColor,
      fit: fit,
    );
  }

  /// SVG icon from assets.
  factory IconSource.svg(
    String assetName, {
    double? size,
    BoxFit fit = BoxFit.contain,
  }) {
    return _SvgIconSource(assetName, size: size, fit: fit);
  }

  /// Custom widget.
  factory IconSource.widget(Widget child, {double? size}) {
    return _WidgetIconSource(child, size: size);
  }

  /// Custom builder.
  ///
  /// Useful when you want a widget that reacts to the provided `color`/`size`
  /// (e.g. for prefix/suffix icons in form fields).
  factory IconSource.builder(IconSourceBuilder builder) {
    return _BuilderIconSource(builder);
  }
}

class _IconButtonIconSource extends IconSource {
  const _IconButtonIconSource(this.icon, {this.size});

  final IconData icon;
  final double? size;

  @override
  Widget build(
    BuildContext context, {
    required Color color,
    required double size,
  }) {
    return Icon(icon, size: (this.size ?? size).sp, color: color);
  }
}

class _AssetIconSource extends IconSource {
  const _AssetIconSource(
    this.assetPath, {
    this.size,
    this.applyColor = false,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final double? size;
  final bool applyColor;
  final BoxFit fit;

  @override
  Widget build(
    BuildContext context, {
    required Color color,
    required double size,
  }) {
    return Image.asset(
      assetPath,
      width: (this.size ?? size).sp,
      height: (this.size ?? size).sp,
      fit: fit,
      color: applyColor ? color : null,
    );
  }
}

class _SvgIconSource extends IconSource {
  const _SvgIconSource(this.assetName, {this.size, this.fit = BoxFit.contain});

  final String assetName;
  final double? size;
  final BoxFit fit;

  @override
  Widget build(
    BuildContext context, {
    required Color color,
    required double size,
  }) {
    return buildSvgIcon(
      assetName: assetName,
      color: color,
      width: this.size ?? size,
      height: this.size ?? size,
      fit: fit,
    );
  }
}

class _WidgetIconSource extends IconSource {
  const _WidgetIconSource(this.child, {this.size});

  final Widget child;
  final double? size;

  @override
  Widget build(
    BuildContext context, {
    required Color color,
    required double size,
  }) {
    final s = (this.size ?? size).sp;
    return SizedBox(
      width: s,
      height: s,
      child: FittedBox(child: child),
    );
  }
}

class _BuilderIconSource extends IconSource {
  const _BuilderIconSource(this.builder);

  final IconSourceBuilder builder;

  @override
  Widget build(
    BuildContext context, {
    required Color color,
    required double size,
  }) {
    return builder(context, color: color, size: size);
  }
}
