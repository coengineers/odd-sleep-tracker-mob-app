# Implementation Plan: Insights Screen (Charts + Summaries)

**Branch**: `005-insights-screen` | **Date**: 2026-02-10 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/005-insights-screen/spec.md`

## Summary

Implement the Insights screen (D4) with a 7-day sleep duration bar chart, 30-day quality trend line chart, and plain-English pattern summaries (averages, bedtime consistency, best/worst day). The screen uses fl_chart for visualisation, Riverpod FutureProviders for data aggregation, and the existing `AppDatabase.listEntries()` for date-range queries. No schema changes required — all insights are computed in the provider/service layer from raw `SleepEntry` records.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter 3.38+ (stable channel)
**Primary Dependencies**: go_router ^17.1.0, flutter_riverpod ^3.2.1, drift ^2.31.0, fl_chart ^1.1.1, intl ^0.20.0
**Storage**: SQLite via drift (on-device only) — existing `AppDatabase` with full CRUD, no changes needed
**Testing**: flutter_test with in-memory SQLite (`NativeDatabase.memory()`)
**Target Platform**: iOS and Android
**Project Type**: Mobile (Flutter)
**Performance Goals**: Insights tab renders within 1 second with 365 entries
**Constraints**: Fully offline, no network calls, all data on-device
**Scale/Scope**: Single screen with 2 chart widgets, 1 summary section, 1 empty state

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Offline-First & Zero-Network | PASS | No network calls. All data from local SQLite. fl_chart renders locally. |
| II. On-Device Privacy | PASS | No new permissions. No new dependencies with network activity. |
| III. Frictionless UX | PASS | Read-only screen — no user input required. Empty state guides to Log Entry. Charts render from cached provider data. |
| IV. Test-Driven Quality | PASS | Plan includes unit tests for aggregation logic and widget tests for all screen states (empty, single entry, full data). |
| V. Incremental Delivery | PASS | D4 builds on D0–D3 infrastructure. Independently testable. No changes to prior deliverables. |
| VI. Brand Compliance | PASS | Uses existing dark theme, Satoshi/Nunito fonts, brand orange for chart accents. All text meets AA contrast. |

**Gate result: ALL PASS — proceed to Phase 0.**

## Project Structure

### Documentation (this feature)

```text
specs/005-insights-screen/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── insights-api.md  # Internal provider contracts
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── database/
│   └── app_database.dart         # Existing — no changes needed
├── models/
│   └── sleep_entry_model.dart    # Existing — no changes needed
├── providers/
│   ├── database_providers.dart   # Existing — no changes
│   ├── home_providers.dart       # Existing — may extract shared date helper
│   └── insights_providers.dart   # NEW — aggregation providers for insights
├── screens/
│   └── insights_screen.dart      # MODIFY — replace placeholder with full UI
├── services/
│   └── insights_calculator.dart  # NEW — pure computation logic (testable)
├── widgets/
│   ├── mini_duration_chart.dart  # Existing — reference pattern
│   ├── duration_bar_chart.dart   # NEW — full 7-day bar chart for Insights
│   ├── quality_line_chart.dart   # NEW — 30-day quality line chart
│   └── pattern_summary_card.dart # NEW — summary metrics display
└── theme/
    └── app_theme.dart            # Existing — no changes

test/
├── screens/
│   └── insights_screen_test.dart # MODIFY — replace placeholder tests
├── services/
│   └── insights_calculator_test.dart # NEW — unit tests for computations
└── providers/
    └── insights_providers_test.dart  # NEW — provider integration tests
```

**Structure Decision**: Flutter mobile project following existing patterns. New files follow the established `lib/{category}/` and `test/{category}/` conventions. Computation logic separated into a pure `services/insights_calculator.dart` for isolated unit testing without widget overhead.

## Complexity Tracking

> No violations. All design choices follow established patterns.

## Design Decisions

### D1: Computation Layer — Pure Functions in `insights_calculator.dart`

All aggregation logic (averages, bedtime consistency, best/worst day) lives in a standalone pure-function service. This mirrors how `sleep_entry_model.dart` provides `computeDurationMinutes()` and `computeWakeDate()` as pure functions.

**Why**: Pure functions are trivially testable without widget trees, providers, or databases. The provider layer simply calls into this service, keeping providers thin.

### D2: Provider Pattern — FutureProviders Matching Home

Insights uses `FutureProvider` (same as `todaySummaryProvider`, `recentDurationsProvider`, `allEntriesProvider` in `home_providers.dart`). A single `insightsDataProvider` fetches 30-day entries from the database once, then derived providers compute specific metrics from that cached data.

**Why**: Avoids multiple DB queries per screen render. The 30-day window is a superset of 7-day data, so one query serves both charts and summaries.

### D3: Chart Widgets — Separate from Mini Chart

New `DurationBarChart` and `QualityLineChart` widgets are distinct from the existing `MiniDurationChart`. The insights charts need different dimensions (taller), y-axis labels, and touch interactions.

**Why**: The mini chart is compact (120px, no labels) for the Home screen. Insights charts need full-height rendering with axis labels and more detail. Sharing would require excessive conditional logic.

### D4: 7-Day Bar Chart — Sum Duration for Multi-Entry Days

When a day has multiple entries, the bar chart shows total combined duration (sum). This differs from the Home mini chart which uses the latest entry's duration (`putIfAbsent`).

**Why**: For insights, total sleep time per day is more meaningful. A user who naps + has a main sleep session wants to see their total hours.

### D5: 30-Day Line Chart — Average Quality for Multi-Entry Days

When a day has multiple entries, the line chart shows the average quality rating (rounded to one decimal).

**Why**: Quality is a subjective rating. Averaging across entries for a day gives a more representative picture than picking one.

### D6: Bedtime Consistency — Standard Deviation of Time-of-Day

Convert each bedtime to minutes-since-midnight, compute standard deviation. Express as human-readable text:
- <15 min: "very consistent"
- 15–30 min: "fairly consistent (about X minutes)"
- 30–60 min: "varies by about X minutes"
- 60+ min: "varies widely (over X hours)"

**Why**: Standard deviation is the natural statistical measure for variability. The plain-language buckets match the PRD's "plain-English summaries" requirement.

### D7: Empty State — Reuse Pattern from Home Screen

The empty state follows the same visual pattern as `HomeScreen`'s empty state: centered text + "Log sleep" ElevatedButton that navigates to `/log`.

**Why**: Consistency across screens. Users see the same CTA pattern everywhere.
