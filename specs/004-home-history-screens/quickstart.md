# Quickstart: Home + History Screens

**Feature**: 004-home-history-screens
**Date**: 2026-02-10

## Prerequisites

Ensure D0, D1, and D2 are complete and merged:
- D0: Flutter scaffold with go_router navigation and bottom nav
- D1: drift database with `AppDatabase` and CRUD methods
- D2: Log Entry screen with create/edit modes

## Setup

### 1. Switch to the feature branch

```bash
git checkout 004-home-history-screens
```

### 2. Add fl_chart dependency

```bash
cd /Users/edval/gitwork/coengineers/odd-mobile-apps/odd-sleep-tracker-mob-app
flutter pub add fl_chart
```

### 3. Verify existing tests pass

```bash
flutter test
```

All D0/D1/D2 tests should pass before starting D3 work.

## Implementation Order

### Phase 1: Providers (no UI changes)

1. Create `lib/providers/home_providers.dart` with:
   - `todaySummaryProvider` — today's entry query
   - `recentDurationsProvider` — 7-day duration data points
   - `allEntriesProvider` — all entries for History

2. Write `test/providers/home_providers_test.dart`:
   - Test today summary with 0, 1, and multiple entries for today
   - Test recent durations with gaps, full 7 days, and empty DB
   - Test all entries ordering

### Phase 2: Mini Chart Widget

3. Create `lib/widgets/mini_duration_chart.dart`:
   - Accepts `List<({String date, int durationMinutes})>`
   - Renders a `BarChart` from fl_chart
   - Brand orange bars, dark surface background
   - Day-of-week labels on x-axis

4. Write `test/widgets/mini_duration_chart_test.dart`:
   - Renders without errors with valid data
   - Renders with all-zero data (empty state chart)
   - Correct number of bars (7)

### Phase 3: Home Screen

5. Replace `lib/screens/home_screen.dart`:
   - Convert to `ConsumerWidget`
   - Watch `todaySummaryProvider` and `recentDurationsProvider`
   - Show today's summary (duration, quality) when data exists
   - Show empty state with "Log sleep" CTA when no today entry
   - Show mini chart below summary
   - "Log sleep" CTA navigates to `/log` via `context.push`

6. Replace `test/screens/home_screen_test.dart`:
   - Test summary display with seeded entry
   - Test empty state when no entries
   - Test "Log sleep" CTA navigation
   - Test data refresh after returning from Log Entry

### Phase 4: History Screen

7. Replace `lib/screens/history_screen.dart`:
   - Convert to `ConsumerStatefulWidget`
   - Watch `allEntriesProvider`
   - `ListView.builder` with `Dismissible` items
   - Each item shows date, duration, quality
   - Tap item → `context.push('/log?id=$id')` for edit
   - Swipe → confirm dialog → delete → SnackBar with Undo
   - Empty state with "Log sleep" CTA

8. Replace `test/screens/history_screen_test.dart`:
   - Test list rendering with seeded entries
   - Test reverse chronological order
   - Test tap-to-edit navigation
   - Test swipe-to-delete with confirmation
   - Test undo restores entry
   - Test empty state

### Phase 5: Integration Polish

9. Update `ShellScaffold` if needed to support provider invalidation on FAB return.

10. Run full test suite:

```bash
flutter test
flutter analyze
```

## Key Files to Modify

| File | Action |
|------|--------|
| `pubspec.yaml` | Add `fl_chart` dependency |
| `lib/providers/home_providers.dart` | CREATE — new providers |
| `lib/widgets/mini_duration_chart.dart` | CREATE — bar chart widget |
| `lib/screens/home_screen.dart` | REPLACE — full Home implementation |
| `lib/screens/history_screen.dart` | REPLACE — full History implementation |
| `test/providers/home_providers_test.dart` | CREATE — provider unit tests |
| `test/widgets/mini_duration_chart_test.dart` | CREATE — chart widget tests |
| `test/screens/home_screen_test.dart` | REPLACE — Home screen tests |
| `test/screens/history_screen_test.dart` | REPLACE — History screen tests |

## Verification

After implementation, verify:

1. **Home screen**: Shows today's summary when an entry exists for today
2. **Home screen**: Shows empty state with CTA when no entries
3. **Home screen**: Mini chart shows 7 bars
4. **History screen**: Lists all entries newest-first
5. **History screen**: Swipe-to-delete with confirm → SnackBar undo works
6. **History screen**: Tap entry navigates to edit screen
7. **Empty states**: Both screens show CTA that navigates to Log Entry
8. **All tests pass**: `flutter test` exits with 0
9. **No warnings**: `flutter analyze` exits with 0
