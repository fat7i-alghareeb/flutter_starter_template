import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:{{project_name}}/common/widgets/form/app_reactive_text_field.dart';
import 'package:{{project_name}}/core/platform/app_platform.dart';

import '../../helpers/test_app.dart';

/// The phone field's country flag is a picture wherever the system font has
/// no flag emoji.
///
/// Windows and Linux draw the two letters of the code («EG») for a flag
/// emoji, and the package sizes that text for a 24sp heading inside a
/// 32dp slot, so it also came out clipped.
void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('only Android, iOS and macOS draw flag emoji', () {
    final expected = <TargetPlatform, bool>{
      TargetPlatform.android: true,
      TargetPlatform.iOS: true,
      TargetPlatform.macOS: true,
      TargetPlatform.windows: false,
      TargetPlatform.linux: false,
    };
    for (final entry in expected.entries) {
      debugDefaultTargetPlatformOverride = entry.key;
      expect(AppPlatform.rendersFlagEmoji, entry.value, reason: '${entry.key}');
    }
  });

  Future<void> pumpPhone(WidgetTester tester) {
    final form = FormGroup(<String, AbstractControl<dynamic>>{
      'phone': FormControl<String>(),
    });
    addTearDown(form.dispose);
    return pumpApp(
      tester,
      ReactiveForm(
        formGroup: form,
        child: AppReactiveTextField.phone(
          formControlName: 'phone',
          title: 'Phone',
          phoneDefaultIsoCode: 'EG',
          // Asking for emoji must not bring them back where they cannot draw.
          phoneUseEmojiFlags: true,
        ),
      ),
      surfaceSize: TestDevices.desktop,
    );
  }

  testWidgets('Windows: a flag picture, not the letters «EG»', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await pumpPhone(tester);

      expect(find.byType(Image), findsOneWidget);
      // The regional-indicator pair for Egypt, which Windows prints as «EG».
      expect(find.textContaining('\u{1F1EA}\u{1F1EC}'), findsNothing);
      expect(find.text('+20'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('Android: the emoji flag, as asked', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await pumpPhone(tester);

      expect(find.textContaining('\u{1F1EA}\u{1F1EC}'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
