import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.production();
  ref.onDispose(() => db.close());
  return db;
});
