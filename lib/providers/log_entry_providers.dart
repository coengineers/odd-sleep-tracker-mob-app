import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'database_providers.dart';

final sleepEntryProvider =
    FutureProvider.family<SleepEntry?, String>((ref, id) {
  final db = ref.read(appDatabaseProvider);
  return db.getEntryById(id);
});
