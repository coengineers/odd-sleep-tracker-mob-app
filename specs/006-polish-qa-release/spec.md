# Feature Specification: D5 — Polish, QA & Release Readiness

**Feature Branch**: `006-polish-qa-release`
**Created**: 2026-02-10
**Status**: Draft
**Input**: User description: "implement D5 — Polish, QA, release readiness from PRD.md"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - End-to-End Sleep Logging Journey (Priority: P1)

A user opens the app for the first time, logs a sleep entry, views it on the Home screen, checks it in History, and reviews their data in Insights — all verified through an automated integration test that exercises the complete happy path across all four screens.

**Why this priority**: This is the core user journey (J1 from the PRD). If this flow breaks, the app is fundamentally unusable. An automated integration test for this path provides the highest confidence that the app works as a cohesive product.

**Independent Test**: Can be tested by running a single integration test that navigates through all screens and verifies data flows correctly from entry creation through display.

**Acceptance Scenarios**:

1. **Given** a fresh app install with no entries, **When** the integration test opens the app, **Then** the Home screen displays an empty state with a "Log sleep" call-to-action.
2. **Given** the Home empty state, **When** the test taps "Log sleep", enters bedtime/wake time/quality, and saves, **Then** the entry is created and the Home screen shows today's sleep summary with duration and quality.
3. **Given** an entry exists, **When** the test navigates to History, **Then** the entry appears in the list with correct date, duration, and quality.
4. **Given** an entry exists, **When** the test navigates to Insights, **Then** the charts and summaries render without errors.

---

### User Story 2 - Edit and Delete Journey (Priority: P1)

A user edits an existing sleep entry to correct a mistake, then deletes a different entry from History with undo — verified through an automated integration test.

**Why this priority**: Editing and deleting are essential data-correction flows (J2 from the PRD). Users must trust they can fix mistakes. This validates FR-007 and FR-008 in an end-to-end context.

**Independent Test**: Can be tested by creating entries, editing one, deleting another, and verifying the changes persist correctly.

**Acceptance Scenarios**:

1. **Given** an existing entry, **When** the test taps the entry in History to edit it, changes the quality rating, and saves, **Then** the updated quality is reflected in History and Insights.
2. **Given** multiple entries exist, **When** the test swipes to delete an entry and confirms, **Then** the entry is removed from History and an undo option appears.
3. **Given** the undo option is visible, **When** the test taps undo within the timeout period, **Then** the entry is restored.

---

### User Story 3 - Offline Operation Verification (Priority: P1)

A QA tester verifies that all app features work identically in airplane mode and that zero network requests are made during any operation, satisfying NFR-001 and NFR-005.

**Why this priority**: The app's core promise is privacy through offline-only operation. Any network call would violate the fundamental trust contract with users.

**Independent Test**: Can be tested by running the app in airplane mode (or network-disabled environment) and confirming all features work and no HTTP client code exists in the codebase.

**Acceptance Scenarios**:

1. **Given** the device is in airplane mode, **When** the user performs all key journeys (log, edit, delete, view history, view insights), **Then** all features work identically to online mode.
2. **Given** the production codebase, **When** a code audit is performed, **Then** no HTTP client imports, network request libraries, or analytics SDKs are found.

---

### User Story 4 - Accessibility for Screen Reader Users (Priority: P2)

A user relying on a screen reader (TalkBack/VoiceOver) can navigate the entire app, log an entry, browse history, and view insights with meaningful spoken labels for every interactive element.

**Why this priority**: Accessibility compliance (NFR-004) ensures the app is usable by everyone. Screen reader support is the most impactful accessibility improvement and is required for app store acceptance on both platforms.

**Independent Test**: Can be tested by enabling a screen reader and verifying every interactive control announces its purpose and state.

**Acceptance Scenarios**:

1. **Given** a screen reader is enabled, **When** the user navigates through the Home screen, **Then** all buttons, charts, and summary elements have descriptive semantic labels.
2. **Given** a screen reader is enabled, **When** the user interacts with the Log Entry screen, **Then** time pickers, quality selector, note field, and save button all announce their purpose and current value.
3. **Given** a screen reader is enabled, **When** the user browses History, **Then** each entry card announces date, duration, and quality; swipe-to-delete is announced.
4. **Given** a screen reader is enabled, **When** the user views Insights, **Then** charts have descriptive labels and pattern summaries are read aloud.

---

### User Story 5 - Developer Seed Data Tool (Priority: P2)

A developer working on the app can quickly populate the database with realistic sample entries (spanning various dates, durations, and quality ratings) to test UI rendering, chart behavior, and performance with meaningful data — available only in development builds.

