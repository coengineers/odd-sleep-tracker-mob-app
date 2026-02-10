import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/home_providers.dart';
import '../providers/insights_providers.dart';
import '../widgets/duration_bar_chart.dart';
import '../widgets/pattern_summary_card.dart';
import '../widgets/quality_line_chart.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final insightsAsync = ref.watch(insightsDataProvider);
    final allEntriesAsync = ref.watch(allEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: insightsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (insightsEntries) {
          return allEntriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (allEntries) {
              // Empty state: zero total entries.
              if (allEntries.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Not enough data for insights yet.',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Log a few nights of sleep to start seeing patterns.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.push('/log'),
                          child: const Text('Log sleep'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Normal state — show charts and summaries.
              return _InsightsContent(
                theme: theme,
                colorScheme: colorScheme,
                ref: ref,
              );
            },
          );
        },
      ),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  const _InsightsContent({
    required this.theme,
    required this.colorScheme,
    required this.ref,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final durationAsync = ref.watch(durationChartProvider);
    final qualityAsync = ref.watch(qualityChartProvider);
    final summaryAsync = ref.watch(patternSummaryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duration bar chart card.
          _ChartCard(
            title: 'Last 7 days',
            theme: theme,
            colorScheme: colorScheme,
            child: durationAsync.when(
              loading: () =>
                  const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
              data: (data) => DurationBarChart(data: data),
            ),
          ),
          const SizedBox(height: 16),
          // Quality line chart card.
          _ChartCard(
            title: 'Quality trend (30 days)',
            theme: theme,
            colorScheme: colorScheme,
            child: qualityAsync.when(
              loading: () =>
                  const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
              data: (data) => QualityLineChart(data: data),
            ),
          ),
          const SizedBox(height: 16),
          // Pattern summary card.
          summaryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (summary) => PatternSummaryCard(summary: summary),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.theme,
    required this.colorScheme,
    required this.child,
  });

  final String title;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
