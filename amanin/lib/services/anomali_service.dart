import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_config.dart';

/// Kontribusi satu fitur (Magnitudo/Kedalaman/Lintang/Bujur) terhadap skor
/// anomali, dihitung backend memakai SHAP TreeExplainer (IF_SHAP_explainer.pkl).
class ShapContribution {
  final String feature;
  final String label;
  final String unit;
  final double shapValue;
  final double kontribusiPersen;
  final String arah; // "anomali" atau "normal"
  final double? nilaiAktual;
  final double? rataRataHistoris;
  final double? deviasiStd;
  final String? keterangan;

  ShapContribution({
    required this.feature,
    required this.label,
    required this.unit,
    required this.shapValue,
    required this.kontribusiPersen,
    required this.arah,
    this.nilaiAktual,
    this.rataRataHistoris,
    this.deviasiStd,
    this.keterangan,
  });

  factory ShapContribution.fromJson(Map<String, dynamic> json) {
    return ShapContribution(
      feature: json['feature'] ?? '',
      label: json['label'] ?? '',
      unit: json['unit'] ?? '',
      shapValue: (json['shap_value'] ?? 0).toDouble(),
      kontribusiPersen: (json['kontribusi_persen'] ?? 0).toDouble(),
      arah: json['arah'] ?? 'normal',
      nilaiAktual: json['nilai_aktual'] == null
          ? null
          : (json['nilai_aktual'] as num).toDouble(),
      rataRataHistoris: json['rata_rata_historis'] == null
          ? null
          : (json['rata_rata_historis'] as num).toDouble(),
      deviasiStd: json['deviasi_std'] == null
          ? null
          : (json['deviasi_std'] as num).toDouble(),
      keterangan: json['keterangan'],
    );
  }
}

/// Penjelasan lengkap kenapa suatu gempa ditandai anomali, dihasilkan
/// backend dari model SHAP (IF_SHAP_explainer.pkl) — bukan teks statis.
class ShapExplanation {
  final double baseValue;
  final List<ShapContribution> contributions;
  final String summary;

  ShapExplanation({
    required this.baseValue,
    required this.contributions,
    required this.summary,
  });

  factory ShapExplanation.fromJson(Map<String, dynamic> json) {
    return ShapExplanation(
      baseValue: (json['base_value'] ?? 0).toDouble(),
      contributions: (json['contributions'] as List<dynamic>? ?? [])
          .map((c) => ShapContribution.fromJson(c))
          .toList(),
      summary: json['summary'] ?? '',
    );
  }
}

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
  final ShapExplanation? shapExplanation;

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
    this.shapExplanation,
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
      shapExplanation: json['shap_explanation'] == null
          ? null
          : ShapExplanation.fromJson(json['shap_explanation']),
    );
  }
}

/// Hasil pengecekan anomali satu gempa dari endpoint /predict-anomali.
class AnomaliCheckResult {
  final bool isAnomali;
  final double score;

  AnomaliCheckResult({
    required this.isAnomali,
    required this.score,
  });
}

class DemoState {
  // Global value notifier to track the selected demo earthquake
  static final ValueNotifier<AnomaliGempaModel?> selectedDemoGempa = ValueNotifier(null);
  
  // Cache untuk riwayat anomali agar tidak loading berulang kali
  static List<AnomaliGempaModel>? cachedAnomaliHistory;
}

class AnomaliService {
  static Future<List<AnomaliGempaModel>> fetchAnomaliTerkini() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/anomali-terkini'),
      ).timeout(const Duration(seconds: 10));

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

  static Future<List<AnomaliGempaModel>> fetchAnomaliHistory({
    int limit = 5,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/anomali-history?limit=$limit'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> gempaList = data['data'];
        return gempaList
            .map((json) => AnomaliGempaModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Gagal memuat riwayat gempa anomali: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghubungi backend: $e');
    }
  }

  static Future<AnomaliCheckResult> checkSingleAnomali({
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
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AnomaliCheckResult(
          isAnomali: data['is_anomali'] ?? false,
          score: (data['confidence'] ?? 0).toDouble(),
        );
      }
      // Anggap normal jika gagal
      return AnomaliCheckResult(isAnomali: false, score: 0);
    } catch (e) {
      // Jangan tampilkan error ke user, anggap normal jika backend mati
      return AnomaliCheckResult(isAnomali: false, score: 0);
    }
  }
}
