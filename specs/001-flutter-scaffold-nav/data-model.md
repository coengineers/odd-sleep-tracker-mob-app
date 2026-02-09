# Data Model: Flutter Scaffold & Navigation (D0)

**Branch**: `001-flutter-scaffold-nav` | **Date**: 2026-02-09

## Overview

D0 introduces no persistent data entities. The data model for D0
consists only of the navigation route definitions and the theme
configuration. Persistent entities (SleepEntry) are introduced in D1.

## Entities

### Route Definition (conceptual)

Not a persisted entity — defines the navigation graph.

| Field | Type | Description |
|-------|------|-------------|
| path | String | URL path segment (e.g., `/`, `/log`, `/history`, `/insights`) |
| screen | Widget | Flutter widget rendered for this route |
| queryParams | Map<String, String>? | Optional query parameters (e.g., `id` for edit mode) |

### Screen Shell (conceptual)

Not a persisted entity — defines the placeholder UI contract.

| Field | Type | Description |
|-------|------|-------------|
| title | String | Screen title displayed in AppBar |
| subtitle | String? | Optional subtitle or description |
| bodyContent | Widget | Placeholder content for the screen shell |

## Relationships

```text
Home ──push──> LogEntry (optional ?id query param)
Home ──push──> History
Home ──push──> Insights
History ──push──> LogEntry (optional ?id query param)
```

## State Transitions

N/A for D0. Screen shells are stateless placeholders. State
management (Riverpod providers) is introduced in D1 when the
repository layer is built.

## Validation Rules

N/A for D0. Input validation is introduced in D2 (Log Entry screen).

## Future Entities (D1+)

The following entities are planned for future deliverables and are
documented here for context only:

- **SleepEntry** (D1): id, wake_date, bedtime_ts, wake_ts,
  duration_minutes, quality, note, created_at, updated_at
