import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  int _currentWater = 0; // in ml
  final int _goalWater = 2000; // in ml
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dao = context.read<HealthMetricsDAO>();
    final today = DateTime.now();
    // Assuming personID 1 for now
    final data = await dao.getMetricsForDate(1, today);
    if (mounted) {
      setState(() {
        _currentWater =
            data?.waterGlasses ?? 0; // Storing ml in waterGlasses column
        _isLoading = false;
      });
    }
  }

  Future<void> _addWater(int amount) async {
    final dao = context.read<HealthMetricsDAO>();
    final today = DateTime.now();

    // Optimistic update
    setState(() {
      _currentWater += amount;
    });

    try {
      final currentMetrics = await dao.getMetricsForDate(1, today);

      if (currentMetrics != null) {
        // Update existing
        await dao.insertOrUpdateMetrics(
          currentMetrics
              .toCompanion(true)
              .copyWith(
                waterGlasses: drift.Value(_currentWater),
                updatedAt: drift.Value(DateTime.now()),
              ),
        );
      } else {
        // Insert new
        await dao.insertOrUpdateMetrics(
          HealthMetricsTableCompanion.insert(
            personID: 1,
            date: today,
            waterGlasses: drift.Value(_currentWater),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _currentWater -= amount;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving water: $e')));
      }
    }
  }

  Future<void> _resetWater() async {
    final dao = context.read<HealthMetricsDAO>();
    final today = DateTime.now();

    setState(() {
      _currentWater = 0;
    });

    try {
      final currentMetrics = await dao.getMetricsForDate(1, today);
      if (currentMetrics != null) {
        await dao.insertOrUpdateMetrics(
          currentMetrics
              .toCompanion(true)
              .copyWith(
                waterGlasses: const drift.Value(0),
                updatedAt: drift.Value(DateTime.now()),
              ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    double progress = (_currentWater / _goalWater).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tracker'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 16,
                            backgroundColor: colorScheme.primary.withOpacity(
                              0.1,
                            ),
                            color: Colors.blue,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.water_drop,
                              size: 48,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_currentWater',
                              style: textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'ml / $_goalWater ml',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    Text("Quick Add", style: textTheme.titleMedium),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWaterAddButton(100, '100ml', colorScheme),
                        _buildWaterAddButton(250, '250ml', colorScheme),
                        _buildWaterAddButton(500, '500ml', colorScheme),
                      ],
                    ),

                    const SizedBox(height: 48),

                    OutlinedButton.icon(
                      onPressed: _resetWater,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Today'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWaterAddButton(
    int amount,
    String label,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: () => _addWater(amount),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue.withOpacity(0.1),
            foregroundColor: Colors.blue,
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
