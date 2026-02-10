import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';
import 'package:sleeplog/providers/database_providers.dart';
import 'package:sleeplog/providers/insights_providers.dart';

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
    return db.close();
  });

  Future<void> seedEntries(int count, {int daysBack = 0}) async {
    for (var i = 0; i < count; i++) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final wake = today.subtract(Duration(days: daysBack + i));
      final wakeTs = DateTime(wake.year, wake.month, wake.day, 7, 0);
      final bedtimeTs = wakeTs.subtract(const Duration(hours: 7));
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: bedtimeTs,
        wakeTs: wakeTs,
        quality: (i % 5) + 1,
      ));
    }
  }

  test('insightsDataProvider returns 30-day entries', () async {
    // Seed 5 entries within the last 30 days.
    await seedEntries(5);
    // Seed 2 entries outside the window (35 days ago).
    await seedEntries(2, daysBack: 35);

    final entries = await container.read(insightsDataProvider.future);
    expect(entries.length, 5);
  });

  test('durationChartProvider returns 7 items', () async {
    await seedEntries(3);

    final data = await container.read(durationChartProvider.future);
    expect(data.length, 7);
  });

  test('qualityChartProvider returns only days with data', () async {
    await seedEntries(5);

    final data = await container.read(qualityChartProvider.future);
    expect(data.length, 5);
    for (final point in data) {
      expect(point.averageQuality, greaterThanOrEqualTo(1.0));
      expect(point.averageQuality, lessThanOrEqualTo(5.0));
    }
  });

  test('patternSummaryProvider returns valid PatternSummary', () async {
    await seedEntries(10);

    final summary = await container.read(patternSummaryProvider.future);
    expect(summary.avgDuration7d, greaterThan(0));
    expect(summary.avgDuration30d, greaterThan(0));
    expect(summary.avgQuality30d, greaterThan(0));
    expect(summary.consistencyText, isNotEmpty);
    expect(summary.bestDay, isNotNull);
    expect(summary.worstDay, isNotNull);
  });

  test('all providers return defaults when no entries', () async {
    final entries = await container.read(insightsDataProvider.future);
    expect(entries, isEmpty);

    final duration = await container.read(durationChartProvider.future);
    expect(duration.length, 7);
    expect(duration.every((d) => d.durationMinutes == 0), isTrue);

    final quality = await container.read(qualityChartProvider.future);
    expect(quality, isEmpty);

    final summary = await container.read(patternSummaryProvider.future);
    expect(summary.avgDuration7d, 0);
    expect(summary.bestDay, isNull);
  });
}
