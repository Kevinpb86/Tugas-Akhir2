class EarthquakeNode {
  final int id;
  final DateTime eventTime;
  final double latitude;
  final double longitude;
  final double? depth;
  final double? magnitude;
  final String? wilayah;
  final String? dirasakan;
  final String? prediction;
  final double? probability;

  EarthquakeNode({
    required this.id,
    required this.eventTime,
    required this.latitude,
    required this.longitude,
    this.depth,
    this.magnitude,
    this.wilayah,
    this.dirasakan,
    this.prediction,
    this.probability,
  });

  factory EarthquakeNode.fromJson(Map<String, dynamic> json) {
    return EarthquakeNode(
      id: json['id'],
      eventTime: DateTime.parse(json['event_time']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      depth: json['depth'] != null
          ? double.tryParse(json['depth'].toString())
          : null,


      magnitude: json['magnitude'] != null
          ? double.tryParse(json['magnitude'].toString())
          : null,
      wilayah: json['wilayah'],
      dirasakan: json['dirasakan'],
      prediction: json['prediction'],
      probability: json['probability'] != null
          ? (json['probability'] as num).toDouble()
          : null,
    );
  }
}

class EarthquakeEdge {
  final int source;
  final int target;

  EarthquakeEdge({
    required this.source,
    required this.target,
  });

  factory EarthquakeEdge.fromJson(Map<String, dynamic> json) {
    return EarthquakeEdge(
      source: json['source'],
      target: json['target'],
    );
  }
}

class EarthquakeNetwork {
  final List<EarthquakeNode> nodes;
  final List<EarthquakeEdge> edges;

  EarthquakeNetwork({
    required this.nodes,
    required this.edges,
  });

  factory EarthquakeNetwork.fromJson(Map<String, dynamic> json) {
    return EarthquakeNetwork(
      nodes: (json['nodes'] as List)
          .map((e) => EarthquakeNode.fromJson(e))
          .toList(),
      edges: (json['edges'] as List)
          .map((e) => EarthquakeEdge.fromJson(e))
          .toList(),
    );
  }
}

class EarthquakeEvent {
  final int id;
  final DateTime eventTime;
  final double latitude;
  final double longitude;
  final double? depth;
  final double? magnitude;
  final String? wilayah;
  final String? dirasakan;
  final String? prediction;
  final double? probability;

  EarthquakeEvent({
    required this.id,
    required this.eventTime,
    required this.latitude,
    required this.longitude,
    this.depth,
    this.magnitude,
    this.wilayah,
    this.dirasakan,
    this.prediction,
    this.probability,
  });

  factory EarthquakeEvent.fromJson(Map<String, dynamic> json) {
    return EarthquakeEvent(
      id: json['id'],
      eventTime: DateTime.parse(json['event_time']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      depth: json['depth'] != null ? double.tryParse(json['depth'].toString()) : null,
      magnitude: json['magnitude'] != null
          ? double.tryParse(json['magnitude'].toString())
          : null,
      wilayah: json['wilayah'],
      dirasakan: json['dirasakan'],
      prediction: json['prediction'],
      probability: json['probability'] != null
          ? (json['probability'] as num).toDouble()
          : null,
    );
  }
}

class InfluenceZone {
  final int earthquakeId;
  final double latitude;
  final double longitude;
  final double magnitude;
  final double radiusKm;
  final int windowDays;
  final DateTime startTime;
  final DateTime endTime;

  InfluenceZone({
    required this.earthquakeId,
    required this.latitude,
    required this.longitude,
    required this.magnitude,
    required this.radiusKm,
    required this.windowDays,
    required this.startTime,
    required this.endTime,
  });

  factory InfluenceZone.fromJson(Map<String, dynamic> json) {
    return InfluenceZone(
      earthquakeId: json['earthquake_id'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      magnitude: (json['magnitude'] as num).toDouble(),
      radiusKm: (json['radius_km'] as num).toDouble(),
      windowDays: json['window_days'] as int,
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
    );
  }
}

class EarthquakeMapData {
  final List<EarthquakeEvent> earthquakes;
  final List<InfluenceZone> influenceZones;

  EarthquakeMapData({
    required this.earthquakes,
    required this.influenceZones,
  });

  factory EarthquakeMapData.fromJson(Map<String, dynamic> json) {
    return EarthquakeMapData(
      earthquakes: (json['earthquakes'] as List)
          .map((e) => EarthquakeEvent.fromJson(e))
          .toList(),
      influenceZones: (json['influence_zones'] as List)
          .map((e) => InfluenceZone.fromJson(e))
          .toList(),
    );
  }
}
