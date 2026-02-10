# Tasks: Home + History Screens

**Input**: Design documents from `/specs/004-home-history-screens/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Included — the spec references test-driven quality (Constitution Principle IV) and the plan explicitly includes test files.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter mobile project**: `lib/` for source, `test/` for tests at repository root
- All paths relative to repo root: `/Users/edval/gitwork/coengineers/odd-mobile-apps/odd-sleep-tracker-mob-app/`

---

## Phase 1: Setup

**Purpose**: Add the new dependency and verify the existing D0/D1/D2 foundation is intact.

- [X] T001 Add `fl_chart` dependency to `pubspec.yaml` and run `flutter pub get`
- [X] T002 Run `flutter test` to verify all existing D0/D1/D2 tests pass on this branch
- [X] T003 Run `flutter analyze` to confirm zero warnings before starting D3 work

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the Riverpod providers that both screens depend on. These MUST be complete before any screen work begins.

**CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 Create `todaySummaryProvider` (`FutureProvider<SleepEntry?>`) in `lib/providers/home_providers.dart` — computes today's date string from `DateTime.now()`, calls `db.listEntries(fromDate: today, toDate: today, limit: 1)`, returns first entry or null
- [X] T005 Create `recentDurationsProvider` (`FutureProvider<List<({String date, int durationMinutes})>>`) in `lib/providers/home_providers.dart` — queries last 7 days of entries, groups by `wakeDate` (latest `wakeTs` per day), fills missing days with 0, returns exactly 7 data points sorted oldest→newest
- [X] T006 Create `allEntriesProvider` (`FutureProvider<List<SleepEntry>>`) in `lib/providers/home_providers.dart` — calls `db.listEntries()` with no filters, returns all entries ordered by `wakeTs` descending
- [X] T007 Write unit tests for `todaySummaryProvider` in `test/providers/home_providers_test.dart` — test with 0 entries (returns null), 1 entry for today (returns it), multiple entries for today (returns latest wakeTs), entries only for past dates (returns null)
- [X] T008 Write unit tests for `recentDurationsProvider` in `test/providers/home_providers_test.dart` — test with empty DB (7 zero-duration points), full 7 days of data, gaps in data (missing days filled with 0), multiple entries per day (latest wakeTs used)
- [X] T009 Write unit tests for `allEntriesProvider` in `test/providers/home_providers_test.dart` — test with 0 entries (empty list), multiple entries (newest-first ordering)

**Checkpoint**: All 3 providers implemented and tested. Screen work can now begin.

---

## Phase 3: User Story 1 — View Today's Sleep Summary on Home (Priority: P1) MVP

**Goal**: Home screen shows today's sleep summary (duration in "Xh Ym" format, quality rating 1–5) and a mini 7-day bar chart. When no entry exists for today, a "No sleep logged for today" message is shown with a CTA.

**Independent Test**: Seed an in-memory DB with an entry whose wake date = today. Open Home. Verify duration, quality, and mini chart are displayed.

### Implementation for User Story 1

- [X] T010 [P] [US1] Create `MiniDurationChart` widget in `lib/widgets/mini_duration_chart.dart` — accepts `List<({String date, int durationMinutes})>`, renders 7 bars using `fl_chart` `BarChart`, brand orange bars (`colorScheme.primary`), day-of-week labels on x-axis, dark surface background, non-interactive, fixed height ~120px
- [X] T011 [P] [US1] Write widget tests for `MiniDurationChart` in `test/widgets/mini_duration_chart_test.dart` — renders without errors with valid 7-point data, renders with all-zero data, verify 7 bars present (find `BarChart` widget)
- [X] T012 [US1] Replace `lib/screens/home_screen.dart` with full implementation — convert to `ConsumerWidget`, watch `todaySummaryProvider` and `recentDurationsProvider`, display today's summary card (duration formatted as "Xh Ym", quality rating), embed `MiniDurationChart` below summary, show loading state while data fetches, show "No sleep logged for today" with "Log sleep" CTA button when no today entry (but still show chart with historical data), "Log sleep" CTA navigates via `context.push('/log')`, invalidate `todaySummaryProvider` and `recentDurationsProvider` after returning from push
- [X] T013 [US1] Write widget tests for Home screen in `test/screens/home_screen_test.dart` — test summary display with seeded today entry (verify duration text, quality rating visible), test no-today-entry state shows "No sleep logged for today" + CTA, test "Log sleep" CTA navigates to `/log`, test mini chart renders with data, test loading state shows progress indicator

**Checkpoint**: Home screen is fully functional — shows today's summary, mini chart, and handles no-data state. Independently testable.

---

## Phase 4: User Story 2 — Browse Sleep History (Priority: P1)

**Goal**: History screen displays all sleep entries in a virtualised list (newest-first), showing wake date, sleep duration, and quality for each. Handles 365+ entries smoothly.

**Independent Test**: Seed multiple entries across different dates. Open History. Verify entries appear newest-first with correct data.

### Implementation for User Story 2

- [X] T014 [US2] Replace `lib/screens/history_screen.dart` with full implementation — convert to `ConsumerStatefulWidget`, watch `allEntriesProvider`, render entries in `ListView.builder` (virtualised), each entry tile shows: wake date (formatted via `intl`, e.g., "Sat 8 Feb"), duration ("Xh Ym"), quality rating (1–5), use brand-compliant card styling (`colorScheme.surface` background, `colorScheme.outline` border, 12px radius), show loading state while data fetches, tap entry navigates to edit (placeholder — will be connected in US5)
- [X] T015 [US2] Write widget tests for History screen in `test/screens/history_screen_test.dart` — test list renders seeded entries in newest-first order, test each entry tile shows date/duration/quality, test loading state shows progress indicator, test with 0 entries (will be handled by US4 empty state — for now verify no crash)

**Checkpoint**: History screen shows entries in a scrollable, virtualised list. Independently testable.

---

## Phase 5: User Story 3 — Delete an Entry from History (Priority: P2)

**Goal**: Users can swipe an entry in History to delete it. A confirmation dialog appears first. After confirming, a SnackBar with Undo is shown for 5 seconds. Tapping Undo re-inserts the entry.

**Independent Test**: Seed an entry, swipe to delete, confirm, verify removal. Tap Undo within 5 seconds, verify restoration.

### Implementation for User Story 3

- [X] T016 [US3] Add swipe-to-delete to History screen in `lib/screens/history_screen.dart` — wrap each entry tile in `Dismissible` with `direction: DismissDirection.endToStart`, red background with delete icon, `confirmDismiss` shows `AlertDialog` ("Delete this entry?" with Cancel/Delete buttons), on confirm: store deleted `SleepEntry` in local variable, call `db.deleteEntry(id)`, remove from local list, show `SnackBar` with 5-second duration and "Undo" action, on Undo: call `db.createEntry()` with original entry's bedtime/wake/quality/note to re-insert, invalidate `allEntriesProvider`, `todaySummaryProvider`, `recentDurationsProvider`, on cancel: return false to keep entry in place
- [X] T017 [US3] Write widget tests for delete/undo flow in `test/screens/history_screen_test.dart` — test swipe shows red background, test confirm dialog appears, test cancel keeps entry, test confirm removes entry from list, test SnackBar appears with Undo action, test Undo re-inserts entry (verify entry reappears in list)

**Checkpoint**: Delete with undo works end-to-end. Independently testable.

---

## Phase 6: User Story 4 — Empty States for Home and History (Priority: P2)

**Goal**: When no entries exist, Home shows "No sleep logged yet" with a prominent "Log sleep" CTA. History shows a similar empty state. CTAs navigate to the Log Entry screen in create mode.

**Independent Test**: Use an empty database. Open Home and History. Verify empty state messages and CTA navigation.

### Implementation for User Story 4

- [X] T018 [P] [US4] Add full empty state to Home screen in `lib/screens/home_screen.dart` — when `todaySummaryProvider` returns null AND `recentDurationsProvider` returns all-zero (no data at all), show "No sleep logged yet. Add last night's sleep to start tracking." with a prominent "Log sleep" `ElevatedButton`, button navigates via `context.push('/log')`, style per brand (Nunito body text, brand orange CTA button)
- [X] T019 [P] [US4] Add empty state to History screen in `lib/screens/history_screen.dart` — when `allEntriesProvider` returns empty list, show "No entries yet" message with a "Log sleep" `ElevatedButton`, button navigates via `context.push('/log')`
- [X] T020 [US4] Write widget tests for empty states in `test/screens/home_screen_test.dart` and `test/screens/history_screen_test.dart` — test Home empty state shows message + CTA with empty DB, test History empty state shows message + CTA with empty DB, test CTA buttons navigate to `/log`

**Checkpoint**: Both screens handle the no-data case gracefully. Independently testable.

---

## Phase 7: User Story 5 — Navigate from History to Edit (Priority: P2)

**Goal**: Tapping an entry in History navigates to the Log Entry screen in edit mode (pre-populated with that entry's data). Returning from edit refreshes the History list.

**Independent Test**: Seed an entry. Tap it in History. Verify Log Entry opens in edit mode. Edit and save. Return to History and verify updated values.

### Implementation for User Story 5

- [X] T021 [US5] Connect tap-to-edit in History screen in `lib/screens/history_screen.dart` — wrap entry tile in `InkWell` or `GestureDetector` (if not already tappable), `onTap` calls `context.push('/log?id=${entry.id}')`, after push completes (await the Future), invalidate `allEntriesProvider`, `todaySummaryProvider`, `recentDurationsProvider` to refresh data
- [X] T022 [US5] Write widget tests for tap-to-edit navigation in `test/screens/history_screen_test.dart` — test tapping an entry navigates to `/log?id=<entry-id>`, test data refreshes after returning from edit (mock or verify provider invalidation)

**Checkpoint**: Full edit workflow from History works. Independently testable.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final integration, accessibility, and quality checks across all stories.

- [X] T023 Update `ShellScaffold` FAB in `lib/widgets/shell_scaffold.dart` if needed — ensure that after the FAB's `context.push('/log')` completes, providers are invalidated so Home and History refresh (may require converting to `ConsumerWidget` or passing a callback)
- [X] T024 Verify accessibility across both screens — semantic labels on all interactive elements (entry tiles, CTA buttons, chart), confirm 44×44px touch targets on list items and buttons, test with `Semantics` assertions in widget tests
- [X] T025 Run full test suite: `flutter test` — all D0/D1/D2/D3 tests must pass
- [X] T026 Run `flutter analyze` — zero warnings required
- [ ] T027 Manual smoke test: run app on simulator, verify Home shows summary + chart with seeded data, verify History lists entries, verify delete/undo flow, verify empty states, verify edit navigation from History

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (fl_chart added). BLOCKS all user stories.
- **User Story 1 (Phase 3)**: Depends on Phase 2 (providers). Can start immediately after.
- **User Story 2 (Phase 4)**: Depends on Phase 2 (providers). Can start in parallel with US1.
- **User Story 3 (Phase 5)**: Depends on Phase 4 (US2 — History screen must exist for delete to be added).
- **User Story 4 (Phase 6)**: Depends on Phase 3 (US1 — Home screen) AND Phase 4 (US2 — History screen). Both screens must exist to add empty states.
- **User Story 5 (Phase 7)**: Depends on Phase 4 (US2 — History screen must exist for tap-to-edit).
- **Polish (Phase 8)**: Depends on all user stories being complete.

### User Story Dependencies

```
Phase 1: Setup
    │
    ▼
