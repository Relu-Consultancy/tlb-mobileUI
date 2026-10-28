import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/date_format.dart';

void main() {
  group('DateFormat.card', () {
    test('is "Sat, 22 Mar 2026" — weekday, day, month, year', () {
      expect(DateFormat.card(DateTime(2026, 3, 22)), 'Sun, 22 Mar 2026');
      expect(DateFormat.card(DateTime(2026, 3, 21)), 'Sat, 21 Mar 2026');
    });

    test('capitalises the weekday and the month', () {
      final label = DateFormat.card(DateTime(2026, 3, 21));
      expect(label.startsWith('Sat'), isTrue);
      expect(label, contains('Mar'));
      expect(label, isNot(contains('sat')));
      expect(label, isNot(contains('mar')));
    });

    test('does not pad the day to two digits', () {
      expect(DateFormat.card(DateTime(2026, 5, 3)), 'Sun, 3 May 2026');
    });

    test('every month and weekday maps to a real name', () {
      for (var m = 1; m <= 12; m++) {
        expect(DateFormat.card(DateTime(2026, m, 1)), isNot(contains('null')));
      }
      for (var d = 0; d < 7; d++) {
        final label = DateFormat.card(DateTime(2026, 3, 1).add(Duration(days: d)));
        expect(label.split(',').first, isNotEmpty);
      }
    });
  });

  group('DateFormat.cardFrom', () {
    test('parses an API date', () {
      expect(DateFormat.cardFrom('2026-03-21'), 'Sat, 21 Mar 2026');
    });

    test('parses an API datetime', () {
      expect(DateFormat.cardFrom('2026-03-21T18:30:00Z'), 'Sat, 21 Mar 2026');
    });

    test('falls back rather than showing a raw ISO string', () {
      expect(DateFormat.cardFrom(null), 'TBA');
      expect(DateFormat.cardFrom(''), 'TBA');
      expect(DateFormat.cardFrom('not-a-date'), 'TBA');
      expect(DateFormat.cardFrom('nope', fallback: 'nope'), 'nope');
    });
  });

  group('DateFormat.weekday', () {
    test('capitalises the API\'s lowercase day names', () {
      // The programs endpoint sends days_of_week as ["monday", "tuesday"].
      expect(DateFormat.weekday('monday'), 'Monday');
      expect(DateFormat.weekday('saturday'), 'Saturday');
    });

    test('abbreviates on request', () {
      expect(DateFormat.weekday('monday', short: true), 'Mon');
      expect(DateFormat.weekday('saturday', short: true), 'Sat');
    });

    test('is unfazed by casing and stray whitespace', () {
      expect(DateFormat.weekday(' SATURDAY '), 'Saturday');
      expect(DateFormat.weekday('Saturday'), 'Saturday');
    });

    test('capitalises an unrecognised value rather than dropping it', () {
      expect(DateFormat.weekday('holiday'), 'Holiday');
      expect(DateFormat.weekday('holiday', short: true), 'Hol');
      expect(DateFormat.weekday(''), '');
    });
  });

  group('DateFormat.weekdayList', () {
    test('joins a batch\'s recurring days, capitalised', () {
      expect(
        DateFormat.weekdayList(['monday', 'wednesday', 'friday']),
        'Monday, Wednesday, Friday',
      );
    });

    test('abbreviates for the narrow batch cards', () {
      expect(
        DateFormat.weekdayList(['monday', 'wednesday'], short: true),
        'Mon, Wed',
      );
    });

    test('an empty schedule is an empty string', () {
      expect(DateFormat.weekdayList(const []), '');
    });
  });

  group('DateFormat vocabulary accessors', () {
    test('weekdayOf and monthOf feed the stacked calendar tile', () {
      final d = DateTime(2026, 3, 21);
      expect(DateFormat.weekdayOf(d), 'Sat');
      expect(DateFormat.weekdayOf(d, short: false), 'Saturday');
      expect(DateFormat.monthOf(d), 'Mar');
    });
  });
}
