import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/sleep_entry_model.dart';
import '../providers/database_providers.dart';
import '../providers/log_entry_providers.dart';
import '../widgets/quality_selector.dart';

class LogEntryScreen extends ConsumerStatefulWidget {
  const LogEntryScreen({super.key, this.entryId});

  final String? entryId;

  @override
  ConsumerState<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends ConsumerState<LogEntryScreen> {
  DateTime? _bedtime;
  DateTime? _wakeTime;
  int? _quality;
  late TextEditingController _noteController;
  bool _isSaving = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _durationError;
  String? _qualityError;

  bool get _isEditing => widget.entryId != null;

  static final _dateTimeFormat = DateFormat('EEE d MMM, HH:mm');

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();

    if (_isEditing) {
      _isLoading = true;
    } else {
      final now = DateTime.now();
      _bedtime = DateTime(now.year, now.month, now.day - 1, 22, 0);
      _wakeTime = DateTime(now.year, now.month, now.day, 7, 0);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDuration() {
    if (_bedtime == null || _wakeTime == null) return '';
    final minutes = _wakeTime!.difference(_bedtime!).inMinutes;
    if (minutes <= 0) return '0h 0m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  Future<void> _pickDateTime({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final initialDate = current ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final initialTime = TimeOfDay.fromDateTime(current ?? DateTime.now());
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time == null || !mounted) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    onPicked(picked);
  }

  Future<void> _onSave() async {
    // Clear previous errors
    setState(() {
      _errorMessage = null;
      _durationError = null;
      _qualityError = null;
    });

    // Validate
    bool hasError = false;

    if (_bedtime != null && _wakeTime != null) {
      final duration = _wakeTime!.difference(_bedtime!).inMinutes;
      if (duration <= 0 || duration > 1440) {
        _durationError = 'Wake time must be after bedtime (within 24 hours).';
        hasError = true;
      }
    }

    if (_quality == null) {
      _qualityError = 'Please select a quality rating.';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = ref.read(appDatabaseProvider);

      if (_isEditing) {
        await db.updateEntry(
          widget.entryId!,
          UpdateSleepEntryInput(
            bedtimeTs: _bedtime,
            wakeTs: _wakeTime,
            quality: _quality,
            note: _noteController.text.isEmpty ? null : _noteController.text,
            hasNote: true,
          ),
        );
      } else {
        await db.createEntry(
          CreateSleepEntryInput(
            bedtimeTs: _bedtime!,
            wakeTs: _wakeTime!,
            quality: _quality!,
            note: _noteController.text.isEmpty ? null : _noteController.text,
          ),
        );
      }

      if (mounted) context.pop();
    } on InvalidTimeRangeException {
      setState(() {
        _durationError = 'Wake time must be after bedtime (within 24 hours).';
      });
    } on EntryNotFoundException {
      setState(() {
        _errorMessage = 'This entry was deleted.';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.pop();
    } catch (_) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Edit mode: watch provider for data loading
    if (_isEditing && _isLoading) {
      final entryAsync = ref.watch(sleepEntryProvider(widget.entryId!));
      return entryAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Entry')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.pop();
          });
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Entry')),
            body: const Center(child: Text('Entry not found.')),
          );
        },
        data: (entry) {
          if (entry == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.pop();
            });
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Entry')),
              body: const Center(child: Text('Entry not found.')),
            );
          }
          // Populate fields once
          _bedtime = entry.bedtimeTs;
          _wakeTime = entry.wakeTs;
          _quality = entry.quality;
          _noteController.text = entry.note ?? '';
          _isLoading = false;
          // Fall through to form
          return _buildForm(theme, colorScheme);
        },
      );
    }

    return _buildForm(theme, colorScheme);
  }

  Widget _buildForm(ThemeData theme, ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'Log Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bedtime picker
            Text('Bedtime', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Semantics(
              label: 'Bedtime, ${_bedtime != null ? _dateTimeFormat.format(_bedtime!) : "not set"}. Tap to change.',
              button: true,
              child: InkWell(
                onTap: () => _pickDateTime(
                  current: _bedtime,
                  onPicked: (dt) => setState(() {
                    _bedtime = dt;
                    _durationError = null;
                  }),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Text(
                    _bedtime != null ? _dateTimeFormat.format(_bedtime!) : 'Select bedtime',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Wake time picker
            Text('Wake time', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Semantics(
              label: 'Wake time, ${_wakeTime != null ? _dateTimeFormat.format(_wakeTime!) : "not set"}. Tap to change.',
              button: true,
              child: InkWell(
                onTap: () => _pickDateTime(
                  current: _wakeTime,
                  onPicked: (dt) => setState(() {
                    _wakeTime = dt;
                    _durationError = null;
                  }),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Text(
                    _wakeTime != null ? _dateTimeFormat.format(_wakeTime!) : 'Select wake time',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Duration display
            if (_bedtime != null && _wakeTime != null)
              Semantics(
                label: 'Duration, ${_formatDuration()}',
                child: Text(
                  _formatDuration(),
                  style: theme.textTheme.bodySmall,
                ),
              ),

            // Duration error
            if (_durationError != null) ...[
              const SizedBox(height: 4),
              Semantics(
                liveRegion: true,
                child: Text(
                  _durationError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Quality selector
            Text('Quality', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            QualitySelector(
              value: _quality,
              onChanged: (v) => setState(() {
                _quality = v;
                _qualityError = null;
              }),
            ),

            // Quality error
            if (_qualityError != null) ...[
              const SizedBox(height: 4),
              Semantics(
                liveRegion: true,
                child: Text(
                  _qualityError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Note field
            Text('Note (optional)', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLength: 280,
              maxLines: 3,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Add a note about your sleep...',
              ),
            ),

            const SizedBox(height: 24),

            // General error
            if (_errorMessage != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _onSave,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
