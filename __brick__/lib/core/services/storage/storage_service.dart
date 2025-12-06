import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Defines which underlying storage to use.
///
/// [persistent] is intended for non-sensitive user preferences while
/// [secure] is backed by [FlutterSecureStorage] and should be used for
/// secrets such as tokens.
enum StorageArea {
  persistent,
  secure,
}

/// Minimal key–value interface implemented by concrete storage backends.
abstract class KeyValueStore {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
  Future<bool?> readBool(String key);
  Future<void> writeBool(String key, bool value);
  Future<void> remove(String key);
}

class _SharedPreferencesStore implements KeyValueStore {
  _SharedPreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> readString(String key) async => _prefs.getString(key);

  @override
  Future<void> writeString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<bool?> readBool(String key) async => _prefs.getBool(key);

  @override
  Future<void> writeBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}

class _SecureStorageStore implements KeyValueStore {
  _SecureStorageStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readString(String key) => _storage.read(key: key);

  @override
  Future<void> writeString(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<bool?> readBool(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return null;
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    return null;
  }

  @override
  Future<void> writeBool(String key, bool value) =>
      _storage.write(key: key, value: value.toString());

  @override
  Future<void> remove(String key) => _storage.delete(key: key);
}

/// High-level storage façade that unifies shared preferences and secure
/// storage under a single, testable API.
class StorageService {
  StorageService._(this._persistent, this._secure);

  /// Creates a service that uses [SharedPreferences] for both areas.
  factory StorageService.sharedOnly(SharedPreferences sharedPreferences) {
    return StorageService._(
      _SharedPreferencesStore(sharedPreferences),
      _SharedPreferencesStore(sharedPreferences),
    );
  }

  /// Creates a service that uses [SharedPreferences] for persistent data and
  /// [FlutterSecureStorage] for secrets.
  factory StorageService.withSecure({
    required SharedPreferences sharedPreferences,
    required FlutterSecureStorage secureStorage,
  }) {
    return StorageService._(
      _SharedPreferencesStore(sharedPreferences),
      _SecureStorageStore(secureStorage),
    );
  }

  /// Convenience factory for creating a production-ready instance using the
  /// platform defaults for both shared preferences and secure storage.
  static Future<StorageService> createDefault({
    FlutterSecureStorage? secureStorage,
  }) async {
    final shared = await SharedPreferences.getInstance();
    final secure = secureStorage ?? const FlutterSecureStorage();
    return StorageService.withSecure(
      sharedPreferences: shared,
      secureStorage: secure,
    );
  }

  final KeyValueStore _persistent;
  final KeyValueStore _secure;

  KeyValueStore _select(StorageArea area) =>
      area == StorageArea.secure ? _secure : _persistent;

  Future<String?> readString(
    String key, {
    StorageArea area = StorageArea.persistent,
  }) =>
      _select(area).readString(key);

  Future<void> writeString(
    String key,
    String value, {
    StorageArea area = StorageArea.persistent,
  }) =>
      _select(area).writeString(key, value);

  Future<bool?> readBool(
    String key, {
    StorageArea area = StorageArea.persistent,
  }) =>
      _select(area).readBool(key);

  Future<void> writeBool(
    String key,
    bool value, {
    StorageArea area = StorageArea.persistent,
  }) =>
      _select(area).writeBool(key, value);

  Future<void> remove(
    String key, {
    StorageArea area = StorageArea.persistent,
  }) =>
      _select(area).remove(key);
}
