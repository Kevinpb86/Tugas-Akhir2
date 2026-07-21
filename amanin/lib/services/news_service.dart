import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsModel {
  final String title;
  final String link;
  final String snippet;
  final String photoUrl;
  final String publishedDatetimeUtc;
  final String sourceUrl;
  final String sourceName;
  final String sourceLogoUrl;

  NewsModel({
    required this.title,
    required this.link,
    required this.snippet,
    required this.photoUrl,
    required this.publishedDatetimeUtc,
    required this.sourceUrl,
    required this.sourceName,
    required this.sourceLogoUrl,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      publishedDatetimeUtc: json['published_datetime_utc'] ?? '',
      sourceUrl: json['source_url'] ?? '',
      sourceName: json['source_name'] ?? '',
      sourceLogoUrl: json['source_logo_url'] ?? '',
    );
  }
}

class NewsService {
  static const String _baseUrl =
      'https://real-time-news-data.p.rapidapi.com/search';
  static const String _apiKey =
      '03eb68055fmsh5a0fafee3b58505p15903cjsnf0d70bddedd8';
  static const String _apiHost = 'real-time-news-data.p.rapidapi.com';

  // Fallback data berita jika terjadi rate limiting (429) atau kesalahan jaringan
  static final List<NewsModel> _fallbackNews = [
    NewsModel(
      title: 'BMKG Himbau Masyarakat Waspada Potensi Gempa Susulan',
      link: 'https://www.bmkg.go.id/',
      snippet: 'Badan Meteorologi, Klimatologi, dan Geofisika (BMKG) mengimbau masyarakat untuk tetap tenang namun waspada terhadap potensi gempa bumi susulan yang dapat terjadi...',
      photoUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=500&q=80',
      publishedDatetimeUtc: DateTime.now().subtract(const Duration(hours: 2)).toUtc().toIso8601String(),
      sourceUrl: 'https://www.bmkg.go.id/',
      sourceName: 'BMKG',
      sourceLogoUrl: '',
    ),
    NewsModel(
      title: 'Edukasi Mitigasi Bencana: Langkah Keselamatan Saat Gempa Melanda',
      link: 'https://www.bmkg.go.id/',
      snippet: 'Saat gempa terjadi, segera lindungi kepala dan leher Anda. Carilah tempat perlindungan kokoh seperti di bawah meja dan hindari benda-benda kaca serta tembok retak...',
      photoUrl: 'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?auto=format&fit=crop&w=500&q=80',
      publishedDatetimeUtc: DateTime.now().subtract(const Duration(hours: 5)).toUtc().toIso8601String(),
      sourceUrl: 'https://www.bmkg.go.id/',
      sourceName: 'Riksa Edukasi',
      sourceLogoUrl: '',
    ),
    NewsModel(
      title: 'Panduan Praktis Menyusun Tas Siaga Bencana (TSB) Mandiri',
      link: 'https://www.bmkg.go.id/',
      snippet: 'Persiapkan tas siaga bencana berisi dokumen penting, air minum, makanan instan, obat-obatan pribadi, senter, dan peluit untuk mengantisipasi kondisi darurat pascabencana...',
      photoUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=500&q=80',
      publishedDatetimeUtc: DateTime.now().subtract(const Duration(days: 1)).toUtc().toIso8601String(),
      sourceUrl: 'https://www.bmkg.go.id/',
      sourceName: 'Riksa Siaga',
      sourceLogoUrl: '',
    ),
    NewsModel(
      title: 'Penerapan Teknologi Tahan Gempa pada Konstruksi Bangunan Modern',
      link: 'https://www.bmkg.go.id/',
      snippet: 'Pemerintah terus mendorong para arsitek dan kontraktor untuk mengadopsi standar konstruksi bangunan tahan gempa guna meminimalisir kerusakan material dan korban jiwa saat bencana...',
      photoUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=500&q=80',
      publishedDatetimeUtc: DateTime.now().subtract(const Duration(days: 2)).toUtc().toIso8601String(),
      sourceUrl: 'https://www.bmkg.go.id/',
      sourceName: 'Portal Konstruksi',
      sourceLogoUrl: '',
    ),
  ];

  static Future<List<NewsModel>> fetchNews() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?query=bencana&limit=10&time_published=anytime&country=ID&lang=id',
      );
      final response = await http.get(
        uri,
        headers: {'x-rapidapi-key': _apiKey, 'x-rapidapi-host': _apiHost},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['data'] != null) {
          final List<dynamic> newsList = data['data'];
          return newsList.map((json) => NewsModel.fromJson(json)).toList();
        } else {
          print('[NewsService] Gagal memuat berita: status bukan OK. Menggunakan data fallback.');
          return _fallbackNews;
        }
      } else {
        print('[NewsService] Gagal memuat berita: status ${response.statusCode}. Menggunakan data fallback.');
        return _fallbackNews;
      }
    } catch (e) {
      print('[NewsService] Terjadi kesalahan saat memuat berita: $e. Menggunakan data fallback.');
      return _fallbackNews;
    }
  }
}
