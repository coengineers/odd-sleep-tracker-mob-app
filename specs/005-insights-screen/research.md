# Research: Insights Screen

**Feature**: 005-insights-screen
**Date**: 2026-02-10

## R1: fl_chart Line Chart Configuration

**Decision**: Use `LineChart` from fl_chart with `FlSpot` data points. Only plot spots for days with data; fl_chart natively connects spots with line segments, skipping gaps.

**Rationale**: fl_chart is already a dependency (^1.1.1) used for the Home mini bar chart. The `LineChart` widget is part of the same package. No additional dependency needed.

**Alternatives considered**:
- `syncfusion_flutter_charts`: More features but adds a large dependency and requires a licence for commercial use. Violates constitution principle of minimal dependencies.
- Custom `CustomPaint`: Maximum control but significant development effort for standard chart behaviour.

## R2: Multi-Entry Day Aggregation Strategy

**Decision**: Aggregate at the provider/service layer in Dart, not with SQL GROUP BY.

**Rationale**: The existing `listEntries()` method returns raw `SleepEntry` records with date-range filtering. Aggregating in Dart keeps the database layer unchanged (no schema or query modifications to existing code). With a maximum of ~365 entries, in-memory aggregation is negligible in cost.

**Alternatives considered**:
- SQL aggregation queries on `AppDatabase`: Would require adding new methods to `app_database.dart`, modifying D1 deliverable code. More efficient for large datasets but unnecessary at this scale.
- Drift views: Clean abstraction but adds schema complexity for a read-only use case.

## R3: Bedtime Consistency — Minutes-Since-Midnight Approach

**Decision**: Convert each bedtime to minutes-since-midnight (handling cross-midnight by adding 1440 if bedtime is after midnight but treating it as "late night"). Compute standard deviation. Map to plain-language buckets.

**Rationale**: Bedtimes cluster around midnight. A bedtime of 23:30 and 00:30 are 1 hour apart in reality but 1380 minutes apart in raw minutes-since-midnight. Solution: normalise all bedtimes to a window centred on midnight. If bedtime hour < 12 (morning), add 1440 to treat it as "past midnight" for continuity. This ensures 23:30 (1410 min) and 00:30 (1470 min after adjustment) are correctly 60 minutes apart.

**Alternatives considered**:
- Circular statistics (mean of angles): Mathematically correct for cyclic data, but over-engineered for this use case and harder to explain in tests.
- Range (max - min): Sensitive to outliers. A single unusual bedtime would skew the metric.

## R4: Best/Worst Day — Day-of-Week Grouping

**Decision**: Group 30-day entries by `DateTime.weekday` (1=Monday...7=Sunday). Compute average duration per weekday. The weekday with the highest average is "best"; lowest is "worst". Display as full day name (e.g., "Saturday").

**Rationale**: PRD FR-010 specifies "best day, worst day" in the summary. Using day-of-week rather than specific calendar date gives actionable, repeating insight ("You sleep best on Saturdays").

**Alternatives considered**:
- Specific calendar date: Less useful — tells the user about one particular day, not a pattern.
- Median instead of average: More robust to outliers, but with at most 4-5 entries per weekday in a 30-day window, average is sufficient and more intuitive.

## R5: Provider Architecture — Single Query, Derived Computations

**Decision**: One `insightsDataProvider` fetches all entries in the 30-day window via `db.listEntries(fromDate: thirtyDaysAgo, toDate: today)`. Derived providers (`durationChartProvider`, `qualityChartProvider`, `patternSummaryProvider`) read from this single provider and compute their specific aggregations using `insights_calculator.dart` functions.

**Rationale**: The 30-day query is a superset of the 7-day data. Running one DB query and deriving multiple views in memory is simpler and faster than multiple queries. Follows the pattern established by `recentDurationsProvider` in `home_providers.dart`.

**Alternatives considered**:
- Independent providers each querying the DB: Simpler provider code but 3 separate DB queries for the same screen. Wasteful.
- StreamProvider watching the table: Would auto-refresh on changes, but adds complexity. FutureProvider with manual invalidation (already the pattern used by Home) is simpler and matches existing architecture.

## R6: Chart Dimensions and Styling

**Decision**:
- 7-day bar chart: 200px height, y-axis showing hour labels (0h, 4h, 8h, 12h), x-axis showing day abbreviations. Bar width 24px, brand orange colour, rounded top corners.
- 30-day line chart: 200px height, y-axis 1–5 quality scale, x-axis showing date labels at ~weekly intervals. Line in brand orange, data points as small circles.
- Both charts wrapped in cards (`bg-surface` background, `rounded-xl`, `border-fintech` border) matching brand kit component patterns.

**Rationale**: 200px provides enough detail for insights while keeping both charts and summaries visible without excessive scrolling. The existing mini chart (120px) is intentionally compact; insights charts deserve more vertical space for readability.

**Alternatives considered**:
- Full-screen charts: Takes too much space, pushes summaries below fold.
- Expandable/collapsible charts: Over-engineered for 2 simple charts.

## R7: Empty State Threshold

**Decision**: Show empty state only when zero entries exist. If at least 1 entry exists (even outside the 30-day window), show charts (which may be empty) and summaries with available data.

**Rationale**: The spec defines empty state for "zero entries". A user with old data should still see the Insights structure even if charts are empty — this signals that logging recent sleep will populate insights, rather than hiding the feature entirely.

**Alternatives considered**:
- Show empty state when no entries in last 30 days: Could confuse users who have historical data but see "no data" message.
- Partial empty states per section: Over-complicated. A single threshold is cleaner.
