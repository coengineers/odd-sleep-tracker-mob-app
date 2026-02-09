import 'package:flutter/material.dart';

class LogEntryScreen extends StatelessWidget {
  const LogEntryScreen({super.key, this.entryId});

  final String? entryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = entryId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Entry' : 'Log Entry')),
      body: Center(
        child: Text(
          'Sleep entry form coming soon.',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
