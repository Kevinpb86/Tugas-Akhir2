class GempaModel {
  final String magnitude;
  final String lintang;
  final String bujur;
  final String wilayah;

  // NEW (ML FIELDS)
  final int? rfPrediction; // 1 = aftershock, 0 = normal
  final bool? isClusterCenter;

  GempaModel({
    required this.magnitude,
    required this.lintang,
    required this.bujur,
    required this.wilayah,
    this.rfPrediction,
    this.isClusterCenter,
  });
}