import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyForecast {
  final String dayName;
  final String condition;
  final String imagePath;
  final int maxTemp;
  final int minTemp;
  final bool isEstimate; // true = estimasi, bukan data real BMKG

  DailyForecast({
    required this.dayName,
    required this.condition,
    required this.imagePath,
    required this.maxTemp,
    required this.minTemp,
    this.isEstimate = false,
  });
}

class CuacaModel {
  final int suhu;
  final String cuaca;
  final String image;
  final int kelembapan;
  final double kecAngin;
  final String kota;
  final String peringatanDini;
  final List<DailyForecast> dailyForecasts;

  CuacaModel({
    required this.suhu,
    required this.cuaca,
    required this.image,
    required this.kelembapan,
    required this.kecAngin,
    required this.kota,
    required this.peringatanDini,
    required this.dailyForecasts,
  });

  factory CuacaModel.fromJson(Map<String, dynamic> jsonCuaca, String namaKota, String peringatan, List<DailyForecast> daily) {
    return CuacaModel(
      suhu: jsonCuaca['t'] ?? 0,
      cuaca: jsonCuaca['weather_desc'] ?? '',
      image: jsonCuaca['image'] ?? '',
      kelembapan: jsonCuaca['hu'] ?? 0,
      kecAngin: (jsonCuaca['ws'] ?? 0).toDouble(),
      kota: namaKota,
      peringatanDini: peringatan,
      dailyForecasts: daily,
    );
  }
}

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

  static const String _cuacaUrl = 'https://api.bmkg.go.id/publik/prakiraan-cuaca';

  // Mendapatkan cuaca (default Jakarta Pusat - Gambir: 31.71.01.1001)
  // Bisa diganti adm4 cilacap jika dibutuhkan
  static Future<CuacaModel> fetchCurrentWeather([String adm4 = '31.71.01.1001']) async {
    try {
      final response = await http.get(Uri.parse('$_cuacaUrl?adm4=$adm4'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final namaKota = data['lokasi']['kotkab'] ?? data['lokasi']['provinsi'] ?? 'Kota Tidak Diketahui';
        
        final List<dynamic> days = data['data'][0]['cuaca'];
        List<dynamic> allIntervals = [];
        List<DailyForecast> parsedDaily = [];
        String peringatanMsg = "Sedang tidak ada peringatan cuaca yang signifikan untuk saat ini.";
        bool isPeringatanSet = false;

        for (var i = 0; i < days.length; i++) {
          final dayIntervals = days[i];
          allIntervals.addAll(dayIntervals);
          
          int maxT = -100;
          int minT = 100;
          Map<String, int> condCounts = {};
          String reprCond = '';
          String reprIcon = '';
          
          for (var interval in dayIntervals) {
            final t = interval['t'] as int;
            if (t > maxT) maxT = t;
            if (t < minT) minT = t;
            
            final code = interval['weather'] as int;
            final desc = interval['weather_desc'] as String;
            final icon = interval['image'] as String;
            
            condCounts[desc] = (condCounts[desc] ?? 0) + 1;
            
            // Aturan Peringatan Dini (Cuaca ekstrem: Hujan Petir / Hujan Lebat)
            // 65: Hujan Lebat, 95/97: Hujan Petir
            if ((code == 65 || code == 95 || code == 97) && !isPeringatanSet) {
              isPeringatanSet = true;
              peringatanMsg = "Waspada potensi $desc di kawasan $namaKota dan sekitarnya.";
            }
          }
          
          // Cari kondisi dominan
          int maxCount = 0;
          for (var interval in dayIntervals) {
            final c = interval['weather_desc'] as String;
            if (condCounts[c] != null && condCounts[c]! > maxCount) {
              maxCount = condCounts[c]!;
              reprCond = c;
              reprIcon = interval['image'] as String;
            }
          }
          
          String dayName;
          final startDateTime = dayIntervals[0]['local_datetime'] as String;
          // Ambil tanggal dari interval pertama hari tersebut
          final dayDate = DateTime.parse(startDateTime.replaceAll(' ', 'T'));
          final todayDate = DateTime.now();
          final diffDays = dayDate.difference(DateTime(todayDate.year, todayDate.month, todayDate.day)).inDays;
          
          const List<String> namaHari = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
          if (diffDays == 0) {
            dayName = 'Hari ini';
          } else if (diffDays == 1) {
            dayName = 'Besok (${namaHari[dayDate.weekday % 7]})';
          } else {
            dayName = namaHari[dayDate.weekday % 7];
          }
          
          parsedDaily.add(DailyForecast(
            dayName: dayName,
            condition: reprCond,
            imagePath: reprIcon,
            maxTemp: maxT,
            minTemp: minT,
          ));
        }

        // Tambahkan estimasi 4 hari lagi (total 7 hari) dari pola hari terakhir API
        if (parsedDaily.isNotEmpty) {
          final lastDay = parsedDaily.last;
          const List<String> namaHari = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
          final today = DateTime.now();
          int addedDays = parsedDaily.length; // sudah ada 3 hari
          while (parsedDaily.length < 7) {
            final futureDate = today.add(Duration(days: addedDays));
            final fDayName = namaHari[futureDate.weekday % 7];
            parsedDaily.add(DailyForecast(
              dayName: fDayName,
              condition: lastDay.condition,
              imagePath: lastDay.imagePath,
              maxTemp: lastDay.maxTemp,
              minTemp: lastDay.minTemp,
              isEstimate: true,
            ));
            addedDays++;
          }
        }
        
        DateTime now = DateTime.now();
        Map<String, dynamic>? currentCuaca;
        
        for (var cuaca in allIntervals) {
          DateTime dt = DateTime.parse(cuaca['local_datetime'].replaceAll(' ', 'T'));
          // Cari interval terdekat yang ada di masa depan atau sekarang
          if (dt.isAfter(now.subtract(const Duration(hours: 2)))) {
            currentCuaca = cuaca;
            break;
          }
        }
        
        currentCuaca ??= allIntervals[0];
        
        return CuacaModel.fromJson(currentCuaca!, namaKota.toString(), peringatanMsg, parsedDaily);
      } else {
        throw Exception('Gagal memuat data cuaca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan cuaca: $e');
    }
  }
}
