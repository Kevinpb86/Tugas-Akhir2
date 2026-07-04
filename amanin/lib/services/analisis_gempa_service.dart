import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analisis_gempa_model.dart';

class NetworkService {
  static const String baseUrl =
      "https://amanin.fastapicloud.dev"; // Android Emulator

  static Future<EarthquakeNetwork> fetchNetwork() async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/earthquakes/network?days=8",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load network");
    }

    return EarthquakeNetwork.fromJson(
      jsonDecode(response.body),
    );
  }
}