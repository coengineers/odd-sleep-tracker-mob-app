import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );
  });

  tearDown(() => db.close());

  // ========== US1: Create a Sleep Entry ==========

  group('createEntry', () {
    test('returns complete SleepEntry with UUID id and correct computed fields',
        () async {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      );

      final entry = await db.createEntry(input);

      // UUID format check (8-4-4-4-12)
      expect(entry.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
      expect(entry.durationMinutes, 480);
      expect(entry.wakeDate, '2026-02-08');
      expect(entry.bedtimeTs, DateTime(2026, 2, 7, 23, 0));
      expect(entry.wakeTs, DateTime(2026, 2, 8, 7, 0));
      expect(entry.quality, 4);
      expect(entry.note, isNull);
      expect(entry.createdAt, isNotNull);
      expect(entry.updatedAt, isNotNull);
    });

    test('cross-midnight entry (23:30->07:30) returns duration=480 and correct wake_date',
        () async {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 30),
        wakeTs: DateTime(2026, 2, 8, 7, 30),
        quality: 3,
      );

      final entry = await db.createEntry(input);

      expect(entry.durationMinutes, 480);
      expect(entry.wakeDate, '2026-02-08');
    });

    test('with optional note stores and returns note', () async {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
        note: 'Fell asleep quickly',
      );

      final entry = await db.createEntry(input);

      expect(entry.note, 'Fell asleep quickly');
    });

    test('with null note succeeds', () async {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      );

      final entry = await db.createEntry(input);

      expect(entry.note, isNull);
    });

    test('with invalid time range throws InvalidTimeRangeException', () async {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 8, 7, 0),
        wakeTs: DateTime(2026, 2, 8, 6, 0), // wake before bed
        quality: 3,
      );

      expect(
        () => db.createEntry(input),
        throwsA(isA<InvalidTimeRangeException>()),
      );
    });

    test('with invalid quality throws InvalidQualityException', () async {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 0,
      );

      expect(
        () => db.createEntry(input),
        throwsA(isA<InvalidQualityException>()),
      );
    });

    test('with note > 280 chars throws NoteTooLongException', () async {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
        note: 'a' * 281,
      );

      expect(
        () => db.createEntry(input),
        throwsA(isA<NoteTooLongException>()),
      );
    });
  });

  group('getEntryById', () {
    test('returns entry when it exists', () async {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      );
      final created = await db.createEntry(input);

      final found = await db.getEntryById(created.id);

      expect(found, isNotNull);
      expect(found!.id, created.id);
      expect(found.durationMinutes, created.durationMinutes);
    });

    test('returns null when entry does not exist', () async {
      final found = await db.getEntryById('non-existent-id');
      expect(found, isNull);
    });
  });

  // ========== US2: List Sleep Entries ==========

  group('listEntries', () {
    test('returns entries ordered by wake_ts descending', () async {
      // Create entries with different wake times
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 5, 23, 0),
        wakeTs: DateTime(2026, 2, 6, 7, 0),
        quality: 3,
      ));
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      ));
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 6, 23, 0),
        wakeTs: DateTime(2026, 2, 7, 7, 0),
        quality: 5,
      ));

      final entries = await db.listEntries();

      expect(entries.length, 3);
      // Newest first
      expect(entries[0].wakeDate, '2026-02-08');
      expect(entries[1].wakeDate, '2026-02-07');
      expect(entries[2].wakeDate, '2026-02-06');
    });

    test('with fromDate/toDate filters correctly', () async {
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 5, 23, 0),
        wakeTs: DateTime(2026, 2, 6, 7, 0),
        quality: 3,
      ));
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 6, 23, 0),
        wakeTs: DateTime(2026, 2, 7, 7, 0),
        quality: 4,
      ));
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 5,
      ));

      final entries = await db.listEntries(
        fromDate: '2026-02-07',
        toDate: '2026-02-07',
      );

      expect(entries.length, 1);
      expect(entries[0].wakeDate, '2026-02-07');
    });

    test('with limit/offset paginates correctly', () async {
      for (var i = 1; i <= 5; i++) {
        await db.createEntry(CreateSleepEntryInput(
          bedtimeTs: DateTime(2026, 2, i, 23, 0),
          wakeTs: DateTime(2026, 2, i + 1, 7, 0),
          quality: 3,
        ));
      }

      final page1 = await db.listEntries(limit: 2, offset: 0);
      final page2 = await db.listEntries(limit: 2, offset: 2);

      expect(page1.length, 2);
      expect(page2.length, 2);
      // Page 1 should have newest entries
      expect(page1[0].wakeDate, '2026-02-06');
      expect(page1[1].wakeDate, '2026-02-05');
      // Page 2 should have older entries
      expect(page2[0].wakeDate, '2026-02-04');
      expect(page2[1].wakeDate, '2026-02-03');
    });

    test('on empty database returns empty list', () async {
      final entries = await db.listEntries();
      expect(entries, isEmpty);
    });

    test('with only fromDate works', () async {
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 5, 23, 0),
        wakeTs: DateTime(2026, 2, 6, 7, 0),
        quality: 3,
      ));
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      ));

      final entries = await db.listEntries(fromDate: '2026-02-08');
      expect(entries.length, 1);
      expect(entries[0].wakeDate, '2026-02-08');
    });

    test('with only toDate works', () async {
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 5, 23, 0),
        wakeTs: DateTime(2026, 2, 6, 7, 0),
        quality: 3,
      ));
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      ));

      final entries = await db.listEntries(toDate: '2026-02-06');
      expect(entries.length, 1);
      expect(entries[0].wakeDate, '2026-02-06');
    });
  });

  // ========== US3: Update a Sleep Entry ==========

  group('updateEntry', () {
    test('update wake_ts recomputes duration_minutes and wake_date', () async {
      final created = await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0), // 480 min
        quality: 4,
      ));

      final updated = await db.updateEntry(
        created.id,
        UpdateSleepEntryInput(wakeTs: DateTime(2026, 2, 8, 8, 0)), // 540 min
      );

      expect(updated.durationMinutes, 540);
      expect(updated.wakeDate, '2026-02-08');
    });

    test('update only quality changes quality and updated_at, not duration',
        () async {
      final created = await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 3,
      ));

      // Small delay to ensure updatedAt differs
      await Future.delayed(const Duration(milliseconds: 10));

      final updated = await db.updateEntry(
        created.id,
        const UpdateSleepEntryInput(quality: 5),
      );

      expect(updated.quality, 5);
      expect(updated.durationMinutes, created.durationMinutes);
      expect(updated.updatedAt.isAfter(created.updatedAt), isTrue);
    });

    test('update note stores new note', () async {
      final created = await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
        note: 'Original note',
      ));

      final updated = await db.updateEntry(
        created.id,
        const UpdateSleepEntryInput(note: 'Updated note', hasNote: true),
      );

      expect(updated.note, 'Updated note');
    });

    test('update with invalid times throws InvalidTimeRangeException',
        () async {
      final created = await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      ));

      expect(
        () => db.updateEntry(
          created.id,
          UpdateSleepEntryInput(
            wakeTs: DateTime(2026, 2, 7, 22, 0), // before bedtime
          ),
        ),
        throwsA(isA<InvalidTimeRangeException>()),
      );
    });

    test('update non-existent ID throws EntryNotFoundException', () async {
      expect(
        () => db.updateEntry(
          'non-existent-id',
          const UpdateSleepEntryInput(quality: 5),
        ),
        throwsA(isA<EntryNotFoundException>()),
      );
    });

    test('updated_at changes on every update', () async {
      final created = await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      ));

      await Future.delayed(const Duration(milliseconds: 10));
      final updated1 = await db.updateEntry(
        created.id,
        const UpdateSleepEntryInput(quality: 3),
      );

      await Future.delayed(const Duration(milliseconds: 10));
      final updated2 = await db.updateEntry(
        updated1.id,
        const UpdateSleepEntryInput(quality: 5),
      );

      expect(updated1.updatedAt.isAfter(created.updatedAt), isTrue);
      expect(updated2.updatedAt.isAfter(updated1.updatedAt), isTrue);
    });

    test('created_at does not change on update', () async {
      final created = await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      ));

      await Future.delayed(const Duration(milliseconds: 10));
      final updated = await db.updateEntry(
        created.id,
        const UpdateSleepEntryInput(quality: 5),
      );

      expect(updated.createdAt, created.createdAt);
    });
  });

  // ========== US4: Delete a Sleep Entry ==========

  group('deleteEntry', () {
    test('delete existing entry returns true and entry is removed', () async {
      final created = await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      ));

      final result = await db.deleteEntry(created.id);
      expect(result, isTrue);

      final entries = await db.listEntries();
      expect(entries, isEmpty);
    });

    test('delete non-existent ID returns false', () async {
      final result = await db.deleteEntry('non-existent-id');
      expect(result, isFalse);
    });

    test('delete then getEntryById returns null', () async {
      final created = await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      ));

      await db.deleteEntry(created.id);
      final found = await db.getEntryById(created.id);
      expect(found, isNull);
    });
  });
}
