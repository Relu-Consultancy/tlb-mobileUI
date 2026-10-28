import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Dates used to be formatted by thirteen private helpers spread across the
/// screens, producing eight different shapes — "22 Mar 2026", "Sat 22 Mar",
/// "Sat, Mar 22", "Saturday, Mar 22", "Mar 22, 2026" — so two cards side by
/// side could disagree. Worse, the program detail screen printed a batch's
/// days straight from the API: "monday, tuesday, wednesday", lowercase.
///
/// Every one of those now goes through DateFormat. These screens each build
/// their labels inside widgets that need a live API fetch to reach, so this
/// guards the source: no screen may grow its own month or weekday table again.
void main() {
  String read(String path) => File(path).readAsStringSync();

  /// Every file that used to carry a private date formatter.
  const converted = <String>[
    'lib/screens/booking_detail_screen.dart',
    'lib/screens/class_detail_screen.dart',
    'lib/screens/date_time_selection_screen.dart',
    'lib/screens/event_detail_screen.dart',
    'lib/screens/format_events_screen.dart',
    'lib/screens/plan_party_screen.dart',
    'lib/screens/program_detail_screen.dart',
    'lib/screens/refund_tracking_screen.dart',
    'lib/screens/select_batch_screen.dart',
    'lib/screens/select_program_batch_screen.dart',
    'lib/screens/venue_checkout_screen.dart',
    'lib/screens/venue_detail_screen.dart',
    'lib/screens/your_reviews_screen.dart',
    'lib/widgets/review_sheet.dart',
  ];

  group('One date format across the app', () {
    for (final path in converted) {
      test('${path.split('/').last} — no private month or weekday table', () {
        final src = read(path);
        expect(src, contains("import '"), reason: 'sanity: file was read');
        expect(
          src,
          isNot(contains("'Jan', 'Feb'")),
          reason: 'a month table here is a second date format waiting to drift',
        );
        expect(src, isNot(contains("'Mon', 'Tue'")));
        expect(src, isNot(contains("'Monday', 'Tuesday'")));
      });
    }

    test('the only month and weekday tables live in DateFormat', () {
      final core = read('lib/core/date_format.dart');
      expect(core, contains("'Jan', 'Feb'"));
      expect(core, contains("'Mon', 'Tue'"));
      expect(core, contains("'Monday', 'Tuesday'"));
    });
  });

  group('Program detail — batch days are capitalised', () {
    test('days_of_week is never printed raw', () {
      // The API sends ["monday", "tuesday"]; joining it directly put a
      // lowercase "monday, tuesday" on the schedule row.
      final src = read('lib/screens/program_detail_screen.dart');
      expect(src, isNot(contains("b.daysOfWeek.join(', ')")));
      expect(src, contains('DateFormat.weekdayList(b.daysOfWeek)'));
    });
  });

  group('Mock card dates match the app format', () {
    test('every eventDate reads "Ddd, D Mon YYYY"', () {
      final src = read('lib/data/dummy_data.dart');
      final dates = RegExp(r"eventDate: '([^']*)'")
          .allMatches(src)
          .map((m) => m.group(1)!)
          // A handful are duration labels ("5 Days Camp"), not dates.
          .where((d) => d.contains(','));

      expect(dates, isNotEmpty);
      final shape = RegExp(
          r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), \d{1,2} '
          r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{4}$');
      for (final d in dates) {
        expect(shape.hasMatch(d), isTrue, reason: '"$d" is a different shape');
      }
    });
  });
}
