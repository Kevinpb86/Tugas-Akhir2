import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class MLPredictionModel {
  final String riskLevel;
  final int predictionCode;
  final double confidence;

  MLPredictionModel({
    required this.riskLevel,
    required this.predictionCode,
    required this.confidence,
  });

  factory MLPredictionModel.fromJson(Map<String, dynamic> json) {
    return MLPredictionModel(
      riskLevel: json['risk_level'] ?? 'Tidak Diketahui',
      predictionCode: json['prediction_code'] ?? -1,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
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
    required double latitude,
    required double longitude,
    String source = 'bmkg',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'magnitude': magnitude,
          'depth': depth,
          'latitude': latitude,
          'longitude': longitude,
          'source': source,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MLPredictionModel.fromJson(data);
      } else {
        throw Exception('Gagal melakukan prediksi: ${response.body}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi ke backend ML: $e');
    }
  }
}
