import 'dart:math';

import 'package:intl/intl.dart';

import '../database/app_database.dart';
import '../providers/home_providers.dart';

/// A quality data point for the 30-day line chart.
typedef QualityDataPoint = ({String date, double averageQuality});

/// Plain-English pattern summary computed from sleep entries.
class PatternSummary {
  final int avgDuration7d;
  final int avgDuration30d;
  final double avgQuality30d;
  final String consistencyText;
  final String? bestDay;
  final String? worstDay;

  const PatternSummary({
    required this.avgDuration7d,
    required this.avgDuration30d,
    required this.avgQuality30d,
    required this.consistencyText,
    this.bestDay,
    this.worstDay,
  });
}

/// Pure computation functions for insights aggregation.
///
/// All methods are static and side-effect-free. They take raw [SleepEntry]
/// records (already filtered to the 30-day window) and produce chart-ready
/// data structures.
class InsightsCalculator {
  InsightsCalculator._();

  /// Computes 7-day duration data points for the bar chart.
  ///
  /// Returns exactly 7 [DurationDataPoint]s sorted oldest → newest,
  /// covering [today - 6 days] through [today].
  /// Each point's durationMinutes is the SUM of all entries for that day.
  /// Days with no entries have durationMinutes = 0.
  static List<DurationDataPoint> computeDurationChart(
    List<SleepEntry> entries,
    DateTime today,
  ) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final sixDaysAgo = todayDate.subtract(const Duration(days: 6));

    // Group by wakeDate, sum durationMinutes per day.
    final sumByDate = <String, int>{};
    for (final entry in entries) {
      final entryDate = DateTime.tryParse(entry.wakeDate);
      if (entryDate == null) continue;
      if (entryDate.isBefore(sixDaysAgo) || entryDate.isAfter(todayDate)) {
        continue;
      }
      sumByDate[entry.wakeDate] =
          (sumByDate[entry.wakeDate] ?? 0) + entry.durationMinutes;
    }

