# Data Model: Local Database & Repository Layer

**Feature**: 002-local-db-repository
**Date**: 2026-02-09

## Entities

### SleepEntry

A single sleep session recorded by the user.

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| id | TEXT (UUID v4) | NOT NULL | Primary key, auto-generated on create |
| wake_date | TEXT (YYYY-MM-DD) | NOT NULL | Derived from wake_ts local date on save |
| bedtime_ts | TEXT (ISO 8601) | NOT NULL | Local datetime when user went to bed |
| wake_ts | TEXT (ISO 8601) | NOT NULL | Local datetime when user woke up |
| duration_minutes | INTEGER | NOT NULL | Computed: wake_ts - bedtime_ts in minutes |
| quality | INTEGER | NOT NULL | User rating 1–5 |
| note | TEXT (max 280 chars) | NULL | Optional user note |
| created_at | TEXT (ISO 8601) | NOT NULL | Set on create, never modified |
| updated_at | TEXT (ISO 8601) | NOT NULL | Set on create, refreshed on every update |

### Indexes

| Index | Column(s) | Purpose |
|-------|-----------|---------|
| idx_sleep_entries_wake_date | wake_date | Fast lookup by calendar date (Home "today" query, Insights date ranges) |
| idx_sleep_entries_wake_ts | wake_ts | Fast ordering by wake time (History list, newest first) |

### Constraints

| Constraint | Rule | Error Type |
|------------|------|------------|
| quality_range | quality BETWEEN 1 AND 5 | CHECK constraint (DB) + `invalid_quality` (app) |
| duration_range | duration_minutes BETWEEN 1 AND 1440 | CHECK constraint (DB) + `invalid_time_range` (app) |
| note_length | LENGTH(note) <= 280 OR note IS NULL | App-level validation → `note_too_long` |

### Computed Fields (on save)

These fields are derived, not user-provided:

| Field | Computation | When |
|-------|-------------|------|
| id | UUID v4 generation | Create only |
| wake_date | Date portion of wake_ts in local timezone (YYYY-MM-DD) | Create and update |
| duration_minutes | (wake_ts - bedtime_ts) in whole minutes | Create and update |
| created_at | Current local datetime | Create only |
| updated_at | Current local datetime | Create and update |

### State Transitions

SleepEntry has no explicit state machine. It supports:
- **Create**: All required fields provided → validated → computed fields derived → persisted
- **Update**: Partial patch (any subset of bedtime_ts, wake_ts, quality, note) → validated → computed fields re-derived if times changed → persisted
- **Delete**: Permanent removal by ID

## Domain Input Types

### CreateSleepEntryInput

Fields the caller provides when creating a new entry:

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| bedtimeTs | DateTime | Yes | Local datetime |
| wakeTs | DateTime | Yes | Local datetime |
| quality | int | Yes | 1–5 |
| note | String? | No | Max 280 characters |

### UpdateSleepEntryInput

Fields the caller can patch when updating an existing entry:

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| bedtimeTs | DateTime? | No | If provided, duration and wake_date recomputed |
| wakeTs | DateTime? | No | If provided, duration and wake_date recomputed |
| quality | int? | No | 1–5 if provided |
| note | String? | No | Max 280 characters; pass empty string to clear |

When both bedtimeTs and wakeTs are null in the update, duration and wake_date remain unchanged. When either is provided, both the existing and new values are used to recompute.

## Relationships

SleepEntry is a standalone entity with no foreign keys in D1. Future deliverables may add related entities (e.g., tags, goals) but the current schema has no relationships.

## Data Lifecycle

- **Retention**: Indefinite (on-device until user deletes or app is uninstalled)
- **Backup**: None in v1 (on-device only)
- **Migration**: Schema version 1 (initial). Future versions use drift's onUpgrade callback.
