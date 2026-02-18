
class ScoreData {
  final double healthGlobalScore;
  final double socialGlobalScore;
  final double financialGlobalScore;
  final double careerGlobalScore;

  ScoreData({
    required this.healthGlobalScore,
    required this.socialGlobalScore,
    required this.financialGlobalScore,
    required this.careerGlobalScore,
  });

  factory ScoreData.empty() {
    return ScoreData(
      healthGlobalScore: 0.0,
      socialGlobalScore: 0.0,
      financialGlobalScore: 0.0,
      careerGlobalScore: 0.0,
    );
  }

  ScoreData copyWith({
    double? healthGlobalScore,
    double? socialGlobalScore,
    double? financialGlobalScore,
    double? careerGlobalScore,
  }) {
    return ScoreData(
      healthGlobalScore: healthGlobalScore ?? this.healthGlobalScore,
      socialGlobalScore: socialGlobalScore ?? this.socialGlobalScore,
      financialGlobalScore: financialGlobalScore ?? this.financialGlobalScore,
      careerGlobalScore: careerGlobalScore ?? this.careerGlobalScore,
    );
  }
}
