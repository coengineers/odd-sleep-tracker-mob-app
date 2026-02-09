# Tasks: Local Database & Repository Layer

**Input**: Design documents from `/specs/002-local-db-repository/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/sleep_entry_repository.md, quickstart.md

**Tests**: Included — spec SC-007 and Constitution Principle IV require unit tests covering all CRUD, validation, duration computation, and edge cases.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add drift dependencies and configure code generation

- [X] T001 Add drift, drift_flutter, uuid, path_provider dependencies to pubspec.yaml and run flutter pub get
- [X] T002 Create build.yaml at project root with drift options: store_date_time_values_as_text: true, case_from_dart_to_sql: snake_case, named_parameters: true, generate_manager: false

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Schema, domain model, validation, database class, and Riverpod provider — MUST complete before any user story

**Note**: US5 (Input Validation) is implemented here as it's a cross-cutting concern needed by all CRUD operations.

- [X] T003 [P] Define SleepEntries drift table with all columns, primary key, CHECK constraints, and indexes per data-model.md in lib/database/tables/sleep_entries.dart
- [X] T004 [P] Create domain types (CreateSleepEntryInput, UpdateSleepEntryInput, exception classes) and pure validation function (validateCreateInput, validateUpdateInput) in lib/models/sleep_entry_model.dart
- [X] T005 Create AppDatabase class with DriftDatabase annotation, schema version 1, migration strategy, production constructor (driftDatabase), and test constructor (forTesting) in lib/database/app_database.dart
- [X] T006 Run dart run build_runner build --delete-conflicting-outputs to generate lib/database/app_database.g.dart
- [X] T007 Create appDatabaseProvider (Riverpod Provider) with onDispose cleanup in lib/providers/database_providers.dart
- [X] T008 [P] Write validation unit tests in test/database/duration_computation_test.dart: duration computation for same-day, cross-midnight, boundary values (1 min, 1440 min), invalid ranges (0, negative, >1440), quality validation (0, 1, 5, 6), note length validation (280, 281), and wake_date derivation

**Checkpoint**: Foundation ready — drift table defined, code generated, validation tested, database class operational. User story CRUD methods can now be added.

---

## Phase 3: User Story 1 - Create a Sleep Entry (Priority: P1)

**Goal**: Users can create sleep entries with auto-generated ID, computed duration/wake_date, and timestamps. Cross-midnight sessions work correctly.

**Independent Test**: Create an entry via the repository, verify it returns with correct computed fields (id, duration_minutes, wake_date, created_at, updated_at).

### Tests for User Story 1

- [X] T009 [US1] Write create entry tests in test/database/sleep_entry_repository_test.dart: create with valid input returns complete SleepEntry with UUID id, correct duration_minutes, correct wake_date, and timestamps; create cross-midnight entry (23:30→07:30) returns duration=480 and wake_date=wake day; create with optional note stores and returns note; create with null note succeeds; create with invalid input throws InvalidTimeRangeException / InvalidQualityException / NoteTooLongException

### Implementation for User Story 1

- [X] T010 [US1] Implement createEntry(CreateSleepEntryInput) method on AppDatabase in lib/database/app_database.dart: validate input, generate UUID, compute duration_minutes and wake_date, set created_at/updated_at, insert into sleep_entries table, return complete SleepEntry
- [X] T011 [US1] Implement getEntryById(String id) method on AppDatabase in lib/database/app_database.dart: select by primary key, return SleepEntry or null
- [X] T012 [US1] Verify T009 tests pass — all create + getById tests green

**Checkpoint**: User Story 1 complete — entries can be created and retrieved by ID with all computed fields correct.

---

## Phase 4: User Story 2 - List Sleep Entries (Priority: P1)

**Goal**: Users can retrieve all entries (newest first), filter by date range, and paginate results. Empty database returns empty list.

**Independent Test**: Seed multiple entries across dates, verify list returns correct order, filtering, and pagination.

### Tests for User Story 2

- [X] T013 [US2] Write list entries tests in test/database/sleep_entry_repository_test.dart: list returns entries ordered by wake_ts descending; list with fromDate/toDate filters correctly; list with limit/offset paginates correctly; list on empty database returns empty list; list with only fromDate or only toDate works

### Implementation for User Story 2

- [X] T014 [US2] Implement listEntries({fromDate?, toDate?, limit?, offset?}) method on AppDatabase in lib/database/app_database.dart: build select query with optional where clauses on wake_date, order by wake_ts descending, apply limit/offset, return List<SleepEntry>
- [X] T015 [US2] Verify T013 tests pass — all list/filter/pagination tests green

**Checkpoint**: User Stories 1 AND 2 complete — entries can be created and listed with filtering and pagination.

---

## Phase 5: User Story 3 - Update a Sleep Entry (Priority: P2)

**Goal**: Users can update any field on an existing entry. Duration and wake_date are recomputed when times change. Updated_at is refreshed.

**Independent Test**: Create an entry, update fields (times, quality, note separately), verify stored entry reflects changes with correct recomputation.

### Tests for User Story 3

- [X] T016 [US3] Write update entry tests in test/database/sleep_entry_repository_test.dart: update wake_ts recomputes duration_minutes and wake_date; update only quality changes quality and updated_at, not duration; update note stores new note; update with invalid times throws InvalidTimeRangeException; update non-existent ID throws EntryNotFoundException; updated_at changes on every update; created_at does not change on update

### Implementation for User Story 3

- [X] T017 [US3] Implement updateEntry(String id, UpdateSleepEntryInput) method on AppDatabase in lib/database/app_database.dart: fetch existing entry (throw EntryNotFoundException if missing), merge patch fields with existing values, validate merged result, recompute duration_minutes and wake_date if times changed, set updated_at, update row, return complete SleepEntry
- [X] T018 [US3] Verify T016 tests pass — all update/recomputation/error tests green

**Checkpoint**: User Stories 1, 2, AND 3 complete — full create, list, update cycle works.

---

## Phase 6: User Story 4 - Delete a Sleep Entry (Priority: P2)

**Goal**: Users can permanently delete entries by ID. Deleting a non-existent ID is graceful (returns false).

**Independent Test**: Create an entry, delete it, verify it no longer appears in list. Delete non-existent ID returns false.

### Tests for User Story 4

- [X] T019 [US4] Write delete entry tests in test/database/sleep_entry_repository_test.dart: delete existing entry returns true and entry is removed from list; delete non-existent ID returns false; delete then getEntryById returns null

### Implementation for User Story 4

- [X] T020 [US4] Implement deleteEntry(String id) method on AppDatabase in lib/database/app_database.dart: delete from sleep_entries where id matches, return true if rows affected > 0, false otherwise
- [X] T021 [US4] Verify T019 tests pass — all delete tests green

**Checkpoint**: All user stories complete — full CRUD lifecycle works with validation and computed fields.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Verify all tests pass together, ensure no regressions, validate existing D0 tests still pass

- [X] T022 Run flutter test to verify ALL tests pass (D0 + D1) with zero failures
- [X] T023 Run flutter analyze to verify zero lint warnings across all new files
- [X] T024 Verify existing D0 tests in test/routing/ and test/screens/ still pass (no regressions from new dependencies)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (dependencies installed) — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Phase 2 (table + model + database class ready)
- **User Story 2 (Phase 4)**: Depends on Phase 2 (needs createEntry from US1 for seeding test data, but only the implementation, not the tests)
- **User Story 3 (Phase 5)**: Depends on Phase 2 + US1 implementation (needs existing entries to update)
- **User Story 4 (Phase 6)**: Depends on Phase 2 + US1 implementation (needs existing entries to delete)
- **Polish (Phase 7)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (Create)**: Can start immediately after Phase 2 — no dependencies on other stories
- **US2 (List)**: Can start after Phase 2 — uses createEntry to seed test data but doesn't depend on US1 tests passing
- **US3 (Update)**: Can start after Phase 2 + T010 (createEntry implementation) — needs entries to exist
- **US4 (Delete)**: Can start after Phase 2 + T010 (createEntry implementation) — needs entries to exist
- **US2, US3, US4 can proceed in parallel** once T010 (createEntry) is implemented

### Within Each User Story

- Tests written FIRST, expected to FAIL before implementation
- Implementation tasks in dependency order
- Verification that tests PASS after implementation
- Story complete before moving to next priority (or parallel if capacity allows)

### Parallel Opportunities

- T003 and T004 can run in parallel (different files: tables/ vs models/)
- T008 can run in parallel with T003/T004 (test file, no file conflicts)
- US2, US3, US4 can run in parallel after T010 completes (all write to different test groups in the same test file, but different methods in app_database.dart — serialise if single developer)

---

## Parallel Example: Phase 2 (Foundational)

```text
# These can run in parallel (different files):
Agent 1: T003 — lib/database/tables/sleep_entries.dart (drift table)
Agent 2: T004 — lib/models/sleep_entry_model.dart (domain types + validation)
Agent 3: T008 — test/database/duration_computation_test.dart (validation tests)

