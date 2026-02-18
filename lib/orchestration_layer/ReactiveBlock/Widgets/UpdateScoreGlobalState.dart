import 'package:signals/signals.dart';

class UpdateScoreGlobalState {
  final currentScore = signal<int>(0);

  void setCurrentScore(int value) {
    currentScore.value = value;
  }
}

// Tạo instance để dùng trong app
final counter = UpdateScoreGlobalState();
