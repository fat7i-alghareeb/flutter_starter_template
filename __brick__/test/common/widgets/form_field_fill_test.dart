import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:{{project_name}}/common/widgets/form/app_reactive_text_field.dart';

import '../../helpers/test_app.dart';

/// A field is drawn in ONE box.
///
/// `AppReactiveTextField` paints its own rounded container (fill, border,
/// shadow) and puts a bare `TextField` inside it. The theme says
/// `inputDecorationTheme.filled: true` for every other text field, so an
/// inner decoration that does not say `filled: false` paints a second,
/// differently coloured rectangle inside the first — a box in a box,
/// obvious in dark mode.
void main() {
  Future<void> pumpField(WidgetTester tester, Brightness brightness) {
    final form = FormGroup(<String, AbstractControl<dynamic>>{
      'email': FormControl<String>(value: 'demo@example.com'),
      'password': FormControl<String>(value: 'secret'),
    });
    addTearDown(form.dispose);
    return pumpApp(
      tester,
      ReactiveForm(
        formGroup: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppReactiveTextField.email(formControlName: 'email'),
            AppReactiveTextField.password(formControlName: 'password'),
          ],
        ),
      ),
      brightness: brightness,
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets('no second fill inside a field (${brightness.name})', (
      tester,
    ) async {
      await pumpField(tester, brightness);

      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields, isNotEmpty);
      for (final field in fields) {
        expect(
          field.decoration?.filled,
          isFalse,
          reason: 'the container around the field owns the fill',
        );
      }
    });
  }
}
