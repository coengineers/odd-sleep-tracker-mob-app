# Implementation Plan: D5 — Polish, QA & Release Readiness

**Branch**: `006-polish-qa-release` | **Date**: 2026-02-10 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/006-polish-qa-release/spec.md`

## Summary

Stabilise the SleepLog app for release by adding integration tests for the two key user journeys (J1: first use → log sleep, J2: review history → edit/delete), improving accessibility with `Semantics` wrappers across all screens and chart widgets, building a dev-only seed data tool for QA and performance testing, verifying zero-network compliance, and producing a release checklist documenting known limitations and QA steps.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter 3.38+ (stable channel)
**Primary Dependencies**: go_router ^17.1.0, flutter_riverpod ^3.2.1, drift ^2.31.0, fl_chart ^1.1.1, intl ^0.20.0, integration_test (Flutter SDK — new dev dependency)
**Storage**: SQLite via drift (on-device only) — existing `AppDatabase` with full CRUD, no changes needed
**Testing**: flutter_test (existing unit/widget) + integration_test (new E2E) with in-memory SQLite
**Target Platform**: iOS and Android
**Project Type**: Mobile (Flutter)
**Performance Goals**: Home + History render ≤ 500ms with 365 entries; seed tool populates 365 entries in < 5s
**Constraints**: Fully offline, zero network calls, all data on-device
**Scale/Scope**: Cross-cutting quality work across all 4 screens + 2 new integration test files + 1 seed tool + 1 release doc

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Offline-First & Zero-Network | PASS | No new network dependencies. `integration_test` is a Flutter SDK package with no network calls. Network audit confirms zero HTTP code in production. |
| II. On-Device Privacy | PASS | No new permissions. Seed tool uses existing `AppDatabase.createEntry()`. No new external dependencies. |
| III. Frictionless UX | PASS | No UX changes to core flows. Accessibility improvements enhance usability for screen reader users. Seed tool is debug-only, invisible to production users. |
| IV. Test-Driven Quality | PASS | This deliverable's primary purpose is to add integration tests (J1, J2 journeys) and improve overall quality through accessibility and QA verification. |
| V. Incremental Delivery | PASS | D5 builds on D0–D4 infrastructure. No changes to existing functionality. All new code is additive (tests, semantics, dev tools, docs). |
| VI. Brand Compliance | PASS | No visual changes beyond accessibility-required `Semantics` wrappers (invisible to sighted users). Existing brand colours, fonts, and spacing are preserved. |

**Gate result: ALL PASS — proceed to Phase 0.**

**Post-Phase 1 re-check: ALL PASS.** No design decisions introduced violations. The seed tool is `kDebugMode`-gated (tree-shaken from release builds). Integration tests use in-memory databases. All accessibility changes use standard Flutter `Semantics` API.

## Project Structure

### Documentation (this feature)

```text
specs/006-polish-qa-release/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output — research findings
├── data-model.md        # Phase 1 output — no schema changes
├── quickstart.md        # Phase 1 output — setup & run guide
├── contracts/
│   └── seed-api.md      # Seed tool internal contract
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── database/
│   └── app_database.dart           # Existing — no changes
├── dev/
│   └── seed_data.dart              # NEW — dev-only seed data generator
├── models/
│   └── sleep_entry_model.dart      # Existing — no changes
├── providers/
│   ├── database_providers.dart     # Existing — no changes
│   ├── home_providers.dart         # Existing — no changes
│   ├── log_entry_providers.dart    # Existing — no changes
│   └── insights_providers.dart     # Existing — no changes
├── routing/
│   └── app_router.dart             # Existing — no changes
├── screens/
│   ├── home_screen.dart            # MODIFY — add Semantics + seed trigger (debug)
│   ├── log_entry_screen.dart       # Existing — already has Semantics (no changes)
│   ├── history_screen.dart         # MODIFY — add Semantics to entry tiles, states
│   └── insights_screen.dart        # MODIFY — add Semantics to chart cards, states
├── services/
│   └── insights_calculator.dart    # Existing — no changes
├── widgets/
│   ├── shell_scaffold.dart         # MODIFY — add FAB tooltip
│   ├── quality_selector.dart       # MODIFY — replace hardcoded fontSize with theme
│   ├── mini_duration_chart.dart    # MODIFY — add Semantics wrapper
│   ├── duration_bar_chart.dart     # MODIFY — add Semantics wrapper
│   ├── quality_line_chart.dart     # MODIFY — add Semantics wrapper
│   └── pattern_summary_card.dart   # MODIFY — add Semantics label
└── theme/
    └── app_theme.dart              # Existing — no changes

