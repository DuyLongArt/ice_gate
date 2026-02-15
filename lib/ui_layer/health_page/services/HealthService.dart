import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';

class HealthService {
  static int _cachedSteps = 0;
  static bool _isListening = false;

  static void _initSubscription() {
    if (_isListening) return;

    _isListening = true;
    Pedometer.stepCountStream.listen(
      (event) {
        _cachedSteps = event.steps;
        debugPrint("HealthService: Steps updated to $_cachedSteps");
      },
      onError: (error) {
        debugPrint("HealthService: Pedometer error: $error");
      },
      cancelOnError: false,
    );
  }

  /// Fetches today's step count using the Pedometer plugin.
  /// Returns 0 if permissions are denied or an error occurs.
  static Future<int> fetchStepCount() async {
    _initSubscription();

    // Return immediately if we have data
    if (_cachedSteps > 0) return _cachedSteps;

    try {
      // If no data yet, wait briefly for the first event
      // Reduced timeout to 2 seconds to avoid blocking too long
      if (_cachedSteps == 0) {
        final event = await Pedometer.stepCountStream.first.timeout(
          const Duration(seconds: 2),
        );
        _cachedSteps = event.steps;
      }
      return _cachedSteps;
    } catch (error) {
      // Don't throw exception, just log and return 0 (or cached value)
      debugPrint(
        "HealthService: Initial step fetch timed out or failed (returning 0).",
      );
      return 0;
    }
  }
}
