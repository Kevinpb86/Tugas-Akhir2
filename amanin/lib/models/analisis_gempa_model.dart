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