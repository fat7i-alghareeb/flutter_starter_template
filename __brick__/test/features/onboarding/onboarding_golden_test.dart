import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_icons.dart';
import 'package:{{project_name}}/features/onboarding/presentation/ui/widgets/onboarding_collage.dart';
import 'package:{{project_name}}/features/onboarding/presentation/ui/widgets/onboarding_slide.dart';

import '../../helpers/golden_helper.dart';

/// The collage, not the screen: a golden of the screen would need
/// `pumpLocalizedApp`, which cannot run twice in one file.
void main() {
  setUpAll(loadTestFonts);

  goldenTest(
    'onboarding_collage',
    () => const SizedBox(
      height: 380,
      child: OnboardingCollage(
        index: 0,
        slides: <OnboardingSlideData>[
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
              OnboardingSupport(icon: AppIcons.search, label: 'بحث سريع'),
              OnboardingSupport(icon: AppIcons.tag, label: 'عروض'),
            ],
          ),
          OnboardingSlideData(
            icon: AppIcons.bookmark,
            headline: 'احفظ ما يهمّك وأكمل من حيث توقفت',
            supports: <OnboardingSupport>[
              OnboardingSupport(icon: AppIcons.bookmark, label: 'إشارات مرجعية'),
              OnboardingSupport(
                icon: AppIcons.heart,
                label: 'مفضّلة',
              ),
            ],
          ),
        ],
      ),
    ),
  );

  goldenTest(
    'onboarding_dots',
    () => const OnboardingDots(count: 3, index: 1),
    brightnesses: <Brightness>[Brightness.light],
  );
}
