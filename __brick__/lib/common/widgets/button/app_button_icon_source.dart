import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/helpers/build_svg_icon.dart';

abstract class AppButtonIconSource {
  const AppButtonIconSource();

  Widget build(
    BuildContext context, {
    required Color color,
    required double size,
  });

  factory AppButtonIconSource.icon(IconData icon, {double? size}) {
    return _IconButtonIconSource(icon, size: size);
  }

  factory AppButtonIconSource.asset(
    String assetPath, {
    double? size,
    bool applyColor = false,
    BoxFit fit = BoxFit.contain,
  }) {
    return _AssetButtonIconSource(
      assetPath,
      size: size,
      applyColor: applyColor,
      fit: fit,
    );
  }

  factory AppButtonIconSource.svg(
    String assetName, {
    double? size,
    BoxFit fit = BoxFit.contain,
  }) {
    return _SvgButtonIconSource(assetName, size: size, fit: fit);
  }

  factory AppButtonIconSource.widget(Widget child, {double? size}) {
    return _WidgetButtonIconSource(child, size: size);
  }
}

class _IconButtonIconSource extends AppButtonIconSource {
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

class _AssetButtonIconSource extends AppButtonIconSource {
  const _AssetButtonIconSource(
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

class _SvgButtonIconSource extends AppButtonIconSource {
  const _SvgButtonIconSource(
    this.assetName, {
    this.size,
    this.fit = BoxFit.contain,
  });

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

class _WidgetButtonIconSource extends AppButtonIconSource {
  const _WidgetButtonIconSource(this.child, {this.size});

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
