# Implementation Plan: Log Entry Screen (Create/Edit)

**Branch**: `003-log-entry-screen` | **Date**: 2026-02-10 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-log-entry-screen/spec.md`

## Summary

Implement the Log Entry screen (D2) that allows users to create and edit sleep entries with bedtime/wake time pickers, a 1–5 quality rating selector, and an optional note field. The screen integrates with the existing drift database layer (D1) via Riverpod providers, validates all inputs inline before save, and navigates back on success. The existing `LogEntryScreen` shell is replaced with a full `StatefulWidget` form backed by `ConsumerStatefulWidget` for Riverpod access.

## Technical Context

**Language/Version**: Dart 3.10+ / Flutter 3.38+ (stable channel)
**Primary Dependencies**: go_router ^17.1.0, flutter_riverpod ^3.2.1, drift ^2.31.0, intl (date formatting)
**Storage**: SQLite via drift (on-device only) — CRUD already implemented in D1 (`AppDatabase.createEntry`, `updateEntry`, `getEntryById`)
**Testing**: flutter_test (widget tests with in-memory drift DB + `ProviderScope` overrides)
**Target Platform**: iOS and Android
**Project Type**: Mobile (Flutter)
**Performance Goals**: Entry completion in ≤ 30 seconds (PRD M1); inline validation with zero save-round-trips for invalid data
**Constraints**: Offline-only, no network calls, all data on-device, brand-compliant dark theme
**Scale/Scope**: Single screen (create + edit modes), 4 form fields, ~5 new/modified files + tests

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Offline-First & Zero-Network | PASS | No network calls. Uses local drift DB only. No new dependencies that phone home. |
| II. On-Device Privacy | PASS | All data stored locally in SQLite. No new permissions requested. No analytics. |
| III. Frictionless UX | PASS | Target: entry in ≤ 30s. Sensible time defaults, platform pickers, inline validation, single-tap quality selector. |
| IV. Test-Driven Quality | PASS | Widget tests for all form states (create, edit, validation errors). Unit tests not needed — DB layer already tested in D1. |
| V. Incremental Delivery | PASS | D2 builds on D0 (routing/theme) and D1 (database). Screen is independently testable and demonstrable. |
| VI. Brand Compliance | PASS | Uses existing `AppTheme.dark`. Form inputs follow brand kit tokens: surface bg, fintech border, 12px radius, orange focus ring, min 44px touch targets. |

**Gate result**: ALL PASS — proceed to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/003-log-entry-screen/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── log-entry-screen-contract.md
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── screens/
│   └── log_entry_screen.dart      # MODIFY — replace placeholder with full form
├── providers/
│   ├── database_providers.dart    # EXISTS — appDatabaseProvider (no changes)
│   └── log_entry_providers.dart   # NEW — providers for form state + save logic
├── widgets/
│   └── quality_selector.dart      # NEW — reusable 1–5 quality rating widget
├── database/
│   └── app_database.dart          # EXISTS — no changes (CRUD already complete)
├── models/
│   └── sleep_entry_model.dart     # EXISTS — no changes (inputs/validation complete)
├── routing/
│   └── app_router.dart            # EXISTS — no changes (route already configured)
└── theme/
    └── app_theme.dart             # MODIFY — add InputDecorationTheme for form fields

test/
├── screens/
│   └── log_entry_screen_test.dart # MODIFY — replace placeholder tests with full coverage
└── widgets/
    └── quality_selector_test.dart # NEW — widget tests for quality selector
```

**Structure Decision**: Follows existing Flutter project layout. New files are minimal: one provider file, one reusable widget, and test coverage. The form lives in the existing `LogEntryScreen` file. Theme is extended with `InputDecorationTheme` for brand-compliant form styling.

## Complexity Tracking

No constitution violations to justify. The implementation is straightforward:
- Reuses existing routing, DB, providers, and theme infrastructure
- Adds one new provider file (form state management)
- Adds one new reusable widget (quality selector)
- Extends the existing theme (InputDecorationTheme)

## Post-Design Constitution Re-Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Offline-First & Zero-Network | PASS | No new dependencies. `intl` is already in pubspec (used for date formatting). |
| II. On-Device Privacy | PASS | No new permissions. No data leaves device. |
| III. Frictionless UX | PASS | Smart defaults (22:00/07:00), tap-based quality selector, platform-native pickers, inline validation. |
| IV. Test-Driven Quality | PASS | Widget tests for create mode, edit mode, all validation paths, quality selector, note field. Tests use in-memory DB + ProviderScope overrides. |
| V. Incremental Delivery | PASS | D2 depends only on D0+D1 (both complete). Screen is self-contained and demonstrable. |
| VI. Brand Compliance | PASS | InputDecorationTheme uses brand tokens (surface bg, fintech border, 12px radius, orange focus ring). Quality selector uses orange for selected state, 44px touch targets. |

**Post-design gate result**: ALL PASS.
