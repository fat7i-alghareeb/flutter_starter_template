import '../../utils/helpers/colored_print.dart';

class ApiConfig {
  ApiConfig._();

  static const String _baseUrl = '';

  static bool _hasLoggedBaseUrl = false;

  static String get baseUrl {
    _logBaseUrlOnce(_baseUrl);
    return _baseUrl;
  }

  static void _logBaseUrlOnce(String url) {
    if (_hasLoggedBaseUrl) return;
    _hasLoggedBaseUrl = true;

    if (url.isEmpty) {
      printY(
        '[ApiConfig] Base URL is empty. Configure it before using network calls.',
      );
    } else {
      printC('[ApiConfig] Using base URL: $url');
    }
  }
}
