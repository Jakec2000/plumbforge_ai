class TakeoffResult {
  final List<String> detectedFixtures;
  final List<PipeRun> pipeRuns;
  final List<String> complianceFlags;
  final String recommendedSolution;

  TakeoffResult({
    required this.detectedFixtures,
    required this.pipeRuns,
    required this.complianceFlags,
    required this.recommendedSolution,
  });

  factory TakeoffResult.fromJson(Map<String, dynamic> json) {
    return TakeoffResult(
      detectedFixtures: List<String>.from(json['detectedFixtures'] ?? []),
      pipeRuns: (json['pipeRuns'] as List<dynamic>?)
              ?.map((e) => PipeRun.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      complianceFlags: List<String>.from(json['complianceFlags'] ?? []),
      recommendedSolution: json['recommendedSolution'] ?? '',
    );
  }
}

class PipeRun {
  final String material;
  final double estimatedLength;
  final int diameter;

  PipeRun({
    required this.material,
    required this.estimatedLength,
    required this.diameter,
  });

  factory PipeRun.fromJson(Map<String, dynamic> json) {
    return PipeRun(
      material: json['material'] ?? 'Unknown',
      estimatedLength: (json['estimatedLength'] as num?)?.toDouble() ?? 0.0,
      diameter: json['diameter'] as int? ?? 0,
    );
  }
}
