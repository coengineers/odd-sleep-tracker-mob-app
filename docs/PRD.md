```yaml
prd_version: 1.0
product: SleepLog (Local Sleep Tracker)
doc_owner: Greta
last_updated: 2026-02-08
status: draft
tech_stack:
  client:
    - Flutter (stable)
    - Dart
    - go_router (navigation)
    - Riverpod (state management)
    - drift (SQLite ORM + migrations)  # uses SQLite on-device
    - fl_chart (charts)
    - intl (date/time formatting)
    - uuid (ids)
  backend:
    - none (offline-first, on-device only)
repositories:
  - <repo name or url>
environments:
  - name: dev
    notes: Flutter run on simulator/emulator
  - name: prod
    notes: iOS + Android builds, local DB migrations included
```

## 1) TL;DR

* **Problem:** People want a simple way to track sleep and spot patterns without accounts, wearables, or cloud storage.
* **Solution:** A 4-screen, on-device sleep log that captures bedtime/wake time + quality rating, shows history, and surfaces simple insights with charts.
* **Success metrics (3–5):**

  * M1: User can add a sleep entry in ≤ 30 seconds (median).
  * M2: Home renders in ≤ 500ms with 365 entries (cold start excluded) on mid-range devices.
  * M3: Crash-free sessions ≥ 99% in production.
  * M4: Data remains on-device (no network calls; verified via inspection).
* **Out of scope (top 3):**

  * OOS1: Accounts / sign-in / cloud sync / backups.
  * OOS2: Wearables integration (Apple Health / Google Fit / Oura).
  * OOS3: Sleep stages, audio recording, smart alarm.
* **Deliverables:** D0–D5 (Section 10)

---

## 2) Goals and Non-Goals

### Goals (MUST)

* G1: Provide a frictionless way to log sleep (bedtime, wake time, 1–5 quality).
* G2: Let users review, correct, and delete entries easily.
* G3: Provide lightweight insights (7-day duration bars, 30-day quality trend, plain-English patterns).
* G4: Keep everything offline and stored locally on the phone.

### Non-Goals (NOT doing in v1)

* NG1: Any user identity, profiles, or cross-device sync.
* NG2: Advanced recommendations (coaching, plans, nudges).
* NG3: Complex journaling (tags/mood/caffeine) beyond a single optional note field (if included).

---

## 3) Users and Key Flows

### Personas

* P1: Busy professional who wants quick tracking with no setup.
* P2: Curious self-improver who wants basic trend insights.

### Key journeys

* J1: **First use → log sleep**

  1. Open app → Home (empty state)
  2. Tap “Log sleep”
  3. Enter bedtime + wake time + quality (1–5)
  4. Save → Home shows summary + mini chart

* J2: **Review history → fix mistake**

  1. Open History
  2. See list of entries (latest first)
  3. Tap an entry to edit OR swipe to delete with confirmation/undo

* J3: **Check patterns**

  1. Open Insights
  2. See 7-day duration bar chart + 30-day quality line chart
  3. Read plain-English summaries (average duration, consistency, best/worst)

---

## 4) Functional Requirements (FR)

### FR list

**FR-001: App MUST run fully offline and MUST NOT require account creation.**

* **Acceptance (BDD):**

  * Given the device is in airplane mode
    When the user opens and uses all screens
    Then all features work and no network requests are made

**FR-002: App MUST allow creating a sleep entry with bedtime, wake time, and quality rating (1–5).**

* **Acceptance (BDD):**

  * Given the Log Entry screen
    When the user enters bedtime, wake time, selects quality 1–5 and taps Save
    Then an entry is persisted locally and is visible in History and Home

**FR-003: App MUST support sleep sessions that cross midnight.**

* **Acceptance (BDD):**

  * Given bedtime is 23:30 and wake time is 07:30 next day
    When the user saves
    Then duration is computed correctly (8 hours) and the entry is assigned to the wake date

**FR-004: App MUST validate inputs and prevent impossible entries.**

* **Acceptance (BDD):**

  * Given bedtime and wake time inputs
    When duration ≤ 0 or duration > 24 hours
    Then Save is blocked and an inline validation message is shown

**FR-005: Home screen MUST show “today’s sleep summary” based on the most recent entry with wake date = today (local time).**

* **Acceptance (BDD):**

  * Given at least one entry exists with wake date = today
    When the user opens Home
    Then Home shows duration, quality rating, and a mini chart snippet

**FR-006: History screen MUST list all past entries (latest first) with key fields.**

