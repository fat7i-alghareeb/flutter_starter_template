import 'package:flutter/material.dart';
import 'package:test_name_to_delete/features/root/presentation/widgets/root_body.dart';

import '../../../../common/widgets/custom_scaffold/app_scaffold.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  static const String pagePath = '/root_screen';
  static const String pageName = 'RootScreen';

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold.body(child: const RootBody());
  }
}
