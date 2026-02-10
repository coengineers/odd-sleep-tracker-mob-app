# Feature Specification: Home + History Screens

**Feature Branch**: `004-home-history-screens`
**Created**: 2026-02-10
**Status**: Draft
**Input**: User description: "implement D3 — Home + History screens from PRD"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Today's Sleep Summary on Home (Priority: P1)

A user opens the app and immediately sees a summary of their most recent sleep for today — including how long they slept, their quality rating, and a mini chart showing the last 7 days of sleep duration. This is the primary landing experience and the first thing users interact with every day.

**Why this priority**: The Home screen is the app's front door. Every session starts here, and a clear today-summary drives daily engagement and gives users instant feedback on their sleep.

**Independent Test**: Can be fully tested by seeding at least one entry with today's wake date and verifying the Home screen displays duration, quality, and mini chart. Delivers immediate value as the daily dashboard.

**Acceptance Scenarios**:

1. **Given** at least one entry exists with wake date = today (local time), **When** the user opens the Home screen, **Then** the screen displays the duration (formatted as hours and minutes), the quality rating (1–5), and a mini chart showing the last 7 days of sleep duration.
2. **Given** multiple entries exist with wake date = today, **When** the user opens Home, **Then** the summary displays data from the entry with the latest wake time.
3. **Given** entries exist but none with wake date = today, **When** the user opens Home, **Then** the summary area shows a message like "No sleep logged for today" with a call-to-action to log sleep, while the mini chart still displays available historical data.

---

### User Story 2 - Browse Sleep History (Priority: P1)

A user navigates to the History screen to review all past sleep entries. Entries are listed newest-first, showing the date, sleep duration, and quality rating for each. The list handles large numbers of entries smoothly.

**Why this priority**: Reviewing past entries is essential for users to verify their data, spot patterns manually, and access entries for editing. It's equally critical alongside the Home screen for a functional sleep tracker.

**Independent Test**: Can be fully tested by seeding multiple entries across different dates and verifying they appear in reverse chronological order with correct date, duration, and quality values. Delivers value as a complete sleep log.

**Acceptance Scenarios**:

1. **Given** multiple entries exist, **When** the user opens the History screen, **Then** entries are listed newest-first (by wake date/time), each showing the wake date, sleep duration, and quality rating.
2. **Given** 365+ entries exist, **When** the user scrolls through History, **Then** the list scrolls smoothly without jank or excessive loading delays (renders within 500ms).
3. **Given** an entry was just created or edited, **When** the user returns to History, **Then** the list reflects the latest data.

---

### User Story 3 - Delete an Entry from History (Priority: P2)

A user wants to remove an incorrect or duplicate sleep entry. They swipe on the entry in the History list, confirm the deletion, and the entry is removed. An undo option appears briefly in case the deletion was accidental.

**Why this priority**: Delete with undo is important for data management and user confidence, but secondary to the core viewing flows. Users need to trust they can correct mistakes.

**Independent Test**: Can be fully tested by creating an entry, swiping to delete it, verifying the confirmation step, verifying removal, and then testing the undo restores the entry. Delivers value as a data correction mechanism.

**Acceptance Scenarios**:

1. **Given** an entry exists in History, **When** the user swipes the entry to delete and confirms, **Then** the entry is removed from the list and from local storage.
2. **Given** the user just confirmed a deletion, **When** the undo option appears, **Then** it remains available for 5 seconds. If the user taps Undo within 5 seconds, the entry is restored to its original position and data.
3. **Given** the user confirmed a deletion, **When** 5 seconds pass without tapping Undo, **Then** the deletion is permanent and the undo option disappears.
4. **Given** the user swipes to delete, **When** a confirmation prompt appears, **Then** the user can cancel the deletion and the entry remains unchanged.

---

### User Story 4 - Empty States for Home and History (Priority: P2)

A first-time user (or a user with no data) opens the app. Both the Home screen and History screen show friendly empty-state messages with a clear call-to-action to log their first sleep entry.

**Why this priority**: Empty states are essential for onboarding and guiding new users, but secondary to the core data display flows.

**Independent Test**: Can be fully tested with an empty database — open Home and History, verify empty state messages and CTA buttons are displayed and functional.

**Acceptance Scenarios**:

1. **Given** zero entries exist, **When** the user opens the Home screen, **Then** an empty state is shown with the message "No sleep logged yet" and a prominent "Log sleep" call-to-action.
2. **Given** zero entries exist, **When** the user opens the History screen, **Then** an empty state is shown indicating no entries and a "Log sleep" call-to-action.
3. **Given** the user taps the "Log sleep" CTA from either empty state, **When** the action completes, **Then** the user is navigated to the Log Entry screen in create mode.

---

### User Story 5 - Navigate from History to Edit an Entry (Priority: P2)

