import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables/sleep_entries.dart';
import '../models/sleep_entry_model.dart';

part 'app_database.g.dart';

const _uuid = Uuid();

@DriftDatabase(tables: [SleepEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Production constructor using drift_flutter's platform-aware SQLite.
  factory AppDatabase.production() {
    return AppDatabase(driftDatabase(name: 'sleeplog'));
  }

  /// Test constructor accepting any [QueryExecutor] (e.g., NativeDatabase.memory()).
  factory AppDatabase.forTesting(QueryExecutor executor) {
    return AppDatabase(executor);
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );

  // --- Repository Methods ---

  /// Creates a new sleep entry with computed fields.
  Future<SleepEntry> createEntry(CreateSleepEntryInput input) async {
    validateCreateInput(input);

    final id = _uuid.v4();
    final now = DateTime.now();
    final durationMins = computeDurationMinutes(input.bedtimeTs, input.wakeTs);
    final wakeDate = computeWakeDate(input.wakeTs);

    final companion = SleepEntriesCompanion.insert(
      id: id,
      wakeDate: wakeDate,
      bedtimeTs: input.bedtimeTs,
      wakeTs: input.wakeTs,
      durationMinutes: durationMins,
      quality: input.quality,
      note: Value(input.note),
      createdAt: now,
      updatedAt: now,
    );

    await into(sleepEntries).insert(companion);

    return (select(sleepEntries)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Gets a single entry by ID, or null if not found.
  Future<SleepEntry?> getEntryById(String id) {
    return (select(sleepEntries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Lists entries ordered by wake_ts descending with optional filters.
  Future<List<SleepEntry>> listEntries({
    String? fromDate,
    String? toDate,
    int? limit,
    int? offset,
  }) {
    final query = select(sleepEntries);
    query.where((t) {
      Expression<bool> condition = const Constant(true);
      if (fromDate != null) {
        condition = condition & t.wakeDate.isBiggerOrEqualValue(fromDate);
      }
      if (toDate != null) {
        condition = condition & t.wakeDate.isSmallerOrEqualValue(toDate);
      }
      return condition;
    });
    query.orderBy([(t) => OrderingTerm.desc(t.wakeTs)]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }

  /// Updates an existing entry. Recomputes duration and wake_date if times change.
  Future<SleepEntry> updateEntry(
      String id, UpdateSleepEntryInput input) async {
    final existing = await getEntryById(id);
    if (existing == null) {
      throw EntryNotFoundException('No entry found with id: $id');
    }

    final mergedBedtime = input.bedtimeTs ?? existing.bedtimeTs;
    final mergedWake = input.wakeTs ?? existing.wakeTs;
    final mergedQuality = input.quality ?? existing.quality;
    final mergedNote = input.hasNote ? input.note : existing.note;

    validateUpdateInput(
      bedtimeTs: mergedBedtime,
      wakeTs: mergedWake,
      quality: mergedQuality,
      note: mergedNote,
      hasNote: input.hasNote,
    );

    final timesChanged = input.bedtimeTs != null || input.wakeTs != null;
    final now = DateTime.now();

    final companion = SleepEntriesCompanion(
      bedtimeTs: Value(mergedBedtime),
      wakeTs: Value(mergedWake),
      quality: Value(mergedQuality),
      note: Value(mergedNote),
      durationMinutes: timesChanged
          ? Value(computeDurationMinutes(mergedBedtime, mergedWake))
          : const Value.absent(),
      wakeDate: timesChanged
          ? Value(computeWakeDate(mergedWake))
          : const Value.absent(),
      updatedAt: Value(now),
    );

    await (update(sleepEntries)..where((t) => t.id.equals(id)))
        .write(companion);

    return (select(sleepEntries)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Deletes an entry by ID. Returns true if deleted, false if not found.
  Future<bool> deleteEntry(String id) async {
    final rows = await (delete(sleepEntries)..where((t) => t.id.equals(id)))
        .go();
    return rows > 0;
  }
}
