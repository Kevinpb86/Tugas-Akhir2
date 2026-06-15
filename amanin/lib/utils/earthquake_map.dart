import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_utils.dart';

class EarthquakeMap extends StatelessWidget {
  final String coordinates;
  final double initialZoom;
  final bool interactive;
  final LatLng? userLocation; // titik biru lokasi pengguna

  const EarthquakeMap({
    super.key,
    required this.coordinates,
    this.initialZoom = 7.0,
    this.interactive = true,
    this.userLocation,
  });

  /// Hitung jarak dalam km menggunakan Haversine formula
  double _distanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final sinDLat = math.sin(dLat / 2);
    final sinDLon = math.sin(dLon / 2);
    final x = sinDLat * sinDLat +
        math.cos(_deg2rad(a.latitude)) *
            math.cos(_deg2rad(b.latitude)) *
            sinDLon *
            sinDLon;
    final c = 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
    return r * c;
  }

  double _deg2rad(double deg) => deg * math.pi / 180;

  /// Titik tengah antara dua koordinat
  LatLng _midpoint(LatLng a, LatLng b) {
    return LatLng(
      (a.latitude + b.latitude) / 2,
      (a.longitude + b.longitude) / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (coordinates.isEmpty) {
      return Container(
        color: const Color(0xFFF1F5F9),
        child: const Center(
          child: Icon(Icons.map, size: 48, color: Color(0xFFCBD5E1)),
        ),
      );
    }

    final latLng = LatLng(
      double.parse(coordinates.split(',')[0]),
      double.parse(coordinates.split(',')[1]),
    );

    // Hitung jarak & midpoint jika lokasi pengguna tersedia
    String? distanceLabel;
    LatLng? midpoint;
    if (userLocation != null) {
      final km = _distanceKm(userLocation!, latLng);
      distanceLabel = km >= 1
          ? '${km.toStringAsFixed(0)} km'
          : '${(km * 1000).toStringAsFixed(0)} m';
      midpoint = _midpoint(userLocation!, latLng);
    }

    final markers = <Marker>[
      // Titik merah berdetak — pusat gempa
      Marker(
        point: latLng,
        width: 120,
        height: 120,
        child: const PulsatingMarker(color: Colors.red, radius: 60),
      ),
      // Titik biru berdetak — lokasi pengguna saat ini
      if (userLocation != null)
        Marker(
          point: userLocation!,
          width: 60,
          height: 60,
          child: const PulsatingMarker(color: Color(0xFF2196F3), radius: 30),
        ),
      // Label jarak di tengah garis
      if (midpoint != null && distanceLabel != null)
        Marker(
          point: midpoint,
          width: 110,
          height: 36,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.straighten, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(
                  distanceLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
    ];

    return FlutterMap(
      options: MapOptions(
        initialCenter: latLng,
        initialZoom: initialZoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.amanin',
          maxZoom: 19,
          maxNativeZoom: 19,
        ),
        // Garis putus-putus dari lokasi pengguna ke pusat gempa
        if (userLocation != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [userLocation!, latLng],
                color: const Color(0xFF2196F3),
                strokeWidth: 2.5,
                pattern: StrokePattern.dotted(),
              ),
            ],
          ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
