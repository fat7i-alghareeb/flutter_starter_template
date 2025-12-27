import 'package:flutter/material.dart';

import '../../../../common/widgets/custom_scaffold/app_scaffold.dart';
import '../widgets/auth_body.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const String pagePath = '/auth_screen';
  static const String pageName = 'AuthScreen';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold.body(child: const AuthBody());
  }
}
