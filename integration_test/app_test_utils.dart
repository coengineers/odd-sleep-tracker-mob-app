import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';
import 'package:sleeplog/providers/database_providers.dart';
import 'package:sleeplog/routing/app_router.dart';
import 'package:sleeplog/theme/app_theme.dart';

/// Creates a fully wired integration test app with an in-memory database.
///
/// The returned widget is identical to the production [SleepLogApp] except:
/// - Uses an in-memory SQLite database (passed in)
/// - Overrides [appDatabaseProvider] so all providers read from it
Widget buildIntegrationTestApp(AppDatabase db) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp.router(
      routerConfig: createRouter(),
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
    ),
  );
}

/// Seeds test entries into the database and returns the created entries.
///
/// Generates [count] entries with varied bedtimes, durations, and quality.
/// Entries are spaced one day apart going back from [baseDate] (defaults to
/// today). Useful for setting up integration test preconditions.
Future<List<SleepEntry>> seedTestEntries(
  AppDatabase db, {
  int count = 3,
  DateTime? baseDate,
}) async {
  final base = baseDate ?? DateTime.now();
  final entries = <SleepEntry>[];

  for (var i = 0; i < count; i++) {
    final wakeDate = DateTime(base.year, base.month, base.day)
        .subtract(Duration(days: i));
    final wakeTs = wakeDate.add(const Duration(hours: 7, minutes: 30));
    final bedtimeTs = wakeTs.subtract(Duration(minutes: 420 + i * 15));

    final entry = await db.createEntry(CreateSleepEntryInput(
      bedtimeTs: bedtimeTs,
      wakeTs: wakeTs,
      quality: (i % 5) + 1,
    ));
    entries.add(entry);
  }

  return entries;
}
