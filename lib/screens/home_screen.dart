import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/home_providers.dart';
import '../widgets/mini_duration_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Format duration minutes as "Xh Ym".
  static String formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todaySummaryProvider);
    final durationsAsync = ref.watch(recentDurationsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('SleepLog')),
      body: todayAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (todayEntry) {
          return durationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (durations) {
              final hasAnyData =
                  durations.any((d) => d.durationMinutes > 0);

              // Full empty state: no today entry AND no historical data at all
              if (todayEntry == null && !hasAnyData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No sleep logged yet.',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Add last night's sleep to start tracking.",
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            await context.push('/log');
                            ref.invalidate(todaySummaryProvider);
                            ref.invalidate(recentDurationsProvider);
                          },
                          child: const Text('Log sleep'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Normal state (with or without today entry)
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's summary card
                    if (todayEntry != null)
                      _TodaySummaryCard(
                        duration: formatDuration(todayEntry.durationMinutes),
                        quality: todayEntry.quality,
                        colorScheme: colorScheme,
                        theme: theme,
                      )
                    else
                      _NoTodayEntryCard(
                        colorScheme: colorScheme,
                        theme: theme,
                        onLogSleep: () async {
                          await context.push('/log');
                          ref.invalidate(todaySummaryProvider);
                          ref.invalidate(recentDurationsProvider);
                        },
                      ),
                    const SizedBox(height: 24),
                    // Mini chart
                    Text('Last 7 days', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 12),
                    MiniDurationChart(data: durations),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({
    required this.duration,
    required this.quality,
    required this.colorScheme,
    required this.theme,
  });

  final String duration;
  final int quality;
  final ColorScheme colorScheme;
  final ThemeData theme;

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
          Text("Today's sleep", style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Text(
            duration,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Quality: $quality / 5',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _NoTodayEntryCard extends StatelessWidget {
  const _NoTodayEntryCard({
    required this.colorScheme,
    required this.theme,
    required this.onLogSleep,
  });

  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onLogSleep;

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
        children: [
          Text(
            'No sleep logged for today',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onLogSleep,
            child: const Text('Log sleep'),
          ),
        ],
      ),
    );
  }
}
