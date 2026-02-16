import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  double sleepHours = 0.0;
  TimeOfDay bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay wakeTime = const TimeOfDay(hour: 6, minute: 30);
  final double recommendedSleep = 8.0;
  bool _isLoading = true;

  double get sleepQuality =>
      (sleepHours / recommendedSleep * 100).clamp(0, 100);
  double get sleepDeficit =>
      (recommendedSleep - sleepHours).clamp(0, recommendedSleep);
  int get sleepCycles => (sleepHours / 1.5).floor();

  String get sleepRating {
    if (sleepHours >= 8) return 'Excellent';
    if (sleepHours >= 7) return 'Good';
    if (sleepHours >= 6) return 'Fair';
    return 'Poor';
  }

  Color get ratingColor {
    if (sleepHours >= 8) return Colors.green;
    if (sleepHours >= 7) return Colors.lightGreen;
    if (sleepHours >= 6) return Colors.orange;
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dao = context.read<HealthMetricsDAO>();
    final today = DateTime.now();
    final data = await dao.getMetricsForDate(1, today);
    if (mounted) {
      setState(() {
        sleepHours = data?.sleepHours ?? 0.0;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSleepHours() async {
    final dao = context.read<HealthMetricsDAO>();
    final today = DateTime.now();

    try {
      final currentMetrics = await dao.getMetricsForDate(1, today);

      if (currentMetrics != null) {
        await dao.insertOrUpdateMetrics(
          currentMetrics
              .toCompanion(true)
              .copyWith(
                sleepHours: drift.Value(sleepHours),
                updatedAt: drift.Value(DateTime.now()),
              ),
        );
      } else {
        await dao.insertOrUpdateMetrics(
          HealthMetricsTableCompanion.insert(
            personID: 1,
            date: today,
            sleepHours: drift.Value(sleepHours),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saved ${sleepHours.toStringAsFixed(1)} hours of sleep',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: ratingColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving sleep data: $e')));
      }
    }
  }

  Future<void> _selectBedTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: bedTime,
    );
    if (picked != null) {
      setState(() {
        bedTime = picked;
        _calculateSleepHours();
      });
    }
  }

  Future<void> _selectWakeTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: wakeTime,
    );
    if (picked != null) {
      setState(() {
        wakeTime = picked;
        _calculateSleepHours();
      });
    }
  }

  void _calculateSleepHours() {
    double bedMinutes = (bedTime.hour * 60 + bedTime.minute).toDouble();
    double wakeMinutes = (wakeTime.hour * 60 + wakeTime.minute).toDouble();

    if (wakeMinutes < bedMinutes) {
      wakeMinutes += 24 * 60;
    }

    double totalMinutes = wakeMinutes - bedMinutes;
    setState(() {
      sleepHours = totalMinutes / 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Night Sky Decoration
                Positioned(
                  top: -50,
                  right: -50,
                  child: Icon(
                    Icons.nightlight_round_rounded,
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                    size: 300,
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
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 20,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Text(
                              'Sleep Analysis',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Main Sleep Display
                        Center(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primaryContainer,
                                  colorScheme.surface,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.bedtime_rounded,
                                  color: colorScheme.primary,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Duration',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      sleepHours.toStringAsFixed(1),
                                      style: textTheme.displayLarge?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 64,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'hrs',
                                      style: textTheme.titleLarge?.copyWith(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ratingColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    sleepRating.toUpperCase(),
                                    style: textTheme.titleSmall?.copyWith(
                                      color: ratingColor,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                LinearProgressIndicator(
                                  value: sleepQuality / 100,
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ratingColor,
                                  ),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${sleepQuality.toStringAsFixed(0)}% of goal reached',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Schedule Section
                        Text(
                          'Schedule',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: _modernTimeCard(
                                context,
                                'Bedtime',
                                bedTime,
                                Icons.nightlight_round,
                                _selectBedTime,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _modernTimeCard(
                                context,
                                'Wake up',
                                wakeTime,
                                Icons.wb_sunny_rounded,
                                _selectWakeTime,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveSleepHours,
                            icon: const Icon(Icons.save_rounded),
                            label: const Text('Save Sleep Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Statistics Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cardWidth = (constraints.maxWidth - 15) / 2;
                            return Wrap(
                              spacing: 15,
                              runSpacing: 15,
                              children: [
                                _statCard(
                                  context,
                                  'Cycles',
                                  sleepCycles.toString(),
                                  '90m/c',
                                  Icons.refresh_rounded,
                                  cardWidth,
                                ),
                                _statCard(
                                  context,
                                  'Deficit',
                                  sleepDeficit.toStringAsFixed(1),
                                  'hrs',
                                  Icons.trending_down_rounded,
                                  cardWidth,
                                ),
                                _statCard(
                                  context,
                                  'Deep',
                                  (sleepHours * 0.25).toStringAsFixed(1),
                                  'hrs',
                                  Icons.dark_mode_rounded,
                                  cardWidth,
                                ),
                                _statCard(
                                  context,
                                  'REM',
                                  (sleepHours * 0.20).toStringAsFixed(1),
                                  'hrs',
                                  Icons.psychology_rounded,
                                  cardWidth,
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Tips
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Sleep Tips',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _buildTip(
                                context,
                                'Maintain a consistent schedule',
                              ),
                              _buildTip(context, 'Avoid caffeine before bed'),
                              _buildTip(context, 'Keep room cool and dark'),
                              _buildTip(context, 'No screens 30m before sleep'),
                            ],
                          ),
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

  Widget _modernTimeCard(
    BuildContext context,
    String label,
    TimeOfDay time,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(label, style: textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    String unit,
    IconData icon,
    double width,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '$label ($unit)',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, String tip) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(tip, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
