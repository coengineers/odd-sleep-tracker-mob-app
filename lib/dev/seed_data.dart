import 'dart:math';

import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';

// The generated SleepEntry data class from drift.
// Re-export not needed — callers import app_database.dart which provides it.

const _sampleNotes = [
  'Slept really well',
  'Woke up once during the night',
  "Couldn't fall asleep easily",
  'Felt very rested',
  'Had a weird dream',
  'Too hot in the room',
  'Very quiet night',
  'Woke up earlier than planned',
];

/// Generates [days] sample sleep entries going back from today.
///
/// Each day gets one entry with randomised bedtime (21:00-23:59),
/// duration (300-600 min), quality (1-5), and an optional note (~30 % chance).
/// Returns the list of created [SleepEntry] objects in insertion order
/// (oldest first).
Future<List<SleepEntry>> seedSampleEntries(
  AppDatabase db, {
  int days = 90,
}) async {
  final rng = Random();
  final today = DateTime.now();
  final results = <SleepEntry>[];

  for (var i = days; i >= 1; i--) {
    // The wake date is `i` days ago from today.
    final wakeDate = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: i - 1));

    // Random bedtime on the PREVIOUS day: hour 21-23, minute 0-59.
    final bedHour = 21 + rng.nextInt(3); // 21, 22, or 23
    final bedMinute = rng.nextInt(60);
    final bedDate = wakeDate.subtract(const Duration(days: 1));
    final bedtime = DateTime(bedDate.year, bedDate.month, bedDate.day,
        bedHour, bedMinute);

    // Random duration between 300 and 600 minutes (inclusive).
    final durationMinutes = 300 + rng.nextInt(301); // 0..300 → 300..600

    final wakeTime = bedtime.add(Duration(minutes: durationMinutes));

    // Random quality 1-5.
    final quality = 1 + rng.nextInt(5);

    // ~30 % chance of a note.
    final String? note = rng.nextDouble() < 0.3
        ? _sampleNotes[rng.nextInt(_sampleNotes.length)]
        : null;

    final entry = await db.createEntry(CreateSleepEntryInput(
      bedtimeTs: bedtime,
      wakeTs: wakeTime,
      quality: quality,
      note: note,
    ));

    results.add(entry);
  }

  return results;
}
