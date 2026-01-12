import 'dart:async';
import 'dart:convert';

import 'package:dio_refresh_bot/dio_refresh_bot.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../utils/constants/auth_constants.dart';
import '../../../utils/helpers/colored_print.dart';
import '../storage/storage_service.dart';
import 'auth_token_model.dart';

/// Token storage that bridges secure persistence and dio_refresh_bot.
///
/// Persists [AuthTokenModel] plus a concrete expiry timestamp in
/// [StorageService] while exposing the in-memory token to dio_refresh_bot via
/// [BotMemoryTokenStorage] and [RefreshBotMixin].
@lazySingleton
class JwtTokenStorage extends BotMemoryTokenStorage<AuthTokenModel>
    with RefreshBotMixin<AuthTokenModel> {
  JwtTokenStorage(this._storage) : super();

  final StorageService _storage;

  AuthTokenModel? _cachedToken;
  DateTime? _cachedExpiry;

  AuthTokenModel? get cachedToken => _cachedToken;

  /// Loads a previously stored token and initializes the in-memory cache.
  Future<void> initialize() async {
    try {
      final String? raw = await _storage.readString(
        AuthStorageKeys.jwtToken,
        area: StorageArea.secure,
      );
      if (raw == null || raw.isEmpty) {
        printY('${AuthLogTags.jwtTokenStorage} no token found in storage');
        _cachedToken = null;
        await super.write(null);
        return;
      }

      final Map<String, dynamic> jsonMap =
          json.decode(raw) as Map<String, dynamic>;

      final token = AuthTokenModel.fromMap(jsonMap);
      final expiry = _readOrDeriveExpiry(jsonMap, token);

      if (_isExpired(expiry)) {
        printY('${AuthLogTags.jwtTokenStorage} stored token is expired');
        // Keep the token so dio_refresh_bot can attempt a refresh on the first
        // protected call (401) instead of forcing an immediate logout on app
        // start.
        _cachedToken = token;
        _cachedExpiry = expiry;
        await super.write(token);
        return;
      }

      _cachedToken = token;
      _cachedExpiry = expiry;
      printC('${AuthLogTags.jwtTokenStorage} token restored from storage');
      await super.write(token);
    } catch (e) {
      printR('${AuthLogTags.jwtTokenStorage} initialize error: $e');
      await _clearStorage();
      _cachedToken = null;
      await super.write(null);
    }
  }

  /// Writes the given [token] to secure storage and updates the in-memory
  /// representation used by dio_refresh_bot.
  @override
  FutureOr<void> write(AuthTokenModel? token) async {
    if (token == null || token.accessToken.isEmpty) {
      printY('${AuthLogTags.jwtTokenStorage} clearing token');
      await _clearStorage();
      _cachedToken = null;
      _cachedExpiry = null;
      await super.write(null);
      return;
    }

    _cachedToken = token;
    final expiry = _deriveExpiry(token);
    _cachedExpiry = expiry;

    final map = <String, dynamic>{
      ...token.toMap(),
      AuthTokenJsonFields.expiry: expiry.toIso8601String(),
    };

    await _storage.writeString(
      AuthStorageKeys.jwtToken,
      json.encode(map),
      area: StorageArea.secure,
    );

    printG('${AuthLogTags.jwtTokenStorage} token written to storage');
    await super.write(token);
    return null;
  }

  /// Deletes any persisted token and clears the in-memory cache.
  @override
  FutureOr<void> delete([String? message]) async {
    printY('${AuthLogTags.jwtTokenStorage} delete (reason: $message)');
    await _clearStorage();
    _cachedToken = null;
    _cachedExpiry = null;
    await super.delete(message);
    return null;
  }

  /// Returns `true` when a non-expired token exists in storage.
  Future<bool> hasValidTokens() async {
    final expiry = _cachedExpiry ?? await _loadExpiryFromStorage();
    if (expiry == null) return false;
    return !_isExpired(expiry);
  }

  Future<DateTime?> loadExpiry() async {
    return _cachedExpiry ?? await _loadExpiryFromStorage();
  }

  Future<Duration?> remainingUntilExpiry() async {
    final expiry = await loadExpiry();
    if (expiry == null) return null;
    return expiry.difference(DateTime.now());
  }

  Future<void> _clearStorage() async {
    await _storage.remove(AuthStorageKeys.jwtToken, area: StorageArea.secure);
  }

  Future<DateTime?> _loadExpiryFromStorage() async {
    final String? raw = await _storage.readString(
      AuthStorageKeys.jwtToken,
      area: StorageArea.secure,
    );
    if (raw == null || raw.isEmpty) return null;

    try {
      final Map<String, dynamic> jsonMap =
          json.decode(raw) as Map<String, dynamic>;
      final rawExpiry = jsonMap[AuthTokenJsonFields.expiry] as String?;
      if (rawExpiry == null) return null;
      return DateTime.parse(rawExpiry);
    } catch (e) {
      printR('${AuthLogTags.jwtTokenStorage} loadExpiry error: $e');
      return null;
    }
  }

  DateTime _deriveExpiry(AuthTokenModel token) {
    // Prefer absolute expiry derived from JWT. If it fails, fall back to
    // expiresIn when provided, otherwise use a short default.
    try {
      return JwtDecoder.getExpirationDate(token.accessToken);
    } catch (_) {
      if (token.expiresIn != null) {
        return DateTime.now().add(Duration(seconds: token.expiresIn!));
      }
      printY('${AuthLogTags.jwtTokenStorage} expiry decode failed, using 1h');
      return DateTime.now().add(const Duration(hours: 1));
    }
  }

  DateTime _readOrDeriveExpiry(Map<String, dynamic> map, AuthTokenModel token) {
    final rawExpiry = map[AuthTokenJsonFields.expiry] as String?;
    if (rawExpiry != null) {
      return DateTime.parse(rawExpiry);
    }
    return _deriveExpiry(token);
  }

  bool _isExpired(DateTime expiry) => DateTime.now().isAfter(expiry);
}
