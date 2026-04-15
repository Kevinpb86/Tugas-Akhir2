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
  static const String _baseUrl = 'https://real-time-news-data.p.rapidapi.com/search';
  static const String _apiKey = '03eb68055fmsh5a0fafee3b58505p15903cjsnf0d70bddedd8';
  static const String _apiHost = 'real-time-news-data.p.rapidapi.com';

  static Future<List<NewsModel>> fetchNews() async {
    try {
      final uri = Uri.parse('$_baseUrl?query=bencana&limit=10&time_published=anytime&country=ID&lang=id');
      final response = await http.get(
        uri,
        headers: {
          'x-rapidapi-key': _apiKey,
          'x-rapidapi-host': _apiHost,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['data'] != null) {
          final List<dynamic> newsList = data['data'];
          return newsList.map((json) => NewsModel.fromJson(json)).toList();
        } else {
          throw Exception('Gagal memuat berita: status bukan OK');
        }
      } else {
        throw Exception('Gagal memuat berita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat berita: $e');
    }
  }
}
