import 'dart:convert';
import 'dart:io';

import 'package:test_name_to_delete/core/config/localization_config.dart';

/// Generates lib/utils/gen/app_strings.g.dart from all
/// JSON files declared in [AppLocalizationConfig.supportedLanguageCodes].
///
/// - Only keys that exist in **all** languages are generated.
/// - Each getter is camelCase and uses 'key'.tr().
/// - Each getter has a doc comment with translations from all languages:
///   /// Welcome - مرحبا - ...
Future<void> main(List<String> args) async {
  const outputPath = 'lib/utils/gen/app_strings.g.dart';

  stdout.writeln('🌐 AppStrings generator starting...');
  stdout.writeln(
    '📁 Translations path: ${AppLocalizationConfig.translationsPath}',
  );
  stdout.writeln(
    '🈯 Supported languages: ${AppLocalizationConfig.supportedLanguageCodes.join(', ')}',
  );

  if (AppLocalizationConfig.supportedLanguageCodes.isEmpty) {
    stderr.writeln(
      '❌ No supportedLanguageCodes configured in AppLocalizationConfig.',
    );
    stderr.writeln('🛑 AppStrings generator FAILED.');
    exitCode = 1;
    return;
  }

  // Load and flatten all language JSON files.
  final languageMaps =
      <String, Map<String, String>>{}; // langCode -> keyPath -> value

  for (final code in AppLocalizationConfig.supportedLanguageCodes) {
    final inputPath = '${AppLocalizationConfig.translationsPath}/$code.json';
    final inputFile = File(inputPath);

    if (!await inputFile.exists()) {
      stderr.writeln('❌ Missing translations file for "$code": $inputPath');
      stderr.writeln('🛑 AppStrings generator FAILED.');
      exitCode = 1;
      return;
    }

    final raw = await inputFile.readAsString();
    if (raw.trim().isEmpty) {
      stderr.writeln('❌ Translation file for "$code" is empty: $inputPath');
      stderr.writeln('🛑 AppStrings generator FAILED.');
      exitCode = 1;
      return;
    }

    final decoded = json.decode(raw);
    if (decoded is! Map<String, dynamic>) {
      stderr.writeln(
        '❌ $inputPath must contain a top-level JSON object (found ${decoded.runtimeType}).',
      );
      stderr.writeln('🛑 AppStrings generator FAILED.');
      exitCode = 1;
      return;
    }

    final flat = _flattenJson(decoded);
    languageMaps[code] = flat;
    stdout.writeln('📖 [$code] loaded ${flat.length} keys from $inputPath');
  }

  // Compute keys present in ALL languages.
  final allKeys = <String>{};
  for (final map in languageMaps.values) {
    allKeys.addAll(map.keys);
  }

  Set<String>? commonKeys;
  for (final map in languageMaps.values) {
    commonKeys ??= map.keys.toSet();
    commonKeys = commonKeys.intersection(map.keys.toSet());
  }

  commonKeys ??= <String>{};

  // Report keys that are missing in some languages.
  final missingByKey =
      <String, List<String>>{}; // keyPath -> missing language codes
  for (final key in allKeys) {
    for (final code in AppLocalizationConfig.supportedLanguageCodes) {
      final map = languageMaps[code]!;
      if (!map.containsKey(key)) {
        missingByKey.putIfAbsent(key, () => <String>[]).add(code);
      }
    }
  }

  if (missingByKey.isNotEmpty) {
    stdout.writeln('⚠️ Keys missing in some languages:');
    for (final entry in missingByKey.entries) {
      stdout.writeln('   • ${entry.key} -> missing: ${entry.value.join(', ')}');
    }
    stderr.writeln(
      '🛑 AppStrings generator FAILED due to missing keys. '
      'Please add translations for all languages and run again.',
    );
    exitCode = 1;
    return;
  }

  final commonKeyList = commonKeys.toList()..sort();

  stdout.writeln('Common keys across all languages: ${commonKeyList.length}');

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln()
    ..writeln('part of app_strings;')
    ..writeln()
    ..writeln('class AppStrings {');

  for (final keyPath in commonKeyList) {
    final segments = keyPath.split('.');
    final propertyName = _camelOfKeyPath(segments);
    if (propertyName.isEmpty) continue;

    // Build doc comment with translations from all languages.
    final translations = <String>[];
    for (final code in AppLocalizationConfig.supportedLanguageCodes) {
      final value = languageMaps[code]![keyPath];
      if (value != null && value.toString().trim().isNotEmpty) {
        translations.add(_cleanDocText(value.toString()));
      }
    }

    if (translations.isNotEmpty) {
      buffer.writeln('  /// ${translations.join(' - ')}');
    }

    buffer.writeln("  static String get $propertyName => '$keyPath'.tr();");
  }

  buffer
    ..writeln('}')
    ..writeln();

  final outputFile = File(outputPath);
  await outputFile.create(recursive: true);
  await outputFile.writeAsString(buffer.toString());

  stdout.writeln('Generated ${commonKeyList.length} keys into $outputPath');
  stdout.writeln('✅ AppStrings generator SUCCESS.');
}

String _camelOfKeyPath(List<String> segments) {
  if (segments.isEmpty) return '';

  final convertedSegments = segments
      .map(_camelSegment)
      .where((s) => s.isNotEmpty)
      .toList();
  if (convertedSegments.isEmpty) return '';

  final buffer = StringBuffer();

  final first = convertedSegments.first;
  if (first.isNotEmpty) {
    buffer.write(first[0].toLowerCase());
    if (first.length > 1) {
      buffer.write(first.substring(1));
    }
  }

  for (final seg in convertedSegments.skip(1)) {
    if (seg.isEmpty) continue;
    buffer.write(_capitalize(seg));
  }

  return buffer.toString();
}

String _camelSegment(String input) {
  if (input.contains('_')) {
    final parts = input.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first.toLowerCase();
    final rest = parts.skip(1).map((p) => _capitalize(p.toLowerCase())).join();
    return first + rest;
  }

  // If there are no underscores, assume the segment is already a reasonable
  // identifier (e.g. camelCase). We keep it as-is.
  return input;
}

String _capitalize(String input) {
  if (input.isEmpty) return '';
  if (input.length == 1) return input.toUpperCase();
  return input[0].toUpperCase() + input.substring(1);
}

/// Flattens a nested JSON object into key paths, e.g.:
/// {"home": {"title": "..."}} -> {"home.title": "..."}
Map<String, String> _flattenJson(Map<String, dynamic> source) {
  final result = <String, String>{};

  void walk(Map<String, dynamic> map, List<String> segments) {
    map.forEach((key, value) {
      final current = <String>[...segments, key];
      if (value is Map<String, dynamic>) {
        walk(value, current);
      } else {
        final path = current.join('.');
        result[path] = value.toString();
      }
    });
  }

  walk(source, const []);
  return result;
}

/// Cleans a translation string for use in a single-line doc comment.
String _cleanDocText(String input) {
  return input.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
}