A user spots an entry in History that has incorrect data. They tap the entry to navigate to the Log Entry screen in edit mode, where they can correct the values and save.

**Why this priority**: Editing from History completes the data correction workflow. The edit screen itself already exists (D2); this story covers the navigation path from History to edit.

**Independent Test**: Can be fully tested by tapping an entry in History and verifying the Log Entry screen opens pre-populated with that entry's data for editing.

**Acceptance Scenarios**:

1. **Given** an entry exists in History, **When** the user taps on it, **Then** the Log Entry screen opens in edit mode with the entry's bedtime, wake time, quality, and note pre-populated.
2. **Given** the user edits an entry from History and saves, **When** the user returns to History, **Then** the updated values are reflected in the list.

---

### Edge Cases

- What happens when the device clock changes (e.g., timezone change or manual adjustment) while viewing Home? The "today" determination should use the device's current local date at the time the screen loads.
- What happens when an entry is deleted from History while the same entry is shown as today's summary on Home? The Home screen should refresh and show the next most recent entry for today, or fall back to the empty state.
- What happens if the user has entries only for past dates and none for today? Home shows "No sleep logged for today" with a CTA, but the mini chart still renders available historical data.
- How does the History list handle entries created with cross-midnight bedtimes? Each entry displays the wake date as its primary date label, matching how the data model assigns dates.
- What happens when the user rapidly swipes to delete multiple entries? Each deletion should be processed independently with its own undo window; a new deletion replaces the previous undo snackbar.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Home screen MUST display today's sleep summary (duration and quality rating) based on the most recent entry whose wake date equals today's local date.
- **FR-002**: Home screen MUST display a mini chart showing sleep duration for the last 7 days.
- **FR-003**: When multiple entries share the same wake date as today, Home MUST use the entry with the latest wake time for the summary.
- **FR-004**: History screen MUST list all sleep entries in reverse chronological order (newest first), showing wake date, sleep duration, and quality rating for each entry.
- **FR-005**: History screen MUST use a virtualised/lazy-loading list to handle large numbers of entries (365+) without performance degradation.
- **FR-006**: History MUST support swipe-to-delete with a confirmation step before removal.
- **FR-007**: After deletion, an Undo option MUST be displayed for 5 seconds. Tapping Undo MUST restore the deleted entry.
- **FR-008**: Tapping an entry in History MUST navigate to the Log Entry screen in edit mode with pre-populated data.
- **FR-009**: Home and History MUST display appropriate empty states with a "Log sleep" call-to-action when no entries exist.
- **FR-010**: The "Log sleep" CTA in empty states MUST navigate the user to the Log Entry screen in create mode.
- **FR-011**: Home MUST refresh its data when returning from other screens (e.g., after creating or editing an entry).

### Key Entities

- **Sleep Entry (display)**: A single sleep record shown in Home and History, consisting of wake date, bedtime, wake time, computed duration, quality rating (1–5), and optional note. The underlying data model is already defined in D1.
- **Today's Summary**: A derived view on Home showing the most recent entry for today's wake date — duration formatted as hours and minutes, quality rating, and contextual mini chart.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their today's sleep summary on the Home screen within 1 second of opening the app (excluding cold start).
- **SC-002**: History screen renders and is scrollable within 500ms with 365 entries in the database.
- **SC-003**: Users can delete an entry and undo the deletion within the 5-second window 100% of the time.
- **SC-004**: 100% of empty state screens display a functional "Log sleep" call-to-action that navigates to the Log Entry screen.
- **SC-005**: All entry data shown in History (date, duration, quality) matches the stored data with no discrepancies.

## Assumptions

- The sleep entry data model and CRUD operations from D1 are fully implemented and available.
- The Log Entry screen (D2) is fully implemented and supports both create and edit modes via navigation parameters.
- Navigation infrastructure (go_router) and bottom navigation from D0 are in place.
- The mini chart on Home is a simple visual representation (e.g., small bar chart or sparkline) of the last 7 days — it does not need to be interactive or tappable.
- "Today" is determined by the device's local date at the time the screen renders.
- Multiple entries per wake date are allowed (as stated in the PRD). Home uses the entry with the latest wake time.
- The undo mechanism for deletion uses an in-memory approach — once the undo window expires, the database deletion is finalized (or the entry is soft-deleted immediately and hard-deleted after the window).

## Dependencies

- **D0 (Flutter scaffold & navigation)**: Provides routing, bottom navigation bar, screen shells.
- **D1 (Local database & repository)**: Provides `AppDatabase` with CRUD operations (`createEntry`, `updateEntry`, `getEntryById`, `deleteEntry`, list/query methods).
- **D2 (Log Entry screen)**: Provides the create/edit screen that Home and History navigate to.
