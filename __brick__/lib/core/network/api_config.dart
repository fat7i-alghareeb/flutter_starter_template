import '../../flavors.dart';
import '../../utils/helpers/colored_print.dart';

class ApiConfig {
  ApiConfig._();

  static const String _stageBaseUrl = '';
  static const String _productionBaseUrl = '';

  static bool _hasLoggedBaseUrl = false;

  static String get baseUrl {
    final url = _selectBaseUrl();
    _logBaseUrlOnce(url);
    return url;
  }

  static String _selectBaseUrl() {
    switch (F.appFlavor) {
      case Flavor.stage:
        return _stageBaseUrl;
      case Flavor.production:
        return _productionBaseUrl;
    }
  }

  static void _logBaseUrlOnce(String url) {
    if (_hasLoggedBaseUrl) return;
    _hasLoggedBaseUrl = true;

    if (url.isEmpty) {
      printY(
        '[ApiConfig] Base URL is empty for flavor: ${F.name}. Configure it before using network calls.',
      );
    } else {
      printC('[ApiConfig] Using base URL (${F.name}): $url');
    }
  }
}
