import 'dart:convert';
import 'package:http/http.dart' as http;

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
}
