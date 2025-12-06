import 'bootstrap.dart';
import 'app.dart';
import 'flavors.dart'show F, Flavor;
import 'package:flutter/services.dart' show appFlavor;


void main() async {
  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
  );
  await bootstrap(() async => const App());
}

