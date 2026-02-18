import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ice_shield/ui_layer/health_page/models/HealthMetric.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HealthMetricCard extends StatelessWidget {
  final HealthMetric metrics;

  const HealthMetricCard({super.key, required this.metrics});

  void _navigateToDetailPage(BuildContext context) {
    if (metrics.detailPage != null) {
      context.go(metrics.detailPage!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detail page for ${metrics.name} coming soon!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final compact = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: InkWell(
          onTap: () => _navigateToDetailPage(context),
          child: Stack(
            children: [
              // Subtle background glow
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: metrics.color.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0), // Reduced from 24
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10), // Reduced from 12
                          decoration: BoxDecoration(
                            color: metrics.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // Reduced from 20
                          ),
                          child: Icon(
                            metrics.icon,
                            color: metrics.color,
                            size: compact ? 20 : 24, // Reduced sizes
                          ),
                        ),
                        if (metrics.trend != null)
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (metrics.trendPositive ?? true)
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    (metrics.trendPositive ?? true)
                                        ? Icons.trending_up_rounded
                                        : Icons.trending_down_rounded,
                                    size: 12, // Reduced from 14
                                    color: (metrics.trendPositive ?? true)
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      metrics.trend!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: (metrics.trendPositive ?? true)
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 9, // Reduced from 10
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12), // Reduced from 20
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metrics.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              fontSize: 9, // Reduced from 10
                            ),
                          ),
                          const SizedBox(height: 2), // Reduced from 4
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  metrics.value,
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w900,
                                    fontSize: compact
                                        ? 22
                                        : 26, // Reduced from 24:28
                                  ),
                                  maxLines: 1,
                                  minFontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 2), // Reduced from 4
                              Text(
                                metrics.unit,
                                style: textTheme.labelSmall?.copyWith(
                                  // Changed from labelMedium
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (metrics.progress != null) ...[
                      const SizedBox(height: 8), // Reduced from 16
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: metrics.progress!.clamp(0.0, 1.0),
                          minHeight: 6, // Reduced from 8
                          backgroundColor: metrics.color.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            metrics.color,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
