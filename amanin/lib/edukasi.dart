import 'package:flutter/material.dart';
import 'akun.dart';
import 'login.dart';
import 'main.dart';
import 'asuransi.dart';
import 'semua_video.dart';
import 'daftar_perlengkapan.dart';
import 'panduan_anomali.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'edukasi_waspada.dart';
import 'services/api_config.dart';
import 'services/edukasi_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  String _currentCityName = 'Memuat lokasi...';
  bool _showSemuaVideo = false;

  final EdukasiService _edukasiService = EdukasiService();
  Future<Map<String, dynamic>?>? _featuredVideoFuture;
  YoutubePlayerController? _youtubeController;

  final Map<String, bool> _tsbCheckedState = {
    'Dokumen Penting (Fotokopi)': true,
    'Makanan Tahan Lama & Air': true,
    'Kotak P3K & Obat Pribadi': false,
    'Senter & Baterai Cadangan': false,
  };

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _featuredVideoFuture = _fetchFeaturedVideo();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _playFeaturedVideo(String videoId) {
    if (_youtubeController != null) {
      _youtubeController!.pause();
      _youtubeController!.dispose();
    }
    setState(() {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          forceHD: false,
        ),
      );
    });
  }

  Future<Map<String, dynamic>?> _fetchFeaturedVideo() async {
    final response = await _edukasiService.fetchVideos();
    if (response.featuredVideo != null) {
      return response.featuredVideo;
    }
    if (response.videos.isNotEmpty) {
      return response.videos.first;
    }
    throw Exception('Tidak ada data video');
  }

  String _decodeHtml(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }

  Future<void> _requestLocationPermission() async {
    String cityName = 'Cianjur';
    Position? position;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      // Try to get last known position first (instant, skipped on web)
      if (!kIsWeb) {
        position = await Geolocator.getLastKnownPosition();
      }
      
      // If null, get current position with a timeout (e.g. 3 seconds)
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 3));

      print(
        "[Edukasi] GPS coordinates: lat=${position.latitude}, lon=${position.longitude}, accuracy=${position.accuracy}m",
      );

      try {
        if (kIsWeb) {
          throw Exception("Geocoding package is not supported on web");
        }
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 2));
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          print(
            "[Edukasi] Geocoding result: subLocality=${place.subLocality}, locality=${place.locality}, subAdmin=${place.subAdministrativeArea}, admin=${place.administrativeArea}",
          );
          cityName =
              place.locality ??
              place.subLocality ??
              place.subAdministrativeArea ??
              'Jakarta Pusat';
          cityName = cityName
              .replaceAll('Kabupaten ', '')
              .replaceAll('Kota ', '')
              .replaceAll(' City', '')
              .replaceAll('Kecamatan ', '')
              .replaceAll('Kelurahan ', '')
              .replaceAll('Desa ', '');
        }
      } catch (e) {
        print(
          "[Edukasi] Geocoding package error: $e, falling back to Nominatim",
        );
        try {
          final url = Uri.parse(
            '${ApiConfig.baseUrl}/reverse-geocode?lat=${position.latitude}&lon=${position.longitude}',
          );
          final response = await http.get(
            url,
          ).timeout(const Duration(seconds: 3));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print("[Edukasi] Nominatim full address: ${data['address']}");
            if (data['address'] != null) {
              final addr = data['address'];
              cityName =
                  addr['town'] ??
                  addr['city'] ??
                  addr['city_district'] ??
                  addr['subdistrict'] ??
                  addr['village'] ??
                  addr['suburb'] ??
                  addr['county'] ??
                  addr['state'] ??
                  'Jakarta Pusat';
              cityName = cityName
                  .replaceAll('Kabupaten ', '')
                  .replaceAll('Kota ', '')
                  .replaceAll('Kecamatan ', '')
                  .replaceAll('Kelurahan ', '')
                  .replaceAll('Desa ', '');
              print("[Edukasi] Final city name: $cityName");
            }
          }
        } catch (fallbackError) {
          print("Nominatim fallback error: $fallbackError");
        }
      }
    } catch (e) {
      print("Location permission error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _currentCityName = cityName;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSemuaVideo) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            setState(() {
              _showSemuaVideo = false;
            });
          }
        },
        child: SemuaVideoPage(
          onBackPressed: () {
            setState(() {
              _showSemuaVideo = false;
            });
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              const Text(
                'Pertolongan Pertama Saat Bencana',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              _buildFirstAidSection(),
              const SizedBox(height: 24),
              _buildAnomalyGuideCard(context),
              const SizedBox(height: 24),
              _buildVideoHeader(context),
              const SizedBox(height: 16),
              _buildVideoCard(context),
              const SizedBox(height: 24),
              const Text(
                'Tas Siaga Bencana (TSB)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              _buildTsbCard(),
              const SizedBox(height: 24),
              _buildInsuranceSection(context),
              const SizedBox(height: 140), // padding for floating bottom nav
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Test the Backend API
          final url = Uri.parse('${ApiConfig.baseUrl}/api/edukasi/waspada');
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          try {
            // Ambil kordinat user terbaru
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
            );

            final response = await http.post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'latitude': position.latitude,
                'longitude': position.longitude,
              }),
            );

            Navigator.pop(context); // Tutup loading

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              String status = data['status'];
              String msg = data['message'];

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Status: $status'),
                  content: Text(msg),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (status == "WASPADA (Kuning)") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EdukasiWaspadaPage(
                                cityName: _currentCityName,
                                locationCategory: "Dalam Ruangan",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('OK / Lihat Edukasi'),
                    ),
                  ],
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${response.statusCode}')),
              );
            }
          } catch (e) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal konek API: $e')),
            );
          }
        },
        backgroundColor: const Color(0xFFFBC02D),
        icon: const Icon(Icons.radar, color: Colors.white),
        label: const Text('Cek Zona Waspada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riksa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentCityName = 'Memuat lokasi...';
                });
                _requestLocationPermission();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA), // Light cyan
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF00BCD4),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentCityName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF00BCD4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.sync_rounded,
                      color: Color(0xFF00BCD4),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 24,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF44336),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ValueListenableBuilder<bool>(
              valueListenable: isLoggedInNotifier,
              builder: (context, isLoggedIn, _) {
                return isLoggedIn
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AkunPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_outline,
                              color: Color(0xFF1A1A1A),
                              size: 24,
                            ),
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BCD4),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00BCD4,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari panduan keselamatan...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          icon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Di Dalam\nRumah',
                subtitle: 'Lindungi kepala, sembunyi di bawah meja.',
                icon: Icons.home,
                color: const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Di Luar\nRuangan',
                subtitle: 'Jauhi gedung, tiang listrik, dan pohon.',
                icon: Icons.park,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Di Dalam\nMobil',
                subtitle: 'Menepi di tempat aman, tetap di dalam.',
                icon: Icons.directions_car,
                color: const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Di Gedung\nTinggi',
                subtitle: 'Jangan gunakan lift, ikuti jalur evakuasi.',
                icon: Icons.domain,
                color: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstAidSection() {
    final items = [
      {
        'icon': Icons.healing,
        'color': const Color(0xFFE53935),
        'title': 'Hentikan Pendarahan',
        'steps': [
          'Tekan luka dengan kain bersih atau perban',
          'Angkat bagian yang luka lebih tinggi dari jantung',
          'Pertahankan tekanan selama 10–15 menit',
          'Jangan lepas perban meski sudah basah, tambahkan di atasnya',
        ],
      },
      {
        'icon': Icons.accessibility_new,
        'color': const Color(0xFFFF9800),
        'title': 'Patah Tulang',
        'steps': [
          'Jangan paksa anggota tubuh untuk digerakkan',
          'Stabilkan dengan bidai dari bahan keras (kayu, kardus)',
          'Ikat bidai di atas dan bawah area patah',
          'Segera bawa ke fasilitas kesehatan terdekat',
        ],
      },
      {
        'icon': Icons.airline_seat_flat,
        'color': const Color(0xFF2196F3),
        'title': 'Korban Pingsan',
        'steps': [
          'Baringkan korban di tempat yang aman dan datar',
          'Longgarkan pakaian di leher dan dada',
          'Pastikan jalan napas terbuka, miringkan kepala ke belakang',
          'Panggil bantuan jika tidak sadar lebih dari 1 menit',
        ],
      },
      {
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFFF5722),
        'title': 'Luka Bakar',
        'steps': [
          'Siram dengan air mengalir selama minimal 10 menit',
          'Jangan pecahkan lepuhan yang terbentuk',
          'Tutup dengan kain bersih yang tidak berbulu',
          'Jangan oleskan pasta gigi atau minyak pada luka',
        ],
      },
    ];

    return Column(
      children: items.map((item) {
        final color = item['color'] as Color;
        final icon = item['icon'] as IconData;
        final title = item['title'] as String;
        final steps = item['steps'] as List<String>;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              subtitle: Text(
                'Ketuk untuk melihat langkah-langkah',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: steps.asMap().entries.map((entry) {
                final i = entry.key + 1;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$i',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF424242),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVideoHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Video Edukasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showSemuaVideo = true;
              });
            },
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _featuredVideoFuture ??= _fetchFeaturedVideo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
            ),
            child: const CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _featuredVideoFuture = _fetchFeaturedVideo();
                    });
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final video = snapshot.data;
        if (video == null) {
          return Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_off, color: Colors.grey, size: 32),
                const SizedBox(height: 8),
                const Text('Data video kosong', style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _featuredVideoFuture = _fetchFeaturedVideo();
                    });
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        return MouseRegion(
          cursor: _youtubeController == null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: () {
              if (_youtubeController == null && video['id'] != null) {
                _playFeaturedVideo(video['id']);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: _youtubeController == null
                        ? BoxDecoration(
                            color: const Color(0xFF757575),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            image: video['thumbnail'] != null
                                ? DecorationImage(
                                    image: NetworkImage(video['thumbnail']),
                                    fit: BoxFit.cover,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black26,
                                      BlendMode.darken,
                                    ),
                                  )
                                : null,
                          )
                        : null,
                    child: _youtubeController != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            child: YoutubePlayer(
                              controller: _youtubeController!,
                              showVideoProgressIndicator: true,
                              bottomActions: [
                                const SizedBox(width: 14.0),
                                CurrentPosition(),
                                const SizedBox(width: 8.0),
                                ProgressBar(isExpanded: true),
                                RemainingDuration(),
                                const PlaybackSpeedButton(),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Color(0xFF2196F3),
                                    size: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _decodeHtml(video['title'] ?? 'Tanpa Judul'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.source,
                              size: 12,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                video['channel'] ?? 'YouTube',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
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
      },
    );
  }

  Widget _buildAnomalyGuideCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PanduanAnomaliPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.troubleshoot_rounded, color: Color(0xFFF57C00), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deteksi Anomali Gempa',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pelajari cara sistem mendeteksi gempa yang tidak biasa',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFBDBDBD)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTsbCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8FD),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.backpack_outlined,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Persiapan Tas Siaga',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Siapkan tas ini untuk 3 hari pertama pasca bencana.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildChecklistItem('Dokumen Penting (Fotokopi)'),
          const SizedBox(height: 12),
          _buildChecklistItem('Makanan Tahan Lama & Air'),
          const SizedBox(height: 12),
          _buildChecklistItem('Kotak P3K & Obat Pribadi'),
          const SizedBox(height: 12),
          _buildChecklistItem('Senter & Baterai Cadangan'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DaftarPerlengkapanPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1A1A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lihat Daftar Lengkap',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    final bool isChecked = _tsbCheckedState[text] ?? false;
    return InkWell(
      onTap: () {
        setState(() {
          _tsbCheckedState[text] = !isChecked;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isChecked ? const Color(0xFF4CAF50) : const Color(0xFFB0BEC5),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isChecked ? Colors.grey[400] : const Color(0xFF424242),
                  fontWeight: FontWeight.w500,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3F3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Color(0xFFED1C24),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Asuransi Pro-Siaga',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Perlindungan aset dan kesehatan keluarga dari dampak bencana alam.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF757575),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Klaim cepat 24 jam',
                      style: TextStyle(fontSize: 12, color: Color(0xFF424242)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Cover gempa & banjir',
                      style: TextStyle(fontSize: 12, color: Color(0xFF424242)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AsuransiWebPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFED1C24),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cek Asuransi Sekarang',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Disponsori oleh Prudential | S&K berlaku',
            style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}
