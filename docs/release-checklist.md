# SleepLog Release Checklist

## 1. Pre-release QA Steps

Manual verification of the three core user journeys. Each must pass on both Android and iOS before release.

### J1: First-time User Journey

- [ ] Fresh install / clear app data — app launches to Home screen
- [ ] Empty state message displayed on Home (no sleep data yet)
- [ ] Tap FAB to navigate to Log Entry screen
- [ ] Fill in bedtime, wake time, and quality rating
- [ ] Save entry — redirected back to Home
- [ ] Home summary card shows correct sleep duration and quality for the new entry
- [ ] Navigate to History tab — new entry appears in the list with correct date, duration, and quality
- [ ] Navigate to Insights tab — charts render with data from the single entry
- [ ] Add 6 more entries (7 total) — Insights weekly averages and charts update correctly

### J2: Edit, Delete, and Undo Journey

- [ ] From History, tap an existing entry to open it in edit mode
- [ ] Modify bedtime, wake time, or quality — save changes
- [ ] Verify updated data reflected on Home summary and History list
- [ ] Swipe an entry in History to trigger delete
- [ ] Confirm deletion in the confirmation dialog
- [ ] Verify the entry is removed from History list, Home summary updates, and Insights charts update
- [ ] Tap "Undo" on the snackbar immediately after deletion
- [ ] Verify the entry is restored in History, Home summary, and Insights

### J3: Navigation and Structure

- [ ] Tap each bottom navigation tab (Home, History, Insights) — correct screen loads
- [ ] FAB is visible on all tabs and navigates to Log Entry screen
- [ ] Back button from Log Entry returns to the previous tab
- [ ] App bar titles are correct on each screen
- [ ] No navigation stack issues after rapid tab switching

---

## 2. Automated Test Gates

All three gates must pass with zero failures and zero warnings before release.

### Unit and Widget Tests

```bash
flutter test
```

- [ ] All tests pass
- [ ] No skipped tests (unless explicitly documented)

### Integration Tests (E2E)

```bash
flutter test integration_test/
```

- [ ] Requires a running emulator or simulator
- [ ] All integration test scenarios pass
- [ ] Tests cover J1, J2, and J3 journeys end-to-end

### Static Analysis

```bash
flutter analyze
```

- [ ] Zero warnings
- [ ] Zero errors
- [ ] Zero info-level issues (or all are explicitly suppressed with justification)

---

## 3. Known Limitations

Document these in user-facing release notes where applicable.

- **DST behaviour**: Sleep duration calculations may vary by +/-60 minutes during daylight saving time transitions. Bedtime and wake time are stored as-is without timezone-aware duration correction.
- **Multiple entries per day**: The app allows multiple sleep entries for the same date. There is no deduplication or conflict resolution.
- **No cloud sync or backup**: All data is stored on-device only using SQLite. Uninstalling the app or clearing app data permanently deletes all entries.
- **No user accounts or authentication**: The app has no login, no user profiles, and no multi-device support.
- **No data export**: There is no way to export sleep data as CSV, JSON, or any other format.

---

## 4. Build Instructions

### Android

```bash
flutter build apk --release
```

- [ ] APK generated at `build/app/outputs/flutter-apk/app-release.apk`
- [ ] APK installs and runs on a physical device or emulator

### iOS

```bash
flutter build ios --release --no-codesign
```

- [ ] Build completes without errors
- [ ] For distribution: re-run with proper code signing and provisioning profile

### Production Build Verification

- [ ] No `kDebugMode`-gated code leaks into production (tree-shaken by the compiler in release mode)
- [ ] No `print()` or `debugPrint()` statements outside of `kDebugMode` guards
- [ ] Release APK/IPA size is reasonable (no bundled test assets)

---

## 5. Accessibility Verification

Manual walkthrough with TalkBack (Android) and VoiceOver (iOS) enabled.

### Home Screen

- [ ] "Loading sleep data" announced while data is loading
- [ ] Summary card content is read aloud (sleep duration, quality, date range)
- [ ] Mini bar chart has a semantic label announced (chart summary text)
- [ ] Empty state message is announced when no data exists

### History Screen

- [ ] Each entry tile is announced with date, duration, and quality
- [ ] Loading state is announced ("Loading sleep history" or equivalent)
- [ ] Error state is announced with the error message
- [ ] Empty state is announced when no entries exist
- [ ] Swipe-to-delete action is discoverable via accessibility actions

### Insights Screen

- [ ] Each chart card label is announced (e.g., "Weekly sleep duration chart")
- [ ] Pattern summary card label is announced with summary text
- [ ] Loading and empty states are announced

### Log Entry Screen

- [ ] All form fields are announced with their labels and current values
- [ ] Quality selector buttons are announced as "Quality N of 5" (where N is the rating)
- [ ] Save button is announced with its label
- [ ] Validation errors are announced when fields are invalid

### FAB (Floating Action Button)

- [ ] "Log sleep" tooltip is announced on focus
- [ ] FAB is reachable via sequential navigation on all tabs

---

## 6. Privacy Verification

### Automated Network Audit

```bash
flutter test test/audit/network_audit_test.dart
```

- [ ] Test passes — confirms zero `dart:io` HttpClient, `http`, `dio`, or other network imports in `lib/`

### Manual Dependency Audit

- [ ] Review `pubspec.yaml` — no runtime dependencies with network capabilities
- [ ] Confirm the following packages are **not** present: `http`, `dio`, `firebase_core`, `firebase_analytics`, `sentry`, `amplitude_flutter`, `mixpanel_flutter`, or any analytics/crash-reporting SDK

### Manual Behaviour Verification

- [ ] Enable airplane mode on device
- [ ] Run the full app — all features work without network
- [ ] No error dialogs or degraded functionality related to missing connectivity
- [ ] No outbound network requests observed (verify via device proxy or network inspector)
