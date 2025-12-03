import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final includeFlavors = context.vars['include_flavors'] as bool? ?? false;

  if (!includeFlavors) {
    logger.info('Skipping flutter_flavorizr (include_flavors is false).');
    return;
  }

  logger.info('Running `dart run flutter_flavorizr`...');

  try {
    final result = await Process.run('dart', [
      'run',
      'flutter_flavorizr',
    ], runInShell: true);

    final stdoutText = result.stdout?.toString();
    final stderrText = result.stderr?.toString();

    if (stdoutText != null && stdoutText.isNotEmpty) {
      logger.info(stdoutText);
    }
    if (stderrText != null && stderrText.isNotEmpty) {
      logger.err(stderrText);
    }

    if (result.exitCode != 0) {
      logger.err('flutter_flavorizr exited with code ${result.exitCode}.');
    } else {
      logger.info('flutter_flavorizr completed successfully.');
    }
  } catch (e) {
    logger.err('Failed to run flutter_flavorizr: $e');
  }
}
