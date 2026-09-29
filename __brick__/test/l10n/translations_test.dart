import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the translation files.
///
/// The failure these prevent is quiet and ugly: a key present in Arabic but
/// missing in English makes the English build render `auth.gate.save` as
/// literal text on a button. Nothing crashes, nothing logs — it just ships.
void main() {
  late Map<String, dynamic> ar;
  late Map<String, dynamic> en;

  setUpAll(() {
    ar =
        jsonDecode(File('assets/l10n/ar.json').readAsStringSync())
            as Map<String, dynamic>;
    en =
        jsonDecode(File('assets/l10n/en.json').readAsStringSync())
            as Map<String, dynamic>;
  });

  /// A plural form other than `other` belongs to one language's grammar —
  /// English has no «two» — so only the general form must be in both.
  Set<String> sharedKeys(Map<String, dynamic> map) => map.keys.where((key) {
    final dot = key.lastIndexOf('.');
    if (dot <= 0) return true;
    final form = key.substring(dot + 1);
    const forms = <String>['zero', 'one', 'two', 'few', 'many'];
    return !(forms.contains(form) &&
        map.containsKey('${key.substring(0, dot)}.other'));
  }).toSet();

  test('both locales carry exactly the same keys', () {
    final onlyAr = sharedKeys(ar).difference(sharedKeys(en));
    final onlyEn = sharedKeys(en).difference(sharedKeys(ar));

    expect(onlyAr, isEmpty, reason: 'missing from en.json: $onlyAr');
    expect(onlyEn, isEmpty, reason: 'missing from ar.json: $onlyEn');
  });

  test('no value is empty', () {
    for (final entry in ar.entries) {
      expect(
        (entry.value as String).trim(),
        isNotEmpty,
        reason: 'ar.${entry.key} is blank',
      );
    }
    for (final entry in en.entries) {
      expect(
        (entry.value as String).trim(),
        isNotEmpty,
        reason: 'en.${entry.key} is blank',
      );
    }
  });

  test('placeholders match between locales', () {
    // `{}` counts must line up, or `.tr(args: [...])` silently drops or
    // duplicates a value in one language only.
    final braces = RegExp(r'\{\}');
    for (final key in ar.keys) {
      // A form English does not write is compared with English's general
      // form: every form carries the same `{}` values; only `{n}` may go.
      final enKey = en.containsKey(key)
          ? key
          : '${key.substring(0, key.lastIndexOf('.'))}.other';
      final arCount = braces.allMatches(ar[key] as String).length;
      final enCount = braces.allMatches(en[enKey] as String).length;
      expect(
        arCount,
        enCount,
        reason: '$key has $arCount placeholders in ar and $enCount in en',
      );
    }
  });

  test('every protected action has a sign-in line of its own', () {
    // The sheet names the ACTION. A missing key here would fall back to
    // showing the raw key to a user who is being asked to trust the app
    // with an account.
    const actions = <String>[
      'auth.gate.save',
      'auth.gate.follow',
      'auth.gate.like',
      'auth.gate.comment',
      'auth.gate.report',
      'auth.gate.account',
      'auth.gate.notifications',
      'auth.gate.settings',
    ];
    for (final key in actions) {
      expect(ar.containsKey(key), isTrue, reason: '$key missing');
      expect(
        ar[key],
        isNot(contains('{}')),
        reason: '$key should be a complete sentence, not a template',
      );
    }
  });

  test('the five navigation labels exist', () {
    for (final key in <String>[
      'nav.feed',
      'nav.buttons',
      'nav.forms',
      'nav.dialogs',
      'nav.alerts',
    ]) {
      expect(ar.containsKey(key), isTrue, reason: '$key missing');
    }
  });

  test('no Arabic value is left in Latin script', () {
    // Catches a key that was copied into ar.json but never translated.
    final arabic = RegExp(r'[؀-ۿ]');
    final exempt = <String>{
      'app.name', // brand names may stay Latin-free
    };

    for (final entry in ar.entries) {
      if (exempt.contains(entry.key)) continue;
      final value = entry.value as String;
      // Values that are purely a placeholder or punctuation are fine.
      if (!RegExp(r'[A-Za-z]{4,}').hasMatch(value)) continue;
      expect(
        arabic.hasMatch(value),
        isTrue,
        reason: 'ar.${entry.key} looks untranslated: "$value"',
      );
    }
  });
}