* **Acceptance (BDD):**

  * Given multiple entries exist
    When the user opens History
    Then entries are shown newest-first with date, duration, and quality

**FR-007: History MUST support swipe-to-delete with confirmation and undo.**

* **Acceptance (BDD):**

  * Given an entry in History
    When the user swipes to delete and confirms
    Then the entry is removed from local storage
    And an Undo option is available for 5 seconds

**FR-008: Log Entry MUST support editing an existing entry.**

* **Acceptance (BDD):**

  * Given an existing entry
    When the user edits values and saves
    Then the stored entry updates and insights reflect the change

**FR-009: Insights MUST show a 7-day duration bar chart and a 30-day quality line chart.**

* **Acceptance (BDD):**

  * Given at least 7 entries in last 7 days
    When the user opens Insights
    Then a 7-day bar chart displays duration per day
  * Given at least 1 entry in last 30 days
    When the user opens Insights
    Then a line chart displays quality trend across the period

**FR-010: Insights MUST include plain-English pattern summaries derived from local data.**

* **Acceptance (BDD):**

  * Given entries exist in the last 30 days
    When the user opens Insights
    Then the app displays at least: avg duration (7d/30d), avg quality (30d), bedtime consistency, best day, worst day

**FR-011: App MUST provide empty states for Home/History/Insights when there is insufficient data.**

* **Acceptance (BDD):**

  * Given zero entries
    When the user opens any screen
    Then an empty state with CTA “Log sleep” is shown

**FR-012: App SHOULD allow an optional note per entry (single short text field).**

* **Acceptance (BDD):**

  * Given the Log Entry screen
    When the user adds a note and saves
    Then the note is stored and viewable in entry edit/details

---

## 5) Non-Functional Requirements (NFR)

**NFR-001 (Privacy/Security):** No sleep data leaves the device.

* Threshold: 0 app-initiated external network requests.
* Test: Run app under a proxy / OS network monitor; confirm no requests; code scan to ensure no HTTP client usage.

**NFR-002 (Performance):**

* Threshold: Home + History render ≤ 500ms with 365 entries (excluding cold start).
* Test: Seed DB with 365 entries; measure via Flutter DevTools timeline; ensure ListView.builder virtualization.

**NFR-003 (Reliability/Data Integrity):**

* Threshold: No data loss across app restarts; drift migrations preserve entries.
* Test: Create entries → restart app → verify; migration test from previous schema.

**NFR-004 (Accessibility):**

* Threshold: All controls have semantic labels; supports larger text sizes where practical.
* Test: TalkBack/VoiceOver pass; check tappable targets and semantics.

**NFR-005 (Offline-first):**

* Threshold: Full feature parity in airplane mode.
* Test: Manual QA in airplane mode + integration tests.

---

## 6) Data & Contracts

### 6.1 Data model (SQLite via drift)

**sleep_entries**

* `id TEXT PRIMARY KEY` (uuid)
* `wake_date TEXT NOT NULL` (`YYYY-MM-DD`, derived from wake time in local timezone)
* `bedtime_ts TEXT NOT NULL` (ISO datetime local)
* `wake_ts TEXT NOT NULL` (ISO datetime local)
* `duration_minutes INTEGER NOT NULL` (computed on save)
* `quality INTEGER NOT NULL` (1–5)
* `note TEXT NULL` (optional, max 280 chars)
* `created_at TEXT NOT NULL`
* `updated_at TEXT NOT NULL`

Indexes:

* index on `wake_date`
* index on `wake_ts`

Constraints:

* `quality` in [1..5]
* `0 < duration_minutes <= 1440`

### 6.2 Repository contracts (local)

**SleepEntryRepository.create(input)**

* Request:

```json
{
  "bedtime_ts": "2026-02-07T23:30:00",
  "wake_ts": "2026-02-08T07:30:00",
  "quality": 4,
  "note": "Fell asleep quickly"
}
```

* Response:

```json
{
  "id": "uuid",
  "wake_date": "2026-02-08",
  "duration_minutes": 480
}
```

* Errors:

  * `invalid_time_range`
  * `invalid_quality`

**SleepEntryRepository.list({fromDate?, toDate?, limit?, offset?})**
**SleepEntryRepository.update(id, patch)**
**SleepEntryRepository.delete(id)**

### 6.3 Permissions

* MUST NOT request microphone/contacts/location.
* MUST NOT add analytics SDKs that transmit data off-device in v1.

---

## 7) UX Spec

### Screens

