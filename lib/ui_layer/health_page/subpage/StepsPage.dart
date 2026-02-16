import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:pedometer/pedometer.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';
import 'package:ice_shield/ui_layer/health_page/services/HealthService.dart';

class StepsPage extends StatefulWidget {
  const StepsPage({super.key});

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  int currentSteps = 0;
  final int dailyGoal = 10000;

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;

  void initPlatformState() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusUpdate)
        .onError(onPedestrianStatusError);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onStepCount(StepCount event) {
    setState(() {
      currentSteps = event.steps;
    });
    _saveSteps(event.steps);
  }

  void onPedestrianStatusUpdate(PedestrianStatus event) {
    setState(() {
      debugPrint("status step: ${event.status}");
    });
  }

  void onPedestrianStatusError(error) {
    debugPrint('Pedestrian Status Error: $error');
  }

  void onStepCountError(error) {
    debugPrint('Step Count Error: $error');
  }

  double get progressPercentage =>
      (currentSteps / dailyGoal * 100).clamp(0, 100);
  int get remainingSteps => (dailyGoal - currentSteps).clamp(0, dailyGoal);
  double get distanceKm => currentSteps * 0.0008;
  int get caloriesBurned => (currentSteps * 0.04).round();

  @override
  void initState() {
    super.initState();
    _loadData();
    initPlatformState();

    // Fetch steps from Apple Health
    HealthService.fetchStepCount().then((steps) {
      if (mounted && steps > currentSteps) {
        setState(() {
          currentSteps = steps;
        });
        _saveSteps(steps);
      }
    });
  }

  Future<void> _loadData() async {
    final dao = context.read<HealthMetricsDAO>();
    final today = DateTime.now();
    final data = await dao.getMetricsForDate(1, today);
    if (mounted && data != null && data.steps > currentSteps) {
      setState(() {
        currentSteps = data.steps;
      });
    }
  }

  Future<void> _saveSteps(int steps) async {
    try {
      final dao = context.read<HealthMetricsDAO>();
      final today = DateTime.now();
      final currentMetrics = await dao.getMetricsForDate(1, today);

      if (currentMetrics != null) {
        if (steps > currentMetrics.steps) {
          await dao.insertOrUpdateMetrics(
            currentMetrics
                .toCompanion(true)
                .copyWith(
                  steps: drift.Value(steps),
                  updatedAt: drift.Value(DateTime.now()),
                ),
          );
        }
      } else {
        await dao.insertOrUpdateMetrics(
          HealthMetricsTableCompanion.insert(
            personID: 1,
            date: today,
            steps: drift.Value(steps),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving steps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'Activity Tracker',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 40), // Balance the back button
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Main Steps Display
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Steps Taken',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentSteps.toString(),
                              style: textTheme.displayLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 64,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: currentSteps / dailyGoal,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                              minHeight: 10,
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Goal: $dailyGoal',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${progressPercentage.toStringAsFixed(0)}%',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    'Daily Statistics',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 15) / 2;
                      return Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        children: [
                          _buildModernStatCard(
                            context,
                            'Remaining',
                            remainingSteps.toString(),
                            'steps',
                            Icons.flag_rounded,
                            cardWidth,
                          ),
                          _buildModernStatCard(
                            context,
                            'Distance',
                            distanceKm.toStringAsFixed(2),
                            'km',
                            Icons.route_rounded,
                            cardWidth,
                          ),
                          _buildModernStatCard(
                            context,
                            'Calories',
                            caloriesBurned.toString(),
                            'kcal',
                            Icons.local_fire_department_rounded,
                            cardWidth,
                          ),
                          _buildModernStatCard(
                            context,
                            'Active Time',
                            '${(currentSteps / 100).round()}',
                            'min',
                            Icons.timer_rounded,
                            cardWidth,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    BuildContext context,
    String label,
    String value,
    String unit,
    IconData icon,
    double width,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(height: 15),
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$label ($unit)',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