integration_test/
├── app_test_utils.dart             # NEW — shared test app builder + seed helpers
├── journey_log_sleep_test.dart     # NEW — J1 end-to-end integration test
└── journey_edit_delete_test.dart   # NEW — J2 end-to-end integration test

test/
└── dev/
    └── seed_data_test.dart         # NEW — unit tests for seed generation logic

docs/
└── release-checklist.md            # NEW — QA steps, known limitations, build instructions
```

**Structure Decision**: Flutter mobile project following established patterns. New `lib/dev/` directory isolates debug-only code. New `integration_test/` directory follows Flutter's standard convention for E2E tests. New `docs/release-checklist.md` follows the existing `docs/` convention (alongside `PRD.md` and `brand-kit.md`).

## Complexity Tracking

> No violations. All design choices follow established patterns. No new abstractions or architectural layers introduced.

## Design Decisions

### D1: Integration Tests — In-Memory Database with Provider Override

Integration tests use `AppDatabase.forTesting(NativeDatabase.memory())` with `appDatabaseProvider.overrideWithValue(db)`, the same pattern used by all existing widget tests. A shared `app_test_utils.dart` provides a `buildIntegrationTestApp()` function that wraps `SleepLogApp` with the test database.

**Why**: Reuses the proven test isolation pattern from D0–D4. In-memory databases are fast, require no cleanup, and prevent test pollution. The provider override pattern is already battle-tested across 12 test files.

**Alternative rejected**: File-based SQLite for "more realistic" testing — rejected because it adds cleanup complexity, risk of stale data, and the existing pattern already tests the full drift/SQLite stack (just in memory).

### D2: Seed Tool — `kDebugMode` Guard + Long-Press Trigger

The seed function lives in `lib/dev/seed_data.dart` as a pure async function. The call site in `home_screen.dart` wraps the trigger gesture in `if (kDebugMode)`. Dart's tree-shaker removes the entire code path from release builds.

**Why**: `kDebugMode` is a compile-time constant — the most reliable way to exclude debug code from production. The long-press gesture is discoverable for developers but invisible to users. No separate build flavour or entry point needed.

**Alternative rejected**: Separate `main_dev.dart` entry point — rejected because it requires maintaining two launch configurations, complicates CI, and is unnecessary for a single seed function.

### D3: Accessibility — Semantics Wrappers with Dynamic Labels

Chart widgets receive `Semantics` wrappers whose labels are computed from the data being displayed (e.g., "Last 7 days sleep duration. Average: 7 hours 30 minutes"). Interactive elements get descriptive labels. Loading/error states get status labels.

**Why**: Static labels like "bar chart" are unhelpful for screen reader users. Dynamic labels that summarise the actual data provide real value. This follows the pattern already established in `log_entry_screen.dart` where Semantics labels include current values.

### D4: Chart Accessibility — Wrapper Approach (Not ExcludeSemantics + DataTable)

Charts are wrapped in a single `Semantics` widget with a descriptive `label` summarising the data. Individual bars/points are NOT made individually focusable.

**Why**: fl_chart renders to Canvas, making individual data point semantics impractical. A single summary label per chart is the standard approach for data visualisation accessibility. Users who need exact values can refer to the Pattern Summary card which presents the same data as accessible text.

### D5: Release Checklist — Markdown in `docs/`

The release checklist is a structured markdown file at `docs/release-checklist.md` with sections for QA steps, automated test gates, known limitations, build instructions, and verification checklists.

**Why**: Version-controlled, reviewable, and sits alongside the existing PRD and brand kit. Can be updated as limitations are resolved in future releases.

### D6: Integration Test Structure — One File Per Journey

Each key journey (J1: log sleep, J2: edit/delete) gets its own integration test file. A shared utilities file provides the test app builder and seed helpers.

**Why**: Keeps tests focused and independently runnable. Matches the PRD's journey structure (J1, J2). Shared utilities avoid duplication without creating unnecessary abstraction.
