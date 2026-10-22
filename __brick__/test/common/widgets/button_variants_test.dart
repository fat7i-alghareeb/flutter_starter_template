import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/button/app_button.dart';
import 'package:{{project_name}}/common/widgets/button/app_button_child.dart';
import 'package:{{project_name}}/common/widgets/button/app_button_variants.dart';

import '../../helpers/test_app.dart';

/// Whatever the plate, its text can be read — and grey means inactive.
///
/// Grey used to be a variant like any other: «Cancel» and «Reset» were grey,
/// with near-white text on a pale plate, so they looked disabled while a real
/// disabled button was unreadable. Now grey is ONLY the look of an inactive
/// button, and an active button cannot be grey.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  // The variants an ACTIVE button can have. Grey is not one of them.
  final activeVariants = <String, AppButtonVariant>{
    'primary': AppButtonVariant.primary,
    'success': AppButtonVariant.success,
    'warning': AppButtonVariant.warning,
    'error': AppButtonVariant.error,
  };

  for (final brightness in Brightness.values) {
    testWidgets('every active plate carries readable text (${brightness.name})', (
      tester,
    ) async {
      final results = <String, double>{};
      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            for (final entry in activeVariants.entries) {
              for (final fill in AppButtonFill.values) {
                final style = AppButtonStyleResolver.resolve(
                  context,
                  variant: entry.value,
                  fill: fill,
                  isActive: true,
                  noShadow: true,
                );
                // A gradient is judged at its WORST end.
                final plates = fill == AppButtonFill.solid
                    ? <Color>[style.color!]
                    : style.gradient!.colors;
                results['${entry.key}/${fill.name}'] = plates
                    .map((plate) => _contrast(style.foreground, plate))
                    .reduce(math.min);
              }
            }
            return const SizedBox();
          },
        ),
        brightness: brightness,
      );

      for (final entry in results.entries) {
        expect(entry.value, greaterThan(4.5), reason: entry.key);
      }
    });

    testWidgets('the inactive (grey) plate is quiet but legible, and apart '
        'from the page (${brightness.name})', (tester) async {
      late AppButtonResolvedStyle style;
      late Color page;
      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            page = Theme.of(context).scaffoldBackgroundColor;
            style = AppButtonStyleResolver.resolve(
              context,
              variant: AppButtonVariant.primary,
              fill: AppButtonFill.solid,
              isActive: false,
              noShadow: true,
            );
            return const SizedBox();
          },
        ),
        brightness: brightness,
      );

      final plate = style.color!;
      expect(
        _contrast(Color.alphaBlend(style.foreground, plate), plate),
        greaterThan(2.5),
      );
      expect(_contrast(plate, page), greaterThan(1.05));
    });
  }

  group('grey means inactive, and only that', () {
    testWidgets('an inactive button of ANY variant is drawn the grey way', (
      tester,
    ) async {
      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            for (final variant in activeVariants.values) {
              for (final fill in AppButtonFill.values) {
                final inactive = AppButtonStyleResolver.resolve(
                  context,
                  variant: variant,
                  fill: fill,
                  isActive: false,
                  noShadow: true,
                );
                final grey = AppButtonStyleResolver.resolve(
                  context,
                  variant: AppButtonVariant.grey,
                  fill: fill,
                  isActive: false,
                  noShadow: true,
                );
                expect(inactive.color, grey.color);
                expect(inactive.gradient?.colors, grey.gradient?.colors);
                expect(inactive.foreground, grey.foreground);
              }
            }
            return const SizedBox();
          },
        ),
      );
    });

    test('an ACTIVE button cannot be grey', () {
      expect(
        () => AppButton.variant(
          variant: AppButtonVariant.grey,
          fill: AppButtonFill.solid,
          child: AppButtonChild.label('Cancel'),
          onTap: () {},
        ),
        throwsAssertionError,
      );
    });

    test('a grey button is allowed only when it is inactive', () {
      expect(
        () => AppButton.variant(
          variant: AppButtonVariant.grey,
          fill: AppButtonFill.solid,
          child: AppButtonChild.label('Not yet'),
          onTap: null,
          isActive: false,
        ),
        returnsNormally,
      );
      expect(
        () => AppButton.grey(child: AppButtonChild.label('Not yet')),
        returnsNormally,
      );
      expect(
        () => AppButton.greyGradient(child: AppButtonChild.label('Not yet')),
        returnsNormally,
      );
    });

    testWidgets('AppButton.grey ignores taps and says why instead', (
      tester,
    ) async {
      var inactiveTaps = 0;
      await pumpApp(
        tester,
        AppButton.grey(
          child: AppButtonChild.label('Not yet'),
          onTapWhenInactive: () => inactiveTaps++,
        ),
      );

      await tester.tap(find.text('Not yet'));
      // Past the quick-press animation's 90ms timer.
      await tester.pump(const Duration(milliseconds: 300));
      expect(inactiveTaps, 1);
    });

    testWidgets('a button is drawn grey by itself when it cannot be pressed', (
      tester,
    ) async {
      Color? plate(WidgetTester tester) {
        final box = tester.widget<AnimatedContainer>(
          find
              .descendant(
                of: find.byType(AppButton),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        return (box.decoration! as BoxDecoration).color;
      }

      late Color grey;
      Widget probe(Widget button) => Builder(
        builder: (context) {
          grey = Theme.of(context).colorScheme.surfaceContainerHighest;
          return button;
        },
      );

      // isActive: false
      await pumpApp(
        tester,
        probe(
          AppButton.primary(
            child: AppButtonChild.label('Send'),
            onTap: () {},
            isActive: false,
          ),
        ),
      );
      expect(plate(tester), grey);

      // No onTap at all.
      await pumpApp(
        tester,
        probe(AppButton.primary(child: AppButtonChild.label('Send'), onTap: null)),
      );
      expect(plate(tester), grey);

      // A pressable button keeps its own colour.
      await pumpApp(
        tester,
        probe(
          AppButton.primary(child: AppButtonChild.label('Send'), onTap: () {}),
        ),
      );
      expect(plate(tester), isNot(grey));
    });

    testWidgets('a button with isActive: false never calls onTap', (
      tester,
    ) async {
      var taps = 0;
      await pumpApp(
        tester,
        AppButton.primary(
          child: AppButtonChild.label('Send'),
          onTap: () => taps++,
          isActive: false,
        ),
      );

      await tester.tap(find.text('Send'));
      await tester.pump();
      expect(taps, 0);
    });

    test('nothing in lib/ but the button itself and its demo uses grey', () {
      // Grey on a button that works is the mistake this rule exists to stop:
      // «Cancel», «Exit» and «Reset» are error (or primary) buttons.
      final grey = RegExp(
        r'AppButton\.grey|AppButton\.greyGradient|variant:\s*AppButtonVariant\.grey',
      );
      const allowed = <String>[
        'lib/common/widgets/button/',
        'lib/features/root/presentation/ui/widgets/showcase/root_tab_buttons_showcase.dart',
      ];
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final path = entity.path.replaceAll(r'\', '/');
        if (allowed.any(path.contains)) continue;
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('//')) continue;
          if (grey.hasMatch(line)) offenders.add('$path:${i + 1}');
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'grey is only the look of an inactive button; use '
            'AppButton.error or AppButton.primary, or isActive: false',
      );
    });
  });
}
