import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'bmkg_service.dart'; // To reuse GempaModel

class UsgsService {
  static const String _baseUrl = 'https://earthquake.usgs.gov/fdsnws/event/1/query';

  // Region Indonesia
  static const double _minLat = -11.0;
  static const double _maxLat = 6.0;
  static const double _minLon = 95.0;
  static const double _maxLon = 141.0;

  static String _translatePlace(String place) {
    if (place.isEmpty) return place;
    if (place == 'Unknown Location') return 'Lokasi Tidak Diketahui';

    String translated = place;
    
    // Translate "of" to "dari"
    translated = translated.replaceAll(' of ', ' dari ');

    // Map of English compass directions to Indonesian
    final Map<String, String> directionMap = {
      'NNE': 'Utara Timur Laut',
      'ENE': 'Timur Timur Laut',
      'ESE': 'Timur Tenggara',
      'SSE': 'Selatan Tenggara',
      'SSW': 'Selatan Barat Daya',
      'WSW': 'Barat Barat Daya',
      'WNW': 'Barat Barat Laut',
      'NNW': 'Utara Barat Laut',
      'NE': 'Timur Laut',
      'SE': 'Tenggara',
      'SW': 'Barat Daya',
      'NW': 'Barat Laut',
      'N': 'Utara',
      'E': 'Timur',
      'S': 'Selatan',
      'W': 'Barat',
    };

    // Split words and replace direction abbreviation
    List<String> words = translated.split(' ');
    for (int i = 0; i < words.length; i++) {
      String upperWord = words[i].toUpperCase();
      if (directionMap.containsKey(upperWord)) {
        words[i] = directionMap[upperWord]!;
      }
    }
    return words.join(' ');
  }

  static Future<List<GempaModel>> fetchIndonesiaEarthquakes() async {
    try {
      final String url = '$_baseUrl?format=geojson'
          '&minlatitude=$_minLat'
          '&maxlatitude=$_maxLat'
          '&minlongitude=$_minLon'
          '&maxlongitude=$_maxLon'
          '&limit=50'
          '&orderby=time';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> allFeatures = data['features'];
        
        // Filter only results that are in Indonesia
        final List<dynamic> features = allFeatures.where((f) {
          final String place = (f['properties']['place'] ?? "").toString().toLowerCase();
          return place.contains('indonesia');
        }).toList();

        return features.map((feature) {
          final props = feature['properties'];
          final geometry = feature['geometry'];
          final coords = geometry['coordinates']; // [lon, lat, depth]

          // Convert time (ms) to BMKG style
          final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(props['time']);
          final String tanggal = DateFormat('dd MMM yyyy').format(dateTime);
          final String jam = '${DateFormat('HH:mm:ss').format(dateTime)} WIB'; // Assume WIB for uniformity

          return GempaModel(
            tanggal: tanggal,
            jam: jam,
            dateTime: dateTime.toIso8601String(),
            coordinates: '${coords[1]},${coords[0]}',
            lintang: coords[1].toString(),
            bujur: coords[0].toString(),
            magnitude: props['mag'].toString(),
            kedalaman: '${coords[2]} km',
            wilayah: _translatePlace(props['place'] ?? 'Unknown Location'),
            potensi: props['tsunami'] == 1 ? 'Berpotensi Tsunami' : 'Tidak berpotensi tsunami',
            dirasakan: props['felt'] != null ? 'Dirasakan' : '-',
            shakemap: '', // USGS doesn't give BMKG shakemap image path
          );
        }).toList();
      } else {
        throw Exception('Failed to load USGS data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching USGS data: $e");
      throw Exception('Terjadi kesalahan data USGS: $e');
    }
  }
}
