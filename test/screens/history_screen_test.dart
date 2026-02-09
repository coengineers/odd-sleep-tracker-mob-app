import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sleeplog/screens/history_screen.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  testWidgets('displays History title', (tester) async {
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(),
          routes: [
            GoRoute(
              path: 'history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('displays placeholder body text', (tester) async {
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(),
          routes: [
            GoRoute(
              path: 'history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router, theme: AppTheme.dark),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your sleep history will appear here.'), findsOneWidget);
  });
}
