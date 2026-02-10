# Tasks: D5 — Polish, QA & Release Readiness

**Input**: Design documents from `/specs/006-polish-qa-release/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Integration tests and unit tests ARE included as they are explicitly required by the feature specification (FR-001, FR-002, FR-008).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Mobile (Flutter)**: `lib/` for source, `test/` for unit/widget tests, `integration_test/` for E2E tests, `docs/` for documentation

---

## Phase 1: Setup

**Purpose**: Add integration_test dependency and create directory structure for new files

- [x] T001 Add `integration_test` Flutter SDK dev dependency to `pubspec.yaml` and run `flutter pub get`
- [x] T002 Create directory structure: `integration_test/`, `lib/dev/`, `test/dev/`
- [x] T003 Verify all existing tests still pass by running `flutter test`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create shared test utilities needed by multiple user stories

**⚠️ CRITICAL**: Integration test utilities (US1, US2) and seed tool (US5) both need to be built before their consumer stories

- [x] T004 Create integration test app builder utility in `integration_test/app_test_utils.dart` — provides `buildIntegrationTestApp()` function wrapping `ProviderScope` with `appDatabaseProvider.overrideWithValue(db)` and `MaterialApp.router` with `createRouter()` and `AppTheme.dark`, plus a `seedTestEntries()` helper for creating entries via `AppDatabase.createEntry()`

**Checkpoint**: Foundation ready — user story implementation can begin

---

## Phase 3: User Story 1 - End-to-End Sleep Logging Journey (Priority: P1) 🎯 MVP

**Goal**: Automated integration test verifying the complete J1 journey: fresh app → empty state → log sleep → Home summary → History list → Insights charts

**Independent Test**: Run `flutter test integration_test/journey_log_sleep_test.dart` — test passes on emulator/simulator

### Implementation for User Story 1

- [x] T005 [US1] Create J1 integration test in `integration_test/journey_log_sleep_test.dart` — test opens app with empty DB, verifies empty state CTA on Home, taps "Log sleep", enters bedtime/wake time via time pickers, selects quality rating, saves entry, verifies Home shows today's summary (duration + quality), navigates to History tab and verifies entry appears with correct date/duration/quality, navigates to Insights tab and verifies charts render without errors. Use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` and `buildIntegrationTestApp()` from `app_test_utils.dart`

**Checkpoint**: J1 journey has automated E2E coverage — the core happy path is verified

---

## Phase 4: User Story 2 - Edit and Delete Journey (Priority: P1)

**Goal**: Automated integration test verifying J2 journey: edit existing entry → save → verify update, swipe-to-delete → confirm → verify removal → undo → verify restoration

**Independent Test**: Run `flutter test integration_test/journey_edit_delete_test.dart` — test passes on emulator/simulator

### Implementation for User Story 2

- [x] T006 [US2] Create J2 integration test in `integration_test/journey_edit_delete_test.dart` — test pre-seeds 2 entries via `seedTestEntries()`, navigates to History, taps first entry to edit, changes quality rating, saves, verifies updated quality in History. Then swipes second entry to delete, confirms in dialog, verifies entry removed from list and Undo SnackBar appears, taps Undo within timeout, verifies entry is restored. Use `buildIntegrationTestApp()` from `app_test_utils.dart`

**Checkpoint**: J1 and J2 journeys both have automated E2E coverage

---

## Phase 5: User Story 3 - Offline Operation Verification (Priority: P1)

**Goal**: Verify zero network code exists in production source files through automated code audit

**Independent Test**: Run `flutter test test/audit/network_audit_test.dart` — test passes confirming no network imports

### Implementation for User Story 3

- [x] T007 [US3] Create network audit test in `test/audit/network_audit_test.dart` — test scans all `.dart` files under `lib/` for prohibited imports (`dart:io` HttpClient, `package:http`, `package:dio`, any URL patterns `http://`/`https://`) and fails if any are found. Also verify `pubspec.yaml` has no network-capable runtime dependencies. Use `dart:io` File/Directory to scan the source tree

**Checkpoint**: Zero-network compliance is automatically verified on every test run

---

## Phase 6: User Story 4 - Accessibility for Screen Reader Users (Priority: P2)

**Goal**: Add Semantics wrappers to all interactive controls, charts, and state indicators across all screens so screen readers announce meaningful labels

**Independent Test**: Run `flutter test` — existing widget tests still pass; enable TalkBack/VoiceOver on device and navigate all 4 screens to confirm all controls are announced

### Implementation for User Story 4

