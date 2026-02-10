import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';
import 'package:sleeplog/providers/database_providers.dart';
import 'package:sleeplog/providers/home_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  /// Helper to format a DateTime as YYYY-MM-DD.
  String fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  group('todaySummaryProvider', () {
    test('returns null when no entries exist', () async {
      final summary = await container.read(todaySummaryProvider.future);
      expect(summary, isNull);
    });

    test('returns entry for today', () async {
      final now = DateTime.now();
      final todayWake = DateTime(now.year, now.month, now.day, 7, 0);
      final todayBed = todayWake.subtract(const Duration(hours: 8));

      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: todayBed,
        wakeTs: todayWake,
        quality: 4,
      ));

      final summary = await container.read(todaySummaryProvider.future);
      expect(summary, isNotNull);
      expect(summary!.quality, 4);
      expect(summary.wakeDate, fmtDate(now));
    });

    test('returns latest entry when multiple exist for today', () async {
      final now = DateTime.now();
      final earlyWake = DateTime(now.year, now.month, now.day, 6, 0);
      final lateWake = DateTime(now.year, now.month, now.day, 9, 0);

      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: earlyWake.subtract(const Duration(hours: 7)),
        wakeTs: earlyWake,
        quality: 2,
      ));
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: lateWake.subtract(const Duration(hours: 8)),
        wakeTs: lateWake,
        quality: 5,
      ));

      final summary = await container.read(todaySummaryProvider.future);
      expect(summary, isNotNull);
      // listEntries orders by wakeTs desc, limit 1 returns latest
      expect(summary!.quality, 5);
    });

    test('returns null when entries only exist for past dates', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final wake = DateTime(yesterday.year, yesterday.month, yesterday.day, 7);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: wake.subtract(const Duration(hours: 8)),
        wakeTs: wake,
        quality: 3,
      ));

      final summary = await container.read(todaySummaryProvider.future);
      expect(summary, isNull);
    });
  });

  group('recentDurationsProvider', () {
    test('returns 7 zero-duration points when DB is empty', () async {
      final data = await container.read(recentDurationsProvider.future);
      expect(data.length, 7);
      for (final point in data) {
        expect(point.durationMinutes, 0);
      }
    });

    test('returns 7 points sorted oldest to newest', () async {
      final data = await container.read(recentDurationsProvider.future);
      expect(data.length, 7);

      // Verify dates are in ascending order.
      for (var i = 1; i < data.length; i++) {
        expect(data[i].date.compareTo(data[i - 1].date), greaterThan(0));
      }
    });

    test('fills missing days with 0', () async {
      // Seed entry for 3 days ago only.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final threeDaysAgo = today.subtract(const Duration(days: 3));
      final wake =
          DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day, 7);

      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: wake.subtract(const Duration(hours: 8)),
        wakeTs: wake,
        quality: 4,
      ));

      final data = await container.read(recentDurationsProvider.future);
      expect(data.length, 7);

      final targetDate = fmtDate(threeDaysAgo);
      final nonZero = data.where((p) => p.durationMinutes > 0).toList();
      expect(nonZero.length, 1);
      expect(nonZero.first.date, targetDate);
      expect(nonZero.first.durationMinutes, 480); // 8h = 480min
    });

    test('uses latest wakeTs entry when multiple exist per day', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      // Short sleep (6h)
      final earlyWake =
          DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 6, 0);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: earlyWake.subtract(const Duration(hours: 6)),
        wakeTs: earlyWake,
        quality: 2,
      ));

      // Long sleep (9h) — later wakeTs
      final lateWake =
          DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day, 10, 0);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: lateWake.subtract(const Duration(hours: 9)),
        wakeTs: lateWake,
        quality: 4,
      ));

      final data = await container.read(recentDurationsProvider.future);
      final targetDate = fmtDate(twoDaysAgo);
      final point = data.firstWhere((p) => p.date == targetDate);
      // Should use the latest wakeTs entry (540min = 9h)
      expect(point.durationMinutes, 540);
    });

    test('full 7 days of data returns all durations', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var i = 0; i < 7; i++) {
        final day = today.subtract(Duration(days: 6 - i));
        final wake = DateTime(day.year, day.month, day.day, 7, 0);
        await db.createEntry(CreateSleepEntryInput(
          bedtimeTs: wake.subtract(const Duration(hours: 7)),
          wakeTs: wake,
          quality: 3,
        ));
      }

      final data = await container.read(recentDurationsProvider.future);
      expect(data.length, 7);
      for (final point in data) {
        expect(point.durationMinutes, 420); // 7h = 420min
      }
    });
  });

  group('allEntriesProvider', () {
    test('returns empty list when no entries exist', () async {
      final entries = await container.read(allEntriesProvider.future);
      expect(entries, isEmpty);
    });

    test('returns entries in newest-first order', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Create 3 entries on different days.
      for (var i = 0; i < 3; i++) {
        final day = today.subtract(Duration(days: i));
        final wake = DateTime(day.year, day.month, day.day, 7, 0);
        await db.createEntry(CreateSleepEntryInput(
          bedtimeTs: wake.subtract(const Duration(hours: 8)),
          wakeTs: wake,
          quality: 3,
        ));
      }

      final entries = await container.read(allEntriesProvider.future);
      expect(entries.length, 3);
      // Newest first (today, yesterday, 2 days ago)
      expect(entries[0].wakeDate, fmtDate(today));
      expect(
        entries[2].wakeDate,
        fmtDate(today.subtract(const Duration(days: 2))),
      );
    });
  });
}
