import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart'; // Import generated code
import 'package:signals/signals.dart';
import 'package:drift/drift.dart' as drift;

import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/GrowthBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Widgets/ScoreBlock.dart';
import 'package:ice_shield/initial_layer/FocusAudioHandler.dart';
import 'package:live_activities/live_activities.dart';
import 'package:audioplayers/audioplayers.dart';

enum FocusStatus { idle, running, paused, completed }

class FocusSessionState {
  final int remainingSeconds;
  final int totalDuration;
  final FocusStatus status;
  final int? currentProjectId;
  final String? notes;

  const FocusSessionState({
    required this.remainingSeconds,
    required this.totalDuration,
    required this.status,
    this.currentProjectId,
    this.notes,
  });

  double get progress => totalDuration > 0
      ? (totalDuration - remainingSeconds) / totalDuration
      : 0.0;
}

class FocusBlock {
  // Dependencies
  final FocusSessionsDAO _focusSessionDao;
  final int _currentPersonId;

  // Configuration (Defaults)
  static const int _initialFocusMin = 25;
  static const int _initialShortBreakMin = 5;
  static const int _initialLongBreakMin = 15;

  // Durations (in minutes) - Managed as signals for reactivity
  final focusDuration = signal<int>(_initialFocusMin);
  final shortBreakDuration = signal<int>(_initialShortBreakMin);
  final longBreakDuration = signal<int>(_initialLongBreakMin);

  // Signals
  final remainingTime = signal<int>(_initialFocusMin * 60);
  final isRunning = signal<bool>(false);
  final currentSessionType = signal<String>(
    'Focus',
  ); // Focus, Short Break, Long Break
  final selectedProjectId = signal<int?>(null);
  final selectedTaskId = signal<int?>(null);
  final sessionNotes = signal<String>('');

  // Stats
  final totalStudyTimeToday = signal<int>(0); // In seconds
  final sessionsCompletedToday = signal<int>(0);

  // Theme
  // Theme
  final timerTheme = signal<String>('Default');

  // Audio Customization
  final customSoundPath = signal<String?>(null);
  final isCustomSoundLocal = signal<bool>(false);

  // External Blocks for Automation
  GrowthBlock? growthBlock;
  ScoreBlock? scoreBlock;

  // Timer
  Timer? _timer;
  DateTime? _startTime;

  final FocusAudioHandler? _audioHandler;

  // Live Activity
  final _liveActivities = LiveActivities();
  String? _activityId;

  FocusBlock({
    required FocusSessionsDAO focusSessionDao,
    required int personId,
    FocusAudioHandler? audioHandler,
  }) : _focusSessionDao = focusSessionDao,
       _currentPersonId = personId,
       _audioHandler = audioHandler;

  // --- Initialization ---
  Future<void> init() async {
    try {
      await fetchDailyStats();
      // Use correct bundle ID for app group
      await _liveActivities.init(appGroupId: 'group.duylong.art.iceshield');

      // Register this block with the audio handler for two-way sync
      _audioHandler?.focusBlock = this;
    } catch (e) {
      print("FocusBlock init error: $e");
    }
  }

  // --- Timer Actions ---

