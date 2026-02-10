# Quickstart: Log Entry Screen (D2)

**Feature**: `003-log-entry-screen`
**Date**: 2026-02-10

## Prerequisites

- D0 (`001-flutter-scaffold-nav`) merged: routing, theme, screen shells
- D1 (`002-local-db-repository`) merged: drift database, CRUD methods, domain models
- Flutter SDK 3.38+ on stable channel
- All existing tests pass: `flutter test`

## Branch Setup

```bash
git checkout 003-log-entry-screen
flutter pub get
```

No new dependencies are needed — all packages (`drift`, `flutter_riverpod`, `go_router`, `intl`) are already in `pubspec.yaml` from D0/D1.

## What to Build

### Files to Create

1. **`lib/providers/log_entry_providers.dart`**
   - `sleepEntryProvider`: `FutureProvider.family<SleepEntry?, String>` — fetches entry by ID for edit mode
   - Uses `appDatabaseProvider` from `lib/providers/database_providers.dart`

2. **`lib/widgets/quality_selector.dart`**
   - `QualitySelector`: stateless widget displaying 1–5 tappable items
   - Props: `int? value`, `ValueChanged<int> onChanged`
   - Selected item: primary fill (orange), unselected: surface fill
   - Min 44x44px per item

3. **`test/widgets/quality_selector_test.dart`**
   - Test: renders 5 items
   - Test: tapping an item calls onChanged with correct value
   - Test: selected item has primary colour styling

### Files to Modify

4. **`lib/theme/app_theme.dart`**
   - Add `inputDecorationTheme` to `ThemeData.dark`:
     - `filled: true`, `fillColor: surface`
     - `border: OutlineInputBorder(borderRadius: 12px, borderSide: outline)`
     - `focusedBorder: OutlineInputBorder(borderSide: primary)`
     - `errorBorder: OutlineInputBorder(borderSide: error)`
     - `contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)` (yields ~44px height)

5. **`lib/screens/log_entry_screen.dart`**
   - Replace placeholder with full `ConsumerStatefulWidget` form
   - Create mode: smart defaults (bedtime=yesterday 22:00, wake=today 07:00)
   - Edit mode: load entry via `sleepEntryProvider`, pre-populate fields
   - Form layout: bedtime picker → wake picker → duration display → quality selector → note field → save button
   - Validation on save: duration 1–1440 min, quality required
   - Save: call `createEntry()` or `updateEntry()`, pop on success

6. **`test/screens/log_entry_screen_test.dart`**
   - Replace placeholder tests with full widget test coverage
   - Tests need `ProviderScope` with `appDatabaseProvider` overridden to use in-memory DB
   - Cover: create mode rendering, edit mode pre-population, validation errors, successful save, save button states

## Key Existing Code to Use

```dart
// Database access (lib/providers/database_providers.dart)
final appDatabaseProvider = Provider<AppDatabase>((ref) { ... });

// Create entry (lib/database/app_database.dart)
Future<SleepEntry> createEntry(CreateSleepEntryInput input)

// Update entry (lib/database/app_database.dart)
Future<SleepEntry> updateEntry(String id, UpdateSleepEntryInput input)

// Get entry (lib/database/app_database.dart)
Future<SleepEntry?> getEntryById(String id)

// Domain models (lib/models/sleep_entry_model.dart)
CreateSleepEntryInput({bedtimeTs, wakeTs, quality, note})
UpdateSleepEntryInput({bedtimeTs, wakeTs, quality, note, hasNote})

// Helpers (lib/models/sleep_entry_model.dart)
int computeDurationMinutes(DateTime bedtimeTs, DateTime wakeTs)
String computeWakeDate(DateTime wakeTs)

// Exceptions (lib/models/sleep_entry_model.dart)
InvalidTimeRangeException, InvalidQualityException,
NoteTooLongException, EntryNotFoundException
```

## Testing Pattern

```dart
// Standard test setup (from existing tests)
import 'package:drift/native.dart';

late AppDatabase db;

setUp(() {
  db = AppDatabase.forTesting(NativeDatabase.memory());
});

tearDown(() => db.close());

// Widget test with DB override
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.dark,
    ),
  ),
);
```

## Verification

After implementation, run:

```bash
flutter analyze   # Zero warnings
flutter test      # All tests pass (existing + new)
```

Manual verification:
1. Open app → tap FAB (+) → Log Entry screen appears with defaults
2. Pick bedtime, wake time, quality → tap Save → returns to Home
3. Navigate to History → tap entry → Edit Entry screen pre-populated
4. Change quality → tap Update → returns, change reflected
5. Try saving with identical bedtime/wake → error message shown
6. Try saving without quality selected → error message shown
