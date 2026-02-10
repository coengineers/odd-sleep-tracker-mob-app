# Contract: Seed Data Tool

## Internal API (dev-only)

D5 introduces no external APIs. The only new callable is the dev-only seed data function.

### `seedSampleEntries`

**Location**: `lib/dev/seed_data.dart`

**Signature**:
```
Future<List<SleepEntry>> seedSampleEntries(
  AppDatabase db, {
  int days = 90,
})
```

**Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| db | AppDatabase | required | Database instance to populate |
| days | int | 90 | Number of days of data to generate (going back from today) |

**Behaviour**:
- Generates one entry per day for the specified number of days
- Bedtimes range from 21:00 to 23:59 (randomised)
- Sleep durations range from 300 to 600 minutes (5–10 hours)
- Quality ratings are uniformly distributed 1–5
- ~30% of entries include a randomised note from a predefined set
- Uses `AppDatabase.createEntry()` for each entry (respects all validation)
- Returns the list of created `SleepEntry` objects

**Errors**:
- Propagates any validation errors from `createEntry()` (should not occur with valid randomisation ranges)

**Access control**:
- Call site MUST be guarded by `kDebugMode` check
- The function itself does not check `kDebugMode` — the caller is responsible

### Integration Point

**Location**: `lib/screens/home_screen.dart` (AppBar title long-press)

**Trigger**: Long-press on "SleepLog" text in the Home screen AppBar

**Guard**: `if (kDebugMode)` — the `GestureDetector` is only added in debug builds

**User feedback**: Shows a `SnackBar` with "Seeding N days of sample data..." and then "Done! Added N entries." on completion
