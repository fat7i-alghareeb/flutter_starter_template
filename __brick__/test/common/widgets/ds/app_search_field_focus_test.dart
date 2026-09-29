import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/common/widgets/ds/app_search_field.dart';

import '../../../helpers/test_app.dart';

/// A read-only field is a button into search: it opens it, and holds no
/// focus.
///
/// Focusable, it took focus on the tap and got it back when search closed —
/// the field then sat outlined as if typed in.
void main() {
  testWidgets('a read-only field fires its tap and never takes focus', (
    tester,
  ) async {
    var opened = 0;
    final focus = FocusNode();
    addTearDown(focus.dispose);

    await pumpApp(
      tester,
      SizedBox(
        width: 360,
        child: AppSearchField(
          hintText: 'search',
          readOnly: true,
          focusNode: focus,
          onTap: () => opened++,
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(opened, 1);
    expect(focus.hasFocus, isFalse);

    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isFalse, reason: 'nothing can hand it focus back');
  });
}
