# Provider Contracts: Home + History Screens

**Feature**: 004-home-history-screens
**Date**: 2026-02-10

## New Providers

### todaySummaryProvider

**File**: `lib/providers/home_providers.dart`
**Type**: `FutureProvider<SleepEntry?>`

**Contract**:
- Reads `appDatabaseProvider` to get the database instance.
- Computes today's date string (`YYYY-MM-DD`) from `DateTime.now()`.
- Calls `db.listEntries(fromDate: today, toDate: today, limit: 1)`.
- Returns the first entry (most recent by `wakeTs`) or `null` if no entries for today.

**States**:
- `AsyncLoading` → while query executes
- `AsyncData(SleepEntry)` → today's entry found
- `AsyncData(null)` → no entry for today
- `AsyncError` → database error (unlikely but handled)

---

### recentDurationsProvider

**File**: `lib/providers/home_providers.dart`
**Type**: `FutureProvider<List<DurationDataPoint>>`

Where `DurationDataPoint` is:
```dart
({String date, int durationMinutes})
```

**Contract**:
- Reads `appDatabaseProvider` to get the database instance.
- Computes the date range: 6 days ago → today (7 days total).
- Calls `db.listEntries(fromDate: sixDaysAgo, toDate: today)`.
- Groups results by `wakeDate`. For days with multiple entries, uses the entry with the latest `wakeTs`.
- Fills missing days with `durationMinutes: 0`.
- Returns exactly 7 data points sorted oldest → newest (for left-to-right chart rendering).

**States**:
- `AsyncLoading` → while query executes
- `AsyncData(List<DurationDataPoint>)` → 7 data points (always exactly 7)
- `AsyncError` → database error

---

### allEntriesProvider

**File**: `lib/providers/home_providers.dart`
**Type**: `FutureProvider<List<SleepEntry>>`

**Contract**:
- Reads `appDatabaseProvider` to get the database instance.
- Calls `db.listEntries()` with no filters (returns all entries, ordered by `wakeTs` descending).
- Returns the full list.

**States**:
- `AsyncLoading` → while query executes
- `AsyncData(List<SleepEntry>)` → entries list (may be empty)
- `AsyncError` → database error

---

## Existing Providers (unchanged)

### appDatabaseProvider

**File**: `lib/providers/database_providers.dart`
**Type**: `Provider<AppDatabase>`

No changes. Used by all new providers to access the database.

### sleepEntryProvider

**File**: `lib/providers/log_entry_providers.dart`
**Type**: `FutureProvider.family<SleepEntry?, String>`

No changes. Used by LogEntryScreen in edit mode (existing D2 flow).

---

## Provider Invalidation Contract

| Action | Providers Invalidated | Trigger Location |
|--------|----------------------|------------------|
| Return from Log Entry (create/edit) | `todaySummaryProvider`, `recentDurationsProvider`, `allEntriesProvider` | Home screen and History screen after `context.push('/log')` completes |
| Delete entry from History | `allEntriesProvider`, `todaySummaryProvider`, `recentDurationsProvider` | History screen after successful delete |
| Undo delete | `allEntriesProvider`, `todaySummaryProvider`, `recentDurationsProvider` | History screen after undo re-insert |

**Invalidation mechanism**: `ref.invalidate(providerName)` — causes the provider to re-execute its query on next read.
