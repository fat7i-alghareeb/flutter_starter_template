import 'dart:convert';
import 'dart:io';

/// Reads the real fixtures from `assets/mock/`.
///
/// Tests load the SAME files the app runs on, rather than inline literals. A
/// test that invents its own JSON keeps passing after the fixture drifts out of
/// shape — which is precisely the bug worth catching.
///
/// `rootBundle` is not used: these run in a plain VM test with no asset bundle,
/// so the files are read from disk relative to the package root.
class Fixtures {
  Fixtures._();

  static const String _root = 'assets/mock';

  /// Every fixture path under `assets/mock/`.
  static List<String> all() {
    final dir = Directory(_root);
    if (!dir.existsSync()) return const <String>[];
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => f.path.replaceAll(r'\', '/'))
        .toList()
      ..sort();
  }

  /// Decodes one fixture, e.g. `news/list.json`.
  static Map<String, dynamic> read(String relative) {
    final file = File('$_root/$relative');
    if (!file.existsSync()) {
      throw StateError('No fixture at ${file.path}');
    }
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  /// The `data` payload of a fixture, already unwrapped from the envelope.
  static dynamic data(String relative) => read(relative)['data'];

  /// The `data` payload as a list.
  static List<Map<String, dynamic>> list(String relative) =>
      (data(relative) as List<dynamic>).cast<Map<String, dynamic>>();
}
