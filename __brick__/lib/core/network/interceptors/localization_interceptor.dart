import 'package:dio/dio.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';

import '../../services/localization/locale_service.dart';
import '../../../utils/helpers/colored_print.dart';

/// Adds localization-related headers to every request.
///
/// - `lang`: current language code (e.g. `en`, `ar`).
/// - `X-TimeZoneId`: device time zone identifier.
@lazySingleton
class LocalizationInterceptor extends Interceptor {
  LocalizationInterceptor(this._localeService);

  final LocaleService _localeService;
  String? _cachedTimeZone;

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final langCode = await _localeService.currentLanguageCode();
      final timeZone = await _currentTimeZone();

      options.headers.addAll(<String, Object?>{
        'lang': langCode,
        'X-TimeZoneId': timeZone,
      });

      printC('LocalizationInterceptor → lang=$langCode, tz=$timeZone');
    } catch (e) {
      // Fallback silently if anything goes wrong – network calls should
      // still proceed without localization headers.
      printY('LocalizationInterceptor error: $e');
    }

    handler.next(options);
  }

  Future<String> _currentTimeZone() async {
    final cached = _cachedTimeZone;
    if (cached != null && cached.isNotEmpty) return cached;

    final timeZone = await FlutterTimezone.getLocalTimezone();
    _cachedTimeZone = timeZone.identifier;
    return timeZone.identifier;
  }
}
