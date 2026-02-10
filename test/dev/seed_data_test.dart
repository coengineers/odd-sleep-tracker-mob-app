import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/dev/seed_data.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('seedSampleEntries(db, days: 7) creates exactly 7 entries', () async {
    final entries = await seedSampleEntries(db, days: 7);
    expect(entries.length, 7);

    final stored = await db.listEntries();
    expect(stored.length, 7);
  });

  test('all entries have valid durations (300-600 minutes)', () async {
    final entries = await seedSampleEntries(db, days: 7);

    for (final entry in entries) {
      expect(
        entry.durationMinutes,
        inInclusiveRange(300, 600),
        reason: 'Duration ${entry.durationMinutes} out of range for '
            'entry ${entry.id}',
      );
    }
  });

  test('all entries have valid quality (1-5)', () async {
    final entries = await seedSampleEntries(db, days: 7);

    for (final entry in entries) {
      expect(
        entry.quality,
        inInclusiveRange(1, 5),
        reason: 'Quality ${entry.quality} out of range for entry ${entry.id}',
      );
    }
  });

  test('entries span 7 different wake dates', () async {
    final entries = await seedSampleEntries(db, days: 7);
    final wakeDates = entries.map((e) => e.wakeDate).toSet();
    expect(wakeDates.length, 7);
  });

  test('default call seedSampleEntries(db) creates 90 entries', () async {
    final entries = await seedSampleEntries(db);
    expect(entries.length, 90);

    final stored = await db.listEntries();
    expect(stored.length, 90);
  });

  test('entries are additive — calling twice with days: 3 creates 6 total',
      () async {
    await seedSampleEntries(db, days: 3);
    await seedSampleEntries(db, days: 3);

    final stored = await db.listEntries();
    expect(stored.length, 6);
  });
}
