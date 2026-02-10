import 'package:flutter/material.dart';

import '../services/insights_calculator.dart';

class PatternSummaryCard extends StatelessWidget {
  const PatternSummaryCard({super.key, required this.summary});

  final PatternSummary summary;

  static String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patterns', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          _MetricRow(
            label: 'Avg duration (7d)',
            value: _formatDuration(summary.avgDuration7d),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Avg duration (30d)',
            value: _formatDuration(summary.avgDuration30d),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Avg quality (30d)',
            value: '${summary.avgQuality30d.toStringAsFixed(1)} / 5',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Bedtime consistency',
            value: summary.consistencyText,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Best day',
            value: summary.bestDay ?? '\u2014',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Worst day',
            value: summary.worstDay ?? '\u2014',
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