# Then sequential:
T005 — lib/database/app_database.dart (depends on T003 table definition)
T006 — build_runner (depends on T003 + T005)
T007 — lib/providers/database_providers.dart (depends on T005)
```

## Parallel Example: User Stories 2-4 (after US1 T010 done)

```text
# These user stories can run in parallel:
Agent 1: US2 — T013 → T014 → T015 (list entries)
Agent 2: US3 — T016 → T017 → T018 (update entries)
Agent 3: US4 — T019 → T020 → T021 (delete entries)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T008)
3. Complete Phase 3: User Story 1 — Create (T009–T012)
4. **STOP and VALIDATE**: Run tests, verify create + get works
5. This alone delivers a functional persistence layer for D2 Log Entry screen

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 (Create) → Test independently → MVP!
3. Add US2 (List) → Test independently → History screen can work
4. Add US3 (Update) → Test independently → Edit flow can work
5. Add US4 (Delete) → Test independently → Delete flow can work
6. Each story adds value without breaking previous stories

### Single Developer Strategy (Recommended)

Execute phases sequentially: 1 → 2 → 3 → 4 → 5 → 6 → 7. Within Phase 2, parallelise T003/T004/T008 if using agents.

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- All tests use in-memory SQLite via `NativeDatabase.memory(closeStreamsSynchronously: true)` — no device needed
- Commit after each phase completion (buildable + testable state per Constitution Principle V)
- Test file `test/database/sleep_entry_repository_test.dart` is shared across US1–US4 but test groups are independent
- Generated file `lib/database/app_database.g.dart` should be committed to version control
