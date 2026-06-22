import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AnomaliGempaModel {
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

  // Fitur tambahan dari Backend untuk Anomali
  final bool isAnomali;
  final String statusAnomali;
  final double anomalyScore;

  AnomaliGempaModel({
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
    required this.isAnomali,
    required this.statusAnomali,
    required this.anomalyScore,
  });

  factory AnomaliGempaModel.fromJson(Map<String, dynamic> json) {
    return AnomaliGempaModel(
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
      isAnomali: json['is_anomali'] ?? false,
      statusAnomali: json['status_anomali'] ?? 'Normal',
      anomalyScore: (json['anomaly_score'] ?? 0).toDouble(),
    );
  }
}

class AnomaliService {
  static Future<List<AnomaliGempaModel>> fetchAnomaliTerkini() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/anomali-terkini'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> gempaList = data['data'];
        return gempaList
            .map((json) => AnomaliGempaModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Gagal memuat data anomali gempa terkini: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghubungi backend: $e');
    }
  }

  static Future<bool> checkSingleAnomali({
    required double magnitude,
    required double kedalaman,
    required double lintang,
    required double bujur,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/predict-anomali'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'magnitude': magnitude,
          'depth': kedalaman,
          'latitude': lintang,
          'longitude': bujur,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_anomali'] ?? false;
      }
      return false; // Anggap normal jika gagal
    } catch (e) {
      return false; // Jangan tampilkan error ke user, anggap normal jika backend mati
    }
  }
}
