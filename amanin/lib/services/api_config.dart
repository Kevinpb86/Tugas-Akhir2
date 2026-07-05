import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_config_local.dart';

class ApiConfig {
  // URL otomatis dipilih berdasarkan platform:
  // - Web (Chrome): http://127.0.0.1:8000
  // - HP Android fisik: menggunakan localBackendIp dari api_config_local.dart
  
  static const String _webUrl = 'http://127.0.0.1:8000';
  static const String _androidUrl = 'http://$localBackendIp:8000';
  
  static String get baseUrl => kIsWeb ? _webUrl : _androidUrl;
}
