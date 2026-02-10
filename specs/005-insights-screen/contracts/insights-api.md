# Internal API Contracts: Insights Screen

**Feature**: 005-insights-screen
**Date**: 2026-02-10

This feature has no external API. All contracts are internal Dart interfaces between the provider layer, computation service, and widget layer.

## Service Layer: `InsightsCalculator`

Pure static functions. No state, no side effects, no database access.

### `computeDurationChart`

```dart
/// Computes 7-day duration data points for the bar chart.
///
/// Returns exactly 7 [DurationDataPoint]s sorted oldest → newest,
/// covering [today - 6 days] through [today].
/// Each point's durationMinutes is the SUM of all entries for that day.
/// Days with no entries have durationMinutes = 0.
static List<DurationDataPoint> computeDurationChart(
  List<SleepEntry> entries,
  DateTime today,
)
```

**Input**: All entries within the 30-day window (superset), `today` as local date.
**Output**: Exactly 7 `DurationDataPoint` records.
**Invariants**:
- Result always has exactly 7 elements
- Result is sorted by date ascending
- `durationMinutes >= 0` for all elements

### `computeQualityChart`

```dart
/// Computes 30-day quality data points for the line chart.
///
/// Returns 0–30 [QualityDataPoint]s sorted oldest → newest,
/// covering [today - 29 days] through [today].
/// Only days with at least one entry are included.
/// Each point's averageQuality is the MEAN of all entries' quality
/// for that day, rounded to 1 decimal place.
static List<QualityDataPoint> computeQualityChart(
  List<SleepEntry> entries,
  DateTime today,
)
```

**Input**: All entries within the 30-day window, `today` as local date.
**Output**: 0 to 30 `QualityDataPoint` records (only days with data).
**Invariants**:
- Result is sorted by date ascending
- `1.0 <= averageQuality <= 5.0` for all elements
- No duplicate dates

### `computePatternSummary`

```dart
/// Computes plain-English pattern summary from entries in the 30-day window.
///
/// Returns a [PatternSummary] with averages, consistency text, and best/worst day.
/// If [entries] is empty, returns zero averages and null best/worst day.
static PatternSummary computePatternSummary(
  List<SleepEntry> entries,
  DateTime today,
)
```

**Input**: All entries within the 30-day window, `today` as local date.
**Output**: Single `PatternSummary` instance.
**Invariants**:
- `avgDuration7d >= 0`, `avgDuration30d >= 0`
- `0.0 <= avgQuality30d <= 5.0` (0.0 only when no entries)
- `consistencyText` is never empty
- `bestDay` and `worstDay` are both null or both non-null

## Provider Layer: `insights_providers.dart`

### `insightsDataProvider`

```dart
/// Fetches all sleep entries within the last 30 days.
/// This is the single data source for all insights computations.
final insightsDataProvider = FutureProvider<List<SleepEntry>>((ref) async {
  // Queries db.listEntries(fromDate: thirtyDaysAgo, toDate: today)
});
```

**Depends on**: `appDatabaseProvider`
**Returns**: `List<SleepEntry>` ordered by wakeTs descending

### `durationChartProvider`

```dart
/// Derived: 7-day duration chart data from insightsDataProvider.
final durationChartProvider = FutureProvider<List<DurationDataPoint>>((ref) async {
  // Reads insightsDataProvider, calls InsightsCalculator.computeDurationChart
});
```

**Depends on**: `insightsDataProvider`
**Returns**: Exactly 7 `DurationDataPoint` records

### `qualityChartProvider`

```dart
/// Derived: 30-day quality trend data from insightsDataProvider.
final qualityChartProvider = FutureProvider<List<QualityDataPoint>>((ref) async {
  // Reads insightsDataProvider, calls InsightsCalculator.computeQualityChart
});
```

**Depends on**: `insightsDataProvider`
**Returns**: 0–30 `QualityDataPoint` records

### `patternSummaryProvider`

```dart
/// Derived: Pattern summary from insightsDataProvider.
final patternSummaryProvider = FutureProvider<PatternSummary>((ref) async {
  // Reads insightsDataProvider, calls InsightsCalculator.computePatternSummary
});
```

**Depends on**: `insightsDataProvider`
**Returns**: Single `PatternSummary` instance

## Widget Layer Contracts

### `DurationBarChart`

```dart
class DurationBarChart extends StatelessWidget {
  const DurationBarChart({super.key, required this.data});
  final List<DurationDataPoint> data; // Exactly 7 items
}
```

**Renders**: fl_chart `BarChart` with 7 bars, y-axis in hours, x-axis day abbreviations.

### `QualityLineChart`

```dart
class QualityLineChart extends StatelessWidget {
  const QualityLineChart({super.key, required this.data});
  final List<QualityDataPoint> data; // 0–30 items
}
```

**Renders**: fl_chart `LineChart` with data points connected by line. Y-axis 1–5 quality scale.

### `PatternSummaryCard`

```dart
class PatternSummaryCard extends StatelessWidget {
  const PatternSummaryCard({super.key, required this.summary});
  final PatternSummary summary;
}
```

**Renders**: Card with 6 metric rows: avg duration 7d, avg duration 30d, avg quality 30d, bedtime consistency, best day, worst day.
