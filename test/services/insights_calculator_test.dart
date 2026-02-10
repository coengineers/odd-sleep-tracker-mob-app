import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';
import 'package:sleeplog/services/insights_calculator.dart';

/// Helper to create a SleepEntry via a real in-memory database so that the
/// drift-generated data class is correctly populated.
Future<SleepEntry> _createEntry(
  AppDatabase db, {
  required DateTime bedtime,
  required DateTime wake,
  int quality = 3,
}) {
  return db.createEntry(CreateSleepEntryInput(
    bedtimeTs: bedtime,
    wakeTs: wake,
    quality: quality,
  ));
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  // Reference date: 2025-03-15 (Saturday)
  final today = DateTime(2025, 3, 15);

  group('computeDurationChart', () {
    test('returns 7 zeros for empty input', () {
      final result = InsightsCalculator.computeDurationChart([], today);
      expect(result.length, 7);
      expect(result.every((p) => p.durationMinutes == 0), isTrue);
    });

    test('returns exactly 7 items sorted oldest to newest', () async {
      // Seed entries for 3 of the 7 days.
      final entries = <SleepEntry>[];
      for (var i = 0; i < 3; i++) {
        final wake = DateTime(2025, 3, 15 - i, 7, 0);
        final bedtime = wake.subtract(const Duration(hours: 7));
        entries.add(await _createEntry(db, bedtime: bedtime, wake: wake));
      }

      final result = InsightsCalculator.computeDurationChart(entries, today);
      expect(result.length, 7);
      // Should be sorted oldest first.
      expect(result.first.date, '2025-03-09');
      expect(result.last.date, '2025-03-15');
    });

    test('keeps longest entry for multi-entry days', () async {
      // Two entries on the same day.
      final wake1 = DateTime(2025, 3, 15, 7, 0);
      final bedtime1 = wake1.subtract(const Duration(hours: 7));
      final wake2 = DateTime(2025, 3, 15, 14, 0);
      final bedtime2 = wake2.subtract(const Duration(hours: 1, minutes: 30));

      final entry1 =
          await _createEntry(db, bedtime: bedtime1, wake: wake1);
      final entry2 =
          await _createEntry(db, bedtime: bedtime2, wake: wake2);

      final result = InsightsCalculator.computeDurationChart(
        [entry1, entry2],
        today,
      );

      // Last item should be today with the longest entry = 7*60 = 420 minutes.
      expect(result.last.durationMinutes, 420);
    });

    test('fills missing days with zero', () async {
      // Only one entry, 3 days ago.
      final wake = DateTime(2025, 3, 12, 8, 0);
      final bedtime = wake.subtract(const Duration(hours: 8));
      final entry = await _createEntry(db, bedtime: bedtime, wake: wake);

      final result =
          InsightsCalculator.computeDurationChart([entry], today);

      // Day at index 3 (Mar 12) should have data, rest should be 0.
      expect(result[3].date, '2025-03-12');
      expect(result[3].durationMinutes, 480);
      expect(result[0].durationMinutes, 0);
      expect(result[6].durationMinutes, 0);
    });

    test('excludes entries outside 7-day window', () async {
      // Entry 10 days ago — outside window.
      final wake = DateTime(2025, 3, 5, 7, 0);
      final bedtime = wake.subtract(const Duration(hours: 8));
      final entry = await _createEntry(db, bedtime: bedtime, wake: wake);

      final result =
          InsightsCalculator.computeDurationChart([entry], today);

      expect(result.every((p) => p.durationMinutes == 0), isTrue);
    });

    test('7 days all present', () async {
      final entries = <SleepEntry>[];
      for (var i = 0; i < 7; i++) {
        final wake = DateTime(2025, 3, 9 + i, 7, 0);
        final bedtime = wake.subtract(Duration(hours: 6 + i));
        entries.add(await _createEntry(db, bedtime: bedtime, wake: wake));
      }

      final result = InsightsCalculator.computeDurationChart(entries, today);
      expect(result.length, 7);
      expect(result.every((p) => p.durationMinutes > 0), isTrue);
      // First day: 6h = 360min, last day: 12h = 720min.
      expect(result[0].durationMinutes, 360);
      expect(result[6].durationMinutes, 720);
    });
  });

  group('computeQualityChart', () {
    test('returns empty list for empty input', () {
      final result = InsightsCalculator.computeQualityChart([], today);
      expect(result, isEmpty);
    });

    test('single entry per day', () async {
      final entries = <SleepEntry>[];
      for (var i = 0; i < 5; i++) {
        final wake = DateTime(2025, 3, 11 + i, 7, 0);
        final bedtime = wake.subtract(const Duration(hours: 7));
        entries.add(
          await _createEntry(db, bedtime: bedtime, wake: wake, quality: i + 1),
        );
      }

      final result = InsightsCalculator.computeQualityChart(entries, today);
      expect(result.length, 5);
      expect(result[0].averageQuality, 1.0);
      expect(result[4].averageQuality, 5.0);
    });

    test('multi-entry days averaged to 1 decimal', () async {
      // Two entries on same day with quality 3 and 4 → avg 3.5.
      final wake1 = DateTime(2025, 3, 15, 7, 0);
      final bedtime1 = wake1.subtract(const Duration(hours: 7));
      final wake2 = DateTime(2025, 3, 15, 14, 0);
      final bedtime2 = wake2.subtract(const Duration(hours: 1, minutes: 30));

      final e1 = await _createEntry(db, bedtime: bedtime1, wake: wake1, quality: 3);
      final e2 = await _createEntry(db, bedtime: bedtime2, wake: wake2, quality: 4);

      final result =
          InsightsCalculator.computeQualityChart([e1, e2], today);
      expect(result.length, 1);
      expect(result[0].averageQuality, 3.5);
    });

    test('only days with data included (no zero-fill)', () async {
      // Entry only on day 15 — should only return 1 data point.
      final wake = DateTime(2025, 3, 15, 7, 0);
      final bedtime = wake.subtract(const Duration(hours: 7));
      final entry = await _createEntry(db, bedtime: bedtime, wake: wake, quality: 4);

      final result = InsightsCalculator.computeQualityChart([entry], today);
      expect(result.length, 1);
      expect(result[0].date, '2025-03-15');
    });

    test('sorted oldest to newest', () async {
      final entries = <SleepEntry>[];
      // Add entries in reverse order.
      for (var i = 4; i >= 0; i--) {
        final wake = DateTime(2025, 3, 11 + i, 7, 0);
        final bedtime = wake.subtract(const Duration(hours: 7));
        entries.add(
          await _createEntry(db, bedtime: bedtime, wake: wake, quality: 3),
        );
      }

      final result = InsightsCalculator.computeQualityChart(entries, today);
      for (var i = 0; i < result.length - 1; i++) {
        expect(result[i].date.compareTo(result[i + 1].date), lessThan(0));
      }
    });

    test('excludes entries outside 30-day window', () async {
      final wake = DateTime(2025, 2, 1, 7, 0);
      final bedtime = wake.subtract(const Duration(hours: 8));
      final entry = await _createEntry(db, bedtime: bedtime, wake: wake);

      final result = InsightsCalculator.computeQualityChart([entry], today);
      expect(result, isEmpty);
    });
  });

  group('computePatternSummary', () {
    test('empty input returns zeros and nulls', () {
      final result = InsightsCalculator.computePatternSummary([], today);
      expect(result.avgDuration7d, 0);
      expect(result.avgDuration30d, 0);
      expect(result.avgQuality30d, 0.0);
      expect(result.consistencyText, 'Not enough data for consistency');
      expect(result.bestDay, isNull);
      expect(result.worstDay, isNull);
    });

    test('avg duration 7d and 30d computed correctly', () async {
      final entries = <SleepEntry>[];
      // 7 entries in last 7 days: 420 min each.
      for (var i = 0; i < 7; i++) {
        final wake = DateTime(2025, 3, 9 + i, 7, 0);
        final bedtime = wake.subtract(const Duration(hours: 7));
        entries.add(await _createEntry(db, bedtime: bedtime, wake: wake));
      }
      // 3 entries earlier in the 30-day window: 480 min each.
      for (var i = 0; i < 3; i++) {
        final wake = DateTime(2025, 2, 20 + i, 8, 0);
        final bedtime = wake.subtract(const Duration(hours: 8));
        entries.add(await _createEntry(db, bedtime: bedtime, wake: wake));
      }

      final result = InsightsCalculator.computePatternSummary(entries, today);
      // 7d avg: 7 entries * 420 = 2940 / 7 = 420.
      expect(result.avgDuration7d, 420);
      // 30d avg: (7*420 + 3*480) = (2940+1440) = 4380 / 10 = 438.
      expect(result.avgDuration30d, 438);
    });

    test('avg quality 30d rounded to 1 decimal', () async {
      final entries = <SleepEntry>[];
      // 3 entries with quality 3, 4, 5 → avg = 4.0.
      for (var i = 0; i < 3; i++) {
        final wake = DateTime(2025, 3, 13 + i, 7, 0);
        final bedtime = wake.subtract(const Duration(hours: 7));
        entries.add(
          await _createEntry(
            db,
            bedtime: bedtime,
            wake: wake,
            quality: 3 + i,
          ),
        );
      }

      final result = InsightsCalculator.computePatternSummary(entries, today);
      expect(result.avgQuality30d, 4.0);
    });

    test('bedtime consistency - very consistent (<15 stddev)', () async {
      final entries = <SleepEntry>[];
      // All bedtimes at exactly 23:00 — stddev = 0.
      for (var i = 0; i < 5; i++) {
        final bedtime = DateTime(2025, 3, 10 + i, 23, 0);
        final wake = bedtime.add(const Duration(hours: 7));
        entries.add(await _createEntry(db, bedtime: bedtime, wake: wake));
      }

      final result = InsightsCalculator.computePatternSummary(entries, today);
      expect(result.consistencyText, 'Your bedtime is very consistent');
    });

    test('bedtime consistency - fairly consistent (15-30 stddev)', () async {
      final entries = <SleepEntry>[];
      // Bedtimes at 22:45, 23:00, 23:15, 22:30, 23:30 — should give ~20 min stddev.
      final times = [
        DateTime(2025, 3, 11, 22, 45),
        DateTime(2025, 3, 12, 23, 0),
        DateTime(2025, 3, 13, 23, 15),
        DateTime(2025, 3, 14, 22, 30),
        DateTime(2025, 3, 15, 23, 30),
      ];
      for (final bedtime in times) {
        final wake = bedtime.add(const Duration(hours: 7));
        entries.add(await _createEntry(db, bedtime: bedtime, wake: wake));
      }

      final result = InsightsCalculator.computePatternSummary(entries, today);
      expect(result.consistencyText, contains('fairly consistent'));
    });

    test('bedtime consistency - varies by about (30-60 stddev)', () async {
      final entries = <SleepEntry>[];
      // Spread bedtimes about 45 min apart to get ~35 stddev.
      final times = [
        DateTime(2025, 3, 11, 22, 0),
        DateTime(2025, 3, 12, 23, 30),
        DateTime(2025, 3, 13, 22, 15),
        DateTime(2025, 3, 14, 23, 45),
        DateTime(2025, 3, 15, 22, 30),
      ];
      for (final bedtime in times) {
        final wake = bedtime.add(const Duration(hours: 7));
        entries.add(await _createEntry(db, bedtime: bedtime, wake: wake));
      }

      final result = InsightsCalculator.computePatternSummary(entries, today);
      expect(result.consistencyText, contains('varies by about'));
    });

    test('bedtime consistency - varies widely (60+ stddev)', () async {
      final entries = <SleepEntry>[];
      // Very spread bedtimes.
      final times = [
        DateTime(2025, 3, 11, 21, 0),
        DateTime(2025, 3, 12, 0, 30), // After midnight.
        DateTime(2025, 3, 13, 22, 0),
        DateTime(2025, 3, 14, 2, 0), // After midnight.
        DateTime(2025, 3, 15, 20, 30),
      ];
      for (final bedtime in times) {
        final wake = bedtime.add(const Duration(hours: 7));
        entries.add(await _createEntry(db, bedtime: bedtime, wake: wake));
      }

      final result = InsightsCalculator.computePatternSummary(entries, today);
      expect(result.consistencyText, contains('varies widely'));
    });

    test('<2 entries shows "Not enough data for consistency"', () async {
      final wake = DateTime(2025, 3, 15, 7, 0);
      final bedtime = wake.subtract(const Duration(hours: 7));
      final entry = await _createEntry(db, bedtime: bedtime, wake: wake);

      final result =
          InsightsCalculator.computePatternSummary([entry], today);
      expect(result.consistencyText, 'Not enough data for consistency');
    });

    test('best/worst day by weekday average', () async {
      final entries = <SleepEntry>[];
      // Saturday (weekday 6): 10h = 600 min — best.
      final satWake = DateTime(2025, 3, 15, 8, 0); // Saturday.
      final satBedtime = satWake.subtract(const Duration(hours: 10));
      entries.add(await _createEntry(db, bedtime: satBedtime, wake: satWake));

      // Wednesday (weekday 3): 5h = 300 min — worst.
      final wedWake = DateTime(2025, 3, 12, 7, 0); // Wednesday.
      final wedBedtime = wedWake.subtract(const Duration(hours: 5));
      entries.add(await _createEntry(db, bedtime: wedBedtime, wake: wedWake));

      final result = InsightsCalculator.computePatternSummary(entries, today);
      expect(result.bestDay, 'Saturday');
      expect(result.worstDay, 'Wednesday');
    });

    test('single entry edge case — best and worst are same day', () async {
      final wake = DateTime(2025, 3, 15, 7, 0);
      final bedtime = wake.subtract(const Duration(hours: 7));
      final entry = await _createEntry(db, bedtime: bedtime, wake: wake);

      final result =
          InsightsCalculator.computePatternSummary([entry], today);
      expect(result.bestDay, result.worstDay);
      expect(result.bestDay, isNotNull);
    });
  });
}
