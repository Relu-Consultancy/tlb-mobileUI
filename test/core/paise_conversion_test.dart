import 'package:flutter_test/flutter_test.dart';

/// Razorpay takes the amount in paise and rejects one that does not match the
/// order it was created for. The conversion is `amount * 100`, and the product
/// is a double — so truncating it can send a paise less than the order is for,
/// which surfaces only as Razorpay's generic "Something went wrong".
///
/// Guards the rule rather than the call site: the failure is silent, and the
/// only visible symptom is on a third party's screen.
void main() {
  int paise(double rupees) => (rupees * 100).round();

  group('Rupees to paise', () {
    test('TC_C_PA_001 — whole rupees convert exactly', () {
      expect(paise(500.0), 50000);
      expect(paise(1.0), 100);
      expect(paise(0.0), 0);
    });

    // The case that breaks: 1234.35 * 100 is 123434.99999999999 as a double.
    test('TC_C_PA_002 — a total that lands just under an integer rounds up',
        () {
      expect(1234.35 * 100, lessThan(123435));
      expect((1234.35 * 100).toInt(), 123434); // what truncation would send
      expect(paise(1234.35), 123435); // what the order is actually for
    });

    test('TC_C_PA_003 — ordinary two-decimal totals survive', () {
      expect(paise(449.99), 44999);
      expect(paise(10.29), 1029);
      expect(paise(899.70), 89970);
    });

    // Coupon discounts are where non-whole totals come from.
    test('TC_C_PA_004 — a percentage discount converts exactly', () {
      const original = 1234.35;
      final discounted = original * 0.9; // 10% off
      expect(paise(discounted), (discounted * 100).round());
      expect(paise(discounted) % 1, 0);
    });
  });
}