  void startTimer({bool fromSystem = false}) async {
    print(
      "FocusBlock(${identityHashCode(this)}): startTimer called. isRunning: ${isRunning.value}, fromSystem: $fromSystem",
    );
    if (isRunning.value) return;

    isRunning.value = true;
    _startTime ??= DateTime.now();

    // debugPrint("audio: "+ _audioHandler.mediaItem.value.toString());]
    try {
      if (!fromSystem) {
        bool sourceSet = await _updateAudioSource();
        if (sourceSet) {
          _audioHandler?.play();
        } else {
          print("FocusBlock: Skipping audio playback (no valid source).");
        }
      }
    } catch (e) {
      print("FocusBlock startTimer error: $e");
    }

    // Start Live Activity asynchronously without blocking the timer
    _createLiveActivity();

    print("FocusBlock: Starting Timer.periodic");
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;

        // Sync to Live Activity (Primary)
        try {
          _updateLiveActivity();
        } catch (e) {
          print("FocusBlock: Live Activity Update Error: $e");
        }

        // Sync to Media Metadata (Secondary, only if audio is active)
        try {
          if (_audioHandler?.mediaItem.value != null) {
            _updateMediaMetadata();
          }
        } catch (e) {
          print("FocusBlock: Media Metadata Update Error: $e");
        }
      } else {
        completeSession();
      }
    });
  }

  Future<void> _createLiveActivity() async {
    try {
      _activityId = await _liveActivities
          .createActivity('group.duylong.art.iceshield', {
            'title': "${currentSessionType.value} Practise",
            'time': _formatTime(remainingTime.value),
            'progress': remainingTime.value / (focusDuration.value * 60),
          });
    } catch (e) {
      print("Error creating Live Activity: $e");
    }
  }

  void _updateLiveActivity() {
    if (_activityId != null) {
      _liveActivities.updateActivity(_activityId!, {
        'time': _formatTime(remainingTime.value),
        'progress': remainingTime.value / (focusDuration.value * 60),
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSecs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSecs.toString().padLeft(2, '0')}';
  }

  void pauseTimer({bool fromSystem = false}) {
    print(
      "FocusBlock(${identityHashCode(this)}): pauseTimer called. isRunning: ${isRunning.value}, fromSystem: $fromSystem",
    );
    if (!isRunning.value) return;

    isRunning.value = false;
    _timer?.cancel();
    _timer = null;

    if (!fromSystem) {
      _audioHandler?.pause();
    }
    if (_activityId != null) {
      _liveActivities.endActivity(_activityId!);
      _activityId = null;
    }
  }

  void _updateMediaMetadata() {
    if (_audioHandler == null) return;

    String title =
        "${currentSessionType.value}: ${_formatTime(remainingTime.value)}";
    String artist = "Theme: ${timerTheme.value}";
    if (customSoundPath.value != null) {
      artist = isCustomSoundLocal.value
          ? "Local Audio"
          : "Preset: ${customSoundPath.value!.split('/').last}";
    }

    final totalSecs = _getDurationForType(currentSessionType.value);
    _audioHandler.updateMetadata(
      title: title,
      artist: artist,
      duration: Duration(seconds: totalSecs),
      position: Duration(seconds: totalSecs - remainingTime.value),
    );
  }

  Future<bool> _updateAudioSource() async {
    if (_audioHandler == null) return false;

    try {
      Source targetSource;
      if (customSoundPath.value != null) {
        targetSource = isCustomSoundLocal.value
            ? DeviceFileSource(customSoundPath.value!)
            : AssetSource(customSoundPath.value!);
      } else {
        final soundAsset = _getThemeSoundAsset(timerTheme.value);
        targetSource = AssetSource(soundAsset);
      }

      await _audioHandler.setSource(targetSource);
      return true;
    } catch (e) {
      print("FocusBlock: Failed to set audio source: $e");
      return false;
    }
  }

  String _getThemeSoundAsset(String themeName) {
    // This should ideally be shared with FocusPage
    switch (themeName) {
      case 'Emerald Haven':
        return 'sounds/forest_stream.mp3';
      case 'Emerald Forest':
        return 'sounds/birds.mp3';
      case 'Sakura Zen':
        return 'sounds/zen_garden.mp3';
      case 'Deep Sea':
        return 'sounds/ocean_waves.mp3';
      case 'Frosty Morning':
        return 'sounds/snow_wind.mp3';
      case 'Sunset':
        return 'sounds/crickets.mp3';
      case 'Cyberpunk 2077':
        return 'sounds/cyber_ambience.mp3';
      case 'Nordic Night':
        return 'sounds/campfire.mp3';
      case 'Royal Velvet':
        return 'sounds/lofi.mp3';
      case 'Midnight Gold':
        return 'sounds/space_drone.mp3';
      case 'Light Purple':
        return 'sounds/bubbles.mp3';
      case 'Nebula':
        return 'sounds/nebula_hum.mp3';
      case 'Cherry':
        return 'sounds/fire_crackle.mp3';
      case 'Default':
      default:
        return 'sounds/rain.mp3';
    }
  }

  void resetTimer() {
    pauseTimer();
    remainingTime.value = _getDurationForType(currentSessionType.value);
    _startTime = null;
  }

  void stopTimer() {
    // Save as 'interrupted' if desired, or just reset
    _saveSession(status: 'interrupted');
    resetTimer();
  }

  Future<void> completeSession() async {
    pauseTimer();
    // Play sound or notification here
    await _saveSession(status: 'completed');

    // Update stats immediately
    if (currentSessionType.value == 'Focus') {
      int duration = _getDurationForType('Focus');
      totalStudyTimeToday.value += duration;
      sessionsCompletedToday.value++;

      // New: Automation - Complete task and increase points
      if (selectedTaskId.value != null && growthBlock != null) {
        await growthBlock!.completeGoal(
          selectedTaskId.value!,
          scoreBlock: scoreBlock,
        );
        // Clear selected task after completion
        selectedTaskId.value = null;
      }
    }

    // Auto-switch to break? Or wait for user.
    // For now, let's just reset to default or next steps.
    resetTimer();
  }

  int _getDurationForType(String type) {
    switch (type) {
      case 'Short Break':
        return shortBreakDuration.value * 60;
      case 'Long Break':
        return longBreakDuration.value * 60;
      default:
        return focusDuration.value * 60;
    }
  }

  void setDurations({int? focus, int? short, int? long}) {
    if (focus != null) focusDuration.value = focus;
    if (short != null) shortBreakDuration.value = short;
    if (long != null) longBreakDuration.value = long;

    // If not running, update current remaining time
    if (!isRunning.value) {
      remainingTime.value = _getDurationForType(currentSessionType.value);
    }
  }

  void setSessionType(String type) {
    currentSessionType.value = type;
    resetTimer();
  }

  void setTimerTheme(String theme) {
    timerTheme.value = theme;
  }

  void setCustomSound(String path, {bool isLocal = false}) {
    customSoundPath.value = path;
    isCustomSoundLocal.value = isLocal;
  }

  void clearCustomSound() {
    customSoundPath.value = null;
    isCustomSoundLocal.value = false;
  }

  void setProject(int? projectId) {
    selectedProjectId.value = projectId;
    selectedTaskId.value = null; // Reset task when project changes
  }

  void setTask(int? taskId) {
    selectedTaskId.value = taskId;
  }

  // --- Database Actions ---

  Future<void> _saveSession({required String status}) async {
    if (_startTime == null) return;

    final duration =
        _getDurationForType(currentSessionType.value) - remainingTime.value;

    // Only save significant sessions (e.g., > 1 minute)
    if (duration < 60) return;

    final session = FocusSessionsTableCompanion.insert(
      personID: _currentPersonId,
      projectID: drift.Value(selectedProjectId.value),
      taskID: drift.Value(selectedTaskId.value),
      startTime: _startTime!,
      endTime: drift.Value(DateTime.now()),
      durationSeconds: duration,
      status: status, // 'completed' or 'interrupted'
      notes: drift.Value(
        sessionNotes.value.isNotEmpty ? sessionNotes.value : null,
      ),
    );

    await _focusSessionDao.insertSession(session);
    await fetchDailyStats();
  }

  Future<void> fetchDailyStats() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // We need a query for today's sessions.
    // Since DAO only has watchSessionsByPerson, we might need to filter manually or add a specific query.
    // For simplicity, let's filter the stream or assume we add a getTodaySessions to DAO later.
    // Here we'll just use the stream subscription approach or a one-time fetch if we add that to DAO.

    // Ideally, we should add `getSessionsForDateRange` to DAO.
    // Without it, we can't easily get *just* today without fetching all.
    // Let's rely on the stream in the UI for history,
    // and for stats, maybe we listen to the stream once.

    // Implementing a simple listener on the full stream for now (not efficient for large data, but works for MVP).
    final allSessions = await _focusSessionDao
        .watchSessionsByPerson(_currentPersonId)
        .first;

    int todayDuration = 0;
    int todayCount = 0;

    for (var session in allSessions) {
      if (session.startTime.isAfter(todayStart) &&
          session.startTime.isBefore(todayEnd)) {
        if (session.status == 'completed' &&
            session.durationSeconds >= 25 * 60) {
          // Assume 'Focus' sessions are roughly this length or marked?
          // Actually, we should check duration or have a type field.
          // For 'Study Time', sum durationSeconds.
          todayDuration += session.durationSeconds;
          todayCount++;
        } else if (session.status == 'completed') {
          todayDuration += session.durationSeconds;
          // maybe count breaks? usually not as "sessions".
        }
      }
    }

    totalStudyTimeToday.value = todayDuration;
    sessionsCompletedToday.value = todayCount;
  }

  void dispose() {
    _timer?.cancel();
    if (_activityId != null) {
      _liveActivities.endActivity(_activityId!);
    }
  }
}
