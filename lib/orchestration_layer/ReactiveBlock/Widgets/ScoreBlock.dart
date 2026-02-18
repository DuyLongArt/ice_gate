import 'dart:async';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart'
    hide ScoreData;
import 'package:ice_shield/initial_layer/CoreLogics/GamificationService.dart';
import 'package:ice_shield/initial_layer/CoreLogics/PowerPoint/Const.dart';
import 'package:signals/signals.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Widgets/ScoreData.dart';

class ScoreBlock {
  final _score = signal<ScoreData>(ScoreData.empty());

  // DAOs stored locally for access in update methods
  late ScoreDAO _dao;
  late PersonManagementDAO _personDAO;
  late FinanceDAO _financeDAO;
  late HealthMetricsDAO _healthDAO;
  late HealthMealDAO _mealDAO;

  late int _personID;

  // Track subscriptions to cancel them on dispose
  final List<StreamSubscription> _subscriptions = [];

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

  /// Global level (Cumulative: Level L requires 50*L*(L+1) pts)
  late final globalLevel = computed(() {
    return GamificationService.getLevel(totalXP.value.toInt());
  });

  /// Percentage progress towards the next level
  late final levelProgress = computed(() {
    return GamificationService.getProgressToNextLevel(totalXP.value.toInt());
  });

  /// Descriptive rank based on Level
  late final rankTitle = computed(() {
    final level = globalLevel.value;
    if (level < 10) return "Novice";
    if (level < 20) return "Protector";
    if (level < 30) return "Guardian";
    return "Legend";
  });

  void updateScore(ScoreData score) {
    _score.value = score;
  }

  void init(
    ScoreDAO dao,
    PersonManagementDAO personDAO,
    FinanceDAO financeDAO,
    HealthMetricsDAO healthDAO,
    HealthMealDAO mealDAO,
    int personID,
  ) {
    _dao = dao;
    _personDAO = personDAO;
    _financeDAO = financeDAO;
    _healthDAO = healthDAO;
    _mealDAO = mealDAO;
    _personID = personID;

    // 1. Listen to Score changes (read)
    _subscriptions.add(
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
      }),
    );

    // 2. Auto-Update Logic (write)

    // Finance Watcher
    _subscriptions.add(
      financeDAO.watchAccounts(personID).listen((_) => _updateFinanceScore()),
    );
    _subscriptions.add(
      financeDAO.watchAssets(personID).listen((_) => _updateFinanceScore()),
    );

    // Social Watcher
    _subscriptions.add(
      personDAO.getAllContacts().listen((_) => _updateSocialScore()),
    );

    // Health Watcher (Debounce might be good here for steps, but direct listen is fine for now)
    _subscriptions.add(
      healthDAO.watchAllMetrics(personID).listen((_) => _updateHealthScore()),
    );
    _subscriptions.add(
      mealDAO.watchDaysWithMeals().listen((_) => _updateHealthScore()),
    );
  }

  Future<void> _updateFinanceScore() async {
    try {
      final accounts = await _financeDAO.watchAccounts(_personID).first;
      final assets = await _financeDAO.watchAssets(_personID).first;

      double totalNetWorth = 0;
      double investmentPoints = 0;

      for (var acc in accounts) {
        totalNetWorth += acc.balance;
      }

      for (var asset in assets) {
        final currentVal = asset.currentEstimatedValue ?? 0.0;
        final purchaseVal = asset.purchasePrice ?? 0.0;

        totalNetWorth += currentVal;

        // Investment Return Calculation
        if (purchaseVal > 0 && currentVal > purchaseVal) {
          final returnPercentage =
              ((currentVal - purchaseVal) / purchaseVal) * 100;
          if (returnPercentage >= FINANCE_INVESTMENT_RETURN_THRESHOLD) {
            investmentPoints +=
                (returnPercentage / FINANCE_INVESTMENT_RETURN_THRESHOLD)
                    .floor() *
                FINANCE_INVESTMENT_POINTS;
          }
        }
      }

      final savingsPoints =
          ((totalNetWorth / FINANCE_SAVINGS_MILESTONE) * FINANCE_SAVINGS_POINTS)
              .toDouble();

      final financeScore = savingsPoints + investmentPoints;

      await _dao.updateFinancialScore(_personID, financeScore);
    } catch (e) {
      print("Error updating finance score: $e");
    }
  }

  Future<void> _updateSocialScore() async {
    try {
      final contacts = await _personDAO.getAllContacts().first;
      int totalAffection = 0;
      for (var c in contacts) {
        totalAffection += c.affection;
      }
      final socialScore =
          (contacts.length * CONTACT_POINTS).toDouble() +
          ((totalAffection ~/ AFFECTION_PER_UNIT) * AFFECTION_POINTS)
              .toDouble();
      await _dao.updateSocialScore(_personID, socialScore);
    } catch (e) {
      print("Error updating social score: $e");
    }
  }

  Future<void> _updateHealthScore() async {
    try {
      // 1. Steps
      int stepsPoints = 0;
      final allMetrics = await _healthDAO.watchAllMetrics(_personID).first;
      int totalSteps = 0;
      for (var m in allMetrics) {
        totalSteps += m.steps;
      }
      if (STEPS_PER_POINT > 0) {
        stepsPoints = (totalSteps / STEPS_PER_POINT).floor();
      }

      // 2. Diet
      int dietPoints = 0;
      final allMealsWrapper = await _mealDAO.watchDaysWithMeals().first;
      final Map<String, double> dailyCalories = {};

      for (var item in allMealsWrapper) {
        // Group by YYYY-MM-DD
        final d = item.meal.eatenAt;
        final dateKey = "${d.year}-${d.month}-${d.day}";
        dailyCalories[dateKey] =
            (dailyCalories[dateKey] ?? 0) + item.meal.calories;
      }

      dailyCalories.forEach((_, calories) {
        if (calories > 0 && calories < CALORIE_LIMIT) {
          dietPoints += CALORIE_BONUS_POINTS;
        }
      });

      final healthScore = (stepsPoints + dietPoints).toDouble();
      await _dao.updateHealthScore(_personID, healthScore);
    } catch (e) {
      print("Error updating health score: $e");
    }
  }

  Future<void> persistentCareerIncrement(double points) async {
    await _dao.incrementCareerScore(_personID, points);
  }

  void dispose() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    _score.dispose();
  }
}
