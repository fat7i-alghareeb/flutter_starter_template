import 'package:get_it/get_it.dart' show GetIt;
import 'package:injectable/injectable.dart';

import 'injectable.config.dart';

/// Global GetIt instance used across the app.
final GetIt getIt = GetIt.instance;

/// Configures dependency injection using Injectable + GetIt.
///
/// This function registers low-level primitives like [StorageService]
/// manually, then delegates the rest of the wiring to the generated
/// `GetItInjectableX.init()` extension.
@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init(); 
}
