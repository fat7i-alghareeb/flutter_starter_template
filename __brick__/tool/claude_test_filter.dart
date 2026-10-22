import 'dart:convert';
import 'dart:io';

/// A Claude Code `PreToolUse` hook (see `.claude/settings.json`): a plain
/// `flutter test` prints a line for every test that ran, which is thousands of
/// tokens Claude never needs. This adds `--reporter=failures-only` — failures
/// and the final summary only.
///
/// It touches nothing else: no reporter is added when one is already named,
/// and a compound command (`&&`, `;`, `|`) is left exactly as written.
Future<void> main() async {
  final input = await utf8.decoder.bind(stdin).join();
  final decoded = jsonDecode(input);
  final toolInput = decoded is Map ? decoded['tool_input'] : null;
  final command = toolInput is Map ? toolInput['command'] : null;

  if (command is! String || !_shouldRewrite(command)) {
    stdout.write('{}');
    return;
  }

  final rewritten = <String, Object?>{
    ...Map<String, Object?>.from(toolInput as Map),
    'command': '$command --reporter=failures-only',
  };
  stdout.write(
    jsonEncode(<String, Object?>{
      'hookSpecificOutput': <String, Object?>{
        'hookEventName': 'PreToolUse',
        'updatedInput': rewritten,
      },
    }),
  );
}

bool _shouldRewrite(String command) {
  final trimmed = command.trim();
  if (!RegExp(r'^flutter test(\s|$)').hasMatch(trimmed)) return false;
  if (trimmed.contains('--reporter') || trimmed.contains('-r ')) return false;
  return !RegExp(r'[;&|<>`$]').hasMatch(trimmed);
}
