import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';
import 'package:ice_shield/initial_layer/DuyLongServices/PowerPoint/Const.dart';
import 'package:intl/intl.dart';

class GamificationService {
  final HealthMetricsDAO _healthMetricsDAO;
  final HealthMealDAO _healthMealDAO;
  final PersonManagementDAO _personDAO;

  GamificationService(
    this._healthMetricsDAO,
    this._healthMealDAO,
    this._personDAO,
  );

  Future<int> calculateTotalPoints(int personID) async {
    // 1. Points from Steps: STEPS_PER_POINT steps = 1 point
    int stepsPoints = 0;
    try {
      final allMetrics = await _healthMetricsDAO
          .watchAllMetrics(personID)
          .first;
      int totalSteps = 0;
      for (var m in allMetrics) {
        totalSteps += m.steps;
      }
      stepsPoints = (totalSteps / STEPS_PER_POINT).floor();
    } catch (e) {
      stepsPoints = 0;
    }

    // 2. Points from Diet: Daily Calories < CALORIE_LIMIT = CALORIE_BONUS_POINTS
    int dietPoints = 0;
    try {
      final allMealsWrapper = await _healthMealDAO.watchDaysWithMeals().first;

      // Group by Day
      final Map<String, double> dailyCalories = {};
      for (var item in allMealsWrapper) {
        final dateKey = DateFormat('yyyy-MM-dd').format(item.meal.eatenAt);
        dailyCalories[dateKey] =
            (dailyCalories[dateKey] ?? 0) + item.meal.calories;
      }

      // Calculate points
      dailyCalories.forEach((date, calories) {
        if (calories > 0 && calories < CALORIE_LIMIT) {
          dietPoints += CALORIE_BONUS_POINTS;
        }
      });
    } catch (e) {
      dietPoints = 0;
    }

    // 3. Points from Social: CONTACT_POINTS per contact, AFFECTION_POINTS per AFFECTION_PER_UNIT affection
    int socialPoints = 0;
    try {
      final contacts = await _personDAO.getAllContacts().first;
      int totalAffection = 0;
      for (var contact in contacts) {
        totalAffection += contact.affection;
      }
      socialPoints =
          (contacts.length * CONTACT_POINTS) +
          ((totalAffection ~/ AFFECTION_PER_UNIT) * AFFECTION_POINTS);
    } catch (e) {
      socialPoints = 0;
    }

    return stepsPoints + dietPoints + socialPoints;
  }

  int getLevel(int points) {
    if (points <= 0) return 0;
    return (points / 100).floor();
  }

  double getProgressToNextLevel(int points) {
    if (points < 0) return 0;
    int currentLevel = getLevel(points);
    int currentLevelBase = currentLevel * 100;

    // Progress is (points - base) / 100
    // Example: 150 pts. Level 1. Base 100. (150-100)/100 = 0.5. Correct.
    return (points - currentLevelBase) / 100;
  }
}