Phase 2: Foundational (providers)
    │
    ├──────────────────┐
    ▼                  ▼
Phase 3: US1         Phase 4: US2
(Home screen)        (History screen)
    │                  │
    │    ┌─────────────┼──────────────┐
    │    ▼             ▼              ▼
    │  Phase 5: US3  Phase 7: US5  Phase 6: US4
    │  (Delete/undo) (Tap-to-edit) (Empty states)
    │    │             │           ← also depends on US1
    │    │             │              │
    ▼    ▼             ▼              ▼
Phase 8: Polish (all stories complete)
```

### Within Each User Story

- Tests can be written alongside implementation (same task or parallel)
- Widget implementation before widget tests is acceptable (test the rendered output)
- Provider tests (Phase 2) MUST pass before screen work begins

### Parallel Opportunities

**Phase 2 (Foundational)**:
- T004, T005, T006 can be written in the same file but are sequential within it
- T007, T008, T009 can be written in the same test file but are sequential within it

**Phase 3 + Phase 4 (US1 + US2)** — after Phase 2 completes:
- T010, T011 (mini chart) can run in parallel with T014 (History screen)
- US1 (Home) and US2 (History) can be implemented in parallel by different developers

**Phase 5, 6, 7 (US3, US4, US5)** — after their dependencies:
- T018 and T019 (empty states for Home and History) can run in parallel

---

## Parallel Example: Phase 3 + Phase 4

```bash
# After Phase 2 completes, launch US1 and US2 in parallel:

