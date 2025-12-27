import 'package:flutter/material.dart';
import 'package:test_name_to_delete/common/widgets/custom_scaffold/app_scaffold.dart'
    show AppScaffold;

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});
  static const String pagePath = '/on_boarding_screen';
  static const String pageName = 'OnBoardingScreen';

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold.body(child: const SizedBox());
  }
}
