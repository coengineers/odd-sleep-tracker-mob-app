import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/routing/app_router.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  testWidgets('displays SleepLog title', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SleepLog'), findsOneWidget);
  });

  testWidgets('displays empty-state message', (tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No sleep logged yet. Tap + to start tracking.'),
      findsOneWidget,
    );
  });
}
