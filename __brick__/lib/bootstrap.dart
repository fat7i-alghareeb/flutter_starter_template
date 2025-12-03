import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded<Future<void>>(
    () async {
      final app = await builder();
      runApp(app);
    },
    (error, stackTrace) {
      log('Uncaught application error', error: error, stackTrace: stackTrace);
    },
  );
}
