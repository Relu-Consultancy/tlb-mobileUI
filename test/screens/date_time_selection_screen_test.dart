import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/date_time_selection_screen.dart';

import '../helpers/test_setup.dart';

const _event = EventModel(
  id: 'a379ee9f',
  title: 'Monsoon Special Art Festival',
  venue: 'Powai, Mumbai',
  imagePath: 'assets/images/placeholder.png',
);

/// Builds a window that always straddles "now", so the screen's
/// don't-offer-past-days rule can't make the test depend on the wall clock.
({DateTime start, DateTime end}) _window({required int days}) {
  final today = DateTime.now();
  final start = DateTime(today.year, today.month, today.day, 4, 30);
  return (start: start, end: start.add(Duration(days: days - 1, hours: 11)));
}

Future<void> _pump(WidgetTester tester,
    {DateTime? start, DateTime? end}) async {
  await pumpTLBApp(
    tester,
    DateTimeSelectionScreen(
      event: _event,
      eventDateTime: start,
      eventEndDateTime: end,
    ),
  );
}

void main() {
  group('DateTimeSelectionScreen dates', () {
    // The regression: start_datetime and end_datetime a month apart used to
    // render a single date chip, because end was ignored when building them.
    testWidgets('TC_S_DT_001 — a multi-day event offers every day',
        (tester) async {
      final w = _window(days: 5);
      await _pump(tester, start: w.start, end: w.end);

      for (var i = 0; i < 5; i++) {
        final day = w.start.add(Duration(days: i));
        expect(find.text('${day.day}'), findsOneWidget,
            reason: 'day ${day.day} should have a chip');
      }
      expect(find.text('5 days'), findsOneWidget);
    });

    testWidgets('TC_S_DT_002 — a single-day event offers exactly one day',
        (tester) async {
      final start = _window(days: 1).start;
      await _pump(tester, start: start, end: start.add(const Duration(hours: 6)));

      expect(find.text('${start.day}'), findsOneWidget);
      // The day count only appears once the strip is long enough to scroll.
      expect(find.textContaining(' days'), findsNothing);
    });

    testWidgets('TC_S_DT_003 — the first day is selected and labelled Today',
        (tester) async {
      final w = _window(days: 4);
      await _pump(tester, start: w.start, end: w.end);
      expect(find.text('Today'), findsOneWidget);
    });
  });

  group('DateTimeSelectionScreen times', () {
    // A single window with no per-day sessions must not be shown as if the
    // start time and end time belong to the same day.
    testWidgets('TC_S_DT_004 — a multi-day event never fakes a daily range',
        (tester) async {
      final w = _window(days: 5);
      await _pump(tester, start: w.start, end: w.end);

      expect(find.text('From 4:30 AM'), findsOneWidget);
      expect(find.textContaining('–'), findsNothing);
    });

    testWidgets('TC_S_DT_005 — a single-day event does show its range',
        (tester) async {
      final start = _window(days: 1).start;
      await _pump(tester, start: start, end: start.add(const Duration(hours: 6)));
      expect(find.text('4:30 AM – 10:30 AM'), findsOneWidget);
    });

    testWidgets('TC_S_DT_006 — the closing day says when it ends',
        (tester) async {
      final w = _window(days: 3);
      await _pump(tester, start: w.start, end: w.end);

      final last = w.start.add(const Duration(days: 2));
      await tester.tap(find.text('${last.day}'));
      await tester.pumpAndSettle();

      expect(find.text('Until 3:30 PM'), findsOneWidget);
      expect(find.text('From 4:30 AM'), findsNothing);
    });

    testWidgets('TC_S_DT_007 — a day in the middle runs right through',
        (tester) async {
      final w = _window(days: 3);
      await _pump(tester, start: w.start, end: w.end);

      final middle = w.start.add(const Duration(days: 1));
      await tester.tap(find.text('${middle.day}'));
      await tester.pumpAndSettle();

      expect(find.text('Open all day'), findsOneWidget);
    });
  });

  group('DateTimeSelectionScreen chrome', () {
    testWidgets('TC_S_DT_008 — the date strip scrolls horizontally',
        (tester) async {
      final w = _window(days: 20);
      await _pump(tester, start: w.start, end: w.end);

      final list = tester.widget<ListView>(find.byType(ListView).first);
      expect(list.scrollDirection, Axis.horizontal);
      expect(find.text('20 days'), findsOneWidget);
    });

    testWidgets('TC_S_DT_009 — falls back to placeholder days with no window',
        (tester) async {
      await _pump(tester);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Select Time'), findsOneWidget);
    });
  });
}
