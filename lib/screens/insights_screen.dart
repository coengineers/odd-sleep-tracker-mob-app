import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: Center(
        child: Text(
          'Sleep insights will appear here.',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
