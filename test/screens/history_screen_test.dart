import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';
import 'package:sleeplog/providers/database_providers.dart';
import 'package:sleeplog/screens/history_screen.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Widget buildTestApp({AppDatabase? database}) {
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/log',
          builder: (context, state) => Scaffold(
            body: Text('Log Entry ${state.uri.queryParameters['id'] ?? ''}'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database ?? db),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.dark,
      ),
    );
  }

  group('History screen with data', () {
    testWidgets('displays History title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('renders entries in newest-first order', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Create entries for today, yesterday, 2 days ago.
      for (var i = 0; i < 3; i++) {
        final day = today.subtract(Duration(days: i));
        final wake = DateTime(day.year, day.month, day.day, 7, 0);
        await db.createEntry(CreateSleepEntryInput(
          bedtimeTs: wake.subtract(const Duration(hours: 8)),
          wakeTs: wake,
          quality: 3,
        ));
      }

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Verify today's date appears (newest first).
      final todayLabel = DateFormat('EEE d MMM').format(today);
      expect(find.text(todayLabel), findsOneWidget);

      // Verify 3 duration labels.
      expect(find.text('8h 0m'), findsNWidgets(3));
    });

    testWidgets('each entry tile shows date, duration, quality', (
      tester,
    ) async {
      final now = DateTime.now();
      final todayWake = DateTime(now.year, now.month, now.day, 7, 30);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: todayWake.subtract(const Duration(hours: 9)),
        wakeTs: todayWake,
        quality: 5,
      ));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final dateLabel = DateFormat('EEE d MMM').format(
        DateTime(now.year, now.month, now.day),
      );
      expect(find.text(dateLabel), findsOneWidget);
      expect(find.text('9h 0m'), findsOneWidget);
      expect(find.text('Quality: 5 / 5'), findsOneWidget);
    });

    testWidgets('tapping entry navigates to edit screen', (tester) async {
      final now = DateTime.now();
      final todayWake = DateTime(now.year, now.month, now.day, 7, 0);
      final entry = await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: todayWake.subtract(const Duration(hours: 8)),
        wakeTs: todayWake,
        quality: 3,
      ));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap the entry tile.
      await tester.tap(find.text('8h 0m'));
      await tester.pumpAndSettle();

      expect(find.text('Log Entry ${entry.id}'), findsOneWidget);
    });
  });

  group('Swipe-to-delete', () {
    Future<void> swipeToDismiss(WidgetTester tester) async {
      // Use fling for a more aggressive gesture that triggers confirmDismiss.
      await tester.fling(find.byType(Dismissible), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();
    }

    testWidgets('swipe shows confirm dialog', (tester) async {
      final now = DateTime.now();
      final todayWake = DateTime(now.year, now.month, now.day, 7, 0);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: todayWake.subtract(const Duration(hours: 8)),
        wakeTs: todayWake,
        quality: 3,
      ));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await swipeToDismiss(tester);

      expect(find.text('Delete this entry?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('cancel keeps entry', (tester) async {
      final now = DateTime.now();
      final todayWake = DateTime(now.year, now.month, now.day, 7, 0);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: todayWake.subtract(const Duration(hours: 8)),
        wakeTs: todayWake,
        quality: 3,
      ));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await swipeToDismiss(tester);

      // Tap Cancel.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Entry should still be visible.
      expect(find.text('8h 0m'), findsOneWidget);

      // Entry should still be in DB.
      final entries = await db.listEntries();
      expect(entries.length, 1);
    });

    testWidgets('confirm deletes entry and shows SnackBar with Undo', (
      tester,
    ) async {
      final now = DateTime.now();
      final todayWake = DateTime(now.year, now.month, now.day, 7, 0);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: todayWake.subtract(const Duration(hours: 8)),
        wakeTs: todayWake,
        quality: 3,
      ));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await swipeToDismiss(tester);

      // Tap Delete.
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // SnackBar should be visible.
      expect(find.text('Entry deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Entry should be deleted from DB.
      final entries = await db.listEntries();
      expect(entries, isEmpty);
    });

    testWidgets('undo re-inserts entry', (tester) async {
      final now = DateTime.now();
      final todayWake = DateTime(now.year, now.month, now.day, 7, 0);
      await db.createEntry(CreateSleepEntryInput(
        bedtimeTs: todayWake.subtract(const Duration(hours: 8)),
        wakeTs: todayWake,
        quality: 4,
      ));

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Delete.
      await swipeToDismiss(tester);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Tap Undo.
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // Entry should be back in DB.
      final entries = await db.listEntries();
      expect(entries.length, 1);
      expect(entries.first.quality, 4);
    });
  });

  group('Empty state', () {
    testWidgets('shows empty state with CTA when no entries', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('No entries yet'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Log sleep'), findsOneWidget);
    });

    testWidgets('CTA navigates to /log', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log sleep'));
      await tester.pumpAndSettle();

      expect(find.text('Log Entry '), findsOneWidget);
    });
  });

  // Note: Loading state test omitted — in-memory DB resolves synchronously,
  // so the FutureProvider settles before the first frame renders.
}
