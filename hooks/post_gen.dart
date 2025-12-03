import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final includeFlavors = context.vars['include_flavors'] as bool? ?? false;

  if (!includeFlavors) {
    logger.info('Skipping flutter_flavorizr (include_flavors is false).');
    return;
  }

  final progress = logger.progress('Running flutter_flavorizr...');

  try {
    final pubGetResult = await Process.run('flutter', [
      'pub',
      'get',
    ], runInShell: true);

    final pubGetStdout = pubGetResult.stdout?.toString();
    final pubGetStderr = pubGetResult.stderr?.toString();

    if (pubGetStdout != null && pubGetStdout.isNotEmpty) {
      logger.info(pubGetStdout);
    }
    if (pubGetStderr != null && pubGetStderr.isNotEmpty) {
      logger.err(pubGetStderr);
    }

    if (pubGetResult.exitCode != 0) {
      logger.err(
        '`flutter pub get` exited with code ${pubGetResult.exitCode}.',
      );
      return;
    }

    final result = await Process.run('flutter', [
      'pub',
      'run',
      'flutter_flavorizr',
      '-f',
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
  } finally {
    progress.complete();
  }
}
