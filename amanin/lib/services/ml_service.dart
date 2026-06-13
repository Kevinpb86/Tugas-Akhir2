import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AnomalyPredictionModel {
  final bool isAnomali;
  final String label;
  final int predictionCode;
  final double confidence;

  AnomalyPredictionModel({
    required this.isAnomali,
    required this.label,
    required this.predictionCode,
    required this.confidence,
  });

  factory AnomalyPredictionModel.fromJson(Map<String, dynamic> json) {
    return AnomalyPredictionModel(
      isAnomali: json['is_anomali'] ?? false,
      label: json['label'] ?? 'Tidak Diketahui',
      predictionCode: json['prediction_code'] ?? -1,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class MLPredictionModel {
  final String riskLevel;
  final int predictionCode;
  final double confidence;
  final double latitude;
  final double longitude;

  MLPredictionModel({
    required this.riskLevel,
    required this.predictionCode,
    required this.confidence,
    required this.latitude,
    required this.longitude,
  });

  factory MLPredictionModel.fromJson(Map<String, dynamic> json) {
    return MLPredictionModel(
      riskLevel: json['risk_level'] ?? 'Tidak Diketahui',
      predictionCode: json['prediction_code'] ?? -1,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
}

class MlService {
  static const String _baseUrl = ApiConfig.baseUrl;

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'ok' && data['model_loaded'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<MLPredictionModel> predictRisk({
    required double magnitude,
    required double depth,
    required String locationName,
    String source = 'bmkg',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'magnitude': magnitude,
          'depth': depth,
          'location_name': locationName,
          'source': source,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MLPredictionModel.fromJson(data);
      } else {
        try {
          final errData = json.decode(response.body);
          final errMsg = errData['detail'] ?? response.body;
          throw Exception(errMsg);
        } catch (_) {
          throw Exception('Gagal melakukan prediksi: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi ke backend ML: $e');
    }
  }

  static Future<AnomalyPredictionModel> predictAnomali({
    required double latitude,
    required double longitude,
    required double depth,
    required double gap,
    required double dmin,
    required double nst,
    required int bulan,
    required int jam,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict-anomali'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
          'depth': depth,
          'gap': gap,
          'dmin': dmin,
          'nst': nst,
          'bulan': bulan,
          'jam': jam,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AnomalyPredictionModel.fromJson(data);
      } else {
        throw Exception('Gagal melakukan deteksi anomali: ${response.body}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi ke backend ML: $e');
    }
  }
}
