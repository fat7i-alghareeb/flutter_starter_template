import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show appFlavor;

import 'app.dart' show appAuthMode;
import 'core/injection/injectable.dart';
import 'core/services/session/auth_manager.dart';
import 'flavors.dart' show F, Flavor;

/// Common bootstrap entry point used by all flavors.
///
/// It initializes Flutter bindings, configures dependency injection, sets the
/// current flavor, prepares the [AuthManager] singleton, and finally runs the
/// provided widget tree inside a guarded zone.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  // Decide which AuthManager variant to use (JWT / non-JWT) based on
  // the app-level selector in app.dart.
  registerAuthManager(appAuthMode);

  final authManager = getIt<AuthManager>();
  await authManager.initialize();

  await runZonedGuarded<Future<void>>(
    () async {
      F.appFlavor = Flavor.values.firstWhere(
        (element) => element.name == appFlavor,
      );
      final app = await builder();
      runApp(app);
    },
    (error, stackTrace) {
      log('Uncaught application error', error: error, stackTrace: stackTrace);
    },
  );
}
