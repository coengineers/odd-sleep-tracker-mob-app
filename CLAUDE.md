# Application Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-02-08

## Active Technologies
- N/A (no persistence in D0) (001-flutter-scaffold-nav)
- Dart 3.10+ / Flutter 3.38+ (stable channel) + drift ^2.31.0, drift_flutter ^0.2.0, uuid ^4.0.0, path_provider ^2.0.0 (runtime); drift_dev ^2.31.0, build_runner ^2.4.0 (dev) (002-local-db-repository)
- SQLite via drift (on-device only) (002-local-db-repository)
- Dart 3.10+ / Flutter 3.38+ (stable channel) + go_router ^17.1.0, flutter_riverpod ^3.2.1, drift ^2.31.0, intl (date formatting) (003-log-entry-screen)
- SQLite via drift (on-device only) — CRUD already implemented in D1 (`AppDatabase.createEntry`, `updateEntry`, `getEntryById`) (003-log-entry-screen)
- Dart 3.10+ / Flutter 3.38+ (stable channel) + go_router ^17.1.0, flutter_riverpod ^3.2.1, drift ^2.31.0, intl ^0.20.0, fl_chart (new — for mini bar chart) (004-home-history-screens)
- SQLite via drift (on-device only) — existing `AppDatabase` with full CRUD (004-home-history-screens)

- Dart 3.4+ / Flutter 3.22+ (stable channel) + go_router ^17.1.0, flutter_riverpod ^3.2.1, intl (date formatting) (001-flutter-scaffold-nav)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Dart 3.4+ / Flutter 3.22+ (stable channel)

## Code Style

Dart 3.4+ / Flutter 3.22+ (stable channel): Follow standard conventions

## Recent Changes
- 004-home-history-screens: Added Dart 3.10+ / Flutter 3.38+ (stable channel) + go_router ^17.1.0, flutter_riverpod ^3.2.1, drift ^2.31.0, intl ^0.20.0, fl_chart (new — for mini bar chart)
- 003-log-entry-screen: Added Dart 3.10+ / Flutter 3.38+ (stable channel) + go_router ^17.1.0, flutter_riverpod ^3.2.1, drift ^2.31.0, intl (date formatting)
- 002-local-db-repository: Added Dart 3.10+ / Flutter 3.38+ (stable channel) + drift ^2.31.0, drift_flutter ^0.2.0, uuid ^4.0.0, path_provider ^2.0.0 (runtime); drift_dev ^2.31.0, build_runner ^2.4.0 (dev)


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
