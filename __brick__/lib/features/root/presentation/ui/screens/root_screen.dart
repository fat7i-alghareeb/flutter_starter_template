import 'package:flutter/material.dart';

import '../widgets/root_body.dart';
import '../../../../../common/widgets/custom_scaffold/app_scaffold.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  static const String pagePath = '/root_screen';
  static const String pageName = 'RootScreen';

  @override
  Widget build(BuildContext context) {
    return AppScaffold.body(child: const RootBody());
  }
}
