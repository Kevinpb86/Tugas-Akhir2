class ApiConfig {
  // Gunakan 'http://10.0.2.2:8000' jika menguji menggunakan emulator Android.
  // Gunakan 'http://localhost:8000' jika menguji menggunakan emulator iOS / Chrome Web.
  //
  // JIKA MENGGUNAKAN HP FISIK (Android/iOS):
  // 1. Pastikan laptop dan HP Anda terhubung ke jaringan Wi-Fi / Hotspot yang sama.
  // 2. Buka terminal laptop, jalankan `ipconfig` untuk mencari IPv4 Address Anda (misal: 192.168.1.10).
  // 3. Ganti value baseUrl di bawah ini dengan IP tersebut (contoh: 'http://192.168.1.10:8000').
  static const String baseUrl = 'http://localhost:8000';
}
