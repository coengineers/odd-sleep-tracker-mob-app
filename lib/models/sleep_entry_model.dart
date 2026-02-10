/// Domain input type for creating a new sleep entry.
class CreateSleepEntryInput {
  final DateTime bedtimeTs;
  final DateTime wakeTs;
  final int quality;
  final String? note;

  const CreateSleepEntryInput({
    required this.bedtimeTs,
    required this.wakeTs,
    required this.quality,
    this.note,
  });
}

/// Domain input type for updating an existing sleep entry (partial patch).
class UpdateSleepEntryInput {
  final DateTime? bedtimeTs;
  final DateTime? wakeTs;
  final int? quality;
  final String? note;
  final bool hasNote;

  /// Use [hasNote] to distinguish between "no change" (default) and
  /// "explicitly set to null/empty". When constructing with a note parameter,
  /// set [hasNote] to true.
  const UpdateSleepEntryInput({
    this.bedtimeTs,
    this.wakeTs,
    this.quality,
    this.note,
    this.hasNote = false,
  });
}

// --- Exceptions ---

class InvalidTimeRangeException implements Exception {
  final String message;
  const InvalidTimeRangeException(this.message);
  @override
  String toString() => 'InvalidTimeRangeException: $message';
}

class InvalidQualityException implements Exception {
  final String message;
  const InvalidQualityException(this.message);
  @override
  String toString() => 'InvalidQualityException: $message';
}

class NoteTooLongException implements Exception {
  final String message;
  const NoteTooLongException(this.message);
  @override
  String toString() => 'NoteTooLongException: $message';
}

class EntryNotFoundException implements Exception {
  final String message;
  const EntryNotFoundException(this.message);
  @override
  String toString() => 'EntryNotFoundException: $message';
}

// --- Validation ---

/// Validates a create input. Throws typed exceptions on failure.
void validateCreateInput(CreateSleepEntryInput input) {
  _validateTimes(input.bedtimeTs, input.wakeTs);
  _validateQuality(input.quality);
  _validateNote(input.note);
}

/// Validates an update input with merged times. Throws typed exceptions on failure.
void validateUpdateInput({
  required DateTime bedtimeTs,
  required DateTime wakeTs,
  required int quality,
  String? note,
  required bool hasNote,
}) {
  _validateTimes(bedtimeTs, wakeTs);
  _validateQuality(quality);
  if (hasNote) {
    _validateNote(note);
  }
}

void _validateTimes(DateTime bedtimeTs, DateTime wakeTs) {
  final durationMinutes = wakeTs.difference(bedtimeTs).inMinutes;
  if (durationMinutes <= 0) {
    throw const InvalidTimeRangeException(
      'Wake time must be after bedtime (duration must be positive)',
    );
  }
  if (durationMinutes > 1440) {
    throw const InvalidTimeRangeException(
      'Sleep duration cannot exceed 1440 minutes (24 hours)',
    );
  }
}

void _validateQuality(int quality) {
  if (quality < 1 || quality > 5) {
    throw InvalidQualityException(
      'Quality must be between 1 and 5, got $quality',
    );
  }
}

void _validateNote(String? note) {
  if (note != null && note.length > 280) {
    throw NoteTooLongException(
      'Note must be 280 characters or less, got ${note.length}',
    );
  }
}

/// Computes duration in minutes between bedtime and wake time.
int computeDurationMinutes(DateTime bedtimeTs, DateTime wakeTs) {
  return wakeTs.difference(bedtimeTs).inMinutes;
}

/// Derives the wake date string (YYYY-MM-DD) from the wake timestamp.
String computeWakeDate(DateTime wakeTs) {
  return '${wakeTs.year.toString().padLeft(4, '0')}-'
      '${wakeTs.month.toString().padLeft(2, '0')}-'
      '${wakeTs.day.toString().padLeft(2, '0')}';
}
