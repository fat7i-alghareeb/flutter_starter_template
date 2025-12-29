import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../common/widgets/custom_scaffold/app_scaffold.dart'
    show AppScaffold;
import '../../../../../utils/constants/app_flow_constants.dart';
import '../../../../../utils/extensions/context_extensions.dart';
import '../../../../../utils/extensions/theme_extensions.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static const String pagePath = '/splash_screen';
  static const String pageName = 'SplashScreen';

  @override
  Widget build(BuildContext context) {
    // Total duration allocated for the entire splash animation sequence.
    final total = SplashConfig.durationForSplashScreen;

    // Split the total duration into 3 equal steps (fade in / hold / fade out).
    // We use integer division (~/) because Duration requires an integer value.
    final step = Duration(milliseconds: total.inMilliseconds ~/ 3);

    final boxSize = (context.screenWidth * 0.28).clamp(96.0, 140.0);

    return AppScaffold.body(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: context.gradients.primary),
        child: Center(
          child:
              Container(
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: context.shadows.primary,
                    ),
                    child: Icon(
                      Icons.flutter_dash,
                      color: Colors.white,
                      size: 56.sp,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: step)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1))
                  .moveY(begin: -100, end: 0)
                  .then(delay: step)
                  .moveY(begin: 0, end: 100)
                  .fadeOut(duration: step),
        ),
      ),
    );
  }
}