1. Home: today’s summary + mini chart + CTA.
2. Log Entry: create/edit entry.
3. History: list entries; swipe delete; tap edit.
4. Insights: charts + summaries.

### Navigation

* Home → Log Entry (new)
* Home → Log Entry (edit today if exists)
* Home → History
* Home → Insights
* History → Log Entry (edit)

### Per-screen notes

**Home**

* Empty state: “No sleep logged yet. Add last night’s sleep to start tracking.”
* Shows: duration (h m), quality (1–5), mini chart (e.g., last 7 days sparkline/bars)

**Log Entry**

* Inputs: bedtime picker, wake picker, quality selector (1–5), optional note
* Validation: duration between 1 min and 24h; cross-midnight supported
* Error copy: “Wake time must be after bedtime (within 24 hours).”

**History**

* Virtualised list (ListView.builder)
* Swipe-to-delete: use Slidable or Dismissible + confirm + SnackBar Undo (5s)

**Insights**

* 7-day duration bar chart
* 30-day quality line chart
* Summaries: averages, consistency, best/worst

---

## 8) Telemetry & Ops (v1 default: none)

* No remote analytics in v1.
* Optional: local-only debug logging (dev builds only).

---

## 9) Risks & Edge Cases

**Risks**

* Time/date confusion (cross-midnight, DST) → store full timestamps; derive `wake_date` on save; show explicit dates in UI.
* Chart integration differences on iOS/Android → choose one chart library (fl_chart) and test early.

**Edge cases**

* Multiple entries for same `wake_date` allowed (v1). Home uses the latest wake time for “today”.
* DST changes may skew duration by ±60 minutes depending on local conversion—acceptable in v1, document behaviour.

**Open questions**

* Enforce one entry per day vs allow multiple?
* “Today’s sleep” = wake date today vs most recent entry?
* Include note field in v1 or keep form minimal?

---

## 10) Deliverables Plan (Agent Build Units)

### D0 — Flutter scaffold & navigation

* **Objective:** App boots with routing + screen shells + shared UI.
* **Scope:** FR-001 navigation map + basic theming
* **Tech choices:** Flutter + go_router; Riverpod setup (providers folder)
* **Artifacts:**

  * Flutter project, routes for Home/Log/History/Insights
  * Basic layout, bottom nav or simple home links (choose one and keep consistent)
  * README: run/lint/test
* **Acceptance (BDD):**

  * Given a fresh install
    When the user opens the app
    Then Home renders and navigation reaches all 4 screens

### D1 — Local database + repository layer (drift)

* **Objective:** Local persistence + migrations.
* **Scope:** Section 6 + FR-002/003/004/006/008
* **Artifacts:**

  * drift DB schema + migration strategy
  * Repository with CRUD + validation + duration calculation
  * Unit tests (flutter_test) for compute + CRUD using in-memory sqlite where possible
* **Acceptance:** create/list/update/delete work and enforce constraints.

### D2 — Log Entry screen (create/edit)

* **Objective:** Users can add/edit entries with solid validation UX.
* **Scope:** FR-002/003/004/008/012
* **Implementation notes:**

  * Use Form + validators (or formz) and platform date/time pickers
  * On save: compute duration, derive wake_date, write to DB
* **Artifacts:** UI + tests for validation paths.

### D3 — Home + History screens

* **Objective:** Home summary + history list + delete/undo.
* **Scope:** FR-005/006/007/011
* **Implementation notes:**

  * History: ListView.builder, Dismissible/Slidable, confirm dialog, SnackBar Undo
  * Home: query “today’s entry” + mini chart input
* **Artifacts:** UI + tests for delete/undo and “today summary” selection.

### D4 — Insights screen (charts + summaries)

* **Objective:** Charts + plain-English patterns.
* **Scope:** FR-009/010/011
* **Implementation notes:**

  * Aggregation queries (7d, 30d) in repository/service layer
  * fl_chart for bar + line
  * Missing days handled gracefully (gaps or zero values—define behaviour in code comments)
* **Artifacts:** UI + aggregation tests.

### D5 — Polish, QA, release readiness

* **Objective:** Stabilise UX, accessibility, and reliability.
* **Scope:** NFR-001/003/004/005 + regression pass
* **Artifacts:**

  * Integration tests (integration_test) for key journeys
  * Seed/debug tools (dev-only) to populate sample entries
  * Release checklist + known limitations (DST, multiple entries/day)
* **Acceptance:** Airplane-mode QA passes; no network calls observed; crash-free smoke.