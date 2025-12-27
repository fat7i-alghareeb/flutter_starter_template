import 'package:flutter/material.dart';
import 'package:test_name_to_delete/common/widgets/custom_scaffold/app_scaffold.dart'
    show AppScaffold;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String pagePath = '/splash_screen';
  static const String pageName = 'SplashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold.body(child: const SizedBox());
  }
}