- [x] T008 [P] [US4] Add `tooltip: 'Log sleep'` to FloatingActionButton in `lib/widgets/shell_scaffold.dart`
- [x] T009 [P] [US4] Add Semantics wrappers to Home screen loading and error states in `lib/screens/home_screen.dart` — wrap `CircularProgressIndicator` with `Semantics(label: 'Loading sleep data')`, wrap error text with `Semantics(label: 'Error loading data')`
- [x] T010 [P] [US4] Add Semantics to History screen in `lib/screens/history_screen.dart` — wrap each `_EntryTile` in `Semantics(label: 'Sleep entry for [date], [duration], Quality [N] of 5')` with dynamic values; add `Semantics(label: 'Loading history')` to loading state; add `Semantics(label: 'Error loading history')` to error state
- [x] T011 [P] [US4] Add Semantics to Insights screen in `lib/screens/insights_screen.dart` — add `Semantics(label: 'Loading insights')` to loading state; add `Semantics(label: 'Error loading insights')` to error state; add descriptive labels to chart card containers (e.g., `Semantics(label: 'Sleep duration chart for the last 7 days')`)
- [x] T012 [P] [US4] Add Semantics wrapper with dynamic data summary to `lib/widgets/mini_duration_chart.dart` — wrap `BarChart` in `Semantics(label: 'Last 7 days sleep duration chart. [computed summary from data]')` using `ExcludeSemantics` on the chart child to avoid duplicate announcements
- [x] T013 [P] [US4] Add Semantics wrapper with dynamic data summary to `lib/widgets/duration_bar_chart.dart` — wrap `BarChart` in `Semantics(label: 'Sleep duration bar chart for the last 7 days. [computed summary]')` with `ExcludeSemantics` on child
- [x] T014 [P] [US4] Add Semantics wrapper with dynamic data summary to `lib/widgets/quality_line_chart.dart` — wrap `LineChart` in `Semantics(label: 'Quality trend line chart for the last 30 days. [computed summary]')` with `ExcludeSemantics` on child
- [x] T015 [P] [US4] Add Semantics label to pattern summary card container in `lib/widgets/pattern_summary_card.dart` — wrap card in `Semantics(label: 'Sleep patterns summary')`
- [x] T016 [P] [US4] Replace hardcoded `fontSize: 16` in `lib/widgets/quality_selector.dart` with `Theme.of(context).textTheme.bodyMedium` to respect system text scaling
- [x] T017 [US4] Run `flutter test` to verify all existing widget tests pass with the new Semantics wrappers and font size change

**Checkpoint**: All interactive controls across all screens are announced by screen readers

---

## Phase 7: User Story 5 - Developer Seed Data Tool (Priority: P2)

**Goal**: Dev-only tool to populate database with realistic sample entries, triggered by long-press on Home screen title, guarded by `kDebugMode`

**Independent Test**: Run `flutter test test/dev/seed_data_test.dart` — unit tests pass; run app in debug mode, long-press "SleepLog" title, verify entries appear in History

### Implementation for User Story 5

- [x] T018 [P] [US5] Create `seedSampleEntries()` function in `lib/dev/seed_data.dart` — async function accepting `AppDatabase db` and optional `int days = 90`, generates one entry per day going back from today using `db.createEntry()` with randomised bedtime (21:00–23:59), duration (300–600 min), quality (1–5), and ~30% chance of a note from a predefined list. Uses `dart:math` Random. Returns `List<SleepEntry>`
- [x] T019 [P] [US5] Create unit tests for seed tool in `test/dev/seed_data_test.dart` — test that `seedSampleEntries(db, days: 7)` creates exactly 7 entries with valid durations (300–600), quality (1–5), and varied wake dates spanning 7 days. Test default of 90 days. Test that entries are additive (calling twice doubles count). Use `AppDatabase.forTesting(NativeDatabase.memory())`
- [x] T020 [US5] Add long-press seed trigger to Home screen AppBar title in `lib/screens/home_screen.dart` — wrap "SleepLog" title text in `GestureDetector` with `onLongPress` callback, guarded by `if (kDebugMode)`. On trigger: read `AppDatabase` from `ref.read(appDatabaseProvider)`, call `seedSampleEntries(db)`, show SnackBar "Seeding 90 days of sample data..." then "Done! Added N entries." on completion. Import `package:flutter/foundation.dart` for `kDebugMode`
- [x] T021 [US5] Run `flutter test test/dev/seed_data_test.dart` to verify seed tool tests pass

**Checkpoint**: Developers can quickly populate realistic test data in debug builds

---

## Phase 8: User Story 6 - Data Integrity Across App Restarts (Priority: P2)

**Goal**: Verify data persistence survives app restarts — covered by existing integration tests (create → verify) and existing repository tests (CRUD operations use real SQLite)

**Independent Test**: Existing test coverage already validates this — `test/database/sleep_entry_repository_test.dart` tests create/update/delete with real in-memory SQLite, and integration tests (US1, US2) verify end-to-end data flow

### Implementation for User Story 6

- [x] T022 [US6] Add explicit data persistence verification to J1 integration test in `integration_test/journey_log_sleep_test.dart` — after creating an entry and navigating away, navigate back to Home and verify the entry still appears (simulates within-session persistence). Add a comment documenting that cross-restart persistence is guaranteed by SQLite/drift and verified by repository unit tests

**Checkpoint**: Data integrity is documented and verified through existing + enhanced test coverage

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Release documentation, final verification, and cleanup

