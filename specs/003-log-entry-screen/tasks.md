# Tasks: Log Entry Screen (Create/Edit)

**Input**: Design documents from `/specs/003-log-entry-screen/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/log-entry-screen-contract.md, quickstart.md

**Tests**: Included — Constitution Principle IV (Test-Driven Quality) requires automated tests for acceptance criteria. Plan.md confirms widget tests for all form states.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Verify prerequisites and ensure branch is ready for development

- [x] T001 Verify D0+D1 prerequisites: run `flutter test` to confirm all existing tests pass, run `flutter analyze` to confirm zero warnings
- [x] T002 Verify branch `003-log-entry-screen` is checked out and based on latest `main` with D0+D1 merged

**Checkpoint**: Branch ready, all existing tests green

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared infrastructure that ALL user stories depend on — theme extension and reusable widget

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Add `InputDecorationTheme` to `AppTheme.dark` in `lib/theme/app_theme.dart` — filled=true, fillColor=surface (`#1A1B1F`), border=OutlineInputBorder with 12px radius and outline colour (`#23283A`), focusedBorder with primary colour (`#F7931A`), errorBorder with error colour (`#EF4444`), contentPadding=EdgeInsets.symmetric(horizontal: 16, vertical: 14) for 44px min height, hintStyle with muted colour (`#6E748A`). See research.md R6 for full token mapping
- [x] T004 [P] Create `QualitySelector` widget in `lib/widgets/quality_selector.dart` — stateless widget with `int? value` and `ValueChanged<int> onChanged` props. Render horizontal row of 5 tappable items (1–5). Selected item: primary fill (`#F7931A`) with onPrimary text (black). Unselected: surface fill with outline border and onSurface text. Min 44x44px touch targets. Add semantic labels: "Quality N of 5" with selected/unselected state. See research.md R3 and contracts/log-entry-screen-contract.md Accessibility Contract
- [x] T005 [P] Create widget tests for `QualitySelector` in `test/widgets/quality_selector_test.dart` — test: renders 5 items with numbers 1–5; test: tapping item 3 calls onChanged(3); test: selected item (value=4) has primary colour; test: no item selected when value=null; test: each item has semantic label. Use `ProviderScope` + `MaterialApp` + `AppTheme.dark` wrapper
- [x] T006 Create `sleepEntryProvider` in `lib/providers/log_entry_providers.dart` — `FutureProvider.family<SleepEntry?, String>` that reads `appDatabaseProvider` and calls `getEntryById(id)`. Import `AppDatabase` from `lib/database/app_database.dart` and `appDatabaseProvider` from `lib/providers/database_providers.dart`. See research.md R5

**Checkpoint**: Foundation ready — InputDecorationTheme applied, QualitySelector widget tested, entry provider available. User story implementation can now begin.

---

## Phase 3: User Story 1 — Log a New Sleep Entry (Priority: P1) MVP

**Goal**: User can open Log Entry screen, pick bedtime/wake time, select quality 1–5, and save a new entry that persists locally. Screen pops back on success.

**Independent Test**: Navigate to `/log`, fill bedtime/wake/quality, tap Save, verify entry exists in database and screen pops back.

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T007 [US1] Write widget tests for create mode in `test/screens/log_entry_screen_test.dart` — replace existing placeholder tests. Setup: create GoRouter with `/log` route, `ProviderScope` with `appDatabaseProvider` overridden to in-memory DB (`AppDatabase.forTesting(NativeDatabase.memory())`), `MaterialApp.router` with `AppTheme.dark`. Tests: (1) screen shows "Log Entry" title in create mode; (2) screen renders bedtime picker row with default "yesterday 22:00" label; (3) screen renders wake time picker row with default "today 07:00" label; (4) screen renders QualitySelector with no selection; (5) screen renders Save button; (6) tapping Save without selecting quality shows "Please select a quality rating." error. See quickstart.md Testing Pattern for setup boilerplate

### Implementation for User Story 1

