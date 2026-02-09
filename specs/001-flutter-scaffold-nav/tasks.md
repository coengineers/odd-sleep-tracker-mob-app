# Tasks: Flutter Scaffold & Navigation (D0)

**Input**: Design documents from `/specs/001-flutter-scaffold-nav/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/routes.md, quickstart.md

**Tests**: Included — the feature specification explicitly requires widget tests for navigation and screen rendering (FR-D0-002, FR-D0-003, SC-003, SC-004). Test contract defined in contracts/routes.md.

**Organization**: Tasks are grouped by user story. US1 and US2 are both P1 but are ordered sequentially because US2 (navigation) depends on the screen widgets created in US1.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths included in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Flutter project initialisation, dependency installation, font bundling, and linting configuration.

- [x] T001 Run `flutter create --org com.coengineers --platforms ios,android --project-name sleeplog .` to initialise the Flutter project in-place
- [x] T002 Update `pubspec.yaml`: add `go_router: ^17.1.0` and `flutter_riverpod: ^3.2.1` to dependencies; add `flutter_lints: ^5.0.0` to dev_dependencies; declare font assets under `flutter.fonts` (Satoshi-Variable, Nunito-Regular, Nunito-SemiBold, Nunito-Bold) and `flutter.assets` for `assets/fonts/`
- [x] T003 [P] Create `assets/fonts/` directory and place font files: `Satoshi-Variable.ttf`, `Nunito-Regular.ttf`, `Nunito-SemiBold.ttf`, `Nunito-Bold.ttf`
- [x] T004 [P] Configure `analysis_options.yaml` with `flutter_lints` and strict analysis rules
- [x] T005 Run `flutter pub get` to install dependencies and verify resolution

**Checkpoint**: Flutter project compiles, `flutter analyze` runs (may have warnings about unused code until screens are wired up).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Theme and router infrastructure that ALL screens and navigation depend on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T006 Create `lib/theme/app_theme.dart` — implement `AppTheme` class with static `dark` getter returning `ThemeData` with: manual `ColorScheme` (background `#0E0F12`, surface `#1A1B1F`, primary/brand orange `#F7931A`, onPrimary black `#000000`, onSurface `#F5F5F5`), `TextTheme` (headings: Satoshi fontFamily, body: Nunito fontFamily, minimum body size 16px), 4px spacing grid constants, radius scale tokens, 44px minimum touch target via `materialTapTargetSize`
- [x] T007 Create `lib/routing/app_router.dart` — implement `createRouter()` factory function returning `GoRouter` with `initialLocation: '/'`, nested route tree: `/` → HomeScreen, `/log` → LogEntryScreen (with `?id` query param), `/history` → HistoryScreen, `/insights` → InsightsScreen (per contracts/routes.md)
- [x] T008 Create `lib/main.dart` — implement `main()` with `runApp()`, `SleepLogApp` widget wrapping `ProviderScope` → `MaterialApp.router` with `routerConfig: createRouter()`, `theme: AppTheme.dark`, `debugShowCheckedModeBanner: false`
- [x] T009 Delete generated `test/widget_test.dart` (created by `flutter create`, references default counter app)

**Checkpoint**: App compiles and launches to a blank Home route. `flutter analyze` passes. Theme and router are ready for screen widgets.

---

## Phase 3: User Story 1 — Launch App and See Home Screen (Priority: P1) 🎯 MVP

**Goal**: The app boots to a Home screen with brand theme, empty-state message, and "Log sleep" CTA button.

**Independent Test**: Launch app in airplane mode → Home screen renders within 2s with title, empty-state message, and tappable CTA.

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T010 [US1] Write widget test `test/screens/home_screen_test.dart` — verify: app title "SleepLog" is displayed, empty-state message "No sleep logged yet. Add last night's sleep to start tracking." is visible, "Log sleep" CTA button is rendered and tappable, navigation links to History and Insights are present. Test wrapper: `ProviderScope` + `MaterialApp.router` with `createRouter()` + `AppTheme.dark`.

### Implementation for User Story 1

- [x] T011 [US1] Create `lib/screens/home_screen.dart` — `HomeScreen` StatelessWidget with: AppBar displaying "SleepLog" title (Satoshi font), centered empty-state message (Nunito body), "Log sleep" ElevatedButton (brand orange background, black text, 44px min height) calling `context.push('/log')`, text links/buttons for "History" and "Insights" calling `context.push('/history')` and `context.push('/insights')` respectively
- [x] T012 [US1] Run `flutter test test/screens/home_screen_test.dart` — verify all Home screen tests pass

**Checkpoint**: Home screen renders correctly with empty state, CTA, and nav links. Widget tests pass.

---

## Phase 4: User Story 2 — Navigate to All Screens (Priority: P1)

**Goal**: All four screen shells are reachable via navigation from Home. Push-style navigation preserves back stack.

