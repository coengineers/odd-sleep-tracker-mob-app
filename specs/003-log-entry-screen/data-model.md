# Data Model: Log Entry Screen (D2)

**Feature**: `003-log-entry-screen`
**Date**: 2026-02-10

## Existing Entities (from D1 — no changes)

### SleepEntry (drift-generated data class)

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | String (UUID) | PRIMARY KEY | Generated on create |
| wakeDate | String | NOT NULL, YYYY-MM-DD | Computed from wakeTs |
| bedtimeTs | DateTime | NOT NULL | ISO 8601 local |
| wakeTs | DateTime | NOT NULL | ISO 8601 local |
| durationMinutes | int | NOT NULL, CHECK 1–1440 | Computed from bedtimeTs/wakeTs |
| quality | int | NOT NULL, CHECK 1–5 | User-selected rating |
| note | String? | nullable, max 280 chars | Optional user note |
| createdAt | DateTime | NOT NULL | Set on create, never updated |
| updatedAt | DateTime | NOT NULL | Set on create, updated on edit |

**Indexes**: `idx_sleep_entries_wake_date` (wakeDate), `idx_sleep_entries_wake_ts` (wakeTs)

### CreateSleepEntryInput (domain model)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| bedtimeTs | DateTime | yes | From picker |
| wakeTs | DateTime | yes | From picker |
| quality | int | yes | 1–5 from selector |
| note | String? | no | From text field |

### UpdateSleepEntryInput (domain model)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| bedtimeTs | DateTime? | no | null = no change |
| wakeTs | DateTime? | no | null = no change |
| quality | int? | no | null = no change |
| note | String? | no | null = no change (unless hasNote=true) |
| hasNote | bool | yes | true = explicitly set note (even to null) |

## Screen-Local State (not persisted)

The Log Entry screen manages ephemeral form state that exists only while the screen is mounted:

| State Field | Type | Initial Value (Create) | Initial Value (Edit) |
|-------------|------|----------------------|---------------------|
| bedtime | DateTime? | Yesterday 22:00 | entry.bedtimeTs |
| wakeTime | DateTime? | Today 07:00 | entry.wakeTs |
| quality | int? | null (unselected) | entry.quality |
| note | String | "" | entry.note ?? "" |
| isSaving | bool | false | false |
| errorMessage | String? | null | null |
| durationError | String? | null | null |
| qualityError | String? | null | null |

**Validation rules** (applied on save attempt):
1. `bedtime` must not be null
2. `wakeTime` must not be null
3. `wakeTime - bedtime` must be between 1 and 1440 minutes → else `durationError`
4. `quality` must not be null (1–5) → else `qualityError`
5. `note.length` ≤ 280 (enforced at input level via `maxLength`)

## State Transitions

```
[Screen Opens]
    ├── Create mode: set defaults (22:00 / 07:00)
    └── Edit mode: fetch entry by ID → populate fields
          ├── Loading... (show spinner)
          ├── Entry found → populate
          └── Entry not found → show error, pop back

[User Interacts]
    ├── Tap bedtime → date picker → time picker → update bedtime, clear durationError
    ├── Tap wake time → date picker → time picker → update wakeTime, clear durationError
    ├── Tap quality (1–5) → update quality, clear qualityError
    └── Type note → update note (maxLength enforced)

[User Taps Save]
    ├── Validate all fields
    │   ├── Fail → set error messages, abort
    │   └── Pass → set isSaving=true
    ├── Call createEntry() or updateEntry()
    │   ├── Success → pop back
    │   └── Error → set errorMessage, set isSaving=false
    └── Done
```
