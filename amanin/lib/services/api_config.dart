import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // URL otomatis dipilih berdasarkan platform:
  // - Web (Chrome): http://127.0.0.1:8000
  // - HP Android fisik: http://192.168.1.20:8000  (IP laptop di jaringan Wi-Fi)
  //
  // JIKA MENGGUNAKAN HP FISIK (Android/iOS):
  // 1. Pastikan laptop dan HP Anda terhubung ke jaringan Wi-Fi / Hotspot yang sama.
  // 2. Buka terminal laptop, jalankan `ipconfig` untuk mencari IPv4 Address Anda (misal: 192.168.1.10).
  // 3. Ganti _androidUrl di bawah dengan IP tersebut atau gunakan public tunnel (contoh: 'http://192.168.1.10:8000').
  
  static const String _webUrl = 'http://127.0.0.1:8000';
  static const String _androidUrl = 'http://172.16.1.48:8000'; // Ganti dengan IP laptop Anda jika diperlukan
  // static const String _androidUrl = 'https://llpx8v-ip-182-10-131-224.tunnelmole.net';

  static String get baseUrl => kIsWeb ? _webUrl : _androidUrl;
}
