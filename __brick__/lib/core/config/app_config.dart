import '../../flavors.dart';
import '../network/api_config.dart';

class AppConfig {
  AppConfig._();

  static Flavor get flavor => F.appFlavor;

  static String get apiBaseUrl => ApiConfig.baseUrl;
}