**Independent Test**: From Home, tap each CTA/link → correct screen shell renders → back button returns to Home.

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T013 [P] [US2] Write widget test `test/screens/log_entry_screen_test.dart` — verify: title shows "Log Entry" when no id param, title shows "Edit Entry" when `?id=abc123` is provided, placeholder body text is visible. Test wrapper: `ProviderScope` + `MaterialApp.router` + `AppTheme.dark`.
- [x] T014 [P] [US2] Write widget test `test/screens/history_screen_test.dart` — verify: title "History" is displayed, placeholder body text is visible. Test wrapper: `ProviderScope` + `MaterialApp.router` + `AppTheme.dark`.
- [x] T015 [P] [US2] Write widget test `test/screens/insights_screen_test.dart` — verify: title "Insights" is displayed, placeholder body text is visible. Test wrapper: `ProviderScope` + `MaterialApp.router` + `AppTheme.dark`.
- [x] T016 [US2] Write navigation test `test/routing/app_router_test.dart` — verify: initial route renders HomeScreen, tapping "Log sleep" navigates to LogEntryScreen, tapping "History" navigates to HistoryScreen, tapping "Insights" navigates to InsightsScreen, back navigation returns to HomeScreen, `/log?id=abc123` passes entryId to LogEntryScreen. Each test uses fresh `createRouter()`.

### Implementation for User Story 2

- [x] T017 [P] [US2] Create `lib/screens/log_entry_screen.dart` — `LogEntryScreen` StatelessWidget accepting optional `String? entryId`, AppBar title: "Log Entry" when entryId is null, "Edit Entry" when entryId is provided, placeholder body text (Nunito), back navigation via AppBar leading
- [x] T018 [P] [US2] Create `lib/screens/history_screen.dart` — `HistoryScreen` StatelessWidget with AppBar title "History", placeholder body text (Nunito), back navigation via AppBar leading
- [x] T019 [P] [US2] Create `lib/screens/insights_screen.dart` — `InsightsScreen` StatelessWidget with AppBar title "Insights", placeholder body text (Nunito), back navigation via AppBar leading
- [x] T020 [US2] Run `flutter test` — verify all screen widget tests and navigation tests pass

**Checkpoint**: All four screens render their shells. Full navigation loop (Home → each screen → back) works. All widget and navigation tests pass.

---

## Phase 5: User Story 3 — Brand-Compliant Visual Identity (Priority: P2)

**Goal**: Theme tokens are applied correctly across all screens — dark background, brand orange CTA, Satoshi headings, Nunito body, 44px touch targets.

**Independent Test**: Launch app, visually confirm dark background (#0E0F12), orange CTA (#F7931A) with black text, Satoshi headings, Nunito body text, adequate contrast, and min 44px touch targets.

### Implementation for User Story 3

- [x] T021 [US3] Verify and refine theme application across all screens in `lib/theme/app_theme.dart` — ensure: `ColorScheme` tokens match brand kit exactly, `ElevatedButton.styleFrom` uses brand orange with black text, `AppBar` theme uses Satoshi for title, body text theme uses Nunito at 16px minimum, `materialTapTargetSize: MaterialTapTargetSize.padded` ensures 44px targets, safe area insets respected via `SafeArea` or `Scaffold` defaults
- [x] T022 [US3] Run `flutter analyze` — verify zero warnings and zero errors across all source files

**Checkpoint**: Theme is visually brand-compliant. `flutter analyze` passes cleanly.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, cleanup, and quickstart verification.

- [x] T023 Run `dart format lib/ test/` — ensure consistent code formatting
- [x] T024 Run full test suite `flutter test` — all tests green
- [x] T025 Validate quickstart.md end-to-end: `flutter analyze` (zero issues), `flutter test` (all pass), `flutter run` (launches to Home screen)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Phase 2 (needs theme, router, main.dart)
- **US2 (Phase 4)**: Depends on Phase 3 (screen shells need HomeScreen for navigation tests)
- **US3 (Phase 5)**: Depends on Phase 4 (all screens must exist to verify theme application)
- **Polish (Phase 6)**: Depends on all user story phases complete

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Screen widgets before navigation wiring
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- T003 and T004 can run in parallel (different files)
- T013, T014, T015 can run in parallel (different test files)
- T017, T018, T019 can run in parallel (different screen files)

---

## Implementation Strategy

### Recommended: Sequential by Priority

1. Complete Phase 1: Setup → Flutter project compiles
2. Complete Phase 2: Foundational → Theme + Router + main.dart ready
3. Complete Phase 3: US1 (P1) → Home screen with empty state + CTA
4. Complete Phase 4: US2 (P1) → All screen shells + full navigation
5. Complete Phase 5: US3 (P2) → Brand compliance verified
6. Complete Phase 6: Polish → Clean, formatted, all tests green

### Commit Strategy

- Commit after Phase 1 (setup)
- Commit after Phase 2 (foundational)
- Commit after each user story phase (US1, US2, US3)
- Final commit after polish

---

## Notes

- [P] tasks = different files, no dependencies — can be launched in parallel
- [Story] label maps task to specific user story for traceability
- Font files must be downloaded manually (see quickstart.md) before T003
- `flutter create .` runs in-place — does not overwrite existing docs/, specs/, CLAUDE.md
- Generated `test/widget_test.dart` must be deleted (T009) before tests can pass
