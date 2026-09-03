import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guard for a bug that shipped visibly: the class and program
/// detail screens' schedule rows interpolated a batch's `start_time`/
/// `end_time` straight from the API ("16:00:00" – "18:00:00") with no
/// formatting at all, while every other time shown anywhere else in the app
/// — the batch pickers, the event/venue detail screens — is 12-hour.
///
/// Neither screen is reachable in a widget test without a real API fetch
/// (see auth_service_test.dart's note on the services having no injectable
/// http client), so this checks the source directly: that both call sites
/// route through the shared `TimeFormat.h12()` rather than interpolating the
/// raw string.
void main() {
  String read(String relativePath) => File(relativePath).readAsStringSync();

  group('Class/Program detail — schedule time is 12-hour', () {
    test('class_detail_screen formats the batch time range', () {
      final src = read('lib/screens/class_detail_screen.dart');
      expect(src, contains('TimeFormat.h12(b.startTime)'));
      expect(src, contains('TimeFormat.h12(b.endTime)'));
      expect(
        src,
        isNot(contains(r'${b.startTime} – ${b.endTime}')),
        reason: 'that is the raw 24-hour string with no formatting at all',
      );
    });

    test('program_detail_screen formats both batch time rows', () {
      final src = read('lib/screens/program_detail_screen.dart');
      // Two call sites: the schedule summary line and the batch-card row.
      expect('TimeFormat.h12(b.startTime!)'.allMatches(src).length, 2);
      expect('TimeFormat.h12(b.endTime!)'.allMatches(src).length, 2);
      expect(
        src,
        isNot(contains(r'${b.startTime} - ${b.endTime}')),
        reason: 'that is the raw 24-hour string with no formatting at all',
      );
    });
  });
}
