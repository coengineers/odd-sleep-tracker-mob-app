# Implementation Plan: Home + History Screens

**Branch**: `004-home-history-screens` | **Date**: 2026-02-10 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-home-history-screens/spec.md`

## Summary

Implement the Home and History screens (PRD D3) to replace the current placeholder screens. Home displays today's sleep summary (duration, quality, mini 7-day bar chart) from the most recent entry with wake date = today. History displays all entries newest-first in a virtualised list with swipe-to-delete (confirmation + 5-second undo via SnackBar). Both screens show empty states with a "Log sleep" CTA when no data exists. Tapping an entry in History navigates to the existing Log Entry screen in edit mode.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter 3.38+ (stable channel)
**Primary Dependencies**: go_router ^17.1.0, flutter_riverpod ^3.2.1, drift ^2.31.0, intl ^0.20.0, fl_chart (new — for mini bar chart)
**Storage**: SQLite via drift (on-device only) — existing `AppDatabase` with full CRUD
**Testing**: flutter_test (widget tests + unit tests), in-memory SQLite via `NativeDatabase.memory()`
**Target Platform**: iOS and Android
**Project Type**: mobile
**Performance Goals**: Home + History render ≤ 500ms with 365 entries (excluding cold start)
**Constraints**: Offline-only, no network requests, 44×44px minimum touch targets, WCAG 2.1 AA contrast
**Scale/Scope**: 2 screens (Home, History), ~4 new providers, 1 new widget (mini chart), 1 new package (fl_chart)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Offline-First & Zero-Network | PASS | No network calls. `fl_chart` is a rendering-only package — no network activity. |
| II. On-Device Privacy | PASS | All data stays in local SQLite. No new permissions needed. `fl_chart` has no analytics/tracking. |
| III. Frictionless UX | PASS | Home renders today's summary immediately. History uses `ListView.builder` for smooth scrolling. Empty states guide users to "Log sleep". |
| IV. Test-Driven Quality | PASS | Plan includes widget tests for both screens, unit tests for new providers/queries, tests for delete/undo flow. |
| V. Incremental Delivery | PASS | D3 builds on D0 (routing), D1 (database), D2 (Log Entry screen). Each is already complete. |
| VI. Brand Compliance | PASS | Dark theme with brand colours already in `AppTheme.dark`. New UI will use existing theme tokens. Mini chart will use brand orange for bars. |

**Pre-design gate: PASS** — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/004-home-history-screens/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── providers.md     # Riverpod provider contracts
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── providers/
│   ├── database_providers.dart      # existing — appDatabaseProvider
│   ├── log_entry_providers.dart     # existing — sleepEntryProvider
│   └── home_providers.dart          # NEW — todaySummaryProvider, recentDurationsProvider
├── screens/
│   ├── home_screen.dart             # REPLACE — full Home screen with today summary + mini chart
│   └── history_screen.dart          # REPLACE — full History list with swipe-to-delete
└── widgets/
    ├── shell_scaffold.dart          # existing — bottom nav + FAB
    ├── quality_selector.dart        # existing — 1–5 button group
    └── mini_duration_chart.dart     # NEW — 7-day bar chart for Home

test/
├── screens/
│   ├── home_screen_test.dart        # REPLACE — tests for summary, chart, empty state, navigation
│   └── history_screen_test.dart     # REPLACE — tests for list, delete/undo, empty state, edit nav
├── providers/
│   └── home_providers_test.dart     # NEW — unit tests for today-summary and recent-durations queries
└── widgets/
    └── mini_duration_chart_test.dart # NEW — widget tests for chart rendering
```

**Structure Decision**: Flutter mobile project — all source under `lib/`, tests under `test/`. No structural changes needed; adding new files within existing directories following established patterns.

## Complexity Tracking

> No constitution violations to justify.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| — | — | — |

## Constitution Re-Check (Post-Design)

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Offline-First & Zero-Network | PASS | `fl_chart` verified as rendering-only, no HTTP client in dependency tree. |
| II. On-Device Privacy | PASS | No new permissions, no data export. |
| III. Frictionless UX | PASS | Summary + chart load from single DB query. History uses `ListView.builder`. Undo via SnackBar (no modal blocker). |
| IV. Test-Driven Quality | PASS | Provider unit tests, widget tests for both screens, delete/undo flow covered. |
| V. Incremental Delivery | PASS | D3 extends D0/D1/D2 without modifying them (except replacing placeholder screen content). |
| VI. Brand Compliance | PASS | Uses existing `AppTheme.dark` tokens. Chart bars use `colorScheme.primary`. Cards use `colorScheme.surface` + `colorScheme.outline` border. |

**Post-design gate: PASS** — no violations.
