# Quickstart: Insights Screen

**Feature**: 005-insights-screen
**Branch**: `005-insights-screen`

## Prerequisites

- Flutter 3.38+ installed (`flutter --version`)
- On branch `005-insights-screen` (`git checkout 005-insights-screen`)
- Dependencies installed (`flutter pub get`)
- Drift codegen up to date (`dart run build_runner build --delete-conflicting-outputs`)

## Build & Run

```bash
# Run on connected device / simulator
flutter run

# Navigate to Insights tab (3rd tab in bottom nav)
```

## Run Tests

```bash
# All tests
flutter test

# Insights-specific tests only
flutter test test/screens/insights_screen_test.dart
flutter test test/services/insights_calculator_test.dart
flutter test test/providers/insights_providers_test.dart

# With verbose output
flutter test --reporter expanded test/services/insights_calculator_test.dart
```

## Lint

```bash
flutter analyze
```

## Key Files to Edit

| File | Action | Purpose |
|------|--------|---------|
| `lib/services/insights_calculator.dart` | CREATE | Pure computation logic |
| `lib/providers/insights_providers.dart` | CREATE | Data providers for Insights screen |
| `lib/widgets/duration_bar_chart.dart` | CREATE | 7-day bar chart widget |
| `lib/widgets/quality_line_chart.dart` | CREATE | 30-day quality line chart widget |
| `lib/widgets/pattern_summary_card.dart` | CREATE | Summary metrics card widget |
| `lib/screens/insights_screen.dart` | MODIFY | Replace placeholder with full UI |
| `test/services/insights_calculator_test.dart` | CREATE | Unit tests for computations |
| `test/providers/insights_providers_test.dart` | CREATE | Provider integration tests |
| `test/screens/insights_screen_test.dart` | MODIFY | Replace placeholder tests |

## Implementation Order

1. `insights_calculator.dart` + `insights_calculator_test.dart` — pure logic first, fully testable
2. `insights_providers.dart` + `insights_providers_test.dart` — wire providers to calculator
3. `duration_bar_chart.dart` — 7-day chart widget
4. `quality_line_chart.dart` — 30-day chart widget
5. `pattern_summary_card.dart` — summary display widget
6. `insights_screen.dart` + `insights_screen_test.dart` — assemble screen, update tests

## Seed Data for Manual Testing

To manually test with sample data, use the Log Entry screen to create entries with various dates/qualities, or temporarily add a seed method in debug mode:

```dart
// In a debug/dev context only:
final db = AppDatabase.production();
for (var i = 0; i < 30; i++) {
  final wake = DateTime.now().subtract(Duration(days: i));
  final bedtime = wake.subtract(Duration(hours: 6 + (i % 4), minutes: (i * 13) % 60));
  await db.createEntry(CreateSleepEntryInput(
    bedtimeTs: bedtime,
    wakeTs: wake,
    quality: (i % 5) + 1,
  ));
}
```
