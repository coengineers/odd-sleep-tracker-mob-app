import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../database/app_database.dart';
import '../models/sleep_entry_model.dart';
import '../providers/database_providers.dart';
import '../providers/home_providers.dart';
import '../providers/invalidate_providers.dart';
import '../screens/home_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  /// Local mutable copy of entries for immediate Dismissible removal.
  /// Set to null when provider should drive the list (initial load, refresh).
  List<SleepEntry>? _localEntries;

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(allEntriesProvider);

    // When the provider transitions from loading → data (i.e. it was
    // invalidated externally, e.g. by the FAB), clear the local cache
    // so the fresh data is picked up.
    ref.listen(allEntriesProvider, (previous, next) {
      if (previous != null && previous.isLoading && next.hasValue) {
        setState(() {
          _localEntries = null;
        });
      }
    });
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: entriesAsync.when(
        loading: () => Center(child: Semantics(label: 'Loading history', child: const CircularProgressIndicator())),
        error: (e, _) => Center(child: Semantics(label: 'Error loading history', child: Text('Error: $e'))),
        data: (providerEntries) {
          // Use local entries if available (during delete flow), otherwise
          // sync from provider.
          _localEntries ??= List.of(providerEntries);
          final entries = _localEntries!;

          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No entries yet',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await context.push('/log');
                        _refreshFromProvider();
                      },
                      child: const Text('Log sleep'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: entries.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _EntryTile(
                entry: entry,
                colorScheme: colorScheme,
                theme: theme,
                onTap: () async {
                  await context.push('/log?id=${entry.id}');
                  _refreshFromProvider();
                },
                onDismissed: () => _deleteEntry(entry, index),
              );
            },
          );
        },
      ),
    );
  }

  /// Clear local cache and invalidate all providers to force a full refresh.
  void _refreshFromProvider() {
    setState(() {
      _localEntries = null;
    });
    invalidateSleepProviders(ref);
  }

  Future<void> _deleteEntry(SleepEntry entry, int index) async {
    // Immediately remove from local list so Dismissible is removed from tree.
    setState(() {
      _localEntries?.removeAt(index);
    });

    final db = ref.read(appDatabaseProvider);
    await db.deleteEntry(entry.id);
    invalidateSleepProviders(ref);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Entry deleted'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await db.createEntry(CreateSleepEntryInput(
              bedtimeTs: entry.bedtimeTs,
              wakeTs: entry.wakeTs,
              quality: entry.quality,
              note: entry.note,
            ));
            _refreshFromProvider();
          },
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.colorScheme,
    required this.theme,
    required this.onTap,
    required this.onDismissed,
  });

  final SleepEntry entry;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final wakeDate = DateTime.tryParse(entry.wakeDate);
    final dateLabel =
        wakeDate != null ? DateFormat('EEE d MMM').format(wakeDate) : entry.wakeDate;
    final durationLabel = HomeScreen.formatDuration(entry.durationMinutes);

    return Semantics(
      label: 'Sleep entry for $dateLabel, $durationLabel, Quality ${entry.quality} of 5',
      child: Dismissible(
        key: ValueKey(entry.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _showConfirmDialog(context),
        onDismissed: (_) => onDismissed(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: colorScheme.error,
          child: Icon(Icons.delete, color: colorScheme.onError),
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateLabel, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(durationLabel, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                Text(
                  'Quality: ${entry.quality} / 5',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
