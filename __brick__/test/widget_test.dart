import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/flavors.dart';

void main() {
  test('generated flavor enum exposes stage and production', () {
    expect(Flavor.values, containsAll([Flavor.stage, Flavor.production]));
  });
}
