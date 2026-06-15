import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class EdukasiResponse {
  final List<Map<String, dynamic>> videos;
  final String? nextPageToken;
  final Map<String, dynamic>? featuredVideo;

  EdukasiResponse({
    required this.videos,
    this.nextPageToken,
    this.featuredVideo,
  });
}

class EdukasiService {
  Future<EdukasiResponse> fetchVideos({String? pageToken}) async {
    String url = '${ApiConfig.baseUrl}/api/edukasi/videos';
    if (pageToken != null && pageToken.isNotEmpty) {
      url += '?pageToken=$pageToken';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        final videosList = List<Map<String, dynamic>>.from(jsonResponse['data']);
        final nextToken = jsonResponse['nextPageToken'];
        
        Map<String, dynamic>? featured;
        if (jsonResponse.containsKey('featuredVideo') && jsonResponse['featuredVideo'] != null) {
          featured = Map<String, dynamic>.from(jsonResponse['featuredVideo']);
        }

        return EdukasiResponse(
          videos: videosList,
          nextPageToken: nextToken,
          featuredVideo: featured,
        );
      } else {
        throw Exception('Failed to load videos from API');
      }
    } else {
      throw Exception('Failed to load videos (Server Error)');
    }
  }
}
