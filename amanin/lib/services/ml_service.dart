import 'dart:convert';
import 'dart:async';
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
  static final String _baseUrl = ApiConfig.baseUrl;

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Bypass-Tunnel-Reminder': 'true'},
      ).timeout(const Duration(seconds: 4));
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
    double? latitude,
    double? longitude,
    String source = 'bmkg',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {
          'Content-Type': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
        },
        body: json.encode({
          'magnitude': magnitude,
          'depth': depth,
          'location_name': locationName,
          'latitude': latitude,
          'longitude': longitude,
          'source': source,
        }),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MLPredictionModel.fromJson(data);
      } else {
        final String bodyText = response.body;
        if (bodyText.contains('<html>') ||
            response.statusCode == 504 ||
            response.statusCode == 502 ||
            response.statusCode == 503) {
          throw Exception(
              'Server sedang offline atau sibuk (status ${response.statusCode}).');
        }
        try {
          final errData = json.decode(bodyText);
          final errMsg = errData['detail'] ?? bodyText;
          throw Exception(errMsg);
        } catch (_) {
          throw Exception('Gagal melakukan prediksi: $bodyText');
        }
      }
    } on TimeoutException {
      throw Exception(
          'Batas waktu koneksi habis. Pastikan backend Anda sudah aktif.');
    } catch (e) {
      throw Exception('Gagal terhubung ke server backend ML: $e');
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
        headers: {
          'Content-Type': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
        },
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
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AnomalyPredictionModel.fromJson(data);
      } else {
        final String bodyText = response.body;
        if (bodyText.contains('<html>') ||
            response.statusCode == 504 ||
            response.statusCode == 502 ||
            response.statusCode == 503) {
          throw Exception(
              'Server sedang offline atau sibuk (status ${response.statusCode}).');
        }
        throw Exception('Gagal melakukan deteksi anomali: $bodyText');
      }
    } on TimeoutException {
      throw Exception(
          'Batas waktu koneksi habis. Pastikan backend Anda sudah aktif.');
    } catch (e) {
      throw Exception('Gagal terhubung ke server backend ML: $e');
    }
  }
}
