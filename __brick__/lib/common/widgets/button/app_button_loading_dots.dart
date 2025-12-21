import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Loading indicator used by [AppButton] when `isLoading` is true.
class AppButtonLoadingDots extends StatefulWidget {
  const AppButtonLoadingDots({
    super.key,
    required this.color,
    this.dotSize = 6,
    this.spacing = 6,
    this.dots = 3,
  });

  final Color color;
  final double dotSize;
  final double spacing;
  final int dots;

  @override
  State<AppButtonLoadingDots> createState() => _AppButtonLoadingDotsState();
}

class _AppButtonLoadingDotsState extends State<AppButtonLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotScale(int index) {
    final phase = (_controller.value + (index / widget.dots)) % 1.0;
    final wave = (math.sin(phase * 2 * math.pi) + 1) / 2;
    return 0.60 + (0.50 * wave);
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.dotSize.sp;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.dots, (i) {
            final s = _dotScale(i);
            return Padding(
              padding: EdgeInsets.only(
                right: i == widget.dots - 1 ? 0 : widget.spacing.w,
              ),
              child: Transform.scale(
                scale: s,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
