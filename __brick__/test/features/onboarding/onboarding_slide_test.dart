import 'package:flutter/material.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_icons.dart';
import 'package:{{project_name}}/features/onboarding/presentation/ui/screens/onboarding_screen.dart';
import 'package:{{project_name}}/features/onboarding/presentation/ui/widgets/onboarding_collage.dart';
import 'package:{{project_name}}/features/onboarding/presentation/ui/widgets/onboarding_slide.dart';

import '../../helpers/test_app.dart';

/// The collage takes its strings already translated, so it can be tested without
/// the localization stack — see `test/README.md` for why that matters.
void main() {
  const slides = <OnboardingSlideData>[
    OnboardingSlideData(
      icon: AppIcons.news,
      headline: 'كل جديد أولًا بأول',
      supports: <OnboardingSupport>[
        OnboardingSupport(icon: AppIcons.news, label: 'أخبار'),
        OnboardingSupport(icon: AppIcons.calendar, label: 'فعاليات'),
        OnboardingSupport(
          icon: AppIcons.alert,
          label: 'تنبيهات عاجلة',
          isUrgent: true,
        ),
      ],
    ),
    OnboardingSlideData(
      icon: AppIcons.store,
      headline: 'اعثر على ما تحتاجه بسرعة',
      supports: <OnboardingSupport>[
        OnboardingSupport(icon: AppIcons.pin, label: 'أماكن'),
        OnboardingSupport(icon: AppIcons.tag, label: 'عروض'),
      ],
    ),
  ];

  Widget collage({int index = 0}) => SizedBox(
    height: 360,
    child: OnboardingCollage(slides: slides, index: index),
  );

  group('OnboardingCollage', () {
    testWidgets('draws every word of every slide', (tester) async {
      await pumpApp(tester, collage(), fullScreen: true);
      await tester.pumpAndSettle();

      for (final slide in slides) {
        for (final support in slide.supports) {
          expect(find.text(support.label), findsOneWidget);
        }
      }
    });

    testWidgets('lights the current slide and dims the rest', (tester) async {
      await pumpApp(tester, collage(index: 1), fullScreen: true);
      await tester.pumpAndSettle();

      double opacityOf(String label) => tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity;

      expect(opacityOf('أماكن'), 1);
      expect(opacityOf('أخبار'), lessThan(1));
    });

    testWidgets('only the lit words reach a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, collage(), fullScreen: true);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('أخبار'), findsOneWidget);
      expect(find.bySemanticsLabel('أماكن'), findsNothing);
      handle.dispose();
    });

    testWidgets('survives the narrowest screen', (tester) async {
      await pumpApp(
        tester,
        collage(),
        surfaceSize: TestDevices.small,
        fullScreen: true,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a 1.3x system font', (tester) async {
      await pumpApp(tester, collage(), textScale: 1.3, fullScreen: true);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    forEachBrightness('renders in both themes', (tester, brightness) async {
      await pumpApp(
        tester,
        collage(),
        brightness: brightness,
        fullScreen: true,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('OnboardingHeadline', () {
    testWidgets('shows one headline once the change settles', (tester) async {
      Widget headline(String text) => OnboardingHeadline(text: text);

      await pumpApp(tester, headline('أ'));
      await pumpApp(tester, headline('ب'));
      await tester.pumpAndSettle();

      expect(find.text('ب'), findsOneWidget);
      expect(find.text('أ'), findsNothing);
    });
  });

  group('OnboardingDots', () {
    testWidgets('the active dot is WIDER, not just a different colour', (
      tester,
    ) async {
      // Position must be readable without relying on colour — the same rule the
      // navigation bar follows.
      await pumpApp(tester, const OnboardingDots(count: 3, index: 1));

      final widths = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((c) => c.constraints?.maxWidth)
          .toList();

      expect(widths.where((w) => w == 20).length, 1);
      expect(widths.where((w) => w == 6).length, 2);
    });

    testWidgets('announces the position to a screen reader', (tester) async {
      await pumpApp(tester, const OnboardingDots(count: 3, index: 1));
      expect(
        find.bySemanticsLabel(AppStrings.onboardingSlideOf(2, 3)),
        findsOneWidget,
      );
    });
  });

  group('the slide set', () {
    test('there are exactly three slides', () {
      expect(OnboardingScreen.slides.length, 3);
    });

    test('every slide has a headline and at least two support words', () {
      for (final slide in OnboardingScreen.slides) {
        expect(slide.headline.trim(), isNotEmpty);
        expect(slide.supports.length, greaterThanOrEqualTo(2));
      }
    });

    test('every support word fits a slot in the collage', () {
      final words = OnboardingScreen.slides.fold<int>(
        0,
        (sum, s) => sum + s.supports.length,
      );
      expect(words, lessThanOrEqualTo(8));
    });

    test('each slide has its own icon', () {
      final icons = OnboardingScreen.slides.map((s) => s.icon).toList();
      expect(icons.toSet().length, icons.length);
    });
  });
}
