import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleeplog/routing/app_router.dart';
import 'package:sleeplog/theme/app_theme.dart';

void main() {
  runApp(const SleepLogApp());
}

class SleepLogApp extends StatelessWidget {
  const SleepLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: createRouter(),
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
