# Feature Specification: Local Database & Repository Layer

**Feature Branch**: `002-local-db-repository`
**Created**: 2026-02-09
**Status**: Draft
**Input**: User description: "implement D1 — Local database + repository layer"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a Sleep Entry (Priority: P1)

A user logs a sleep session by providing bedtime, wake time, and a quality rating (1–5). The system persists this entry locally on the device with a computed duration and derived wake date. The entry is immediately available for retrieval.

**Why this priority**: Without the ability to create entries, no other feature (history, insights, editing) can function. This is the foundational write operation.

**Independent Test**: Can be fully tested by creating an entry via the repository and verifying it is returned by a list/get operation with correct computed fields.

**Acceptance Scenarios**:

1. **Given** valid bedtime, wake time, and quality (1–5), **When** the user creates an entry, **Then** the entry is persisted with a generated unique identifier, computed duration in minutes, derived wake date, and creation/update timestamps.
2. **Given** bedtime of 23:30 and wake time of 07:30 the next day (cross-midnight), **When** the entry is saved, **Then** duration equals 480 minutes and wake date equals the date of the wake time.
3. **Given** an optional note (up to 280 characters), **When** the entry is saved, **Then** the note is stored and retrievable with the entry.

---

### User Story 2 - List Sleep Entries (Priority: P1)

A user wants to see their sleep history. The system retrieves all stored entries, ordered by most recent wake time first, with support for date-range filtering and pagination.

**Why this priority**: Listing entries is essential for both the History and Home screens. Without retrieval, persisted data has no user value.

**Independent Test**: Can be fully tested by seeding multiple entries and verifying the list returns them in the correct order with proper filtering and pagination.

**Acceptance Scenarios**:

1. **Given** multiple stored entries, **When** the user lists entries without filters, **Then** all entries are returned ordered by wake time (newest first).
2. **Given** entries spanning multiple dates, **When** a date range filter is applied, **Then** only entries within the specified range are returned.
3. **Given** more entries than the page size, **When** limit and offset parameters are provided, **Then** the correct subset of entries is returned.

---

### User Story 3 - Update a Sleep Entry (Priority: P2)

A user realizes they made a mistake in a previously logged entry and wants to correct the bedtime, wake time, quality, or note. The system updates the entry, recomputes duration and wake date if times changed, and updates the last-modified timestamp.

**Why this priority**: Editing is important for data accuracy but depends on create and list being functional first.

**Independent Test**: Can be fully tested by creating an entry, updating one or more fields, and verifying the stored entry reflects the changes with recomputed derived fields.

**Acceptance Scenarios**:

1. **Given** an existing entry, **When** the user updates the wake time, **Then** duration and wake date are recomputed and the last-modified timestamp is refreshed.
2. **Given** an existing entry, **When** the user updates only the quality rating, **Then** only the quality and last-modified timestamp change; duration and wake date remain the same.
3. **Given** a non-existent entry identifier, **When** an update is attempted, **Then** the system returns an appropriate error indicating the entry was not found.

---

### User Story 4 - Delete a Sleep Entry (Priority: P2)

A user wants to remove an incorrect or unwanted entry from their history. The system permanently deletes the entry from local storage.

**Why this priority**: Deletion supports the swipe-to-delete UX in History and is essential for data management, but depends on create and list.

**Independent Test**: Can be fully tested by creating an entry, deleting it by identifier, and verifying it no longer appears in the list.

**Acceptance Scenarios**:

1. **Given** an existing entry, **When** the user deletes it, **Then** the entry is permanently removed from local storage.
2. **Given** a non-existent entry identifier, **When** a delete is attempted, **Then** the system handles it gracefully without crashing.

---

### User Story 5 - Input Validation and Constraint Enforcement (Priority: P1)

The system validates all inputs before persisting. Invalid entries (impossible durations, out-of-range quality ratings, oversized notes) are rejected with clear error information.

**Why this priority**: Data integrity is critical from the start — invalid data would corrupt insights and summaries.

**Independent Test**: Can be fully tested by attempting to create entries with various invalid inputs and verifying each is rejected with the correct error type.

**Acceptance Scenarios**:

1. **Given** bedtime and wake time that produce duration of 0 minutes or less, **When** the user attempts to save, **Then** the system rejects the entry with an `invalid_time_range` error.
2. **Given** bedtime and wake time that produce duration exceeding 24 hours, **When** the user attempts to save, **Then** the system rejects the entry with an `invalid_time_range` error.
3. **Given** a quality rating outside the 1–5 range, **When** the user attempts to save, **Then** the system rejects the entry with an `invalid_quality` error.
4. **Given** a note exceeding 280 characters, **When** the user attempts to save, **Then** the system rejects the entry with a `note_too_long` error.

---

### Edge Cases

- What happens when multiple entries exist for the same wake date? Allowed — the system does not enforce uniqueness on wake date.
- What happens when bedtime and wake time are identical (0-minute duration)? Rejected as `invalid_time_range`.
- What happens during a DST transition where clocks spring forward or fall back? Duration is computed from the literal local timestamps (wall-clock difference). This may produce ±60 minute variance — acceptable for v1, documented as a known limitation.
- What happens when the database is accessed for the first time (empty)? List operations return an empty list; no errors.
- What happens if the device restarts between creating entries? All previously saved entries persist — the database is durable on-device storage.
- What happens when an update changes times to invalid values? The same validation rules apply on update as on create; the update is rejected.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST persist sleep entries locally on the device with no network calls.
- **FR-002**: System MUST generate a unique identifier for each new entry.
- **FR-003**: System MUST compute duration in minutes from bedtime and wake time on every save (create and update).
- **FR-004**: System MUST derive the wake date (calendar date of the wake time in local timezone) on every save (create and update).
- **FR-005**: System MUST support sleep sessions that cross midnight, computing duration correctly.
- **FR-006**: System MUST validate that duration is between 1 and 1440 minutes (inclusive) and reject entries outside this range with an `invalid_time_range` error.
- **FR-007**: System MUST validate that quality is an integer between 1 and 5 (inclusive) and reject entries outside this range with an `invalid_quality` error.
- **FR-008**: System MUST support an optional note field (max 280 characters) per entry and reject notes exceeding this limit.
- **FR-009**: System MUST support creating, reading (list with filters), updating, and deleting sleep entries (full CRUD).
- **FR-010**: System MUST return entries ordered by wake time (newest first) when listing.
- **FR-011**: System MUST support filtering entries by date range and pagination (limit/offset).
- **FR-012**: System MUST automatically set creation timestamp on new entries and update last-modified timestamp on every modification.
- **FR-013**: System MUST index wake date and wake time columns for efficient querying.
- **FR-014**: System MUST preserve all existing entries across app restarts.
- **FR-015**: System MUST allow multiple entries for the same wake date.

### Key Entities

- **SleepEntry**: A single sleep session record containing: unique identifier, bedtime timestamp, wake timestamp, wake date, computed duration in minutes, quality rating (1–5), optional note (max 280 characters), creation timestamp, and last-updated timestamp.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All CRUD operations (create, list, update, delete) complete successfully with valid inputs and return correct data.
- **SC-002**: All validation rules reject invalid inputs with specific, identifiable error types — no invalid data can be persisted.
- **SC-003**: Cross-midnight sleep sessions produce correct duration calculations (e.g., 23:30 to 07:30 = 480 minutes).
- **SC-004**: Listing 365 entries completes within acceptable interactive performance thresholds on mid-range devices.
- **SC-005**: Data persists across app restarts with zero data loss.
- **SC-006**: Zero network requests are made by the persistence layer.
- **SC-007**: All unit tests pass covering CRUD operations, validation rules, duration computation, cross-midnight handling, edge cases, and empty-state behavior.

## Assumptions

- Multiple entries per wake date are allowed (no uniqueness constraint on wake date).
- "Today's sleep" logic (selecting which entry represents today on the Home screen) is a UI concern handled in a later deliverable (D3), not in this repository layer.
- Duration is computed as simple wall-clock difference (wake time minus bedtime in minutes). DST edge cases producing ±60 minute variance are acceptable for v1.
- The optional note field is included in v1 per PRD FR-012 (marked as SHOULD, included as low-cost addition).
- The repository layer is a pure data access layer; it does not handle UI concerns like undo or confirmation dialogs.
- Migration strategy supports future schema changes but D1 only includes the initial schema (v1).

## Dependencies

- D0 (Flutter scaffold & navigation) must be complete — provides the project structure, Flutter/Dart setup, and Riverpod configuration that D1 builds upon.

## Known Limitations

- DST transitions may cause ±60 minute variance in computed duration when bedtime and wake time span a clock change.
- No server-side backup or sync — data loss occurs if the app is uninstalled or device storage is wiped.