- [x] T023 Create release checklist document at `docs/release-checklist.md` with sections: (1) Pre-release QA steps — manual verification checklist for J1, J2, J3 journeys, (2) Automated test gates — `flutter test`, `flutter test integration_test/`, `flutter analyze` commands, (3) Known limitations — DST behaviour (duration may vary ±60min), multiple entries per day allowed, no cloud sync/backup, no accounts, (4) Build instructions — `flutter build apk --release` and `flutter build ios --release --no-codesign`, (5) Accessibility verification — manual TalkBack/VoiceOver walkthrough steps for each screen, (6) Privacy verification — confirm zero network calls via code audit test
- [x] T024 Run full test suite: `flutter test` (unit/widget) + `flutter test integration_test/` (E2E) + `flutter analyze` (zero warnings)
- [x] T025 Verify release build compiles without errors: `flutter build apk --release` to confirm no debug-only code leaks into production

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS integration test stories (US1, US2)
- **US1 (Phase 3)**: Depends on Phase 2 (needs `app_test_utils.dart`)
- **US2 (Phase 4)**: Depends on Phase 2 (needs `app_test_utils.dart`)
- **US3 (Phase 5)**: Depends on Phase 1 only (no shared utilities needed)
- **US4 (Phase 6)**: Depends on Phase 1 only (no shared utilities needed)
- **US5 (Phase 7)**: Depends on Phase 1 only (no shared utilities needed)
- **US6 (Phase 8)**: Depends on US1 (Phase 3) — enhances J1 integration test
- **Polish (Phase 9)**: Depends on all previous phases

### User Story Dependencies

- **US1 (P1)**: Depends on Foundational (Phase 2) — no other story dependencies
- **US2 (P1)**: Depends on Foundational (Phase 2) — no other story dependencies
- **US3 (P1)**: Independent — can start after Phase 1
- **US4 (P2)**: Independent — can start after Phase 1 (all file modifications are in separate files)
- **US5 (P2)**: Independent — can start after Phase 1
- **US6 (P2)**: Depends on US1 — adds to the J1 integration test file

### Within Each User Story

- US1: Single test file task — no internal parallelism
- US2: Single test file task — no internal parallelism
- US3: Single test file task — no internal parallelism
- US4: All [P] tasks can run in parallel (different files, no dependencies)
- US5: T018 and T019 can run in parallel (different files), then T020 depends on T018, then T021 depends on T019 + T020
- US6: Single task — depends on US1 completion

### Parallel Opportunities

After Phase 2 completes, the following can all run in parallel:
- US1 (J1 integration test)
- US2 (J2 integration test)
- US3 (network audit test)
- US4 (accessibility — all 10 tasks in parallel across different files)
- US5 (seed tool — T018 + T019 in parallel)

---

## Parallel Example: User Story 4 (Accessibility)

```bash
# All accessibility tasks target different files and can run simultaneously:
Task: "T008 — Add FAB tooltip in lib/widgets/shell_scaffold.dart"
Task: "T009 — Add Semantics to Home screen in lib/screens/home_screen.dart"
Task: "T010 — Add Semantics to History screen in lib/screens/history_screen.dart"
Task: "T011 — Add Semantics to Insights screen in lib/screens/insights_screen.dart"
Task: "T012 — Add Semantics to mini_duration_chart.dart"
Task: "T013 — Add Semantics to duration_bar_chart.dart"
Task: "T014 — Add Semantics to quality_line_chart.dart"
Task: "T015 — Add Semantics to pattern_summary_card.dart"
Task: "T016 — Replace hardcoded fontSize in quality_selector.dart"
```

## Parallel Example: User Story 5 (Seed Tool)

```bash
# Create seed function and tests in parallel (different files):
Task: "T018 — Create seedSampleEntries() in lib/dev/seed_data.dart"
Task: "T019 — Create unit tests in test/dev/seed_data_test.dart"

# Then wire up the trigger (depends on T018):
Task: "T020 — Add long-press trigger in lib/screens/home_screen.dart"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (app_test_utils.dart)
3. Complete Phase 3: US1 — J1 integration test
4. Complete Phase 4: US2 — J2 integration test
5. **STOP and VALIDATE**: Both journey tests pass consistently
6. This gives automated E2E coverage of the two most critical user paths

### Incremental Delivery

1. Setup + Foundational → Test utilities ready
2. Add US1 (J1 test) → Validate → Core happy path covered
3. Add US2 (J2 test) → Validate → Edit/delete path covered
4. Add US3 (network audit) → Validate → Privacy compliance automated
5. Add US4 (accessibility) → Validate → Screen reader support complete
6. Add US5 (seed tool) → Validate → Dev QA tooling ready
7. Add US6 (data integrity) → Validate → Persistence documented
8. Polish → Release checklist + final verification

### Parallel Team Strategy

With multiple developers after Phase 2:
- Developer A: US1 + US2 (integration tests — same test utilities)
- Developer B: US4 (accessibility — 10 parallel file modifications)
- Developer C: US3 + US5 (network audit + seed tool — independent)
- All reconvene for US6 + Polish

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- US4 (accessibility) has the most parallel opportunity — 9 files can be modified simultaneously
- US1 + US2 share `app_test_utils.dart` but write to separate test files — can run in parallel after Phase 2
- Integration tests require a running emulator/simulator — `flutter test integration_test/`
