# Implementation Plan: Flutter Scaffold & Navigation (D0)

**Branch**: `001-flutter-scaffold-nav` | **Date**: 2026-02-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-flutter-scaffold-nav/spec.md`

## Summary

Create the SleepLog Flutter application from scratch: project
initialisation, go_router navigation with 4 screen shells (Home,
Log Entry, History, Insights), CoEngineers brand theme (dark mode),
bundled Satoshi + Nunito fonts, and widget tests for navigation and
screen rendering. This is D0 — the foundational scaffold on which
all subsequent deliverables (D1-D5) build.

## Technical Context

**Language/Version**: Dart 3.4+ / Flutter 3.22+ (stable channel)
**Primary Dependencies**: go_router ^17.1.0, flutter_riverpod ^3.2.1
**Storage**: N/A (no persistence in D0)
**Testing**: flutter_test (widget tests), flutter_lints ^5.0.0
**Target Platform**: iOS and Android
**Project Type**: mobile
**Performance Goals**: Cold start to Home screen < 2s on mid-range device
**Constraints**: Zero network requests, offline-only, bundled fonts
**Scale/Scope**: 4 screens (shells), 5 routes, 1 theme

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Offline-First & Zero-Network | PASS | No network dependencies. go_router and flutter_riverpod are offline packages. Fonts bundled as assets. No analytics SDKs. |
| II. On-Device Privacy | PASS | No data storage in D0. No permissions requested. No HTTP client in dependency tree. |
| III. Frictionless UX | PASS | D0 scope is screen shells only. Empty state with CTA on Home. Inline navigation. 44px min touch targets. |
| IV. Test-Driven Quality | PASS | Widget tests planned for all screens and navigation routes. Factory `createRouter()` for test isolation. `ProviderScope` in all test wrappers. |
| V. Incremental Delivery | PASS | D0 is a self-contained deliverable. Establishes shared infrastructure (routing, theme) before screen-level work (D1-D5). |
| VI. Brand Compliance | PASS | Manual `ColorScheme` construction with exact brand hex values. Satoshi headings + Nunito body bundled as assets. 4px spacing grid. 44px touch targets. Dark mode default. Black on orange for buttons. |

**Post-Phase 1 re-check**: All gates still pass. No design decisions
introduced network dependencies, data storage, or brand deviations.

## Project Structure

### Documentation (this feature)

```text
specs/001-flutter-scaffold-nav/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (minimal for D0)
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (navigation contracts)
│   └── routes.md
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── main.dart                      # App entry point + ProviderScope
├── routing/
│   └── app_router.dart            # createRouter() factory function
├── screens/
│   ├── home_screen.dart           # Home with empty state + nav CTAs
│   ├── log_entry_screen.dart      # Log Entry shell (accepts optional id)
│   ├── history_screen.dart        # History shell
│   └── insights_screen.dart       # Insights shell
└── theme/
    └── app_theme.dart             # AppTheme.dark ThemeData

assets/
└── fonts/
    ├── Satoshi-Variable.ttf       # Variable font (weights 300-900)
    ├── Nunito-Regular.ttf         # 400
    ├── Nunito-SemiBold.ttf        # 600
    └── Nunito-Bold.ttf            # 700

test/
├── screens/
│   ├── home_screen_test.dart
│   ├── log_entry_screen_test.dart
│   ├── history_screen_test.dart
│   └── insights_screen_test.dart
└── routing/
    └── app_router_test.dart       # Navigation route tests
```

**Structure Decision**: Standard Flutter mobile structure with `lib/`
for source and `test/` mirroring `lib/`. No `src/` or `tests/`
directories — Flutter convention uses `lib/` and `test/`. Screen
widgets live under `lib/screens/`, routing under `lib/routing/`,
theme under `lib/theme/`. Font assets under `assets/fonts/`.

## Complexity Tracking

> No constitution violations. No complexity justifications required.
