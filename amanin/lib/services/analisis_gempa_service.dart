import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analisis_gempa_model.dart';
import 'api_config.dart';

class NetworkService {
  static Future<EarthquakeNetwork> fetchNetwork() async {
    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/earthquakes/network?days=8",
      ),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to load network");
    }

    return EarthquakeNetwork.fromJson(
      jsonDecode(response.body),
    );
  }
}