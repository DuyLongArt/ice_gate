import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  int _currentMinutes = 0; // in minutes
  final int _goalMinutes = 60; // daily goal
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final dao = context.read<HealthMetricsDAO>();
    final today = DateTime.now();
    // Assuming personID 1 for now
    final data = await dao.getMetricsForDate(1, today);
    if (mounted) {
      setState(() {
        _currentMinutes = data?.exerciseMinutes ?? 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _addExercise(int minutes) async {
    if (!mounted) return;
    final dao = context.read<HealthMetricsDAO>();
    final today = DateTime.now();

    // Optimistic update
    setState(() {
      _currentMinutes += minutes;
    });

    try {
      final currentMetrics = await dao.getMetricsForDate(1, today);

      if (currentMetrics != null) {
        // Update existing
        await dao.insertOrUpdateMetrics(
          currentMetrics
              .toCompanion(true)
              .copyWith(
                exerciseMinutes: drift.Value(_currentMinutes),
                updatedAt: drift.Value(DateTime.now()),
              ),
        );
      } else {
        // Insert new
        await dao.insertOrUpdateMetrics(
          HealthMetricsTableCompanion.insert(
            personID: 1,
            date: today,
            exerciseMinutes: drift.Value(_currentMinutes),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentMinutes -= minutes;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving exercise: $e')));
      }
    }
  }

  Future<void> _resetExercise() async {
    if (!mounted) return;
    final dao = context.read<HealthMetricsDAO>();
    final today = DateTime.now();

    setState(() {
      _currentMinutes = 0;
    });

    try {
      final currentMetrics = await dao.getMetricsForDate(1, today);
      if (currentMetrics != null) {
        await dao.insertOrUpdateMetrics(
          currentMetrics
              .toCompanion(true)
              .copyWith(
                exerciseMinutes: const drift.Value(0),
                updatedAt: drift.Value(DateTime.now()),
              ),
        );
      }
    } catch (e) {
      // Error
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    double progress = (_currentMinutes / _goalMinutes).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Tracker'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 20,
                          backgroundColor: Colors.orange.withOpacity(0.1),
                          color: Colors.orange,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_currentMinutes',
                            style: textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            'min / $_goalMinutes min',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text("Details", style: textTheme.titleMedium),
                  const SizedBox(height: 16),

                  // Stats Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBox(
                        "Calories",
                        "${_currentMinutes * 8}",
                        "kcal (est)",
                        colorScheme,
                      ),
                      _buildStatBox(
                        "Goal",
                        "${(progress * 100).toInt()}%",
                        "completed",
                        colorScheme,
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  Text("Quick Add Activity", style: textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAddButton(15, '+15 m', colorScheme),
                      _buildAddButton(30, '+30 m', colorScheme),
                      _buildAddButton(60, '+1 h', colorScheme),
                    ],
                  ),

                  const SizedBox(height: 48),

                  TextButton.icon(
                    onPressed: _resetExercise,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Today'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    String unit,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(unit, style: TextStyle(color: colorScheme.secondary)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(int minutes, String label, ColorScheme colorScheme) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: () => _addExercise(minutes),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: Colors.orange.withOpacity(0.1),
            foregroundColor: Colors.orange,
            padding: const EdgeInsets.all(20),
            iconSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
