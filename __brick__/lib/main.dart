import 'bootstrap.dart';
import 'app.dart';
{{#include_flavors}}
import 'flavors.dart'show F, Flavor;
import 'package:flutter/services.dart' show appFlavor;

{{/include_flavors}}

void main() async {
  {{#include_flavors}}
  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
  );
  {{/include_flavors}}

  await bootstrap(() async => const App());
}

