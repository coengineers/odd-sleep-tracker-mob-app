# Feature Specification: Insights Screen (Charts + Summaries)

**Feature Branch**: `005-insights-screen`
**Created**: 2026-02-10
**Status**: Draft
**Input**: User description: "Implement D4 — Insights screen from PRD"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View 7-Day Sleep Duration Chart (Priority: P1)

A user opens the Insights tab to see how long they've been sleeping over the past week. They see a bar chart where each bar represents one night's sleep duration. Days with no logged entry show an empty gap (no bar). The chart gives them an at-a-glance picture of their recent sleep quantity.

**Why this priority**: The 7-day duration bar chart is the primary visual insight and the most immediately useful feedback for users tracking sleep patterns.

**Independent Test**: Can be fully tested by seeding 7 days of entries, opening Insights, and verifying 7 bars with correct heights and day labels. Delivers visual sleep-quantity feedback as standalone value.

**Acceptance Scenarios**:

1. **Given** at least 1 entry exists in the last 7 days, **When** the user opens the Insights tab, **Then** a bar chart is displayed showing duration (in hours) for each of the last 7 days, with day-of-week labels on the x-axis.
2. **Given** entries exist for 5 of the last 7 days, **When** the user opens the Insights tab, **Then** the 2 missing days show no bar (zero height) and the 5 days with entries show correct durations.
3. **Given** a day has multiple entries, **When** the user opens the Insights tab, **Then** that day's bar reflects the total duration of all entries for that day.

---

### User Story 2 - View 30-Day Quality Trend Line Chart (Priority: P1)

A user wants to understand how their sleep quality has trended over the past month. They see a line chart plotting their quality rating (1–5 scale) over 30 days. Only days with logged entries have data points; the line connects consecutive data points, skipping days without entries.

**Why this priority**: The quality trend chart provides the second core visual insight (FR-009 in PRD) and is essential for the "check patterns" user journey.

**Independent Test**: Can be tested by seeding entries across 30 days with varying quality ratings, opening Insights, and verifying the line chart shows correct data points and connects them.

**Acceptance Scenarios**:

1. **Given** at least 1 entry exists in the last 30 days, **When** the user opens the Insights tab, **Then** a line chart is displayed showing quality ratings (y-axis 1–5) over the 30-day period.
2. **Given** entries exist for 15 of the last 30 days, **When** the user opens the Insights tab, **Then** data points appear only for days with entries, and the line connects consecutive points.
3. **Given** a day has multiple entries, **When** the user opens the Insights tab, **Then** that day's data point reflects the average quality rating (rounded to one decimal) of all entries for that day.

---

### User Story 3 - Read Plain-English Pattern Summaries (Priority: P1)

A user scrolls below the charts to find plain-English summaries of their sleep patterns. These summaries include average sleep duration (7-day and 30-day), average quality (30-day), bedtime consistency, and identification of their best and worst sleep days.

**Why this priority**: Plain-English summaries make insights accessible to all users, not just those who interpret charts easily. Required by FR-010 in PRD.

**Independent Test**: Can be tested by seeding entries with known values, opening Insights, and verifying all five summary metrics display correct computed values.

**Acceptance Scenarios**:

1. **Given** entries exist in the last 30 days, **When** the user opens the Insights tab, **Then** the following summaries are displayed:
   - Average sleep duration (last 7 days), e.g., "7h 32m"
   - Average sleep duration (last 30 days), e.g., "7h 15m"
   - Average quality (last 30 days), e.g., "3.8 / 5"
   - Bedtime consistency, e.g., "Your bedtime varies by about 45 minutes"
   - Best day (day of week with highest average duration), e.g., "Saturday"
   - Worst day (day of week with lowest average duration), e.g., "Wednesday"
2. **Given** entries exist in the last 7 days but not in the prior 23 days, **When** the user opens Insights, **Then** the 7-day averages compute from the available entries, the 30-day averages compute from the same entries (since they are all within 30 days), and best/worst days compute from available data only.
3. **Given** only 1 entry exists, **When** the user opens Insights, **Then** summaries still display using that single entry's data (e.g., best day and worst day show the same day, consistency shows "Not enough data for consistency").

---

### User Story 4 - See Empty State When No Data Exists (Priority: P2)

A new user opens the Insights tab before logging any sleep entries. Instead of empty charts, they see a friendly empty state message encouraging them to log their first entry, with a clear call-to-action.

**Why this priority**: Empty state handling is required (FR-011 in PRD) but is not the primary use case — most users reaching Insights will have some data.

**Independent Test**: Can be tested with a fresh database (zero entries), opening Insights, and verifying the empty state message and CTA appear.

**Acceptance Scenarios**:

1. **Given** zero entries exist, **When** the user opens the Insights tab, **Then** a friendly message is displayed: "Not enough data for insights yet. Log a few nights of sleep to start seeing patterns." along with a "Log sleep" button.
2. **Given** zero entries exist, **When** the user taps the "Log sleep" button in the empty state, **Then** the app navigates to the Log Entry screen in create mode.

