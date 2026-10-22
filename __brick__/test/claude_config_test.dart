import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps the Claude Code set-up honest.
///
/// Every line of `CLAUDE.md` is paid for in every chat, so it stays small;
/// everything else is loaded on demand. These tests stop it growing back,
/// and stop a rule, a skill or the settings from pointing at nothing.
void main() {
  List<String> linesOf(String path) => File(path).readAsLinesSync();

  test('CLAUDE.md stays small and imports the digest', () {
    final lines = linesOf('CLAUDE.md');
    // The imported digest (.ai/project-rules.md) is loaded as well, so this
    // file is the small half. Raise the limit deliberately, never by drift.
    expect(lines.length, lessThanOrEqualTo(90), reason: 'CLAUDE.md is loaded every chat');

    final imports = lines
        .where((l) => l.startsWith('@'))
        .map((l) => l.substring(1).trim())
        .toList();
    expect(imports, contains('.ai/project-rules.md'));
    for (final path in imports) {
      expect(File(path).existsSync(), isTrue, reason: 'imports $path');
    }
  });

  test('the digest it imports stays under 200 lines', () {
    expect(linesOf('.ai/project-rules.md').length, lessThanOrEqualTo(200));
  });

  group('path-scoped rules', () {
    final rules = Directory('.claude/rules')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList();

    test('there are some', () => expect(rules, isNotEmpty));

    for (final file in rules) {
      final name = file.uri.pathSegments.last;
      test('$name has paths that point at real folders', () {
        final lines = file.readAsLinesSync();
        expect(lines.first, '---');
        final end = lines.indexOf('---', 1);
        expect(end, greaterThan(1), reason: 'frontmatter must close');

        final paths = lines
            .sublist(1, end)
            .where((l) => l.trimLeft().startsWith('- '))
            .map((l) => l.trim().substring(2).replaceAll('"', ''))
            .toList();
        expect(paths, isNotEmpty, reason: 'a rule without paths loads every chat');

        for (final glob in paths) {
          final base = glob.split('/').first;
          // Platform folders are made by `flutter create`, after the brick.
          const platformFolders = <String>['android', 'ios', 'windows', 'macos', 'linux', 'web'];
          expect(
            Directory(base).existsSync() ||
                File(base).existsSync() ||
                base.startsWith('*') ||
                platformFolders.contains(base),
            isTrue,
            reason: '$glob starts at "$base", which does not exist',
          );
        }
        expect(lines.length, lessThan(60), reason: 'a rule is a digest, not a guide');
      });
    }
  });

  group('skills', () {
    final dirs = Directory('.claude/skills').listSync().whereType<Directory>();

    for (final dir in dirs) {
      final name = dir.uri.pathSegments.where((s) => s.isNotEmpty).last;
      test('$name is manual-only and well formed', () {
        final lines = linesOf('${dir.path}/SKILL.md');
        expect(lines.first, '---');
        final front = lines.sublist(1, lines.indexOf('---', 1)).join('\n');
        expect(front, contains('name: $name'));
        // A skill the model may invoke puts its description in every chat.
        expect(front, contains('disable-model-invocation: true'));
        expect(lines.length, lessThan(500));
      });
    }
  });

  group('settings', () {
    final settings =
        jsonDecode(File('.claude/settings.json').readAsStringSync()) as Map<String, dynamic>;
    final permissions = settings['permissions'] as Map<String, dynamic>;

    test('generated files cannot be read or edited', () {
      final deny = (permissions['deny'] as List).cast<String>();
      expect(deny, contains('Read(**/*.freezed.dart)'));
      expect(deny, contains('Edit(**/*.g.dart)'));
      expect(deny, contains('Read(build/**)'));
    });

    test('the checks run without a prompt', () {
      final allow = (permissions['allow'] as List).cast<String>();
      expect(allow, contains('Bash(flutter analyze *)'));
      expect(allow, contains('Bash(flutter test *)'));
    });

    test('nothing destructive is pre-approved', () {
      final allow = (permissions['allow'] as List).cast<String>().join(' ');
      for (final word in <String>['rm ', 'git push', 'git commit', 'git reset']) {
        expect(allow, isNot(contains(word)));
      }
    });

    test('the hook script it names exists', () {
      final hooks = settings['hooks'] as Map<String, dynamic>;
      final text = jsonEncode(hooks);
      expect(text, contains('tool/claude_test_filter.dart'));
      expect(File('tool/claude_test_filter.dart').existsSync(), isTrue);
    });
  });

  group('the feature routine', () {
    test('/finish exists, and CLAUDE.md names it, the style guide and the catalogue', () {
      expect(File('.claude/skills/finish/SKILL.md').existsSync(), isTrue);
      final claude = File('CLAUDE.md').readAsStringSync();
      expect(claude, contains('/finish'));
      expect(claude, contains('docs/CODE_STYLE.md'));
      expect(claude, contains('tool/widget_catalog.dart'));
    });

    test('the style guide names a reference feature that exists', () {
      final style = File('docs/CODE_STYLE.md').readAsStringSync();
      final match = RegExp(r'Reference feature:\*\* `([^`]+)`').firstMatch(style);
      expect(match, isNotNull, reason: 'CODE_STYLE.md must name the reference feature');
      expect(Directory(match!.group(1)!).existsSync(), isTrue);
    });

    test('the duplicate check script exists', () {
      expect(File('tool/widget_catalog.dart').existsSync(), isTrue);
    });
  });

  test('personal Claude files are git-ignored', () {
    final ignore = File('.gitignore').readAsStringSync();
    expect(ignore, contains('CLAUDE.local.md'));
    expect(ignore, contains('.claude/settings.local.json'));
  });
}
