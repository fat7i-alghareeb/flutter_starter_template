import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/config/app_config.dart';

void main() {
  test('stage tools are disabled unless STAGE_TOOLS is defined', () {
    expect(AppConfig.stageToolsEnabled, isFalse);
  });

  test('app title is configured', () {
    expect(AppConfig.appTitle, isNotEmpty);
  });
}
