import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleeplog/screens/history_screen.dart';
import 'package:sleeplog/screens/home_screen.dart';
import 'package:sleeplog/screens/insights_screen.dart';
import 'package:sleeplog/screens/log_entry_screen.dart';
import 'package:sleeplog/widgets/shell_scaffold.dart';

GoRouter createRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/log',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return LogEntryScreen(entryId: id);
        },
      ),
    ],
  );
}
