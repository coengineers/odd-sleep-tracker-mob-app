import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'database_providers.dart';

/// Today's most recent sleep entry (by wakeTs), or null if none.
final todaySummaryProvider = FutureProvider<SleepEntry?>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final now = DateTime.now();
  final today =
      '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final entries = await db.listEntries(fromDate: today, toDate: today, limit: 1);
  return entries.isEmpty ? null : entries.first;
});

/// Type alias for a chart data point.
typedef DurationDataPoint = ({String date, int durationMinutes});

/// Last 7 days of sleep duration data for the mini chart.
/// Always returns exactly 7 points sorted oldest → newest.
/// Missing days are filled with durationMinutes: 0.
final recentDurationsProvider =
    FutureProvider<List<DurationDataPoint>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final sixDaysAgo = today.subtract(const Duration(days: 6));
  final fromDate =
      '${sixDaysAgo.year.toString().padLeft(4, '0')}-${sixDaysAgo.month.toString().padLeft(2, '0')}-${sixDaysAgo.day.toString().padLeft(2, '0')}';
  final toDate =
      '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final entries = await db.listEntries(fromDate: fromDate, toDate: toDate);

  // Group by wakeDate, keeping only the entry with the latest wakeTs per day.
  // entries are already ordered by wakeTs descending, so first occurrence per
  // date is the latest.
  final bestByDate = <String, int>{};
  for (final entry in entries) {
    bestByDate.putIfAbsent(entry.wakeDate, () => entry.durationMinutes);
  }

  // Build exactly 7 data points from sixDaysAgo..today.
  final result = <DurationDataPoint>[];
  for (var i = 0; i < 7; i++) {
    final day = sixDaysAgo.add(Duration(days: i));
    final dateStr =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    result.add((date: dateStr, durationMinutes: bestByDate[dateStr] ?? 0));
  }

  return result;
});

/// All sleep entries ordered by wakeTs descending (for History screen).
final allEntriesProvider = FutureProvider<List<SleepEntry>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.listEntries();
});
