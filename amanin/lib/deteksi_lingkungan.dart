import 'package:flutter/material.dart';
import 'dart:math' as math;

class MountainData {
  final String name;
  final double latitude;
  final double longitude;

  const MountainData(this.name, this.latitude, this.longitude);
}

const List<MountainData> indonesianMountains = [
  // Sumatra
  MountainData('Gunung Sinabung', 3.17, 98.392),
  MountainData('Gunung Sibayak', 3.23, 98.52),
  MountainData('Gunung Kerinci', -1.697, 101.264),
  MountainData('Gunung Marapi', -0.381, 100.473),
  MountainData('Gunung Talang', -0.978, 100.679),
  MountainData('Gunung Dempo', -4.03, 103.13),
  MountainData('Gunung Krakatau', -6.102, 105.423),
  // Jawa
  MountainData('Gunung Salak', -6.716, 106.732),
  MountainData('Gunung Gede', -6.79, 106.98),
  MountainData('Gunung Pangrango', -6.78, 106.96),
  MountainData('Gunung Tangkuban Parahu', -6.76, 107.6),
  MountainData('Gunung Papandayan', -7.32, 107.73),
  MountainData('Gunung Galunggung', -7.25, 108.058),
  MountainData('Gunung Ciremai', -6.892, 108.408),
  MountainData('Gunung Slamet', -7.242, 109.208),
  MountainData('Gunung Sindoro', -7.301, 109.997),
  MountainData('Gunung Sumbing', -7.384, 110.07),
  MountainData('Gunung Merbabu', -7.45, 110.43),
  MountainData('Gunung Merapi', -7.54, 110.446),
  MountainData('Gunung Lawu', -7.625, 111.193),
  MountainData('Gunung Kelud', -7.93, 112.308),
  MountainData('Gunung Bromo', -7.942, 112.953),
  MountainData('Gunung Semeru', -8.108, 112.922),
  MountainData('Gunung Welirang', -7.725, 112.575),
  MountainData('Gunung Arjuno', -7.725, 112.58),
  MountainData('Gunung Ijen', -8.058, 114.242),
  MountainData('Gunung Raung', -8.125, 114.042),
  // Bali & Nusa Tenggara
  MountainData('Gunung Agung', -8.343, 115.508),
  MountainData('Gunung Batur', -8.242, 115.378),
  MountainData('Gunung Rinjani', -8.411, 116.458),
  MountainData('Gunung Tambora', -8.25, 118.0),
  MountainData('Gunung Lewotobi', -8.542, 122.775),
  // Sulawesi & Maluku
  MountainData('Gunung Lokon', 1.358, 124.792),
  MountainData('Gunung Soputan', 1.112, 124.73),
  MountainData('Gunung Karangetang', 2.78, 125.4),
  MountainData('Gunung Gamalama', 0.8, 127.325),
  MountainData('Gunung Ibu', 1.488, 127.63),
  MountainData('Gunung Dukono', 1.685, 127.894),
];

class EnvironmentResult {
  final bool isIndoor;
  final String environmentType;
  final String nearbyMountainName;

  const EnvironmentResult({
    required this.isIndoor,
    required this.environmentType,
    required this.nearbyMountainName,
  });
}

class EnvironmentDetector {
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi / 180
    final a = 0.5 - math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) *
        (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  static bool checkIfNearBeach(String address) {
    final cleanAddress = address.toLowerCase();
    final keywords = ['pantai', 'beach', 'pesisir', 'coast', 'laut', 'ocean', 'bay', 'teluk'];
    for (var word in keywords) {
      if (cleanAddress.contains(word)) {
        return true;
      }
    }
    return false;
  }

  static EnvironmentResult determineEnvironment(
    double latitude,
    double longitude,
    double accuracy,
    String fullAddress,
  ) {
    // 1. Heuristic for Indoor/Outdoor based on GPS accuracy
    final bool autoIndoor = accuracy > 25.0;

    // 2. Calculate closest mountain in Indonesia
    String detectedMountain = '';
    double closestMountainDistance = double.infinity;
    for (var m in indonesianMountains) {
      final dist = calculateDistance(latitude, longitude, m.latitude, m.longitude);
      if (dist < 10.0 && dist < closestMountainDistance) {
        closestMountainDistance = dist;
        detectedMountain = m.name;
      }
    }

    // 3. Determine if near beach based on address keywords
    final bool isNearBeach = checkIfNearBeach(fullAddress);

    String envType = 'Perkotaan';
    if (detectedMountain.isNotEmpty) {
      envType = 'Pegunungan';
    } else if (isNearBeach) {
      envType = 'Pantai';
    }

    return EnvironmentResult(
      isIndoor: autoIndoor,
      environmentType: envType,
      nearbyMountainName: detectedMountain,
    );
  }
}

class EnvironmentStatusCard extends StatelessWidget {
  final bool isIndoor;
  final String environmentType;
  final String nearbyMountainName;
  final VoidCallback onIndoorToggle;
  final GlobalKey chipsKey;

  const EnvironmentStatusCard({
    required this.isIndoor,
    required this.environmentType,
    required this.nearbyMountainName,
    required this.onIndoorToggle,
    required this.chipsKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.sensors_rounded, color: Color(0xFF00BCD4), size: 24),
            SizedBox(width: 8),
            Text(
              'Status & Deteksi Lingkungan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          key: chipsKey,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF092C4C).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Indoor/Outdoor Card (Interactive Row Layout)
              Expanded(
                child: InkWell(
                  onTap: onIndoorToggle,
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: isIndoor 
                          ? const Color(0xFFFFF8E1) 
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isIndoor 
                            ? const Color(0xFFFFD54F) 
                            : const Color(0xFF81C784),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isIndoor 
                                ? const Color(0xFFFFECB3) 
                                : const Color(0xFFC8E6C9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isIndoor ? Icons.home_rounded : Icons.wb_sunny_rounded,
                            color: isIndoor ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Posisi Anda',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isIndoor ? 'Dalam Ruangan' : 'Luar Ruangan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isIndoor ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.sync_rounded,
                          color: Color(0xFF94A3B8),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 2. Territory Type Card (Row Layout)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: environmentType == 'Pegunungan'
                        ? const Color(0xFFE8EAF6)
                        : environmentType == 'Pantai'
                            ? const Color(0xFFE0F7FA)
                            : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: environmentType == 'Pegunungan'
                          ? const Color(0xFF9FA8DA)
                          : environmentType == 'Pantai'
                              ? const Color(0xFF80DEEA)
                              : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: environmentType == 'Pegunungan'
                              ? const Color(0xFFC5CAE9)
                              : environmentType == 'Pantai'
                                  ? const Color(0xFFB2EBF2)
                                  : const Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          environmentType == 'Pegunungan'
                              ? Icons.terrain_rounded
                              : environmentType == 'Pantai'
                                  ? Icons.beach_access_rounded
                                  : Icons.location_city_rounded,
                          color: environmentType == 'Pegunungan'
                              ? const Color(0xFF1A237E)
                              : environmentType == 'Pantai'
                                  ? const Color(0xFF006064)
                                  : const Color(0xFF334155),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Tipe Wilayah',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                                                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              environmentType == 'Pegunungan'
                                  ? 'Dekat ${nearbyMountainName}'
                                  : environmentType == 'Pantai'
                                      ? 'Pesisir Pantai'
                                      : 'Perkotaan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: environmentType == 'Pegunungan'
                                    ? const Color(0xFF1A237E)
                                    : environmentType == 'Pantai'
                                        ? const Color(0xFF006064)
                                        : const Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.gps_fixed_rounded,
                        color: Color(0xFF94A3B8),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
