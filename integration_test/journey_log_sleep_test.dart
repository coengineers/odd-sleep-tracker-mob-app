// J1 end-to-end integration test
//
// Journey: fresh app → empty state → log sleep → Home summary → History list → Insights charts
//
// Cross-restart persistence is guaranteed by SQLite/drift and verified by
// repository unit tests (test/database/sleep_entry_repository_test.dart).

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sleeplog/database/app_database.dart';

import 'app_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('J1 — fresh app → log sleep → Home summary → History → Insights',
      (tester) async {
    // ---------------------------------------------------------------
    // 1. Launch the app with an empty in-memory database.
    // ---------------------------------------------------------------
    await tester.pumpWidget(buildIntegrationTestApp(db));
    await tester.pumpAndSettle();

    // ---------------------------------------------------------------
    // 2. Verify Home empty state.
    // ---------------------------------------------------------------
    expect(find.text('No sleep logged yet.'), findsOneWidget);
    expect(find.text('Log sleep'), findsOneWidget);

    // ---------------------------------------------------------------
    // 3. Tap "Log sleep" to navigate to LogEntryScreen.
    // ---------------------------------------------------------------
    await tester.tap(find.text('Log sleep'));
    await tester.pumpAndSettle();

    // Verify we are on the Log Entry screen.
    expect(find.text('Log Entry'), findsOneWidget);

    // The LogEntryScreen pre-fills bedtime (yesterday 22:00) and wake
    // time (today 07:00) in create mode, giving a default 9h 0m duration.
    // We only need to pick a quality and save.
    expect(find.text('Bedtime'), findsOneWidget);
    expect(find.text('Wake time'), findsOneWidget);

    // Verify the default duration is displayed (9h 0m).
    expect(find.text('9h 0m'), findsOneWidget);

    // ---------------------------------------------------------------
    // 4. Select quality 3 (tap the "3" text inside the QualitySelector).
    // ---------------------------------------------------------------
    // The QualitySelector renders five items each showing just the number.
    // We use the bySemanticsLabel to disambiguate since there may be other
    // "3" text on screen (e.g. in the date).
    final quality3Finder = find.bySemanticsLabel('Quality 3 of 5');
    expect(quality3Finder, findsOneWidget);
    await tester.tap(quality3Finder);
    await tester.pumpAndSettle();

    // ---------------------------------------------------------------
    // 5. Save the entry.
    // ---------------------------------------------------------------
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // ---------------------------------------------------------------
    // 6. Verify Home screen shows today's summary after save.
    //    The entry uses the defaults: 9h 0m, quality 3.
    // ---------------------------------------------------------------
    // After pop, we should be back on the Home screen.
    expect(find.text('SleepLog'), findsOneWidget);
    expect(find.text("Today's sleep"), findsOneWidget);
    expect(find.text('9h 0m'), findsOneWidget);
    expect(find.text('Quality: 3 / 5'), findsOneWidget);

    // The Home screen's mini chart section should also appear.
    expect(find.text('Last 7 days'), findsOneWidget);

    // ---------------------------------------------------------------
    // 7. Navigate to History tab.
    // ---------------------------------------------------------------
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // Verify the History screen is visible.
    expect(find.text('History'), findsWidgets); // AppBar title + nav item

    // Verify the entry appears in the list with duration and quality.
    expect(find.text('9h 0m'), findsOneWidget);
    expect(find.text('Quality: 3 / 5'), findsOneWidget);

    // ---------------------------------------------------------------
    // 8. Navigate to Insights tab.
    // ---------------------------------------------------------------
    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    // Verify the Insights screen shows chart content (not the empty state).
    // The empty state would show "Not enough data for insights yet."
    expect(find.text('Not enough data for insights yet.'), findsNothing);

    // The insights screen should show chart cards with "Last 7 days" title.
    expect(find.text('Last 7 days'), findsOneWidget);
    expect(find.text('Quality trend (30 days)'), findsOneWidget);

    // ---------------------------------------------------------------
    // 9. Navigate back to Home tab and verify the entry persists
    //    (within-session persistence check).
    // ---------------------------------------------------------------
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text("Today's sleep"), findsOneWidget);
    expect(find.text('9h 0m'), findsOneWidget);
    expect(find.text('Quality: 3 / 5'), findsOneWidget);
  });
}
