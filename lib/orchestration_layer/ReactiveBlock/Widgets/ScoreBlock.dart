import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart'
    hide ScoreData;
import 'package:signals/signals.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Widgets/ScoreData.dart';

class ScoreBlock {
  final _score = signal<ScoreData>(ScoreData.empty());

  ScoreBlock({ScoreData? initialScore}) {
    if (initialScore != null) {
      _score.value = initialScore;
    }
  }

  ScoreData get score => _score.value;
  set score(ScoreData value) => _score.value = value;

  late final averageScore = computed(() {
    final s = _score.value;
    return (s.healthGlobalScore +
            s.socialGlobalScore +
            s.financialGlobalScore +
            s.careerGlobalScore) /
        4;
  });

  /// Raw sum of all scores (Range: 0.0 - 4.0)
  late final totalXP = computed(() {
    final s = _score.value;
    return s.healthGlobalScore +
        s.socialGlobalScore +
        s.financialGlobalScore +
        s.careerGlobalScore;
  });

  /// Global level (100 points per level)
  late final globalLevel = computed(() {
    return (totalXP.value / 100).floor() + 1;
  });

  /// Percentage progress towards the next level
  late final levelProgress = computed(() {
    final xp = totalXP.value;
    return (xp % 100) / 100;
  });

  /// Descriptive rank based on Level
  late final rankTitle = computed(() {
    final level = globalLevel.value;
    if (level < 10) return "Novice";
    if (level < 20) return "Protector";
    if (level < 30) return "Guardian";
    return "Legend";
  });

  // Convenient methods to update individual scores
  void updateHealth(double value) {
    _score.value = _score.value.copyWith(healthGlobalScore: value);
  }

  void updateSocial(double value) {
    _score.value = _score.value.copyWith(socialGlobalScore: value);
  }

  void updateFinancial(double value) {
    _score.value = _score.value.copyWith(financialGlobalScore: value);
  }

  void updateCareer(double value) {
    _score.value = _score.value.copyWith(careerGlobalScore: value);
  }

  void updateScore(ScoreData score) {
    _score.value = score;
  }

  void init(ScoreDAO dao, int personID) {
    _dao = dao;
    _personID = personID;
    dao.watchScoreByPersonID(personID).listen((data) {
      if (data != null) {
        updateScore(
          ScoreData(
            healthGlobalScore: data.healthGlobalScore,
            socialGlobalScore: data.socialGlobalScore,
            financialGlobalScore: data.financialGlobalScore,
            careerGlobalScore: data.careerGlobalScore,
          ),
        );
      }
    });
  }

  late ScoreDAO _dao;
  late int _personID;

  Future<void> persistentCareerIncrement(double points) async {
    await _dao.incrementCareerScore(_personID, points);
    // The signal will be updated by the listener in init
  }

  void dispose() {
    _score.dispose();
  }
}
