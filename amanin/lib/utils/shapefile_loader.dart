import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:shapefile/shapefile.dart' as shapefile;

class ShapefileLoader {
  static const String _shapefileAssetDirectory = 'assets/Data_Sesar/';

  /// Loads all line geometries from the first available shapefile asset in
  /// assets/Data_Sesar/. If no asset is found or parsing fails, returns an
  /// empty list.
  static Future<List<List<LatLng>>> loadFaultSegmentsFromAssets() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
      final shapePaths = manifest.keys
          .where((key) => key.startsWith(_shapefileAssetDirectory) &&
          key.toLowerCase().endsWith('.shp'))
          .toList();
      final dbfPaths = manifest.keys
          .where((key) => key.startsWith(_shapefileAssetDirectory) &&
          key.toLowerCase().endsWith('.dbf'))
          .toList();

      if (shapePaths.isEmpty) {
        return [];
      }

      final shpBytes = (await rootBundle.load(shapePaths.first)).buffer.asUint8List();
      final shpStream = Stream.value(shpBytes);
      Stream<List<int>>? dbfStream;

      if (dbfPaths.isNotEmpty) {
        final dbfBytes = (await rootBundle.load(dbfPaths.first)).buffer.asUint8List();
        dbfStream = Stream.value(dbfBytes);
      }

      final collection = await shapefile.featureCollection(
        shpStream,
        dbf: dbfStream,
      );
      final features = (collection['features'] as List<dynamic>?) ?? [];

      final segments = <List<LatLng>>[];
      for (final feature in features) {
        final geometry = feature['geometry'] as Map<String, dynamic>?;
        if (geometry == null) {
          continue;
        }
        segments.addAll(_extractSegments(geometry));
      }
      return segments;
    } catch (_) {
      return [];
    }
  }

  static Iterable<List<LatLng>> _extractSegments(
      Map<String, dynamic> geometry) sync* {
    final type = geometry['type'] as String?;
    final coordinates = geometry['coordinates'];
    if (type == null || coordinates == null) {
      return;
    }

    if (type == 'LineString') {
      yield _toLatLngList(coordinates as List<dynamic>);
      return;
    }

    if (type == 'MultiLineString') {
      for (final part in coordinates as List<dynamic>) {
        yield _toLatLngList(part as List<dynamic>);
      }
      return;
    }

    if (type == 'Polygon') {
      for (final ring in coordinates as List<dynamic>) {
        yield _toLatLngList(ring as List<dynamic>);
      }
      return;
    }

    if (type == 'MultiPolygon') {
      for (final polygon in coordinates as List<dynamic>) {
        for (final ring in polygon as List<dynamic>) {
          yield _toLatLngList(ring as List<dynamic>);
        }
      }
      return;
    }
  }

  static List<LatLng> _toLatLngList(List<dynamic> data) {
    return data
        .whereType<List<dynamic>>()
        .map((coordinate) => LatLng(
      (coordinate[1] as num).toDouble(),
      (coordinate[0] as num).toDouble(),
    ))
        .toList();
  }
}