- [x] T008 [US1] Implement `LogEntryScreen` create mode in `lib/screens/log_entry_screen.dart` — replace placeholder `StatelessWidget` with `ConsumerStatefulWidget`. State fields: `DateTime? _bedtime` (default yesterday 22:00), `DateTime? _wakeTime` (default today 07:00), `int? _quality` (null), `String _note` (""), `bool _isSaving` (false), `String? _errorMessage`, `String? _durationError`, `String? _qualityError`. Build method: Scaffold with AppBar (title "Log Entry" or "Edit Entry" based on `widget.entryId`), body=SingleChildScrollView with 24px padding containing: bedtime picker row, wake time picker row, computed duration display ("Xh Ym"), QualitySelector widget, Save ElevatedButton (full width). Bedtime/wake rows: tappable InkWell/GestureDetector showing formatted date+time (use `intl` DateFormat), on tap open `showDatePicker` then `showTimePicker`, update state and clear `_durationError`. Save button text: "Save". See contracts/log-entry-screen-contract.md for full layout specification
- [x] T009 [US1] Implement save flow for create mode in `lib/screens/log_entry_screen.dart` — `_onSave()` method: validate quality not null (set `_qualityError`), validate duration 1–1440 min (set `_durationError` with message "Wake time must be after bedtime (within 24 hours)."), if valid set `_isSaving=true`, call `ref.read(appDatabaseProvider).createEntry(CreateSleepEntryInput(bedtimeTs: _bedtime!, wakeTs: _wakeTime!, quality: _quality!, note: _note.isEmpty ? null : _note))`, on success call `context.pop()`, on `InvalidTimeRangeException` set `_durationError`, on other exception set `_errorMessage` to "Something went wrong. Please try again.", always set `_isSaving=false` in finally. Disable Save button when `_isSaving`. See research.md R4 and contracts/log-entry-screen-contract.md Save Contract
- [x] T010 [US1] Write widget test for successful save in `test/screens/log_entry_screen_test.dart` — test: select quality via QualitySelector tap, tap Save button, verify `context.pop()` was called (screen navigates back). Verify entry was created in in-memory DB by calling `db.listEntries()` and checking one entry exists with expected quality and default bedtime/wake times

**Checkpoint**: User Story 1 complete. User can create a new sleep entry with bedtime, wake time, and quality. Screen saves to DB and pops back. All create-mode tests pass.

---

## Phase 4: User Story 2 — Edit an Existing Sleep Entry (Priority: P2)

**Goal**: User navigates to `/log?id={entryId}`, screen loads existing entry, pre-populates all fields, user modifies values and saves update.

**Independent Test**: Create entry in DB, navigate to `/log?id={id}`, verify fields pre-populated, change quality, tap Update, verify entry updated in DB.

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T011 [US2] Write widget tests for edit mode in `test/screens/log_entry_screen_test.dart` — setup: create in-memory DB, insert test entry via `db.createEntry(CreateSleepEntryInput(...))`, create GoRouter with `/log?id={testEntryId}` as initial location. Tests: (1) screen shows "Edit Entry" title; (2) bedtime row displays the entry's bedtime formatted value; (3) wake time row displays the entry's wake time formatted value; (4) QualitySelector shows the entry's quality selected; (5) Save button text is "Update"; (6) loading state shows CircularProgressIndicator before entry loads

### Implementation for User Story 2

