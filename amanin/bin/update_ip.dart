import 'dart:io';

void main() async {
  print('🔍 Memindai kartu jaringan untuk mendeteksi IP Wi-Fi/Ethernet aktif...');
  
  String? detectedIp;
  
  try {
    // Ambil daftar seluruh kartu jaringan aktif (IPv4)
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );
    // Tampilkan semua IP aktif untuk membantu debugging
    print('ℹ️ Alamat IP yang terdeteksi di perangkat ini:');
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (!addr.address.startsWith('169.254')) {
          print('  - ${interface.name}: ${addr.address}');
        }
      }
    }
    print('');

    // Urutkan prioritas pencarian: Wi-Fi/WLAN/Hotspot terlebih dahulu, kemudian Ethernet/LAN
    final nameKeywords = ['wi-fi', 'wlan', 'local area connection', 'ethernet', 'en0', 'en1'];
    
    for (var keyword in nameKeywords) {
      for (var interface in interfaces) {
        final interfaceName = interface.name.toLowerCase();
        if (interfaceName.contains(keyword)) {
          for (var addr in interface.addresses) {
            // Abaikan IP link-local (169.254.x.x) yang tidak terhubung ke router
            if (!addr.address.startsWith('169.254')) {
              detectedIp = addr.address;
              break;
            }
          }
        }
        if (detectedIp != null) break;
      }
      if (detectedIp != null) break;
    }
    
    // Fallback: Jika tidak ditemukan kata kunci di atas, ambil IP non-loopback pertama yang valid
    if (detectedIp == null && interfaces.isNotEmpty) {
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.address.startsWith('169.254')) {
            detectedIp = addr.address;
            break;
          }
        }
        if (detectedIp != null) break;
      }
    }
    
    if (detectedIp != null) {
      // Menulis kembali file api_config_local.dart dengan IP terbaru
      final file = File('lib/services/api_config_local.dart');
      
      // Buat file atau timpa isinya
      await file.writeAsString('''// KONTROL IP BACKEND LOKAL INDIVIDUAL (DIPERBARUI OTOMATIS)
//
// File ini sudah diabaikan dari pelacakan Git (skip-worktree) agar IP anggota
// tim tidak saling bertabrakan di repositori Git.
// Untuk memperbarui IP secara otomatis saat pindah WiFi/Cafe, jalankan perintah:
// dart run bin/update_ip.dart

const String localBackendIp = '$detectedIp'; // IP laptop aktif saat ini
''');
      
      print('==================================================');
      print('✅ BERHASIL mendeteksi IP Jaringan Anda!');
      print('🌐 IP Baru: $detectedIp');
      print('📂 Berkas lib/services/api_config_local.dart telah diperbarui.');
      print('==================================================');
    } else {
      print('❌ GAGAL: Tidak ada alamat IP IPv4 aktif yang terdeteksi pada Wi-Fi/Ethernet.');
    }
  } catch (e) {
    print('❌ TERJADI KESALAHAN saat memindai IP: $e');
  }
}
