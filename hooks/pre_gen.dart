import 'package:mason/mason.dart';

void run(HookContext context) {
  final vars = Map<String, dynamic>.from(context.vars);

  final rawProjectName = _readString(vars['project_name'], 'my_app');
  final projectName = _dartPackageName(rawProjectName);

  final rawProjectTitle = _readString(vars['project_title'], '');
  final projectTitle = rawProjectTitle.isEmpty
      ? _titleFromPackageName(projectName)
      : rawProjectTitle.trim();

  final rawPackageName = _readString(vars['package_name'], '');
  final packageName = _bundleIdentifier(rawPackageName, projectName);

  final projectDescription = _readString(
    vars['project_description'],
    'A Flutter Clean Architecture project.',
  );

  context.vars = <String, dynamic>{
    ...vars,
    'raw_project_name': rawProjectName,
    'project_name': projectName,
    'project_name_yaml': _yamlSingleQuoted(projectName),
    'project_title': projectTitle,
    'project_title_dart_literal': _dartStringLiteral(projectTitle),
    'project_title_yaml': _yamlSingleQuoted(projectTitle),
    'project_description': projectDescription,
    'project_description_yaml': _yamlSingleQuoted(projectDescription),
    'package_name': packageName,
    'package_name_yaml': _yamlSingleQuoted(packageName),
    'stage_project_title': '$projectTitle Stage',
    'stage_project_title_dart_literal': _dartStringLiteral(
      '$projectTitle Stage',
    ),
    'stage_project_title_yaml': _yamlSingleQuoted('$projectTitle Stage'),
    'stage_package_name': '$packageName.stage',
    'stage_package_name_yaml': _yamlSingleQuoted('$packageName.stage'),
  };

  _logChange(
    context,
    label: 'Dart package name',
    raw: rawProjectName,
    normalized: projectName,
  );
  _logChange(
    context,
    label: 'Package/bundle id',
    raw: rawPackageName,
    normalized: packageName,
  );
}

String _readString(Object? value, String fallback) {
  final raw = value?.toString().trim() ?? '';
  return raw.isEmpty ? fallback : raw;
}

String _dartPackageName(String input) {
  final normalized = input
      .trim()
      .replaceAll(RegExp(r'([a-z0-9])([A-Z])'), r'$1_$2')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  final fallback = normalized.isEmpty ? 'my_app' : normalized;
  final identifier = RegExp(r'^[a-z]').hasMatch(fallback)
      ? fallback
      : 'app_$fallback';

  return _dartKeywords.contains(identifier) ? 'app_$identifier' : identifier;
}

String _bundleIdentifier(String input, String projectName) {
  final base = input.trim().isEmpty ? 'com.example.$projectName' : input.trim();
  final segments = base
      .split('.')
      .map(_bundleSegment)
      .where((segment) => segment.isNotEmpty)
      .toList();

  if (segments.length >= 2) return segments.join('.');

  final appSegment = _bundleSegment(projectName).replaceAll('_', '');
  return 'com.example.$appSegment';
}

String _bundleSegment(String input) {
  final normalized = input
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '')
      .replaceAll(RegExp(r'^[^a-z]+'), '');

  if (normalized.isEmpty) return '';
  return normalized;
}

String _titleFromPackageName(String packageName) {
  return packageName
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

String _yamlSingleQuoted(String value) {
  return "'${value.replaceAll("'", "''")}'";
}

String _dartStringLiteral(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$')
      .replaceAll('\r', r'\r')
      .replaceAll('\n', r'\n');

  return "'$escaped'";
}

void _logChange(
  HookContext context, {
  required String label,
  required String raw,
  required String normalized,
}) {
  if (raw.trim().isEmpty || raw == normalized) {
    context.logger.info('$label: $normalized');
    return;
  }

  context.logger.warn('$label normalized: "$raw" -> "$normalized"');
}

const _dartKeywords = <String>{
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'type',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};
