import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_booking_model.dart';
import 'package:tlb_mobile_ui/screens/refund_tracking_screen.dart';

import '../helpers/test_setup.dart';

ApiBookingItem _booking({dynamic refund}) => ApiBookingItem.fromJson({
      'id': 'bk1',
      'booking_reference': 'TLB123',
      'booking_type': 'event',
      'status': 'cancelled',
      'listing_title': 'Monsoon Special Art Festival',
      'total_amount': 500,
      'currency': 'INR',
      'payment_status': 'refunded',
      'is_cancellable': false,
      'created_at': '2026-08-20T09:00:00Z',
      'refund_amount': 500,
      'refund': refund,
    });

void main() {
  group('RefundTrackingScreen', () {
    testWidgets('TC_S_RT_001 — shows the amount and what it belongs to',
        (tester) async {
      await pumpTLBApp(
        tester,
        RefundTrackingScreen(
          booking: _booking(refund: {
            'id': 'b3f1',
            'status': 'processing',
            'amount': '500.00',
            'currency': 'INR',
            'requested_at': '2026-08-20T10:00:00Z',
          }),
        ),
      );

      expect(find.text('₹500.00'), findsOneWidget);
      expect(find.text('Monsoon Special Art Festival'), findsOneWidget);
      expect(find.text('TLB123'), findsOneWidget);
    });

    // The API doc is explicit: `processing` does not mean the money arrived.
    testWidgets('TC_S_RT_002 — never says "Refunded" while processing',
        (tester) async {
      await pumpTLBApp(
        tester,
        RefundTrackingScreen(
          booking: _booking(refund: {
            'id': 'b3f1',
            'status': 'processing',
            'amount': '500.00',
            'requested_at': '2026-08-20T10:00:00Z',
          }),
        ),
      );

      expect(find.text('Refund in progress'), findsOneWidget);
      expect(find.text('Refund complete'), findsNothing);
      expect(find.textContaining('Refunded'), findsNothing);
    });

    testWidgets('TC_S_RT_003 — only a settled refund claims completion',
        (tester) async {
      await pumpTLBApp(
        tester,
        RefundTrackingScreen(
          booking: _booking(refund: {
            'id': 'b3f1',
            'status': 'settled',
            'amount': '500.00',
            'requested_at': '2026-08-20T10:00:00Z',
            'settled_at': '2026-08-24T09:00:00Z',
          }),
        ),
      );

      expect(find.text('Refund complete'), findsOneWidget);
      expect(find.text('Money returned'), findsOneWidget);
      expect(find.text('Refund in progress'), findsNothing);
    });

    testWidgets('TC_S_RT_004 — a failed refund offers help, others do not',
        (tester) async {
      await pumpTLBApp(
        tester,
        RefundTrackingScreen(
          booking: _booking(refund: {
            'id': 'b3f1',
            'status': 'failed',
            'amount': '500.00',
            'requested_at': '2026-08-20T10:00:00Z',
            'failed_at': '2026-08-21T09:00:00Z',
          }),
        ),
      );

      expect(find.text('Refund failed'), findsOneWidget);
      expect(find.text('Could not complete'), findsOneWidget);
      expect(find.text('Get help with this refund'), findsOneWidget);
      // A failed refund never reached the customer, so no "Money returned"
      // step should sit below it.
      expect(find.text('Money returned'), findsNothing);
    });

    testWidgets('TC_S_RT_005 — an unknown status stays in-flight, never settled',
        (tester) async {
      await pumpTLBApp(
        tester,
        RefundTrackingScreen(
          booking: _booking(refund: {
            'id': 'b3f1',
            'status': 'reversed_by_bank',
            'amount': '500.00',
            'requested_at': '2026-08-20T10:00:00Z',
          }),
        ),
      );

      expect(find.text('Refund in progress'), findsOneWidget);
      expect(find.text('Refund complete'), findsNothing);
    });

    testWidgets('TC_S_RT_006 — explains itself when there is no refund',
        (tester) async {
      await pumpTLBApp(tester, RefundTrackingScreen(booking: _booking()));

      expect(find.text('No refund on this booking'), findsOneWidget);
      expect(find.text('Refund in progress'), findsNothing);
    });
  });

  group('RefundStatusRow', () {
    testWidgets('TC_S_RT_007 — renders nothing when there is no refund',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(body: RefundStatusRow(booking: _booking())),
      );
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('TC_S_RT_008 — shows the live status and opens the tracker',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: RefundStatusRow(
            booking: _booking(refund: {
              'id': 'b3f1',
              'status': 'processing',
              'amount': '500.00',
              'requested_at': '2026-08-20T10:00:00Z',
            }),
          ),
        ),
      );

      expect(find.text('Refund in progress'), findsOneWidget);

      await tester.tap(find.byType(RefundStatusRow));
      await tester.pumpAndSettle();

      expect(find.byType(RefundTrackingScreen), findsOneWidget);
      expect(find.text('Refund Status'), findsOneWidget);
    });
  });
}