# Developer A (US1 - Home):
Task: "T010 Create MiniDurationChart widget in lib/widgets/mini_duration_chart.dart"
Task: "T011 Write widget tests for MiniDurationChart in test/widgets/mini_duration_chart_test.dart"
Task: "T012 Replace lib/screens/home_screen.dart with full implementation"
Task: "T013 Write widget tests for Home screen in test/screens/home_screen_test.dart"

# Developer B (US2 - History):
Task: "T014 Replace lib/screens/history_screen.dart with full implementation"
Task: "T015 Write widget tests for History screen in test/screens/history_screen_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational providers (T004–T009)
3. Complete Phase 3: User Story 1 — Home screen (T010–T013)
4. **STOP and VALIDATE**: Home screen shows today's summary + mini chart
5. Demo-ready with a functional Home dashboard

### Incremental Delivery

1. Setup + Foundational → Providers ready
2. Add US1 (Home) → Test independently → Demo (MVP!)
3. Add US2 (History list) → Test independently → Demo
4. Add US3 (Delete/undo) → Test independently → Demo
5. Add US4 (Empty states) → Test independently → Demo
6. Add US5 (Tap-to-edit) → Test independently → Demo
7. Polish → Full test pass → Release-ready

### Suggested Commit Points

- After T003: "Add fl_chart dependency and verify existing tests"
- After T009: "Implement Home/History Riverpod providers with tests"
- After T013: "Implement Home screen with today summary and mini chart"
- After T015: "Implement History screen with virtualised entry list"
- After T017: "Add swipe-to-delete with undo to History"
- After T020: "Add empty states to Home and History screens"
- After T022: "Connect tap-to-edit navigation from History"
- After T027: "Polish, accessibility, and full test pass"

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- No database schema changes needed — existing D1 `listEntries()` handles all queries
- `fl_chart` is the only new dependency (pure-Dart, no network, constitution-compliant)
- Undo re-inserts via `createEntry()` with original data (new UUID/timestamps — acceptable)
- Provider invalidation via `ref.invalidate()` after navigation returns or delete/undo actions
- All widget tests use `ProviderScope` with `appDatabaseProvider.overrideWithValue(db)` and `AppDatabase.forTesting(NativeDatabase.memory())` — same pattern as D2 tests
