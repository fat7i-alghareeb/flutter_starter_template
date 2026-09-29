import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces how translations are used, not just that they exist.
///
/// Three rules, each guarding a failure that is silent until a user hits it:
///
/// 1. **Every user-facing word comes from `AppStrings`.** A literal in a widget
///    can never be translated and never shows up in the l10n tests.
/// 2. **`.tr()` is called only by the generated file.** A hand-written
///    `'some.key'.tr()` is a string the compiler cannot check — a typo renders
///    the raw key on screen and nothing fails.
/// 3. **One value belongs to one key.** Two keys with the same sentence means
///    one is dead weight, and editing one leaves the app saying two different
///    things for the same idea.
/// 4. **A counted sentence is a plural group.** Arabic writes a count six
///    ways; one fixed template prints «منذ 2 ساعات» and «1 تعليقات».
void main() {
  const pluralForms = <String>['zero', 'one', 'two', 'few', 'many', 'other'];

  /// `time.hoursAgo` for `time.hoursAgo.two` — when the group exists.
  String? pluralBaseOf(Map<String, dynamic> map, String key) {
    final dot = key.lastIndexOf('.');
    if (dot <= 0 || !pluralForms.contains(key.substring(dot + 1))) return null;
    final base = key.substring(0, dot);
    return map.containsKey('$base.other') ? base : null;
  }

  Map<String, dynamic> readJson(String code) =>
      jsonDecode(File('assets/l10n/$code.json').readAsStringSync())
          as Map<String, dynamic>;

  /// Files that may legitimately hold non-Latin literals.
  ///
  /// Each is listed with the reason, so the list cannot quietly grow.
  const literalAllowlist = <String, String>{
    // Digit glyph maps. These are numerals, not sentences — they are the
    // mechanism by which numbers get localised, so they cannot come from a
    // translation file themselves.
    'lib/utils/extensions/date_time_extensions.dart': 'Arabic-Indic digit map',
    'lib/utils/helpers/input_formatters.dart': 'Arabic-Indic digit map',
    // The single fallback character in an avatar with no name and no photo.
    'lib/common/widgets/ds/app_status_banner.dart': 'avatar fallback glyph',
    // Letters, not copy: the folding rules that make «الشاورما» and
    // «شاورمة» one word for search. There is nothing here a translator
    // could translate.
    'lib/utils/helpers/arabic_text.dart': 'Arabic letter folding',
    // Each language named in ITSELF in the language picker — «العربية», not
    // a translation of «Arabic» — so it is findable whatever the app is in.
    'lib/features/settings/presentation/ui/widgets/settings_pickers.dart':
        'language endonyms',
  };

  final arabic = RegExp('[؀-ۿ]');
  final literal = RegExp("'([^'\n]*[؀-ۿ][^'\n]*)'");

  List<File> dartFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where(
        (f) =>
            !f.path.endsWith('.g.dart') &&
            !f.path.endsWith('.freezed.dart') &&
            !f.path.endsWith('.config.dart'),
      )
      .toList();

  String relative(File f) => f.path.replaceAll(r'\', '/');

  test('no hard-coded Arabic text outside the allowlist', () {
    final offenders = <String>[];

    for (final file in dartFiles()) {
      final path = relative(file);
      if (literalAllowlist.containsKey(path)) continue;

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Doc comments and comments may name a string while explaining it.
        if (line.trimLeft().startsWith('//')) continue;
        for (final match in literal.allMatches(line)) {
          offenders.add('$path:${i + 1}  ${match.group(1)}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Use AppStrings instead. Add a key to assets/l10n/*.json and run '
          '`dart run tool/generate_app_strings.dart`.\n${offenders.join('\n')}',
    );
  });

  test('only the generated file calls .tr()', () {
    // …and the hand-written half of `AppStrings`, whose `_plural` is the one
    // place a counted sentence is resolved.
    const facade = 'lib/utils/helpers/app_strings.dart';
    final offenders = <String>[];

    for (final file in dartFiles()) {
      final path = relative(file);
      if (path == facade) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trimLeft().startsWith('//')) continue;
        if (lines[i].contains('.tr(') || lines[i].contains('.plural(')) {
          offenders.add('$path:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Call AppStrings instead of .tr() directly — the generated getter is '
          'compiler-checked, a raw key string is not.\n${offenders.join('\n')}',
    );
  });

  test('the same value never belongs to two keys', () {
    // The generator refuses to run when this is violated, but the check lives
    // here too: a stale generated file would otherwise hide the problem until
    // someone happens to regenerate.
    for (final code in <String>['ar', 'en']) {
      final data =
          jsonDecode(File('assets/l10n/$code.json').readAsStringSync())
              as Map<String, dynamic>;

      final byValue = <String, List<String>>{};
      data.forEach((key, value) {
        byValue
            .putIfAbsent((value as String).trim(), () => <String>[])
            .add(key);
      });

      final duplicates = byValue.entries.where((e) => e.value.length > 1);
      expect(
        duplicates.map((e) => '"${e.key}" -> ${e.value.join(' · ')}').toList(),
        isEmpty,
        reason: '$code.json reuses a value across keys',
      );
    }
  });

  test('the generated file is in step with the JSON', () {
    // A key added to the JSON without regenerating is invisible to the app; a
    // key removed leaves a getter that throws at runtime.
    final ar =
        jsonDecode(File('assets/l10n/ar.json').readAsStringSync())
            as Map<String, dynamic>;
    final generated = File(
      'lib/utils/gen/app_strings.g.dart',
    ).readAsStringSync();

    // A plural form is generated as its group: `time.hoursAgo.two` lives in
    // `timeHoursAgo`.
    final missing = ar.keys
        .map((k) => pluralBaseOf(ar, k) ?? k)
        .where((k) => !generated.contains("'$k'"))
        .toSet()
        .toList();
    expect(
      missing,
      isEmpty,
      reason:
          'Run `dart run tool/generate_app_strings.dart`. Not generated: '
          '${missing.join(', ')}',
    );
  });

  test('a template key generates a method, not a getter', () {
    // A getter for a `{}` value would put a literal `{}` on screen.
    final ar =
        jsonDecode(File('assets/l10n/ar.json').readAsStringSync())
            as Map<String, dynamic>;
    final generated = File(
      'lib/utils/gen/app_strings.g.dart',
    ).readAsStringSync();

    for (final entry in ar.entries) {
      if (pluralBaseOf(ar, entry.key) != null) continue;
      if (!(entry.value as String).contains('{}')) continue;
      final line = generated
          .split('\n')
          .firstWhere((l) => l.contains("'${entry.key}'"), orElse: () => '');
      expect(
        line,
        contains('args:'),
        reason: '${entry.key} is a template but was generated without args',
      );
      expect(
        line,
        isNot(contains('static String get ')),
        reason: '${entry.key} is a template but was generated as a getter',
      );
    }
  });

  test('a plural group generates ONE method that takes the count', () {
    final ar = readJson('ar');
    final generated = File(
      'lib/utils/gen/app_strings.g.dart',
    ).readAsLinesSync();

    final bases = ar.keys.map((k) => pluralBaseOf(ar, k)).nonNulls.toSet();
    expect(bases, isNotEmpty);
    for (final base in bases) {
      final line = generated.firstWhere(
        (l) => l.contains("_plural('$base',"),
        orElse: () => '',
      );
      expect(line, contains('(num count, String n'), reason: base);
    }
  });

  test('every counted Arabic sentence writes the forms Arabic changes', () {
    // One is «ساعة», two is «ساعتين», three to ten is «ساعات»: without the
    // three, the general form prints «منذ 2 ساعة». `{n}` in the general form
    // is where the count goes — in every language.
    final ar = readJson('ar');
    final en = readJson('en');
    final bases = ar.keys.map((k) => pluralBaseOf(ar, k)).nonNulls.toSet();

    for (final base in bases) {
      for (final form in <String>['one', 'two', 'few', 'other']) {
        expect(ar.containsKey('$base.$form'), isTrue, reason: '$base.$form');
      }
      expect(ar['$base.other'], contains('{n}'), reason: 'ar $base.other');
      expect(en['$base.other'], contains('{n}'), reason: 'en $base.other');
    }
  });

  test('no count is left in a fixed template', () {
    // A `{}` right before a counted noun is a number with one form. It is
    // what «11 محل» and «1 تعليقات» were.
    final counted = RegExp(
      r'\{\}\s*(ساع|أيام|يوم|دقائق|دقيق|تعليق|إعجاب|مشاهد|محل|تقييم|'
      r'تنبيه|عنصر|عناصر|نتيج|نتائج)',
    );
    final ar = readJson('ar');
    final offenders = ar.entries
        .where((e) => pluralBaseOf(ar, e.key) == null)
        .where((e) => counted.hasMatch(e.value as String))
        .map((e) => '${e.key}: ${e.value}')
        .toList();
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('a plural method is handed the count THROUGH AppFormats', () {
    // Never a raw number into a template. The count picks the form;
    // the second argument is what the reader sees, and it must be formatted.
    final ar = readJson('ar');
    final generated = File(
      'lib/utils/gen/app_strings.g.dart',
    ).readAsStringSync();
    final names = RegExp(r"static String (\w+)\(num count, String n")
        .allMatches(generated)
        .map((m) => m.group(1)!)
        .toSet();
    expect(names.length, ar.keys.map((k) => pluralBaseOf(ar, k)).nonNulls.toSet().length);

    final offenders = <String>[];
    for (final file in dartFiles()) {
      final source = file.readAsStringSync();
      for (final name in names) {
        for (final match in RegExp('AppStrings\\.$name\\(').allMatches(source)) {
          final args = _topLevelArguments(source, match.end);
          final shown = args.length > 1 ? args[1] : '';
          if (!shown.contains('AppFormats.') && !shown.contains('number(')) {
            offenders.add('${relative(file)}: $name(${args.join(', ')})');
          }
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('every Arabic value actually contains Arabic', () {
    final ar =
        jsonDecode(File('assets/l10n/ar.json').readAsStringSync())
            as Map<String, dynamic>;

    // A language names ITSELF in its own script wherever it is offered:
    // the picker reads «العربية» · «English».
    // The app's name is a brand: it may stay in Latin letters in Arabic.
    const exempt = <String>{'app.name', 'settings.languageEnglish'};

    for (final entry in ar.entries) {
      if (exempt.contains(entry.key)) continue;
      final value = entry.value as String;
      // A value that is only a placeholder, punctuation or a brand name is fine.
      if (!RegExp('[A-Za-z]{4,}').hasMatch(value)) continue;
      expect(
        arabic.hasMatch(value),
        isTrue,
        reason: 'ar.${entry.key} looks untranslated: "$value"',
      );
    }
  });
}

/// The comma-separated arguments of a call whose `(` ends at [start].
List<String> _topLevelArguments(String source, int start) {
  final args = <String>[];
  final current = StringBuffer();
  var depth = 0;
  for (var i = start; i < source.length; i++) {
    final char = source[i];
    if (char == '(' || char == '[' || char == '{') depth++;
    if (char == ')' || char == ']' || char == '}') {
      if (depth == 0) break;
      depth--;
    }
    if (char == ',' && depth == 0) {
      args.add(current.toString().trim());
      current.clear();
      continue;
    }
    current.write(char);
  }
  if (current.toString().trim().isNotEmpty) args.add(current.toString().trim());
  return args;
}
