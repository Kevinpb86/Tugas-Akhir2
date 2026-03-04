import 'dart:convert';
import 'package:http/http.dart' as http;

class CuacaModel {
  final int suhu;
  final String cuaca;
  final String image;
  final int kelembapan;
  final double kecAngin;
  final String kota;

  CuacaModel({
    required this.suhu,
    required this.cuaca,
    required this.image,
    required this.kelembapan,
    required this.kecAngin,
    required this.kota,
  });

  factory CuacaModel.fromJson(Map<String, dynamic> jsonCuaca, String namaKota) {
    return CuacaModel(
      suhu: jsonCuaca['t'] ?? 0,
      cuaca: jsonCuaca['weather_desc'] ?? '',
      image: jsonCuaca['image'] ?? '',
      kelembapan: jsonCuaca['hu'] ?? 0,
      kecAngin: (jsonCuaca['ws'] ?? 0).toDouble(),
      kota: namaKota,
    );
  }
}

class GempaModel {
  final String tanggal;
  final String jam;
  final String dateTime;
  final String coordinates;
  final String lintang;
  final String bujur;
  final String magnitude;
  final String kedalaman;
  final String wilayah;
  final String potensi;
  final String dirasakan;
  final String shakemap;

  GempaModel({
    required this.tanggal,
    required this.jam,
    required this.dateTime,
    required this.coordinates,
    required this.lintang,
    required this.bujur,
    required this.magnitude,
    required this.kedalaman,
    required this.wilayah,
    required this.potensi,
    required this.dirasakan,
    required this.shakemap,
  });

  factory GempaModel.fromJson(Map<String, dynamic> json) {
    return GempaModel(
      tanggal: json['Tanggal'] ?? '',
      jam: json['Jam'] ?? '',
      dateTime: json['DateTime'] ?? '',
      coordinates: json['Coordinates'] ?? '',
      lintang: json['Lintang'] ?? '',
      bujur: json['Bujur'] ?? '',
      magnitude: json['Magnitude'] ?? '',
      kedalaman: json['Kedalaman'] ?? '',
      wilayah: json['Wilayah'] ?? '',
      potensi: json['Potensi'] ?? '',
      dirasakan: json['Dirasakan'] ?? '',
      shakemap: json['Shakemap'] ?? '',
    );
  }
}

class BmkgService {
  static const String _baseUrl = 'https://data.bmkg.go.id/DataMKG/TEWS';

  // Mendapatkan gempabumi terbaru (autogempa)
  static Future<GempaModel> fetchLatestEarthquake() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/autogempa.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GempaModel.fromJson(data['Infogempa']['gempa']);
      } else {
        throw Exception('Gagal memuat data gempa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Mendapatkan daftar 15 gempabumi M 5.0+ (gempaterkini)
  static Future<List<GempaModel>> fetchEarthquakeList() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/gempaterkini.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> gempaList = data['Infogempa']['gempa'];
        return gempaList.map((json) => GempaModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data gempa terkini: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
  
  // Mendapatkan daftar 15 gempabumi dirasakan (gempadirasakan)
  static Future<List<GempaModel>> fetchFeltEarthquakeList() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/gempadirasakan.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> gempaList = data['Infogempa']['gempa'];
        return gempaList.map((json) => GempaModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data gempa dirasakan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static const String _cuacaUrl = 'https://api.bmkg.go.id/publik/prakiraan-cuaca';

  // Mendapatkan cuaca (default Jakarta Pusat - Gambir: 31.71.01.1001)
  // Bisa diganti adm4 cilacap jika dibutuhkan
  static Future<CuacaModel> fetchCurrentWeather([String adm4 = '31.71.01.1001']) async {
    try {
      final response = await http.get(Uri.parse('$_cuacaUrl?adm4=$adm4'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final namaKota = data['lokasi']['kotkab'] ?? data['lokasi']['provinsi'] ?? 'Kota Tidak Diketahui';
        
        final List<dynamic> days = data['data'][0]['cuaca'];
        List<dynamic> allIntervals = [];
        for (var day in days) {
          allIntervals.addAll(day);
        }
        
        DateTime now = DateTime.now();
        Map<String, dynamic>? currentCuaca;
        
        for (var cuaca in allIntervals) {
          DateTime dt = DateTime.parse(cuaca['local_datetime'].replaceAll(' ', 'T'));
          // Cari interval terdekat yang ada di masa depan atau sekarang
          if (dt.isAfter(now.subtract(const Duration(hours: 2)))) {
            currentCuaca = cuaca;
            break;
          }
        }
        
        currentCuaca ??= allIntervals[0];
        
        return CuacaModel.fromJson(currentCuaca!, namaKota.toString());
      } else {
        throw Exception('Gagal memuat data cuaca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan cuaca: $e');
    }
  }
}
