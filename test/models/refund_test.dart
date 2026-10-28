import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_booking_model.dart';
import 'package:tlb_mobile_ui/models/api_refund.dart';

void main() {
  group('ApiRefund', () {
    test('parses the documented payload', () {
      final r = ApiRefund.fromJson({
        'id': 'b3f1',
        'status': 'processing',
        'amount': '500.00',
        'currency': 'INR',
        'requested_at': '2026-08-20T10:00:00Z',
        'settled_at': null,
        'failed_at': null,
      });

      expect(r, isNotNull);
      expect(r!.id, 'b3f1');
      expect(r.status, RefundStatus.processing);
      // amount arrives as a decimal string, not a number.
      expect(r.amount, 500.00);
      expect(r.currency, 'INR');
      expect(r.requestedAt, DateTime.parse('2026-08-20T10:00:00Z'));
      expect(r.settledAt, isNull);
    });

    test('is null when no refund was ever initiated', () {
      expect(ApiRefund.fromJson(null), isNull);
    });

    test('maps every documented status', () {
      expect(RefundStatus.parse('requested'), RefundStatus.requested);
      expect(RefundStatus.parse('processing'), RefundStatus.processing);
      expect(RefundStatus.parse('settled'), RefundStatus.settled);
      expect(RefundStatus.parse('failed'), RefundStatus.failed);
    });

    // A status this build doesn't know must not be mistaken for "money back".
    test('an unknown status is treated as still in flight, never settled', () {
      final s = RefundStatus.parse('reversed_by_bank');
      expect(s, RefundStatus.unknown);
      expect(s.isSettled, isFalse);
      expect(s.isFailed, isFalse);
      expect(s.isInFlight, isTrue);
    });

    test('only settled counts as money returned', () {
      expect(RefundStatus.settled.isSettled, isTrue);
      expect(RefundStatus.processing.isSettled, isFalse);
      expect(RefundStatus.requested.isSettled, isFalse);
      expect(RefundStatus.processing.isInFlight, isTrue);
      expect(RefundStatus.failed.isInFlight, isFalse);
    });

    test('keeps the raw status for diagnostics', () {
      final r = ApiRefund.fromJson({'id': 'x', 'status': 'reversed_by_bank'});
      expect(r!.rawStatus, 'reversed_by_bank');
      expect(r.status, RefundStatus.unknown);
    });

    test('tolerates a numeric amount as well as a decimal string', () {
      expect(ApiRefund.fromJson({'id': 'a', 'status': 'settled', 'amount': 500})!.amount, 500.0);
      expect(ApiRefund.fromJson({'id': 'a', 'status': 'settled', 'amount': '12.50'})!.amount, 12.5);
      expect(ApiRefund.fromJson({'id': 'a', 'status': 'settled'})!.amount, isNull);
    });

    test('lastUpdatedAt prefers the terminal timestamp', () {
      final settled = ApiRefund.fromJson({
        'id': 'a',
        'status': 'settled',
        'requested_at': '2026-08-20T10:00:00Z',
        'settled_at': '2026-08-24T09:00:00Z',
      });
      expect(settled!.lastUpdatedAt, DateTime.parse('2026-08-24T09:00:00Z'));

      final pending = ApiRefund.fromJson({
        'id': 'a',
        'status': 'processing',
        'requested_at': '2026-08-20T10:00:00Z',
      });
      expect(pending!.lastUpdatedAt, DateTime.parse('2026-08-20T10:00:00Z'));
    });
  });

  group('ApiBookingItem refund wiring', () {
    Map<String, dynamic> booking({dynamic refund}) => {
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
        };

    test('reads the refund object off a booking', () {
      final b = ApiBookingItem.fromJson(booking(refund: {
        'id': 'b3f1',
        'status': 'processing',
        'amount': '500.00',
        'currency': 'INR',
        'requested_at': '2026-08-20T10:00:00Z',
      }));
      expect(b.refund, isNotNull);
      expect(b.refund!.status, RefundStatus.processing);
      // The older snapshot field is untouched by the new object.
      expect(b.refundAmount, 500);
    });

    test('leaves refund null when the API sends null', () {
      expect(ApiBookingItem.fromJson(booking(refund: null)).refund, isNull);
    });

    test('copyWith carries the refund through', () {
      final b = ApiBookingItem.fromJson(booking(refund: {
        'id': 'b3f1',
        'status': 'settled',
      }));
      expect(b.copyWith(status: 'refunded').refund?.status,
          RefundStatus.settled);
    });
  });
}
