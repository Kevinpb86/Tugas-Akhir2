import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_config_local.dart';

class ApiConfig {
  // URL otomatis dipilih berdasarkan platform:
  // - Web (Chrome): http://127.0.0.1:8000
  // - HP Android fisik: menggunakan localBackendIp dari api_config_local.dart
  
  static const String _webUrl = 'https://rpvzwb-ip-180-247-241-88.tunnelmole.net';
  
  // SILAKAN PILIH SALAH SATU URL DI BAWAH (Hanya boleh ada satu yang aktif):
  
  // Pilihan 1: Menggunakan IP Lokal Laptop (untuk koneksi satu jaringan Wi-Fi)
  // static final String _androidUrl = 'http://$localBackendIp:8000';
  
  // Pilihan 2: Menggunakan Tunnelmole (untuk koneksi beda jaringan Wi-Fi/Internet seluler)
  static final String _androidUrl = 'https://rpvzwb-ip-180-247-241-88.tunnelmole.net'; // Tunnelmole URL
  
  static String get baseUrl => kIsWeb ? _webUrl : _androidUrl;
}