---

### Edge Cases

- What happens when there is exactly 1 entry in the database? Charts display a single bar / single data point; summaries compute from that one entry.
- What happens when all entries have the same quality rating? The line chart is flat; average quality equals the common rating.
- What happens when a day has multiple entries? Duration bars show the total duration for that day; quality line shows the average quality for that day.
- How are entries from more than 30 days ago treated? They are excluded from all charts and summaries. Insights always reflects the most recent 30-day window.
- What if the user's most recent entry is older than 7 days? The 7-day bar chart shows all empty bars; the 30-day chart may still have data points if entries fall within 30 days.
- How is bedtime consistency calculated? Standard deviation of bedtime (time-of-day component only) across entries in the 30-day window, expressed as an approximate range in plain language (e.g., "about 30 minutes" or "over 2 hours").

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Insights screen MUST display a 7-day sleep duration bar chart showing one bar per day for the last 7 calendar days (including today).
- **FR-002**: The 7-day bar chart MUST display duration in hours on the y-axis and day-of-week labels on the x-axis.
- **FR-003**: Days with no logged entries MUST show zero-height bars (no bar visible) in the 7-day chart.
- **FR-004**: Days with multiple entries MUST show total combined duration in the 7-day bar chart.
- **FR-005**: Insights screen MUST display a 30-day quality trend line chart plotting quality rating (1–5 scale) over the last 30 calendar days.
- **FR-006**: The 30-day line chart MUST plot data points only for days that have logged entries, connecting consecutive data points with a line.
- **FR-007**: Days with multiple entries MUST show the average quality rating (rounded to one decimal) in the 30-day line chart.
- **FR-008**: Insights screen MUST display the following plain-English pattern summaries derived from local data:
  - Average sleep duration over the last 7 days
  - Average sleep duration over the last 30 days
  - Average sleep quality over the last 30 days
  - Bedtime consistency over the last 30 days (expressed as approximate variation range)
  - Best day of the week (highest average duration)
  - Worst day of the week (lowest average duration)
- **FR-009**: Summaries MUST update dynamically based on available data; if fewer entries exist than the window size, summaries MUST compute from whatever entries are available within the window.
- **FR-010**: When zero entries exist, the Insights screen MUST display an empty state with a descriptive message and a "Log sleep" call-to-action button that navigates to the Log Entry screen.
- **FR-011**: The empty state MUST be replaced by charts and summaries as soon as at least one entry exists.
- **FR-012**: Bedtime consistency MUST be expressed in plain language (e.g., "Your bedtime varies by about 45 minutes") and MUST show "Not enough data for consistency" when fewer than 2 entries exist in the 30-day window.
- **FR-013**: Best/worst day identification MUST be based on average duration per day of week, using only data from the last 30 days.

### Key Entities

- **Sleep Entry**: The existing persisted entry containing bedtime, wake time, duration, quality, and date — the source data for all insights computations.
- **Duration Data Point**: A per-day aggregation of sleep duration (date + total minutes) used to render the 7-day bar chart.
- **Quality Data Point**: A per-day aggregation of sleep quality (date + average rating) used to render the 30-day line chart.
- **Pattern Summary**: A computed set of metrics (averages, consistency, best/worst) derived from entries within a date range.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their 7-day sleep duration pattern within 1 second of opening the Insights tab (with up to 365 entries in the database).
- **SC-002**: All five pattern summaries (7d avg duration, 30d avg duration, 30d avg quality, bedtime consistency, best/worst day) are displayed and computed correctly — verified against manually calculated expected values in test data.
- **SC-003**: New users see a clear empty state with actionable guidance, and can navigate to log their first entry in one tap.
- **SC-004**: Charts and summaries correctly handle edge cases (single entry, missing days, multiple entries per day) without errors or misleading displays.
- **SC-005**: The Insights screen works fully offline with no network requests, consistent with the app's on-device-only architecture.

## Assumptions

- The existing database schema (`sleep_entries` table) and repository methods (`listEntries` with date filters) provide sufficient data access for building insights. No schema changes are needed.
- The 7-day and 30-day windows are always computed relative to today's local date (not UTC).
- "Best day" and "worst day" refer to the day of the week (e.g., "Saturday"), not a specific calendar date.
- Bedtime consistency uses the standard deviation of bedtime-of-day (hour:minute) across entries, converted to a human-readable approximate range.
- When a day has multiple entries, duration is summed (total sleep that day) and quality is averaged.
- Charts use the app's existing dark theme and brand color palette.

## Dependencies

- Existing `AppDatabase` with `listEntries()` method for date-range queries.
- Existing routing: `/insights` route is already configured.
- Existing `recentDurationsProvider` (7-day duration data) — may be reused or adapted.
- Chart library already available as a project dependency.
- Date formatting library already available as a project dependency.