- [x] T012 [US2] Implement edit mode data loading in `lib/screens/log_entry_screen.dart` — in `initState` or via `ref.watch(sleepEntryProvider(widget.entryId!))`, when `entryId` is non-null: show loading indicator while fetching, on data received populate `_bedtime`, `_wakeTime`, `_quality`, `_note` from `SleepEntry` fields, on entry not found show error message and call `context.pop()` after brief delay. Set `_isLoading` state field to control loading indicator visibility. Change Save button text to "Update" when in edit mode. See research.md R5 and data-model.md State Transitions
- [x] T013 [US2] Implement save flow for edit mode in `lib/screens/log_entry_screen.dart` — modify `_onSave()`: when `widget.entryId != null`, call `ref.read(appDatabaseProvider).updateEntry(widget.entryId!, UpdateSleepEntryInput(bedtimeTs: _bedtime, wakeTs: _wakeTime, quality: _quality, note: _note.isEmpty ? null : _note, hasNote: true))`. On `EntryNotFoundException` set `_errorMessage` to "This entry was deleted." and call `context.pop()` after 2-second delay. See contracts/log-entry-screen-contract.md Save Contract (Edit Mode)
- [x] T014 [US2] Write widget test for successful edit save in `test/screens/log_entry_screen_test.dart` — test: insert entry with quality 3, open edit screen, tap quality 5 in QualitySelector, tap Update, verify entry in DB has quality 5 via `db.getEntryById()`. Test: verify bedtime and wake time are preserved when only quality changes

**Checkpoint**: User Story 2 complete. User can edit existing entries with pre-populated fields. Update saves correctly. All edit-mode tests pass.

---

## Phase 5: User Story 3 — Input Validation and Error Feedback (Priority: P2)

**Goal**: All invalid inputs are caught before save with clear inline error messages. Duration out of range and missing quality are the two validation paths.

**Independent Test**: On Log Entry screen, set identical bedtime/wake, tap Save, verify error message. Clear times, select quality only, tap Save, verify duration error. Set valid times but no quality, verify quality error.

### Tests for User Story 3

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T015 [US3] Write validation widget tests in `test/screens/log_entry_screen_test.dart` — tests: (1) when bedtime equals wake time and user taps Save, "Wake time must be after bedtime (within 24 hours)." error text is displayed; (2) when duration exceeds 24 hours and user taps Save, same error message displayed; (3) when quality not selected and user taps Save, "Please select a quality rating." error text is displayed; (4) when both duration invalid and quality missing, both error messages displayed simultaneously; (5) after fixing duration error (picking new wake time), error message clears before next save attempt; (6) after selecting quality, quality error message clears

### Implementation for User Story 3

- [x] T016 [US3] Ensure validation error display in `lib/screens/log_entry_screen.dart` — verify that `_durationError` is displayed below the wake time picker row using `Text` with `colorScheme.error` style. Verify `_qualityError` is displayed below the QualitySelector. Verify errors clear when user interacts with the relevant field (e.g., picking new time clears `_durationError`, selecting quality clears `_qualityError`). Verify `_errorMessage` (general save error) is displayed at the bottom of the form. Add `Semantics(liveRegion: true)` wrapper around error texts for accessibility. See contracts/log-entry-screen-contract.md Validation Contract
- [x] T017 [US3] Write edge case validation tests in `test/screens/log_entry_screen_test.dart` — tests: (1) cross-midnight entry (bedtime 23:30, wake 07:30) saves successfully with correct duration; (2) exactly 1-minute duration saves successfully; (3) exactly 1440-minute (24h) duration saves successfully; (4) Save button shows CircularProgressIndicator while `_isSaving` is true; (5) Save button is disabled while saving (prevent double-tap)

**Checkpoint**: User Story 3 complete. All validation paths produce correct inline errors. Edge cases handled. Validation tests pass.

---

## Phase 6: User Story 4 — Add an Optional Note (Priority: P3)

**Goal**: User can add an optional text note (max 280 chars) when creating or editing a sleep entry. Note persists and is visible on re-edit.

**Independent Test**: Create entry with note text, re-open in edit mode, verify note field shows the saved text.

### Tests for User Story 4

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T018 [US4] Write note field widget tests in `test/screens/log_entry_screen_test.dart` — tests: (1) note field is present with "Note (optional)" label; (2) note field has maxLength 280 and shows character counter; (3) saving with note text persists note to DB (verify via `db.listEntries()`); (4) saving without note text persists null note; (5) edit mode pre-populates note field with existing entry's note; (6) note field allows multiline input (maxLines: 3)

### Implementation for User Story 4

