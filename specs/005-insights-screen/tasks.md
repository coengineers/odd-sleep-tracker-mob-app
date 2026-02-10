# Tasks: Insights Screen (Charts + Summaries)

**Input**: Design documents from `/specs/005-insights-screen/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/insights-api.md

**Tests**: Included — constitution principle IV (Test-Driven Quality) requires automated tests for all deliverables.

**Organization**: Tasks grouped by user story. US1–US3 share foundational computation layer (Phase 2). US4 (empty state) is independent.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Verify existing infrastructure, create directory structure for new files

- [X] T001 Create `lib/services/` directory and verify existing dependencies (fl_chart ^1.1.1, intl ^0.20.0) are in `pubspec.yaml`
- [X] T002 Create `test/services/` and `test/providers/` directories for new test files

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared computation service and data provider that ALL user stories depend on

**CRITICAL**: No user story work can begin until this phase is complete

### Foundational Tests

- [X] T003 Write unit tests for `InsightsCalculator.computeDurationChart()` in `test/services/insights_calculator_test.dart` — test cases: 7 days all present, missing days zero-filled, multi-entry days summed, empty input returns 7 zeros, entries outside 7-day window excluded. Reference: data-model.md "Duration Aggregation" rules and contracts/insights-api.md `computeDurationChart` invariants
- [X] T004 Write unit tests for `InsightsCalculator.computeQualityChart()` in `test/services/insights_calculator_test.dart` — test cases: single entry per day, multi-entry days averaged to 1 decimal, only days with data included (no zero-fill), sorted oldest→newest, empty input returns empty list. Reference: data-model.md "Quality Aggregation" rules
- [X] T005 Write unit tests for `InsightsCalculator.computePatternSummary()` in `test/services/insights_calculator_test.dart` — test cases: avg duration 7d/30d computed correctly, avg quality 30d rounded to 1 decimal, bedtime consistency buckets (<15 "very consistent", 15–30 "fairly consistent", 30–60 "varies by about", 60+ "varies widely"), best/worst day by weekday average, single entry edge case, <2 entries shows "Not enough data for consistency". Reference: data-model.md "Bedtime Consistency" and "Best/Worst Day" rules

### Foundational Implementation

- [X] T006 Implement `QualityDataPoint` typedef and `PatternSummary` class in `lib/services/insights_calculator.dart` — define `typedef QualityDataPoint = ({String date, double averageQuality})` and `PatternSummary` class with fields: `avgDuration7d` (int), `avgDuration30d` (int), `avgQuality30d` (double), `consistencyText` (String), `bestDay` (String?), `worstDay` (String?). Import `DurationDataPoint` from `lib/providers/home_providers.dart`. Reference: data-model.md "New Computed Types"
- [X] T007 Implement `InsightsCalculator.computeDurationChart()` in `lib/services/insights_calculator.dart` — static method taking `List<SleepEntry>` and `DateTime today`. Filter to 7-day window (today - 6 days through today). Group by wakeDate, SUM durationMinutes per day. Return exactly 7 `DurationDataPoint`s sorted oldest→newest, zero-fill missing days. Reference: contracts/insights-api.md `computeDurationChart` contract
- [X] T008 Implement `InsightsCalculator.computeQualityChart()` in `lib/services/insights_calculator.dart` — static method taking `List<SleepEntry>` and `DateTime today`. Filter to 30-day window (today - 29 days through today). Group by wakeDate, MEAN quality per day rounded to 1 decimal. Return only days with data, sorted oldest→newest. Reference: contracts/insights-api.md `computeQualityChart` contract
- [X] T009 Implement `InsightsCalculator.computePatternSummary()` in `lib/services/insights_calculator.dart` — static method taking `List<SleepEntry>` and `DateTime today`. Compute: (a) avg duration 7d/30d from entry count not day count, (b) avg quality 30d to 1 decimal, (c) bedtime consistency via minutes-since-midnight stddev with cross-midnight normalisation (hour < 12 → add 1440), mapped to plain-language buckets per research.md R3/R6 thresholds, (d) best/worst day by grouping wakeTs weekday, averaging durationMinutes per weekday, using DateFormat.EEEE(). Return PatternSummary with null bestDay/worstDay if empty. Reference: data-model.md computation rules, research.md R3, R4
- [X] T010 Run `flutter test test/services/insights_calculator_test.dart` and verify all unit tests pass
- [X] T011 Write provider integration tests in `test/providers/insights_providers_test.dart` — use `AppDatabase.forTesting(NativeDatabase.memory())` with `appDatabaseProvider` override. Test: `insightsDataProvider` returns 30-day entries, `durationChartProvider` returns 7 items, `qualityChartProvider` returns only data days, `patternSummaryProvider` returns valid PatternSummary. Seed DB with known entries and assert computed values match expected. Follow test pattern from `test/screens/home_screen_test.dart` (setUp/tearDown DB lifecycle)
- [X] T012 Implement `insightsDataProvider` in `lib/providers/insights_providers.dart` — `FutureProvider<List<SleepEntry>>` that reads `appDatabaseProvider` and calls `db.listEntries(fromDate: thirtyDaysAgo, toDate: today)` where dates are formatted as YYYY-MM-DD strings. Follow date formatting pattern from `recentDurationsProvider` in `lib/providers/home_providers.dart`
- [X] T013 Implement derived providers (`durationChartProvider`, `qualityChartProvider`, `patternSummaryProvider`) in `lib/providers/insights_providers.dart` — each is a `FutureProvider` that reads `insightsDataProvider`, awaits the data, and calls the corresponding `InsightsCalculator` static method with `DateTime.now()` as today. Export `QualityDataPoint` and `PatternSummary` types. Reference: contracts/insights-api.md provider contracts
- [X] T014 Run `flutter test test/providers/insights_providers_test.dart` and verify all provider tests pass

**Checkpoint**: Computation layer and providers verified — user story widgets can now be built

---

## Phase 3: User Story 1 — View 7-Day Sleep Duration Chart (Priority: P1) MVP

**Goal**: Display a 7-day bar chart showing sleep duration per day on the Insights tab

**Independent Test**: Seed 7 days of entries, open Insights, verify 7 bars render with correct heights and day labels

### Tests for User Story 1

- [X] T015 [US1] Write widget test for `DurationBarChart` in `test/screens/insights_screen_test.dart` — render `DurationBarChart` with 7 known `DurationDataPoint`s, assert `BarChart` widget is present. Test with all-zero data (no bars visible), test with mixed data. Wrap in `MaterialApp` with `AppTheme.dark`

### Implementation for User Story 1

- [X] T016 [US1] Create `DurationBarChart` widget in `lib/widgets/duration_bar_chart.dart` — `StatelessWidget` accepting `List<DurationDataPoint> data` (exactly 7 items). Render fl_chart `BarChart` at 200px height. Y-axis: hour labels (0h, 4h, 8h, 12h) using left `SideTitles`. X-axis: day abbreviations via `DateFormat.E()`. Bars: 24px width, `colorScheme.primary` (brand orange), rounded top corners (4px radius). Grid lines horizontal only, subtle. Max Y = max(data, 480) same scaling approach as `MiniDurationChart`. Reference: research.md R6, existing `lib/widgets/mini_duration_chart.dart` for fl_chart patterns
- [X] T017 [US1] Wire `DurationBarChart` into `InsightsScreen` in `lib/screens/insights_screen.dart` — convert to `ConsumerWidget`, watch `durationChartProvider`. Show chart inside a Card (surface background, rounded-xl border-radius, border-fintech border) with "Last 7 days" section title using `titleMedium` (Satoshi). Handle loading state with `CircularProgressIndicator`. Handle error state with error text. Reference: brand kit card pattern from `lib/screens/home_screen.dart`
- [X] T018 [US1] Run `flutter test test/screens/insights_screen_test.dart` — verify bar chart renders with seeded data

**Checkpoint**: 7-day duration bar chart visible on Insights tab. Story can be tested independently.

---

## Phase 4: User Story 2 — View 30-Day Quality Trend Line Chart (Priority: P1)

**Goal**: Display a 30-day line chart showing quality rating trend on the Insights tab

**Independent Test**: Seed entries across 30 days with varying quality, open Insights, verify line chart with data points

### Tests for User Story 2

- [X] T019 [US2] Write widget test for `QualityLineChart` in `test/screens/insights_screen_test.dart` — render with known `QualityDataPoint`s, assert `LineChart` widget present. Test with single data point, test with 15 data points. Wrap in `MaterialApp` with `AppTheme.dark`

### Implementation for User Story 2

- [X] T020 [US2] Create `QualityLineChart` widget in `lib/widgets/quality_line_chart.dart` — `StatelessWidget` accepting `List<QualityDataPoint> data` (0–30 items). Render fl_chart `LineChart` at 200px height. Y-axis: 1–5 quality scale with integer labels. X-axis: date labels at weekly intervals using `DateFormat.MMMd()` for readability. Line: `colorScheme.primary` (brand orange), 2px width. Data points: small circles (4px radius) in brand orange. Connect consecutive points. Handle empty data gracefully (show "No quality data" text). Reference: research.md R1, R6
- [X] T021 [US2] Wire `QualityLineChart` into `InsightsScreen` in `lib/screens/insights_screen.dart` — watch `qualityChartProvider`. Add below the duration chart in a second Card with "Quality trend (30 days)" section title. Same card styling as duration chart. Handle loading/error states
- [X] T022 [US2] Run `flutter test test/screens/insights_screen_test.dart` — verify line chart renders with seeded data

**Checkpoint**: Both charts visible on Insights tab. US1 + US2 independently testable.

---

## Phase 5: User Story 3 — Read Plain-English Pattern Summaries (Priority: P1)

**Goal**: Display computed pattern summaries (averages, consistency, best/worst day) below the charts

**Independent Test**: Seed entries with known values, open Insights, verify all 6 summary metrics show correct computed values

### Tests for User Story 3

- [X] T023 [US3] Write widget test for `PatternSummaryCard` in `test/screens/insights_screen_test.dart` — render with a known `PatternSummary` instance, assert all 6 metric labels and values are displayed: "Avg duration (7d)", "Avg duration (30d)", "Avg quality (30d)", bedtime consistency text, "Best day", "Worst day". Test with null bestDay/worstDay shows appropriate fallback

### Implementation for User Story 3

- [X] T024 [US3] Create `PatternSummaryCard` widget in `lib/widgets/pattern_summary_card.dart` — `StatelessWidget` accepting `PatternSummary summary`. Render a Card (same surface/border styling) with "Patterns" section title (`titleMedium`, Satoshi). Display 6 rows, each with label (`bodyMedium`, text-secondary) and value (`bodyLarge` or `titleSmall`, text-primary). Format durations as "Xh Ym" using the same `formatDuration()` helper from `lib/screens/home_screen.dart` (extract to shared location or re-implement inline). Format quality as "X.X / 5". Show consistency text as-is. Show best/worst day name or "—" if null. Reference: brand kit spacing (4px grid), typography (Nunito body, Satoshi titles)
- [X] T025 [US3] Wire `PatternSummaryCard` into `InsightsScreen` in `lib/screens/insights_screen.dart` — watch `patternSummaryProvider`. Add below the quality chart. Handle loading/error states. The full Insights screen should now be a `SingleChildScrollView` containing: duration chart card → quality chart card → pattern summary card, with 16px vertical spacing between cards and 16px horizontal padding
- [X] T026 [US3] Run `flutter test test/screens/insights_screen_test.dart` — verify summaries render with seeded data

**Checkpoint**: Full Insights screen with charts + summaries. All P1 stories complete.

---

## Phase 6: User Story 4 — See Empty State When No Data Exists (Priority: P2)

**Goal**: Show friendly empty state with "Log sleep" CTA when zero entries exist

**Independent Test**: Fresh database (zero entries), open Insights, verify empty message and CTA button appear and navigate to /log

### Tests for User Story 4

- [X] T027 [US4] Write widget test for empty state in `test/screens/insights_screen_test.dart` — test with zero entries: assert empty message "Not enough data for insights yet. Log a few nights of sleep to start seeing patterns." and "Log sleep" button are displayed. Assert no `BarChart` or `LineChart` widgets present. Test CTA navigation: tap "Log sleep" button, verify navigation to `/log` route. Follow test setup pattern from `test/screens/home_screen_test.dart` (in-memory DB, appDatabaseProvider override, GoRouter with /insights and /log routes)

### Implementation for User Story 4

- [X] T028 [US4] Add empty state handling to `InsightsScreen` in `lib/screens/insights_screen.dart` — watch `insightsDataProvider`. When data is empty list (zero entries in 30-day window), AND `allEntriesProvider` shows zero total entries, display centered Column with: icon or illustration (optional), text "Not enough data for insights yet." (`titleMedium`, text-primary), text "Log a few nights of sleep to start seeing patterns." (`bodyMedium`, text-secondary), SizedBox(height: 24), ElevatedButton "Log sleep" that calls `context.push('/log')`. When data has at least 1 entry, show the normal charts+summaries layout. Reference: empty state pattern from `lib/screens/home_screen.dart`, design decision D7 in plan.md
- [X] T029 [US4] Run `flutter test test/screens/insights_screen_test.dart` — verify empty state renders with zero entries AND charts render with data entries

**Checkpoint**: All 4 user stories complete. Full Insights screen handles both data and empty states.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, cleanup, lint compliance

- [X] T030 Run full test suite with `flutter test` — verify all existing tests (home, history, log entry, database) still pass alongside new insights tests
- [X] T031 Run `flutter analyze` and fix any warnings or lint issues across all new and modified files
- [X] T032 Verify Insights screen renders correctly on both light and dark themes (app only has dark theme, but verify no hardcoded colours bypass theme)
- [X] T033 Verify accessibility: all chart sections have semantic labels, text meets AA contrast on dark surface, touch targets for "Log sleep" CTA are at least 44x44px

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Foundational (Phase 2) — can start as soon as Phase 2 is complete
- **US2 (Phase 4)**: Depends on Foundational (Phase 2) — can start in parallel with US1 (different widget files)
- **US3 (Phase 5)**: Depends on Foundational (Phase 2) — can start in parallel with US1/US2 (different widget file)
- **US4 (Phase 6)**: Depends on Phase 3 screen structure being in place (US1 establishes the InsightsScreen as ConsumerWidget with provider watching)
- **Polish (Phase 7)**: Depends on all user stories complete

### User Story Dependencies

- **US1 (7-day bar chart)**: Depends on T006–T014 (foundational). No dependency on other stories. Creates the InsightsScreen ConsumerWidget structure.
- **US2 (30-day line chart)**: Depends on T006–T014 (foundational). Widget (T020) is independent file. Screen wiring (T021) depends on US1's screen structure (T017).
- **US3 (pattern summaries)**: Depends on T006–T014 (foundational). Widget (T024) is independent file. Screen wiring (T025) depends on US1's screen structure (T017).
- **US4 (empty state)**: Depends on US1's screen structure (T017) to add conditional rendering.

### Within Each User Story

- Tests FIRST → Implementation → Screen wiring → Verification
- Widget creation is parallel-safe (separate files)
- Screen wiring is sequential (same file: `insights_screen.dart`)

### Parallel Opportunities

**Phase 2 (Foundational)**:
- T003, T004, T005 (test files) can run in parallel — same file but independent test groups
- T007, T008, T009 can run in parallel within `insights_calculator.dart` (separate static methods, though same file requires sequential writes)

**Phase 3–5 (US1, US2, US3 widgets)**:
- T016 (`duration_bar_chart.dart`), T020 (`quality_line_chart.dart`), T024 (`pattern_summary_card.dart`) can all run in parallel — different files, no dependencies
- T015, T019, T023 (widget tests) can run in parallel — different test groups

**Screen wiring must be sequential**:
- T017 (US1 screen wiring) → T021 (US2 screen wiring) → T025 (US3 screen wiring) → T028 (US4 empty state)

---

## Parallel Example: Widget Creation

```
# After Phase 2 foundational is complete, launch widget creation in parallel:
Task: T016 — Create DurationBarChart in lib/widgets/duration_bar_chart.dart
Task: T020 — Create QualityLineChart in lib/widgets/quality_line_chart.dart
Task: T024 — Create PatternSummaryCard in lib/widgets/pattern_summary_card.dart
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T014) — computation + providers
3. Complete Phase 3: US1 (T015–T018) — 7-day bar chart on screen
4. **STOP and VALIDATE**: `flutter test` passes, bar chart visible on Insights tab
5. This alone delivers the primary visual insight

### Incremental Delivery

1. Setup + Foundational → Computation layer verified
2. Add US1 (bar chart) → Test independently → Commit
3. Add US2 (line chart) → Test independently → Commit
4. Add US3 (summaries) → Test independently → Commit
5. Add US4 (empty state) → Test independently → Commit
6. Polish → Full test suite + lint → Final commit

### Recommended Single-Developer Flow

Since screen wiring is sequential (same file), the optimal flow is:

1. Phase 1 + 2 (setup + foundational) — 14 tasks
2. Create all 3 widgets in parallel (T016, T020, T024) — 3 tasks
3. Wire into screen sequentially (T017 → T021 → T025 → T028) — 4 tasks
4. Run all test verifications (T018, T022, T026, T029) — 4 tasks
5. Polish (T030–T033) — 4 tasks

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- `DurationDataPoint` typedef is reused from `lib/providers/home_providers.dart` — import it, don't redefine
- `formatDuration()` helper exists as a static method in `HomeScreen` — either extract to a shared utility or re-implement in `PatternSummaryCard`
- All new widgets use `Theme.of(context)` for colours/typography — no hardcoded brand values
- Commit after each phase checkpoint for clean git history
- Total tasks: 33
