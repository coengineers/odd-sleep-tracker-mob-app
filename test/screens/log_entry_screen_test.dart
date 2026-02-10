import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sleeplog/database/app_database.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';
import 'package:sleeplog/providers/database_providers.dart';
import 'package:sleeplog/screens/log_entry_screen.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Widget buildTestApp({
    String initialLocation = '/log',
    AppDatabase? database,
  }) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Text('Home'),
          ),
        ),
        GoRoute(
          path: '/log',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'];
            return LogEntryScreen(entryId: id);
          },
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

  /// Scrolls to and taps the Save or Update button.
  Future<void> tapSaveButton(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.byType(ElevatedButton),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
  }

  group('Create mode (US1)', () {
    testWidgets('screen shows "Log Entry" title in create mode', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Log Entry'), findsOneWidget);
    });

    testWidgets('screen renders bedtime picker row with default label', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Bedtime'), findsOneWidget);
      final now = DateTime.now();
      final expectedBedtime =
          DateTime(now.year, now.month, now.day - 1, 22, 0);
      final formatted =
          DateFormat('EEE d MMM, HH:mm').format(expectedBedtime);
      expect(find.text(formatted), findsOneWidget);
    });

    testWidgets('screen renders wake time picker row with default label', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Wake time'), findsOneWidget);
      final now = DateTime.now();
      final expectedWake = DateTime(now.year, now.month, now.day, 7, 0);
      final formatted = DateFormat('EEE d MMM, HH:mm').format(expectedWake);
      expect(find.text(formatted), findsOneWidget);
    });

    testWidgets('screen renders QualitySelector with no selection', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Quality'), findsOneWidget);
      for (var i = 1; i <= 5; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
      // No item should have primary colour (none selected)
      final containers =
          tester.widgetList<Container>(find.byType(Container));
      final primaryColor = AppTheme.dark.colorScheme.primary;
      for (final container in containers) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration) {
          expect(decoration.color, isNot(primaryColor));
        }
      }
    });

    testWidgets('screen renders Save button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(ElevatedButton, 'Save'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });

    testWidgets(
      'tapping Save without selecting quality shows quality error',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tapSaveButton(tester);
        await tester.pumpAndSettle();

        expect(
          find.text('Please select a quality rating.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'selecting quality and tapping Save creates entry and pops screen',
      (tester) async {
        // Start at Home so we have a navigation stack to pop back to
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: const Text('Home'),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => context.push('/log'),
                  child: const Icon(Icons.add),
                ),
              ),
            ),
            GoRoute(
              path: '/log',
              builder: (context, state) {
                final id = state.uri.queryParameters['id'];
                return LogEntryScreen(entryId: id);
              },
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
            ],
            child: MaterialApp.router(
              routerConfig: router,
              theme: AppTheme.dark,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to log entry screen
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(find.text('Log Entry'), findsOneWidget);

        // Select quality 4
        await tester.tap(find.text('4'));
        await tester.pumpAndSettle();

        // Scroll to and tap Save
        await tapSaveButton(tester);
        await tester.pumpAndSettle();

        // Verify entry was created in DB
        final entries = await db.listEntries();
        expect(entries.length, 1);
        expect(entries.first.quality, 4);

        // After pop, we should be back at Home
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Log Entry'), findsNothing);
      },
    );

    testWidgets('duration display shows computed duration', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // With defaults: yesterday 22:00 → today 07:00 = 9h 0m
      expect(find.text('9h 0m'), findsOneWidget);
    });

    testWidgets('note field is present with label and max length', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Note (optional)'), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 280);
      expect(textField.maxLines, 3);
    });
  });

  group('Edit mode (US2)', () {
    testWidgets('screen shows "Edit Entry" title and pre-populated fields', (
      tester,
    ) async {
      final entry = await db.createEntry(
        CreateSleepEntryInput(
          bedtimeTs: DateTime(2026, 2, 9, 23, 0),
          wakeTs: DateTime(2026, 2, 10, 7, 30),
          quality: 3,
          note: 'Test note',
        ),
      );

      await tester.pumpWidget(
        buildTestApp(initialLocation: '/log?id=${entry.id}'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Entry'), findsOneWidget);

      final bedFormatted = DateFormat('EEE d MMM, HH:mm')
          .format(DateTime(2026, 2, 9, 23, 0));
      final wakeFormatted = DateFormat('EEE d MMM, HH:mm')
          .format(DateTime(2026, 2, 10, 7, 30));
      expect(find.text(bedFormatted), findsOneWidget);
      expect(find.text(wakeFormatted), findsOneWidget);

      // Scroll to Update button
      await tester.scrollUntilVisible(
        find.widgetWithText(ElevatedButton, 'Update'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.widgetWithText(ElevatedButton, 'Update'),
        findsOneWidget,
      );
    });

    testWidgets('editing quality and tapping Update saves changes', (
      tester,
    ) async {
      final entry = await db.createEntry(
        CreateSleepEntryInput(
          bedtimeTs: DateTime(2026, 2, 9, 23, 0),
          wakeTs: DateTime(2026, 2, 10, 7, 30),
          quality: 3,
        ),
      );

      await tester.pumpWidget(
        buildTestApp(initialLocation: '/log?id=${entry.id}'),
      );
      await tester.pumpAndSettle();

      // Change quality to 5
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      // Scroll to and tap Update
      await tapSaveButton(tester);
      await tester.pumpAndSettle();

      // Verify in DB
      final updated = await db.getEntryById(entry.id);
      expect(updated!.quality, 5);
      expect(updated.bedtimeTs, DateTime(2026, 2, 9, 23, 0));
      expect(updated.wakeTs, DateTime(2026, 2, 10, 7, 30));
    });

    testWidgets('edit mode pre-populates note field', (tester) async {
      final entry = await db.createEntry(
        CreateSleepEntryInput(
          bedtimeTs: DateTime(2026, 2, 9, 23, 0),
          wakeTs: DateTime(2026, 2, 10, 7, 30),
          quality: 3,
          note: 'Slept great',
        ),
      );

      await tester.pumpWidget(
        buildTestApp(initialLocation: '/log?id=${entry.id}'),
      );
      await tester.pumpAndSettle();

      // Scroll to note area
      await tester.scrollUntilVisible(
        find.text('Slept great'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Slept great'), findsOneWidget);
    });
  });

  group('Validation (US3)', () {
    testWidgets('saving without quality shows quality error', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tapSaveButton(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Please select a quality rating.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Save button exists and is enabled before save',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Scroll to Save
        await tester.scrollUntilVisible(
          find.byType(ElevatedButton),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        // The button should be enabled (onPressed is not null) before save
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNotNull);
      },
    );
  });

  group('Note field (US4)', () {
    testWidgets('saving with note text persists note to DB', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Select quality
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Scroll to note field and enter text
      await tester.scrollUntilVisible(
        find.byType(TextField),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField), 'Feeling refreshed');
      await tester.pumpAndSettle();

      // Scroll to and tap Save
      await tapSaveButton(tester);
      await tester.pumpAndSettle();

      final entries = await db.listEntries();
      expect(entries.length, 1);
      expect(entries.first.note, 'Feeling refreshed');
    });

    testWidgets('saving without note text persists null note', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Select quality
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Scroll to and tap Save
      await tapSaveButton(tester);
      await tester.pumpAndSettle();

      final entries = await db.listEntries();
      expect(entries.length, 1);
      expect(entries.first.note, isNull);
    });
  });
}
