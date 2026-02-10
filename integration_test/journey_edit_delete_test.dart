// J2 — Edit existing entry, swipe-to-delete, undo restore
//
// Journey: pre-seeded entries -> edit existing entry -> save -> verify update
//          -> swipe-to-delete -> confirm -> verify removal -> undo -> verify restoration

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

  testWidgets('J2: edit entry, swipe-to-delete, undo restores entry',
      (tester) async {
    // ── 1. Seed 2 entries ──────────────────────────────────────────────
    // seedTestEntries with count: 2 creates:
    //   entry[0]: quality 1, wake today
    //   entry[1]: quality 2, wake yesterday
    // listEntries returns newest first, so in History the order is:
    //   row 0 → entry[0] (quality 1)
    //   row 1 → entry[1] (quality 2)
    final seeded = await seedTestEntries(db, count: 2);
    expect(seeded.length, 2);

    // ── 2. Build the app and wait for initial render ───────────────────
    await tester.pumpWidget(buildIntegrationTestApp(db));
    await tester.pumpAndSettle();

    // ── 3. Navigate to History tab ─────────────────────────────────────
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // ── 4. Verify 2 entries are visible ────────────────────────────────
    expect(find.byType(Dismissible), findsNWidgets(2));
    expect(find.text('Quality: 1 / 5'), findsOneWidget);
    expect(find.text('Quality: 2 / 5'), findsOneWidget);

    // ── 5. Tap first entry (quality 1) to edit it ──────────────────────
    await tester.tap(find.text('Quality: 1 / 5'));
    await tester.pumpAndSettle();

    // Verify we are on the Edit Entry screen
    expect(find.text('Edit Entry'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);

    // ── 6. Change quality from 1 to 4 ──────────────────────────────────
    // The quality selector uses Semantics labels "Quality N of 5"
    await tester.tap(find.bySemanticsLabel('Quality 4 of 5'));
    await tester.pumpAndSettle();

    // ── 7. Save the changes ────────────────────────────────────────────
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    // After saving, the app pops back to History.
    // The history screen refreshes from provider.
    expect(find.text('History'), findsOneWidget);

    // ── 8. Verify the updated quality appears ──────────────────────────
    // Quality 1 should no longer be present; quality 4 should now appear.
    expect(find.text('Quality: 4 / 5'), findsOneWidget);
    expect(find.text('Quality: 1 / 5'), findsNothing);
    // The second entry (quality 2) should still be present.
    expect(find.text('Quality: 2 / 5'), findsOneWidget);

    // ── 9. Swipe second entry (quality 2) to delete ────────────────────
    // After the edit, entry order is: quality 4 (today), quality 2 (yesterday).
    // We target the Dismissible containing quality 2.
    final secondEntry = find.ancestor(
      of: find.text('Quality: 2 / 5'),
      matching: find.byType(Dismissible),
    );
    expect(secondEntry, findsOneWidget);

    await tester.drag(secondEntry, const Offset(-500, 0));
    await tester.pumpAndSettle();

    // ── 10. Confirm deletion in the dialog ─────────────────────────────
    expect(find.text('Delete this entry?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // ── 11. Verify entry is removed from list ──────────────────────────
    expect(find.text('Quality: 2 / 5'), findsNothing);
    expect(find.byType(Dismissible), findsOneWidget); // only the edited entry remains

    // ── 12. Verify "Entry deleted" SnackBar appears with "Undo" ────────
    expect(find.text('Entry deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    // ── 13. Tap "Undo" ────────────────────────────────────────────────
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    // ── 14. Verify entry is restored in the list ───────────────────────
    // Undo re-creates the entry. The quality was 2.
    // Note: undo uses createEntry, so a new ID is generated, but
    // the quality value is preserved.
    expect(find.byType(Dismissible), findsNWidgets(2));
    // The restored entry should show its original quality.
    expect(find.text('Quality: 2 / 5'), findsOneWidget);
    expect(find.text('Quality: 4 / 5'), findsOneWidget);
  });
}
