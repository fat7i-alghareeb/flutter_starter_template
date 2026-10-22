import 'dart:math';

import 'package:mason/mason.dart';

/// Runs before `mason make` writes anything.
///
/// Adds the variables the brick derives instead of asking for:
///
/// - `windows_toast_guid` — the GUID Windows files this app's toast
///   notifications under, and the id Inno Setup uses to recognise an
///   earlier install of the same app. One per project, for its lifetime:
///   change it and Windows treats the app as a new one. A GUID passed on
///   the command line (`--windows_toast_guid`) wins.
void run(HookContext context) {
  final existing = context.vars['windows_toast_guid'];
  if (existing is String && existing.trim().isNotEmpty) return;
  context.vars = <String, dynamic>{
    ...context.vars,
    'windows_toast_guid': _uuidV4(),
  };
}

/// A random (version 4) UUID, lower case — from the secure generator.
String _uuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int from, int to) => bytes
      .sublist(from, to)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
