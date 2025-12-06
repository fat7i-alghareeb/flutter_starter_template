import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/services/session/auth_manager.dart';

/// Global auth mode selector for this app.
///
/// Change this single constant to switch between JWT and non-JWT auth flows.
const AuthMode appAuthMode = AuthMode.withJwt;

/// Root widget of the application.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
