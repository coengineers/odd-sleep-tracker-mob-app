# Feature Specification: Log Entry Screen (Create/Edit)

**Feature Branch**: `003-log-entry-screen`
**Created**: 2026-02-10
**Status**: Draft
**Input**: User description: "implement D2 — Log Entry screen from PRD.md"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Log a New Sleep Entry (Priority: P1)

A user opens the Log Entry screen to record last night's sleep. They pick a bedtime (e.g., 23:00), a wake time (e.g., 07:00), select a quality rating from 1 to 5, and tap Save. The entry is persisted locally and immediately visible in the History and Home screens.

**Why this priority**: This is the core action of the entire app. Without the ability to create a sleep entry, no other feature (history, insights, home summary) has data to display. It directly fulfills the PRD's M1 success metric (entry in ≤ 30 seconds).

**Independent Test**: Can be fully tested by navigating to the Log Entry screen, filling in bedtime/wake/quality, saving, and verifying the entry appears in History.

**Acceptance Scenarios**:

1. **Given** the Log Entry screen in create mode, **When** the user selects bedtime 23:00, wake time 07:00, quality 4, and taps Save, **Then** a new entry is persisted with duration 480 minutes and wake date derived from the wake time, and the user is returned to the previous screen.
2. **Given** the Log Entry screen in create mode, **When** the user selects bedtime 23:30 and wake time 07:30 (cross-midnight), **Then** the duration is correctly computed as 480 minutes and the entry is assigned to the wake date (the next calendar day).
3. **Given** the Log Entry screen in create mode with all fields empty, **When** the user taps Save without entering any times, **Then** Save is blocked and validation messages are shown for the required fields.

---

### User Story 2 - Edit an Existing Sleep Entry (Priority: P2)

A user navigates to the Log Entry screen from History or Home to correct a previously recorded entry. The screen pre-fills all fields with the existing data. The user modifies one or more values and saves. The updated entry replaces the old one.

**Why this priority**: Correcting mistakes is essential for data integrity and user trust. Users who make a typo or forget to adjust a time need a straightforward way to fix it. This supports PRD FR-008.

**Independent Test**: Can be tested by creating an entry, navigating to edit it, changing the quality rating, saving, and verifying the updated value appears in History.

**Acceptance Scenarios**:

1. **Given** the Log Entry screen in edit mode with an existing entry (bedtime 22:00, wake 06:00, quality 3), **When** the user changes quality to 5 and taps Save, **Then** the entry is updated with quality 5 and the original bedtime/wake times are preserved.
2. **Given** the Log Entry screen in edit mode, **When** the user changes the wake time to a value that produces an invalid duration (e.g., same as bedtime), **Then** Save is blocked and a validation message is shown.
3. **Given** the Log Entry screen in edit mode, **When** the screen loads, **Then** all fields (bedtime, wake time, quality, note) are pre-populated with the existing entry's values.

---

### User Story 3 - Input Validation and Error Feedback (Priority: P2)

A user enters values that would produce an impossible sleep entry. The system prevents saving and shows clear, inline error messages explaining what needs to be corrected.

**Why this priority**: Preventing bad data protects the integrity of insights and history. Clear error feedback reduces frustration and supports the "frictionless" goal from the PRD.

**Independent Test**: Can be tested by entering various invalid combinations on the Log Entry screen and verifying that appropriate error messages appear and Save is disabled.

**Acceptance Scenarios**:

1. **Given** bedtime and wake time that produce a duration of 0 minutes (identical times), **When** the user attempts to save, **Then** Save is blocked and the message "Wake time must be after bedtime (within 24 hours)." is displayed.
2. **Given** bedtime and wake time that produce a duration exceeding 24 hours, **When** the user attempts to save, **Then** Save is blocked and the same validation message is shown.
3. **Given** a quality rating has not been selected, **When** the user attempts to save, **Then** Save is blocked and a message indicates that a quality rating is required.

---

### User Story 4 - Add an Optional Note (Priority: P3)

A user optionally adds a short text note (e.g., "Fell asleep quickly" or "Woke up twice") to provide context for a sleep entry. The note is saved with the entry and visible when editing.

