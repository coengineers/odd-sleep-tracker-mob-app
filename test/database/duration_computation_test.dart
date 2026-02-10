import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/models/sleep_entry_model.dart';

void main() {
  group('computeDurationMinutes', () {
    test('same-day sleep returns correct duration', () {
      final bedtime = DateTime(2026, 2, 8, 1, 0); // 1:00 AM
      final wake = DateTime(2026, 2, 8, 7, 0); // 7:00 AM
      expect(computeDurationMinutes(bedtime, wake), 360);
    });

    test('cross-midnight sleep returns correct duration', () {
      final bedtime = DateTime(2026, 2, 7, 23, 30); // 11:30 PM
      final wake = DateTime(2026, 2, 8, 7, 30); // 7:30 AM next day
      expect(computeDurationMinutes(bedtime, wake), 480);
    });

    test('minimum valid duration (1 minute)', () {
      final bedtime = DateTime(2026, 2, 8, 7, 0);
      final wake = DateTime(2026, 2, 8, 7, 1);
      expect(computeDurationMinutes(bedtime, wake), 1);
    });

    test('maximum valid duration (1440 minutes)', () {
      final bedtime = DateTime(2026, 2, 7, 7, 0);
      final wake = DateTime(2026, 2, 8, 7, 0);
      expect(computeDurationMinutes(bedtime, wake), 1440);
    });
  });

  group('computeWakeDate', () {
    test('derives date from wake timestamp', () {
      final wake = DateTime(2026, 2, 8, 7, 30);
      expect(computeWakeDate(wake), '2026-02-08');
    });

    test('cross-midnight uses wake day, not bedtime day', () {
      // Bedtime is Feb 7, wake is Feb 8
      final wake = DateTime(2026, 2, 8, 0, 30);
      expect(computeWakeDate(wake), '2026-02-08');
    });

    test('pads single-digit month and day', () {
      final wake = DateTime(2026, 1, 5, 7, 0);
      expect(computeWakeDate(wake), '2026-01-05');
    });
  });

  group('validateCreateInput', () {
    test('valid input does not throw', () {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
      );
      expect(() => validateCreateInput(input), returnsNormally);
    });

    test('zero duration throws InvalidTimeRangeException', () {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 8, 7, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 3,
      );
      expect(() => validateCreateInput(input),
          throwsA(isA<InvalidTimeRangeException>()));
    });

    test('negative duration throws InvalidTimeRangeException', () {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 8, 7, 0),
        wakeTs: DateTime(2026, 2, 8, 6, 0),
        quality: 3,
      );
      expect(() => validateCreateInput(input),
          throwsA(isA<InvalidTimeRangeException>()));
    });

    test('duration > 1440 throws InvalidTimeRangeException', () {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 7, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 1), // 1441 minutes
        quality: 3,
      );
      expect(() => validateCreateInput(input),
          throwsA(isA<InvalidTimeRangeException>()));
    });

    test('quality 0 throws InvalidQualityException', () {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 0,
      );
      expect(() => validateCreateInput(input),
          throwsA(isA<InvalidQualityException>()));
    });

    test('quality 1 is valid', () {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 1,
      );
      expect(() => validateCreateInput(input), returnsNormally);
    });

    test('quality 5 is valid', () {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 5,
      );
      expect(() => validateCreateInput(input), returnsNormally);
    });

    test('quality 6 throws InvalidQualityException', () {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 6,
      );
      expect(() => validateCreateInput(input),
          throwsA(isA<InvalidQualityException>()));
    });

    test('note with 280 characters is valid', () {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
        note: 'a' * 280,
      );
      expect(() => validateCreateInput(input), returnsNormally);
    });

    test('note with 281 characters throws NoteTooLongException', () {
      final input = CreateSleepEntryInput(
        bedtimeTs: DateTime(2026, 2, 7, 23, 0),
        wakeTs: DateTime(2026, 2, 8, 7, 0),
        quality: 4,
        note: 'a' * 281,
      );
      expect(() => validateCreateInput(input),
          throwsA(isA<NoteTooLongException>()));
    });
  });
}
