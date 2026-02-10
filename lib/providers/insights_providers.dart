import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../services/insights_calculator.dart';
import 'database_providers.dart';
import 'home_providers.dart';

export 'package:sleeplog/services/insights_calculator.dart'
    show QualityDataPoint, PatternSummary;

/// Fetches all sleep entries within the last 30 days.
/// This is the single data source for all insights computations.
final insightsDataProvider = FutureProvider<List<SleepEntry>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thirtyDaysAgo = today.subtract(const Duration(days: 29));

  final fromDate =
      '${thirtyDaysAgo.year.toString().padLeft(4, '0')}-${thirtyDaysAgo.month.toString().padLeft(2, '0')}-${thirtyDaysAgo.day.toString().padLeft(2, '0')}';
  final toDate =
      '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  return db.listEntries(fromDate: fromDate, toDate: toDate);
});

/// Derived: 7-day duration chart data from insightsDataProvider.
final durationChartProvider =
    FutureProvider<List<DurationDataPoint>>((ref) async {
  final entries = await ref.watch(insightsDataProvider.future);
  return InsightsCalculator.computeDurationChart(entries, DateTime.now());
});

/// Derived: 30-day quality trend data from insightsDataProvider.
final qualityChartProvider =
    FutureProvider<List<QualityDataPoint>>((ref) async {
  final entries = await ref.watch(insightsDataProvider.future);
  return InsightsCalculator.computeQualityChart(entries, DateTime.now());
});

/// Derived: Pattern summary from insightsDataProvider.
final patternSummaryProvider = FutureProvider<PatternSummary>((ref) async {
  final entries = await ref.watch(insightsDataProvider.future);
  return InsightsCalculator.computePatternSummary(entries, DateTime.now());
});
