import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/listing_schedule.dart';

/// A finished event must not be bookable. Only events carry a schedule —
/// classes, programs and venues have no end date at all.
void main() {
  final now = DateTime.utc(2026, 8, 23, 12);

  group('ListingSchedule.hasEnded', () {
    test('TC_C_LS_001 — an end in the past has ended', () {
      expect(
        ListingSchedule.hasEnded(DateTime.utc(2026, 8, 22), now: now),
        isTrue,
      );
    });

    test('TC_C_LS_002 — an end in the future has not', () {
      expect(
        ListingSchedule.hasEnded(DateTime.utc(2026, 9, 21), now: now),
        isFalse,
      );
    });

    // Classes, programs and venues send no end date. Treating null as "ended"
    // would hide every one of them.
    test('TC_C_LS_003 — no end date is never treated as ended', () {
      expect(ListingSchedule.hasEnded(null, now: now), isFalse);
    });

    test('TC_C_LS_004 — the boundary is exclusive', () {
      expect(ListingSchedule.hasEnded(now, now: now), isFalse);
      expect(
        ListingSchedule.hasEnded(
            now.subtract(const Duration(seconds: 1)), now: now),
        isTrue,
      );
    });
  });

  group('ListingSchedule.isInProgress', () {
    // The real case: an event that began on 20 Aug and runs to 21 Sep is
    // under way, not finished — filtering on start alone would wrongly hide it.
    test('TC_C_LS_005 — a long run that has begun is still in progress', () {
      expect(
        ListingSchedule.isInProgress(
          DateTime.utc(2026, 8, 20, 23),
          DateTime.utc(2026, 9, 21, 10, 33),
          now: now,
        ),
        isTrue,
      );
    });

    test('TC_C_LS_006 — one not yet started is not in progress', () {
      expect(
        ListingSchedule.isInProgress(
          DateTime.utc(2026, 8, 30),
          DateTime.utc(2026, 8, 31),
          now: now,
        ),
        isFalse,
      );
    });

    test('TC_C_LS_007 — a finished one is not in progress', () {
      expect(
        ListingSchedule.isInProgress(
          DateTime.utc(2026, 8, 1),
          DateTime.utc(2026, 8, 2),
          now: now,
        ),
        isFalse,
      );
    });
  });
}
