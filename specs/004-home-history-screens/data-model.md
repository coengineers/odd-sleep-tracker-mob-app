# Data Model: Home + History Screens

**Feature**: 004-home-history-screens
**Date**: 2026-02-10

## Existing Entities (from D1 — no changes)

### SleepEntry (drift-generated data class)

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | String | PRIMARY KEY, UUID v4 | Generated on create |
| wakeDate | String | NOT NULL, YYYY-MM-DD | Derived from wakeTs local date |
| bedtimeTs | DateTime | NOT NULL | ISO 8601 stored as text |
| wakeTs | DateTime | NOT NULL | ISO 8601 stored as text |
| durationMinutes | int | NOT NULL, CHECK 1–1440 | Computed on save |
| quality | int | NOT NULL, CHECK 1–5 | User-selected rating |
| note | String? | nullable, max 280 chars | Optional |
| createdAt | DateTime | NOT NULL | Set on create |
| updatedAt | DateTime | NOT NULL | Updated on save |

**Indexes**: `idx_sleep_entries_wake_date` (wakeDate), `idx_sleep_entries_wake_ts` (wakeTs)

**No schema changes required for D3.** The existing table, indexes, and repository methods support all queries needed.

## New Derived Views (in-memory, not persisted)

### TodaySummary

A derived view used by the Home screen. Not a database entity — computed from the query result.

| Field | Source | Notes |
|-------|--------|-------|
| entry | SleepEntry | The most recent entry where wakeDate = today |
| formattedDuration | String | e.g., "8h 30m" — computed from `durationMinutes` |
| qualityRating | int | 1–5 from entry |

**Query**: `listEntries(fromDate: today, toDate: today, limit: 1)` — returns the entry with the latest `wakeTs` for today (already ordered descending).

### DurationDataPoint

A lightweight record used by the mini chart on Home.

| Field | Type | Notes |
|-------|------|-------|
| date | String | YYYY-MM-DD |
| durationMinutes | int | 0 if no entry for that day |

**Query**: `listEntries(fromDate: sevenDaysAgo, toDate: today)` — returns all entries in the range. The provider maps these to 7 data points, one per day, taking the entry with the highest `wakeTs` per day if multiple exist. Missing days are filled with 0.

## Existing Repository Methods Used

| Method | Signature | Used By |
|--------|-----------|---------|
| listEntries | `({String? fromDate, String? toDate, int? limit, int? offset}) → Future<List<SleepEntry>>` | Home (today summary + chart), History (all entries) |
| deleteEntry | `(String id) → Future<bool>` | History (swipe-to-delete) |
| createEntry | `(CreateSleepEntryInput) → Future<SleepEntry>` | History (undo — re-insert deleted entry) |
| getEntryById | `(String id) → Future<SleepEntry?>` | Log Entry screen (edit mode, existing) |

**No new repository methods needed.** The existing `listEntries` with date filters + ordering handles all D3 queries.

## State Transitions

### Delete with Undo Flow

```
[Entry visible in list]
    │
    ▼ swipe
[Confirm dialog shown]
    │
    ├─ cancel → [Entry remains]
    │
    ▼ confirm
[Entry removed from list]
[Entry deleted from DB]
[Deleted entry held in memory]
[SnackBar with Undo shown — 5s timer]
    │
    ├─ Undo tapped → [Entry re-inserted via createEntry()] → [List refreshed]
    │
    ▼ 5s elapsed
[In-memory copy discarded]
[Deletion permanent]
```

**Note on undo re-insertion**: When undoing, we call `createEntry()` with the original entry's field values. This generates a new UUID and new timestamps. The entry will appear at its correct position in the list (sorted by `wakeTs`). This is acceptable because the user's data (bedtime, wake time, quality, note) is preserved — the internal ID and timestamps are implementation details not visible to the user.