- [x] T019 [US4] Add note field to `lib/screens/log_entry_screen.dart` — add `TextField` below QualitySelector with: label "Note (optional)" using `labelLarge` style, `maxLength: 280`, `maxLines: 3`, `decoration` from InputDecorationTheme (already configured in T003), character counter enabled, `TextEditingController` initialised from `_note`. Wire `_noteController.text` into save flow for both create and edit modes. In edit mode, initialise controller text from `entry.note ?? ""`. See contracts/log-entry-screen-contract.md UI Contract item 6

**Checkpoint**: User Story 4 complete. Optional note field works in both create and edit modes with character limit enforced. All note tests pass.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final verification, accessibility, and cleanup

- [x] T020 Add accessibility semantics to all interactive elements in `lib/screens/log_entry_screen.dart` — bedtime row: `Semantics(label: "Bedtime, [formatted]. Tap to change.")`, wake time row: `Semantics(label: "Wake time, [formatted]. Tap to change.")`, duration display: `Semantics(label: "Duration, X hours Y minutes")`, error texts: `Semantics(liveRegion: true)`. See contracts/log-entry-screen-contract.md Accessibility Contract
- [x] T021 [P] Run `flutter analyze` and fix any warnings or lint issues across all new and modified files
- [x] T022 [P] Run full test suite (`flutter test`) and verify all tests pass — existing D0/D1 tests plus all new D2 tests
- [x] T023 Run quickstart.md manual verification steps: (1) open app → tap FAB → Log Entry screen with defaults; (2) pick bedtime, wake time, quality → Save → returns to Home; (3) verify no console errors or warnings during operation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — verify prerequisites
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Foundational — MVP, must complete first
- **US2 (Phase 4)**: Depends on US1 (edit mode extends create mode screen)
- **US3 (Phase 5)**: Depends on US1 (validation is on the create screen)
- **US4 (Phase 6)**: Depends on US1 (note field is added to the create screen)
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (P1)**: Requires Foundational only — core create flow
- **US2 (P2)**: Requires US1 — edit mode extends the screen built in US1
- **US3 (P2)**: Requires US1 — validation logic is part of the screen built in US1
- **US4 (P3)**: Requires US1 — note field is added to the form built in US1

> **Note**: US2, US3, and US4 all depend on US1 but are independent of each other. After US1, they can theoretically proceed in parallel (different concerns on the same screen), but since they all modify `log_entry_screen.dart`, sequential execution is safer to avoid merge conflicts.

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Implementation before integration tests
- Story complete before moving to next priority

### Parallel Opportunities

Within Phase 2 (Foundational):
```
Parallel group: T004 (QualitySelector widget) + T005 (QualitySelector tests) + T006 (provider)
Sequential after: T003 (theme) — needed for widget styling
```

Within Phase 7 (Polish):
```
Parallel group: T021 (analyze) + T022 (test suite)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (verify prerequisites)
2. Complete Phase 2: Foundational (theme, widget, provider)
3. Complete Phase 3: User Story 1 (create entry)
4. **STOP and VALIDATE**: Test US1 independently — can create and save an entry
5. This alone delivers the core value of D2

### Incremental Delivery

1. Setup + Foundational → Infrastructure ready
2. Add US1 → Test independently → **MVP complete** (create entry)
3. Add US2 → Test independently → Edit entries work
4. Add US3 → Test independently → Validation comprehensive
5. Add US4 → Test independently → Note field available
6. Polish → All tests pass, accessibility verified

### Single Developer Strategy (Recommended)

Execute phases sequentially: 1 → 2 → 3 → 4 → 5 → 6 → 7. This is a single-screen feature modifying the same file, so sequential is safest.

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- All user stories modify `lib/screens/log_entry_screen.dart` — sequential execution recommended
- Existing D0/D1 code is NOT modified — all changes are additive
- Commit after each task or logical group per Constitution Principle V
- Constitution Principle IV mandates tests — they are included in every user story phase
- `intl` package is already in `pubspec.yaml` — no new dependencies needed
