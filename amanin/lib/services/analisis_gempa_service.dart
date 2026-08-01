import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analisis_gempa_model.dart';

class NetworkService {
  static Future<EarthquakeNetwork> fetchNetwork() async {
    final response = await http
        .get(Uri.parse("http://127.0.0.1:8000/earthquakes/map?days=30"))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to load network");
    }

    return EarthquakeNetwork.fromJson(jsonDecode(response.body));
  }
}

class EarthquakeMapService {
  static Future<EarthquakeMapData> fetchMapData({required int days}) async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:8000/earthquakes/map?days=$days'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to load earthquake map data');
    }

    return EarthquakeMapData.fromJson(jsonDecode(response.body));
  }
}
