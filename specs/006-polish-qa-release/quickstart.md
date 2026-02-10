# Quickstart: D5 — Polish, QA & Release Readiness

## Prerequisites

- Flutter 3.38+ (stable channel)
- All D0–D4 code on branch `005-insights-screen` (merged to main)
- iOS Simulator or Android Emulator configured
- Physical device recommended for accessibility testing

## Setup

```bash
# Checkout the D5 branch
git checkout 006-polish-qa-release

# Install dependencies (integration_test is a Flutter SDK package, no pub fetch needed)
flutter pub get

# Verify existing tests pass before making changes
flutter test
```

## Development Workflow

### 1. Accessibility Improvements

Files to modify:
- `lib/widgets/shell_scaffold.dart` — FAB tooltip
- `lib/screens/home_screen.dart` — Semantics on loading/error states
- `lib/screens/history_screen.dart` — Semantics on entry tiles, loading/error
- `lib/screens/insights_screen.dart` — Semantics on chart cards, loading/error
- `lib/widgets/mini_duration_chart.dart` — Semantics wrapper with data summary
- `lib/widgets/duration_bar_chart.dart` — Semantics wrapper with data summary
- `lib/widgets/quality_line_chart.dart` — Semantics wrapper with data summary
- `lib/widgets/pattern_summary_card.dart` — Semantics label on container
- `lib/widgets/quality_selector.dart` — Replace hardcoded fontSize with theme

### 2. Seed Data Tool

New files:
- `lib/dev/seed_data.dart` — Seed function
- `test/dev/seed_data_test.dart` — Unit tests for seed logic

Modified files:
- `lib/screens/home_screen.dart` — Long-press trigger on AppBar title (debug only)

### 3. Integration Tests

New files:
- `integration_test/journey_log_sleep_test.dart` — J1 end-to-end
- `integration_test/journey_edit_delete_test.dart` — J2 end-to-end
- `integration_test/app_test_utils.dart` — Shared setup utilities

### 4. Release Documentation

New files:
- `docs/release-checklist.md` — QA steps, known limitations, build instructions

## Running Tests

```bash
# Unit and widget tests
flutter test

# Integration tests (requires running emulator/simulator)
flutter test integration_test/

# Run a specific integration test
flutter test integration_test/journey_log_sleep_test.dart

# Analysis (zero warnings required)
flutter analyze
```

## Accessibility Testing

```bash
# On Android emulator: enable TalkBack
# Settings > Accessibility > TalkBack > On

# On iOS simulator: enable VoiceOver
# Settings > Accessibility > VoiceOver > On

# Navigate through all four screens and verify all controls are announced
```

## Build Verification

```bash
# Verify release build compiles (no debug-only code leaks)
flutter build apk --release
flutter build ios --release --no-codesign
```
