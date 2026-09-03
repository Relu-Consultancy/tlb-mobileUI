import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_program_model.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/attendee_details_screen.dart';

import '../helpers/test_setup.dart';

ApiProgramBatch _batch({String? fee}) => ApiProgramBatch(
      id: 1,
      name: 'Batch 1',
      fee: fee,
      isActive: true,
      daysOfWeek: const ['mon'],
    );

EventModel _event({double? price}) => EventModel(
      id: 'class-1',
      title: 'Test Class',
      venue: 'Mumbai',
      imagePath: '',
      price: price,
    );

Future<void> _pump(WidgetTester tester, AttendeeDetailsScreen screen) async {
  await pumpTLBApp(tester, screen);
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

void main() {
  group('AttendeeDetailsScreen fee fallback (Session 43)', () {
    testWidgets('uses batch.fee when present', (tester) async {
      await _pump(
        tester,
        AttendeeDetailsScreen(
          event: _event(price: 1500),
          batch: _batch(fee: '500'),
          selectedDate: '1 Jan',
          selectedTime: '10:00',
          bookingType: 'class',
        ),
      );
      expect(find.text('₹500'), findsOneWidget);
    });

    testWidgets('falls back to event.price when batch.fee is null',
        (tester) async {
      await _pump(
        tester,
        AttendeeDetailsScreen(
          event: _event(price: 1500),
          batch: _batch(fee: null),
          selectedDate: '1 Jan',
          selectedTime: '10:00',
          bookingType: 'class',
        ),
      );
      // This is the Session 43 fix — was showing "Free" before.
      expect(find.text('₹1500'), findsOneWidget);
    });

    testWidgets('falls back to event.price when batch.fee is "0"',
        (tester) async {
      await _pump(
        tester,
        AttendeeDetailsScreen(
          event: _event(price: 1500),
          batch: _batch(fee: '0'),
          selectedDate: '1 Jan',
          selectedTime: '10:00',
          bookingType: 'class',
        ),
      );
      expect(find.text('₹1500'), findsOneWidget);
    });

    testWidgets('shows "Free" when both batch.fee and event.price are null',
        (tester) async {
      await _pump(
        tester,
        AttendeeDetailsScreen(
          event: _event(price: null),
          batch: _batch(fee: null),
          selectedDate: '1 Jan',
          selectedTime: '10:00',
          bookingType: 'class',
        ),
      );
      expect(find.text('Free'), findsOneWidget);
    });
  });

  group('Attendee Details form — age field alignment', () {
    // The age dropdown's closed field used to fall back to `items`' bare
    // `Text('$age years')` once a value was picked — no icon, no gap — so the
    // selected age sat well left of the name field's placeholder and the
    // phone field's "+91", both of which keep their icon regardless of
    // whether they hold a value.
    testWidgets(
        'TC_S_AD_ALIGN — the selected age lines up with the name field',
        (tester) async {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        AttendeeDetailsScreen(
          event: _event(price: 1500),
          batch: _batch(fee: '500'),
          selectedDate: '1 Jan',
          selectedTime: '10:00',
          bookingType: 'class',
        ),
      );

      // warnIfMissed: false — the hint sits inside an IndexedStack whose
      // hit-test target is a covering ancestor, not this RenderParagraph
      // itself; the tap still opens the menu.
      await tester.tap(find.text('Age'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('11 years').last);
      await tester.pumpAndSettle();

      final nameHintLeft = tester.getRect(find.text('Full name')).left;
      final ageTextLeft = tester.getRect(find.text('11 years')).left;
      expect(ageTextLeft, nameHintLeft);
    });

    testWidgets(
        'TC_S_AD_ALIGN2 — the three leading icons share one column after picking an age',
        (tester) async {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        AttendeeDetailsScreen(
          event: _event(price: 1500),
          batch: _batch(fee: '500'),
          selectedDate: '1 Jan',
          selectedTime: '10:00',
          bookingType: 'class',
        ),
      );

      // warnIfMissed: false — the hint sits inside an IndexedStack whose
      // hit-test target is a covering ancestor, not this RenderParagraph
      // itself; the tap still opens the menu.
      await tester.tap(find.text('Age'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('11 years').last);
      await tester.pumpAndSettle();

      final rects = [
        Icons.person_outline_rounded,
        Icons.cake_outlined,
        Icons.phone_outlined,
      ].map((i) => tester.getRect(find.byIcon(i).first)).toList();
      for (final r in rects.skip(1)) {
        expect(r.left, rects.first.left);
      }
    });
  });
}