**Why this priority**: Notes enrich the data but are not essential for core tracking. The feature is optional by design (PRD FR-012 is a SHOULD, not a MUST).

**Independent Test**: Can be tested by creating an entry with a note, then opening the entry in edit mode and verifying the note is displayed.

**Acceptance Scenarios**:

1. **Given** the Log Entry screen, **When** the user types a note of up to 280 characters and saves, **Then** the note is persisted with the entry.
2. **Given** the Log Entry screen, **When** the user types a note exceeding 280 characters, **Then** input is limited to 280 characters (the field prevents further typing or truncates).
3. **Given** the Log Entry screen, **When** the user saves without entering a note, **Then** the entry is saved successfully with no note.

---

### Edge Cases

- What happens when the user changes the device timezone between creating and editing an entry? Times are stored as local ISO datetimes; the displayed times reflect the stored values regardless of current timezone. This is acceptable behavior for v1.
- What happens during a DST transition (e.g., bedtime before "spring forward," wake time after)? Duration may be off by up to 60 minutes. This is documented and accepted for v1 per PRD Section 9.
- What happens if the user navigates away from the Log Entry screen mid-edit without saving? Unsaved changes are discarded. No confirmation dialog is required for v1 (assumption documented below).
- What happens if the entry being edited is deleted from another part of the app while the edit screen is open? The save operation fails gracefully, showing an error message, and the user is returned to the previous screen.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Log Entry screen MUST allow creating a new sleep entry with bedtime, wake time, and a quality rating (1–5).
- **FR-002**: The Log Entry screen MUST allow editing an existing sleep entry, pre-populating all fields with the current values.
- **FR-003**: The system MUST support sleep sessions that cross midnight, correctly computing duration and assigning the entry to the wake date.
- **FR-004**: The system MUST validate that the computed duration is between 1 minute and 1440 minutes (24 hours) inclusive, and MUST block saving with an inline error message when validation fails.
- **FR-005**: The system MUST validate that a quality rating (1–5) has been selected before allowing save.
- **FR-006**: The system MUST display the error message "Wake time must be after bedtime (within 24 hours)." when the duration is out of range.
- **FR-007**: The Log Entry screen MUST include an optional note field that accepts up to 280 characters.
- **FR-008**: On successful save (create or edit), the system MUST persist the entry locally and return the user to the previous screen.
- **FR-009**: The bedtime and wake time inputs MUST use platform-native date/time pickers.
- **FR-010**: The quality rating selector MUST present options 1 through 5 with clear visual indication of the selected value.
- **FR-011**: In edit mode, the screen title MUST change to indicate the user is editing (e.g., "Edit Entry" vs. "Log Entry").

### Key Entities

- **Sleep Entry**: A single sleep record containing bedtime, wake time, computed duration, quality rating (1–5), optional note (max 280 characters), wake date, and timestamps for creation and last update.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete a new sleep entry (select bedtime, wake time, quality, and save) in under 30 seconds on average.
- **SC-002**: 100% of invalid entries (duration out of range, missing quality) are blocked from saving with a visible error message.
- **SC-003**: Entries that cross midnight are saved with the correct duration and correct wake date 100% of the time.
- **SC-004**: Editing an existing entry pre-populates all fields correctly, and saving updates only the changed values.
- **SC-005**: All interactive controls (time pickers, quality selector, save button, note field) are accessible via screen reader with appropriate labels.

## Assumptions

- **A-001**: No unsaved-changes confirmation dialog is needed when navigating away from the Log Entry screen in v1. Users can re-enter data quickly given the minimal form.
- **A-002**: Bedtime defaults to "yesterday at 22:00" and wake time defaults to "today at 07:00" for new entries, providing sensible starting points that reduce picker interaction time.
- **A-003**: Multiple entries for the same wake date are allowed (per PRD Section 9).
- **A-004**: The note field character limit is enforced at the input level (maxLength on the text field), not just on save.
- **A-005**: DST-related duration discrepancies (up to ±60 minutes) are accepted for v1 per PRD Section 9.
