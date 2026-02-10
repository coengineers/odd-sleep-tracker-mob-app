# Contract: SleepEntry Repository

**Feature**: 002-local-db-repository
**Date**: 2026-02-09
**Implementation**: Methods on `AppDatabase` class (drift)

## Overview

The SleepEntry repository provides CRUD operations for sleep entries with input validation and computed field derivation. All methods are local (no network). Errors are returned as typed exceptions.

## Error Types

| Error | Condition | Thrown by |
|-------|-----------|-----------|
| `InvalidTimeRangeException` | Duration ≤ 0 or > 1440 minutes | create, update |
| `InvalidQualityException` | Quality not in 1–5 | create, update |
| `NoteTooLongException` | Note exceeds 280 characters | create, update |
| `EntryNotFoundException` | ID does not exist in database | update |

---

## Methods

### create(CreateSleepEntryInput) → SleepEntry

Creates a new sleep entry. Generates UUID, computes duration and wake_date, sets timestamps.

**Input**:

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| bedtimeTs | DateTime | Yes | Must produce valid duration with wakeTs |
| wakeTs | DateTime | Yes | Must be after bedtimeTs (within 24h) |
| quality | int | Yes | 1–5 inclusive |
| note | String? | No | Max 280 characters if provided |

**Output**: Complete `SleepEntry` with all fields populated (id, wake_date, duration_minutes, created_at, updated_at).

**Computed fields**:
- `id` = UUID v4
- `wake_date` = date portion of wakeTs (YYYY-MM-DD, local timezone)
- `duration_minutes` = (wakeTs - bedtimeTs).inMinutes
- `created_at` = DateTime.now()
- `updated_at` = DateTime.now()

**Errors**: `InvalidTimeRangeException`, `InvalidQualityException`, `NoteTooLongException`

**Example**:
```
Input:
  bedtimeTs: 2026-02-07T23:30:00
  wakeTs: 2026-02-08T07:30:00
  quality: 4
  note: "Fell asleep quickly"

Output:
  id: "a1b2c3d4-..."
  wakeDate: "2026-02-08"
  bedtimeTs: 2026-02-07T23:30:00
  wakeTs: 2026-02-08T07:30:00
  durationMinutes: 480
  quality: 4
  note: "Fell asleep quickly"
  createdAt: 2026-02-09T10:15:00
  updatedAt: 2026-02-09T10:15:00
```

---

### listEntries({fromDate?, toDate?, limit?, offset?}) → List\<SleepEntry\>

Lists sleep entries ordered by wake_ts descending (newest first). Supports optional date-range filtering and pagination.

**Input**:

| Field | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| fromDate | String? (YYYY-MM-DD) | No | null | Inclusive lower bound on wake_date |
| toDate | String? (YYYY-MM-DD) | No | null | Inclusive upper bound on wake_date |
| limit | int? | No | null | Max entries to return |
| offset | int? | No | 0 | Number of entries to skip |

**Output**: List of `SleepEntry` ordered by wake_ts descending. Empty list if no matches.

**Errors**: None (empty list on no results).

---

### updateEntry(String id, UpdateSleepEntryInput) → SleepEntry

Updates an existing sleep entry. Recomputes duration and wake_date if times changed. Refreshes updated_at.

**Input**:

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | String | Yes | Must exist in database |
| bedtimeTs | DateTime? | No | If provided, triggers recomputation |
| wakeTs | DateTime? | No | If provided, triggers recomputation |
| quality | int? | No | 1–5 if provided |
| note | String? | No | Max 280 chars; provide to change, omit to keep |

**Recomputation rules**:
- If either bedtimeTs or wakeTs is provided: use the new value(s) combined with existing value(s) to recompute duration_minutes and wake_date
- If neither is provided: duration_minutes and wake_date remain unchanged

**Output**: Complete updated `SleepEntry` with refreshed `updated_at`.

**Errors**: `EntryNotFoundException`, `InvalidTimeRangeException`, `InvalidQualityException`, `NoteTooLongException`

---

### deleteEntry(String id) → bool

Deletes a sleep entry by ID.

**Input**: Entry ID (String).

**Output**: `true` if an entry was deleted, `false` if no entry with that ID existed.

**Errors**: None (returns false for non-existent IDs).

---

### getEntryById(String id) → SleepEntry?

Retrieves a single entry by ID.

**Input**: Entry ID (String).

**Output**: `SleepEntry` if found, `null` if not found.

**Errors**: None.
