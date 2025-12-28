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
    final total = SplashConfig.initialDelay;
    const fade = Duration(milliseconds: 220);
    final hold = total - (fade * 2);
    final holdDelay = hold.isNegative ? Duration.zero : hold;

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
                  .fadeIn(duration: fade)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1))
                  .then(delay: holdDelay)
                  .fadeOut(duration: fade),
        ),
      ),
    );
  }
}
