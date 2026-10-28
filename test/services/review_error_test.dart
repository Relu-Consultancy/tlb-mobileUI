import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/services/review_service.dart';

/// The create-review endpoint rejects a review for a listing the account has
/// not booked. Before this, every failure surfaced as
/// "Failed to submit review (403)", which tells the customer nothing about
/// what went wrong or what to do.
void main() {
  group('Review submission errors', () {
    test('TC_SV_RV_001 — the server\'s own message always wins', () {
      expect(
        ReviewService.debugReviewError(
          {'error': {'code': 'FORBIDDEN', 'message': 'Book this first.'}},
          403,
        ),
        'Book this first.',
      );
    });

    test('TC_SV_RV_002 — a bare FORBIDDEN explains the booking rule', () {
      expect(
        ReviewService.debugReviewError({'error': {'code': 'FORBIDDEN'}}, 403),
        'You can review this only after booking it.',
      );
    });

    test('TC_SV_RV_003 — PROFILE_INCOMPLETE says what to fix', () {
      expect(
        ReviewService.debugReviewError(
            {'error': {'code': 'PROFILE_INCOMPLETE'}}, 403),
        'Complete your profile before writing a review.',
      );
    });

    test('TC_SV_RV_004 — a bodiless 403 still explains itself', () {
      expect(
        ReviewService.debugReviewError(null, 403),
        'You can review this only after booking it.',
      );
    });

    // The endpoint documents 400 as "Duplicate review or validation error".
    test('TC_SV_RV_005 — 400 reads as an already-reviewed listing', () {
      expect(
        ReviewService.debugReviewError(null, 400),
        "You've already reviewed this listing.",
      );
    });

    test('TC_SV_RV_006 — 401 points at re-authenticating', () {
      expect(
        ReviewService.debugReviewError(null, 401),
        'Please log in again to post your review.',
      );
    });

    test('TC_SV_RV_007 — an unmapped status keeps the code visible', () {
      expect(
        ReviewService.debugReviewError(null, 500),
        'Failed to submit review (500).',
      );
    });

    test('TC_SV_RV_008 — a blank server message falls through, not blank', () {
      expect(
        ReviewService.debugReviewError(
            {'error': {'code': 'FORBIDDEN', 'message': '   '}}, 403),
        'You can review this only after booking it.',
      );
    });
  });
}