    // Build exactly 7 data points.
    final result = <DurationDataPoint>[];
    for (var i = 0; i < 7; i++) {
      final day = sixDaysAgo.add(Duration(days: i));
      final dateStr = _formatDate(day);
      result.add((date: dateStr, durationMinutes: sumByDate[dateStr] ?? 0));
    }
    return result;
  }

  /// Computes 30-day quality data points for the line chart.
  ///
  /// Returns 0–30 [QualityDataPoint]s sorted oldest → newest,
  /// covering [today - 29 days] through [today].
  /// Only days with at least one entry are included.
  /// Each point's averageQuality is the MEAN of all entries' quality
  /// for that day, rounded to 1 decimal place.
  static List<QualityDataPoint> computeQualityChart(
    List<SleepEntry> entries,
    DateTime today,
  ) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final twentyNineDaysAgo = todayDate.subtract(const Duration(days: 29));

    // Group quality values by wakeDate.
    final qualitiesByDate = <String, List<int>>{};
    for (final entry in entries) {
      final entryDate = DateTime.tryParse(entry.wakeDate);
      if (entryDate == null) continue;
      if (entryDate.isBefore(twentyNineDaysAgo) ||
          entryDate.isAfter(todayDate)) {
        continue;
      }
      qualitiesByDate.putIfAbsent(entry.wakeDate, () => []).add(entry.quality);
    }

    // Build sorted list of data points.
    final sortedDates = qualitiesByDate.keys.toList()..sort();
    return sortedDates.map((date) {
      final qualities = qualitiesByDate[date]!;
      final avg = qualities.reduce((a, b) => a + b) / qualities.length;
      final rounded = (avg * 10).round() / 10;
      return (date: date, averageQuality: rounded);
    }).toList();
  }

  /// Computes plain-English pattern summary from entries in the 30-day window.
  ///
  /// Returns a [PatternSummary] with averages, consistency text, and
  /// best/worst day. If [entries] is empty, returns zero averages and null
  /// best/worst day.
  static PatternSummary computePatternSummary(
    List<SleepEntry> entries,
    DateTime today,
  ) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final sixDaysAgo = todayDate.subtract(const Duration(days: 6));
    final twentyNineDaysAgo = todayDate.subtract(const Duration(days: 29));

    // Filter to 30-day window.
    final entries30d = entries.where((e) {
      final d = DateTime.tryParse(e.wakeDate);
      if (d == null) return false;
      return !d.isBefore(twentyNineDaysAgo) && !d.isAfter(todayDate);
    }).toList();

    // Filter to 7-day window.
    final entries7d = entries30d.where((e) {
      final d = DateTime.tryParse(e.wakeDate);
      if (d == null) return false;
      return !d.isBefore(sixDaysAgo) && !d.isAfter(todayDate);
    }).toList();

    // Avg duration 7d (by entry count, not day count).
    final avgDuration7d = entries7d.isEmpty
        ? 0
        : (entries7d.fold<int>(0, (s, e) => s + e.durationMinutes) /
                entries7d.length)
            .round();

    // Avg duration 30d.
    final avgDuration30d = entries30d.isEmpty
        ? 0
        : (entries30d.fold<int>(0, (s, e) => s + e.durationMinutes) /
                entries30d.length)
            .round();

    // Avg quality 30d.
    final avgQuality30d = entries30d.isEmpty
        ? 0.0
        : ((entries30d.fold<int>(0, (s, e) => s + e.quality) /
                    entries30d.length) *
                10)
            .round() /
            10;

    // Bedtime consistency.
    final consistencyText = _computeConsistencyText(entries30d);

    // Best/worst day.
    final (bestDay, worstDay) = _computeBestWorstDay(entries30d);

    return PatternSummary(
      avgDuration7d: avgDuration7d,
      avgDuration30d: avgDuration30d,
      avgQuality30d: avgQuality30d,
      consistencyText: consistencyText,
      bestDay: bestDay,
      worstDay: worstDay,
    );
  }

  static String _computeConsistencyText(List<SleepEntry> entries) {
    if (entries.length < 2) {
      return 'Not enough data for consistency';
    }

    // Convert bedtimeTs to minutes-since-midnight with cross-midnight
    // normalisation: if hour < 12, add 1440 to treat as "past midnight".
    final minutes = entries.map((e) {
      final h = e.bedtimeTs.hour;
      final m = e.bedtimeTs.minute;
      var mins = h * 60 + m;
      if (h < 12) mins += 1440;
      return mins.toDouble();
    }).toList();

    // Compute standard deviation.
    final mean = minutes.reduce((a, b) => a + b) / minutes.length;
    final variance =
        minutes.map((m) => (m - mean) * (m - mean)).reduce((a, b) => a + b) /
            minutes.length;
    final stddev = sqrt(variance);

    if (stddev < 15) {
      return 'Your bedtime is very consistent';
    } else if (stddev < 30) {
      final rounded = (stddev / 5).round() * 5;
      return 'Your bedtime is fairly consistent (about $rounded minutes variation)';
    } else if (stddev < 60) {
      final rounded = (stddev / 5).round() * 5;
      return 'Your bedtime varies by about $rounded minutes';
    } else {
      final hours = (stddev / 60).round();
      return 'Your bedtime varies widely (over $hours hours)';
    }
  }

  static (String?, String?) _computeBestWorstDay(List<SleepEntry> entries) {
    if (entries.isEmpty) return (null, null);

    // Group by weekday of wakeTs.
    final durationsByWeekday = <int, List<int>>{};
    for (final entry in entries) {
      final weekday = entry.wakeTs.weekday;
      durationsByWeekday
          .putIfAbsent(weekday, () => [])
          .add(entry.durationMinutes);
    }

    // Average per weekday.
    String? bestDay;
    String? worstDay;
    double bestAvg = -1;
    double worstAvg = double.infinity;

    for (final entry in durationsByWeekday.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      // Use a reference date where weekday matches. DateTime(2024, 1, 1) is a
      // Monday (weekday 1). Offset by entry.key - 1 to get the correct weekday.
      final refDate = DateTime(2024, 1, entry.key);
      final dayName = DateFormat.EEEE().format(refDate);
      if (avg > bestAvg) {
        bestAvg = avg;
        bestDay = dayName;
      }
      if (avg < worstAvg) {
        worstAvg = avg;
        worstDay = dayName;
      }
    }

    return (bestDay, worstDay);
  }

  static String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}
