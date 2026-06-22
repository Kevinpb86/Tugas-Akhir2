import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'services/edukasi_service.dart';

class SemuaVideoPage extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const SemuaVideoPage({super.key, this.onBackPressed});

  @override
  State<SemuaVideoPage> createState() => _SemuaVideoPageState();
}

class _SemuaVideoPageState extends State<SemuaVideoPage> {
  final EdukasiService _edukasiService = EdukasiService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _videos = [];
  Map<String, dynamic>? _featuredVideo;
  String? _nextPageToken;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  String? _playingVideoId;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _fetchInitialVideos();

    // Listener untuk mendeteksi scroll sampai ke bawah
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreVideos();
      }
    });
  }

  void _playVideo(String videoId) {
    if (_youtubeController != null) {
      _youtubeController!.pause();
      _youtubeController!.dispose();
    }
    setState(() {
      _playingVideoId = videoId;
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialVideos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _edukasiService.fetchVideos();
      setState(() {
        _videos = response.videos;
        _nextPageToken = response.nextPageToken;
        _featuredVideo = response.featuredVideo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreVideos() async {
    // Jangan load jika sedang loading, atau tidak ada token halaman selanjutnya
    if (_isLoadingMore || _nextPageToken == null || _nextPageToken!.isEmpty)
      return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _edukasiService.fetchVideos(
        pageToken: _nextPageToken,
      );
      setState(() {
        _videos.addAll(response.videos);
        _nextPageToken = response.nextPageToken;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      // Tampilkan toast atau snackbar error secara diam-diam
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat video tambahan: $e')),
      );
    }
  }

  Widget _buildFeaturedVideo() {
    if (_featuredVideo == null) return const SizedBox.shrink();

    final bool isPlaying =
        _playingVideoId == _featuredVideo!['id'] && _youtubeController != null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (!isPlaying) _playVideo(_featuredVideo!['id']);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.15),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.amber.shade300, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Video Hari Ini
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pilihan Hari Ini',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Thumbnail or Video Player
              ClipRRect(
                child: isPlaying
                    ? YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: true,
                      )
                    : Stack(
                        children: [
                          _featuredVideo!['thumbnail'] != null
                              ? Image.network(
                                  _featuredVideo!['thumbnail'],
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : Container(height: 200, color: Colors.grey[300]),
                          Center(
                            heightFactor: 3.5,
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 56,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
              ),
              // Title & Desc
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _featuredVideo!['title'] ?? 'Tanpa Judul',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _featuredVideo!['description'] ?? 'Tidak ada deskripsi',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final bool isPlaying =
        _playingVideoId == video['id'] && _youtubeController != null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (!isPlaying) _playVideo(video['id']);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail or Video Player
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: isPlaying
                    ? YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: true,
                      )
                    : Container(
                        height: 160,
                        width: double.infinity,
                        color: const Color(0xFFE0E0E0),
                        child: Stack(
                          children: [
                            video['thumbnail'] != null
                                ? Image.network(
                                    video['thumbnail'],
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox(),
                            Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Edukasi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'] ?? 'Tanpa Judul',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.source,
                          size: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            video['channel'] ?? 'YouTube',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9E9E9E),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Video Edukasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBackPressed != null) {
              widget.onBackPressed!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF90CAF9)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Color(0xFF1976D2), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Video mitigasi ini bersumber otomatis dari YouTube. Dapatkan wawasan keselamatan gempa terbaru.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1565C0),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Gagal memuat video:\n$_error',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchInitialVideos,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount:
                        _videos.length + (_featuredVideo != null ? 1 : 0) + 1,
                    itemBuilder: (context, index) {
                      // Jika index paling atas, tampilkan Featured Video
                      if (index == 0 && _featuredVideo != null) {
                        return _buildFeaturedVideo();
                      }

                      // Adjust index karena ada Featured Video
                      final videoIndex = _featuredVideo != null
                          ? index - 1
                          : index;

                      // Jika index paling bawah, tampilkan loading indicator jika masih memuat data berikutnya
                      if (videoIndex == _videos.length) {
                        return _nextPageToken != null
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    'Tidak ada video lagi',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                      }

                      return _buildVideoCard(_videos[videoIndex]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
