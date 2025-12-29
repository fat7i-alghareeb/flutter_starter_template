import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/button/app_button.dart';
import '../../../../../common/widgets/button/app_button_child.dart';
import '../../../../../common/widgets/custom_scaffold/app_scaffold.dart'
    show AppScaffold, AppScaffoldAppBarConfig;
import '../../../../../core/injection/injectable.dart';
import '../../../../../core/services/onboarding/onboarding_service.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/extensions/widget_extensions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const String pagePath = '/onboarding_screen';
  static const String pageName = 'OnboardingScreen';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await getIt<OnboardingService>().setOnboardingFinished();
  }

  Future<void> _next() async {
    if (_index >= 2) {
      await _finish();
      return;
    }
    await _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold.appBar(
      appBarConfig: const AppScaffoldAppBarConfig(
        title: 'Onboarding',
        showLeading: false,
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (value) => setState(() => _index = value),
              children: const [
                _OnboardingPage(title: 'Welcome', subtitle: ''),
                _OnboardingPage(title: 'Stay organized', subtitle: ''),
                _OnboardingPage(title: 'Ready to start', subtitle: ''),
              ],
            ),
          ),
          Row(
            children: [
              if (_index < 2)
                Expanded(
                  child: AppButton.grey(
                    child: AppButtonChild.label('Skip'),
                    onTap: _finish,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              AppSpacing.md.horizontalSpace,
              Expanded(
                child: AppButton.primary(
                  child: AppButtonChild.label(
                    _index < 2 ? 'Continue' : 'Start',
                  ),
                  onTap: _next,
                ),
              ),
            ],
          ).standardPadding,
          AppSpacing.xl.verticalSpace,
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, textAlign: TextAlign.center),
          if (subtitle.isNotEmpty) ...[
            AppSpacing.sm.verticalSpace,
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ],
      ).standardPadding,
    );
  }
}
