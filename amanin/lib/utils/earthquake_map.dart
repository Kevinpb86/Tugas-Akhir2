import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_utils.dart';

class EarthquakeMap extends StatelessWidget {
  final String coordinates;
  final double initialZoom;
  final bool interactive;

  const EarthquakeMap({
    super.key,
    required this.coordinates,
    this.initialZoom = 7.0,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (coordinates.isEmpty) {
      return Container(
        color: const Color(0xFFF1F5F9),
        child: const Center(
          child: Icon(
            Icons.map,
            size: 48,
            color: Color(0xFFCBD5E1),
          ),
        ),
      );
    }

    final latLng = LatLng(
      double.parse(coordinates.split(',')[0]),
      double.parse(coordinates.split(',')[1]),
    );

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
        MarkerLayer(
          markers: [
            Marker(
              point: latLng,
              width: 120,
              height: 120,
              child: const PulsatingMarker(
                color: Colors.red,
                radius: 60,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
