import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Center(
        child: Text(
          'Your sleep history will appear here.',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
