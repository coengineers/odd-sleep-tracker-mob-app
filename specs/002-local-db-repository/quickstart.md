# Quickstart: Local Database & Repository Layer

**Feature**: 002-local-db-repository
**Date**: 2026-02-09

## Prerequisites

- D0 scaffold complete (branch `001-flutter-scaffold-nav` merged)
- Flutter 3.38+ on stable channel
- Dart 3.10+

## Setup

### 1. Add dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  drift: ^2.31.0
  drift_flutter: ^0.2.0
  path_provider: ^2.0.0
  uuid: ^4.0.0

dev_dependencies:
  drift_dev: ^2.31.0
  build_runner: ^2.4.0
```

Then run:

```bash
flutter pub get
```

### 2. Configure build_runner for drift

Create `build.yaml` in project root:

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          store_date_time_values_as_text: true
          case_from_dart_to_sql: snake_case
          named_parameters: true
          generate_manager: false
```

### 3. Generate drift code

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates `lib/database/app_database.g.dart` from the table definitions.

### 4. Run tests

```bash
flutter test test/database/
```

All tests use in-memory SQLite — no device/emulator needed.

## Key Files

| File | Purpose |
|------|---------|
| `lib/database/tables/sleep_entries.dart` | Drift table definition (schema) |
| `lib/database/app_database.dart` | Database class with repository methods |
| `lib/models/sleep_entry_model.dart` | Domain input/output types + validation |
| `lib/providers/database_providers.dart` | Riverpod providers for DI |
| `test/database/sleep_entry_repository_test.dart` | CRUD + validation tests |
| `test/database/duration_computation_test.dart` | Duration + wake_date computation |
| `test/database/sleep_entries_table_test.dart` | Table schema + constraint tests |

## Usage (for D2+ screens)

```dart
// In a ConsumerWidget:
final db = ref.read(appDatabaseProvider);

// Create
final entry = await db.createEntry(CreateSleepEntryInput(
  bedtimeTs: DateTime(2026, 2, 7, 23, 30),
  wakeTs: DateTime(2026, 2, 8, 7, 30),
  quality: 4,
  note: 'Fell asleep quickly',
));

// List (newest first)
final entries = await db.listEntries();

// List with filters
final weekEntries = await db.listEntries(
  fromDate: '2026-02-01',
  toDate: '2026-02-07',
);

// Update
final updated = await db.updateEntry(
  entry.id,
  UpdateSleepEntryInput(quality: 5),
);

// Delete
final deleted = await db.deleteEntry(entry.id);

// Get by ID
final found = await db.getEntryById(entry.id);
```

## Common Commands

```bash
# Regenerate drift code after schema changes
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on save)
dart run build_runner watch --delete-conflicting-outputs

# Run only D1 tests
flutter test test/database/

# Run all tests (D0 + D1)
flutter test

# Check for lint warnings
flutter analyze
```