**Why this priority**: A seed tool accelerates manual QA, enables consistent demo scenarios, and allows performance testing with a realistic data volume. It is essential for validating NFR-002 (performance with 365 entries).

**Independent Test**: Can be tested by running the seed tool and verifying that sample entries appear across all screens with realistic variety.

**Acceptance Scenarios**:

1. **Given** a development build with an empty database, **When** the developer triggers the seed data tool, **Then** the database is populated with a configurable number of sample entries (default: 90 days of data).
2. **Given** seed data has been generated, **When** the developer views History, **Then** entries span multiple dates with varied durations (5–10 hours) and quality ratings (1–5).
3. **Given** seed data has been generated, **When** the developer views Insights, **Then** charts display meaningful trends and pattern summaries are populated.

---

### User Story 6 - Data Integrity Across App Restarts (Priority: P2)

A user creates, edits, and deletes entries, then force-closes and reopens the app, and all data changes are preserved exactly as expected — satisfying NFR-003.

**Why this priority**: Data persistence reliability is critical for user trust. Any data loss would undermine the app's value proposition.

**Independent Test**: Can be tested by creating entries, restarting the app, and verifying all data persists correctly.

**Acceptance Scenarios**:

1. **Given** the user has created several entries, **When** the app is force-closed and reopened, **Then** all entries are present with correct values.
2. **Given** the user has edited an entry, **When** the app is restarted, **Then** the edited values persist.
3. **Given** the user has deleted an entry (without undo), **When** the app is restarted, **Then** the deleted entry does not reappear.

---

### Edge Cases

- What happens when the seed tool is triggered on a database that already has entries? (It should add entries without deleting existing ones.)
- What happens when the device timezone changes between creating an entry and viewing it? (Entries display based on their stored timestamps; no retroactive recalculation.)
- What happens when DST changes occur during a logged sleep session? (Duration may vary by up to 60 minutes from wall-clock expectation; this is a documented known limitation.)
- What happens when an integration test encounters a slow device or emulator? (Tests should use reasonable timeouts and pumping strategies to avoid flakiness.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST include automated integration tests that verify the complete "first use to log sleep" journey (J1) across all four screens.
- **FR-002**: The app MUST include automated integration tests that verify the "review and correct history" journey (J2), including edit and swipe-to-delete with undo.
- **FR-003**: The app MUST NOT contain any HTTP client code, network request libraries, or analytics SDKs in production builds, verifiable through code inspection.
- **FR-004**: All interactive controls MUST have semantic labels that are announced by screen readers (TalkBack on Android, VoiceOver on iOS).
- **FR-005**: Charts and visual data displays MUST have accessibility descriptions so screen reader users understand the information presented.
- **FR-006**: Tap targets for all interactive elements MUST meet minimum size guidelines (48x48 logical pixels).
- **FR-007**: The app MUST support larger text sizes without layout overflow or truncation of critical information.
- **FR-008**: A development-only seed data tool MUST be available to populate the database with configurable sample entries (default: 90 days).
- **FR-009**: The seed data tool MUST generate realistic entries with varied durations (5–10 hours), quality ratings (1–5), and optional notes.
- **FR-010**: The seed data tool MUST NOT be accessible or included in production/release builds.
- **FR-011**: All data modifications (create, edit, delete) MUST survive app restarts without loss or corruption.
- **FR-012**: A release checklist document MUST be produced listing known limitations (DST behavior, multiple entries per day), QA steps performed, and build instructions.

### Assumptions

- The existing unit and widget tests (12 test files) provide adequate coverage of individual components; D5 focuses on integration-level and cross-cutting quality concerns.
- Accessibility improvements build on the existing `Semantics` wrappers already present in some widgets (quality_selector, log_entry_screen) and extend coverage to all screens.
- The seed data tool will be a dev-mode-only screen or action, excluded from release builds via compile-time flags or conditional imports.
- Performance testing with 365 entries (NFR-002) will be validated using the seed tool plus manual or automated timing measurement.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Integration tests for key journeys J1 and J2 pass consistently (zero flaky failures across 5 consecutive runs).
- **SC-002**: All interactive controls across all four screens are announced correctly by screen readers, with zero unlabeled controls.
- **SC-003**: Zero HTTP client imports or network request code found in production source files via code audit.
- **SC-004**: All data persists correctly across app restart cycles with zero data loss incidents.
- **SC-005**: The seed tool populates 365 entries in under 5 seconds, and the Home and History screens render within 500 milliseconds afterward.
- **SC-006**: A release checklist is complete with all QA steps verified and known limitations documented.
