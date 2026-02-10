// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_sleep_entries_wake_date', columns: {#wakeDate})
@TableIndex(name: 'idx_sleep_entries_wake_ts', columns: {#wakeTs})
class SleepEntries extends Table {
  TextColumn get id => text()();
  TextColumn get wakeDate => text()();
  DateTimeColumn get bedtimeTs => dateTime()();
  DateTimeColumn get wakeTs => dateTime()();
  IntColumn get durationMinutes => integer().check(
        durationMinutes.isBetween(const Constant(1), const Constant(1440)),
      )();
  IntColumn get quality => integer().check(
        quality.isBetween(const Constant(1), const Constant(5)),
      )();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
