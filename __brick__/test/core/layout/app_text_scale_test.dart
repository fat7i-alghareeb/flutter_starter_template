import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/layout/adaptive_typography.dart';
import 'package:{{project_name}}/core/layout/app_layout.dart';

/// Text grows a little with the window, and never beyond what the reader
/// asked for times that step.
void main() {
  Future<double> scaleAt(
    WidgetTester tester, {
    required Size size,
    double system = 1,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = size;
    addTearDown(tester.view.reset);

    late double seen;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(system),
        ),
        child: AppTextScaleHost(
          child: Builder(
            builder: (context) {
              seen = MediaQuery.textScalerOf(context).scale(10) / 10;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    return seen;
  }

  test('no boost below 840dp, then 5%, 10%, 15% by size class', () {
    expect(AppTextScale.windowBoost(WindowSize.compact), 1);
    expect(AppTextScale.windowBoost(WindowSize.medium), 1);
    expect(AppTextScale.windowBoost(WindowSize.expanded), 1.05);
    expect(AppTextScale.windowBoost(WindowSize.large), 1.1);
    expect(AppTextScale.windowBoost(WindowSize.extraLarge), 1.15);
  });

  testWidgets('a phone keeps the reader\'s size exactly', (tester) async {
    expect(await scaleAt(tester, size: const Size(390, 844)), 1);
  });

  testWidgets('a desktop window gets a little more', (tester) async {
    expect(await scaleAt(tester, size: const Size(900, 700)), closeTo(1.05, 1e-9));
    expect(await scaleAt(tester, size: const Size(1500, 900)), closeTo(1.1, 1e-9));
    expect(await scaleAt(tester, size: const Size(1920, 1080)), closeTo(1.15, 1e-9));
  });

  testWidgets('the boost multiplies the reader\'s size, within 85–130%', (
    tester,
  ) async {
    expect(
      await scaleAt(tester, size: const Size(1500, 900), system: 1.2),
      closeTo(1.2 * 1.1, 1e-9),
    );
    // Past 130% the reader's size is capped BEFORE the boost.
    expect(
      await scaleAt(tester, size: const Size(1500, 900), system: 2),
      closeTo(1.3 * 1.1, 1e-9),
    );
    expect(await scaleAt(tester, size: const Size(390, 844), system: 0.5), 0.85);
  });
}
