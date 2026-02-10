# Navigation Contracts: Flutter Scaffold & Navigation (D0)

**Branch**: `001-flutter-scaffold-nav` | **Date**: 2026-02-09

## Route Table

| Path | Screen | Method | Parameters | Back Target |
|------|--------|--------|------------|-------------|
| `/` | HomeScreen | Initial | None | N/A (root) |
| `/log` | LogEntryScreen | `context.push('/log')` | `?id=<uuid>` (optional query param) | Home or History |
| `/history` | HistoryScreen | `context.push('/history')` | None | Home |
| `/insights` | InsightsScreen | `context.push('/insights')` | None | Home |

## Navigation Flows

### Home -> LogEntry (new)

```text
Trigger: User taps "Log sleep" CTA on Home
Action:  context.push('/log')
Result:  LogEntryScreen renders with entryId = null (new mode)
Back:    Returns to Home
```

### Home -> LogEntry (edit today, future)

```text
Trigger: User taps edit on today's entry (future D3)
Action:  context.push('/log?id=<uuid>')
Result:  LogEntryScreen renders with entryId = <uuid> (edit mode)
Back:    Returns to Home
```

### Home -> History

```text
Trigger: User taps "History" link/button on Home
Action:  context.push('/history')
Result:  HistoryScreen renders
Back:    Returns to Home
```

### Home -> Insights

```text
Trigger: User taps "Insights" link/button on Home
Action:  context.push('/insights')
Result:  InsightsScreen renders
Back:    Returns to Home
```

### History -> LogEntry (edit)

```text
Trigger: User taps an entry in History list (future D3)
Action:  context.push('/log?id=<uuid>')
Result:  LogEntryScreen renders with entryId = <uuid> (edit mode)
Back:    Returns to History
```

## Screen Widget Contracts

### HomeScreen

- **Type**: StatelessWidget (or ConsumerWidget for future D3)
- **Constructor**: `const HomeScreen()`
- **Displays**:
  - App title ("SleepLog")
  - Empty-state message: "No sleep logged yet. Add last night's
    sleep to start tracking."
  - "Log sleep" CTA button (primary, brand orange)
  - Navigation links to History and Insights
- **Navigation**: Pushes to `/log`, `/history`, `/insights`

### LogEntryScreen

- **Type**: StatelessWidget (shell in D0)
- **Constructor**: `LogEntryScreen({String? entryId})`
- **Displays**:
  - Title: "Log Entry" (new) or "Edit Entry" (when id provided)
  - Placeholder body text
- **Parameters**: Optional `entryId` from query param `?id=`

### HistoryScreen

- **Type**: StatelessWidget (shell in D0)
- **Constructor**: `const HistoryScreen()`
- **Displays**:
  - Title: "History"
  - Placeholder body text

### InsightsScreen

- **Type**: StatelessWidget (shell in D0)
- **Constructor**: `const InsightsScreen()`
- **Displays**:
  - Title: "Insights"
  - Placeholder body text

## Router Factory Contract

```dart
// lib/routing/app_router.dart
GoRouter createRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'log',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'];
            return LogEntryScreen(entryId: id);
          },
        ),
        GoRoute(
          path: 'history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: 'insights',
          builder: (context, state) => const InsightsScreen(),
        ),
      ],
    ),
  ],
);
```

## Test Contract

Each widget test MUST:
1. Create a fresh `GoRouter` via `createRouter()`
2. Wrap in `ProviderScope` + `MaterialApp.router`
3. Apply `AppTheme.dark` as the theme
4. Verify screen rendering and navigation independently
