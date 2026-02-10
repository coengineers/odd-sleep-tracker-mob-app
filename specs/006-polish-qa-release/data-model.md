# Data Model: D5 — Polish, QA & Release Readiness

## No Schema Changes

D5 does not introduce any new entities or modify the existing `sleep_entries` table. All work in this deliverable operates on the existing data model established in D1.

## Existing Entity Reference

### SleepEntry (unchanged)

| Field | Type | Constraints |
|-------|------|-------------|
| id | String (UUID) | Primary key |
| wake_date | String (YYYY-MM-DD) | Not null, indexed |
| bedtime_ts | DateTime (ISO 8601) | Not null |
| wake_ts | DateTime (ISO 8601) | Not null, indexed |
| duration_minutes | int | Not null, 1–1440 |
| quality | int | Not null, 1–5 |
| note | String? | Optional, max 280 chars |
| created_at | DateTime (ISO 8601) | Not null |
| updated_at | DateTime (ISO 8601) | Not null |

## Seed Data Model

The seed tool generates `CreateSleepEntryInput` objects (the existing input DTO from D1) with randomised but realistic values. No new data structures are introduced.

### Seed Generation Parameters

| Parameter | Default | Range |
|-----------|---------|-------|
| days | 90 | 1–365 |
| bedtime hour | Random 21–24 | 9pm–midnight |
| sleep duration | Random 300–600 min | 5–10 hours |
| quality | Random 1–5 | Integer |
| note probability | 30% | Boolean per entry |
| entries per day | 1 | Fixed |

The seed function uses the existing `AppDatabase.createEntry()` method, so all validation and computed fields (duration, wake_date) are handled by the existing repository logic.
