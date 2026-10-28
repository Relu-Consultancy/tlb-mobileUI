import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/homepage_section_model.dart';

/// start_datetime / end_datetime were added to GET /homepage/sections/ (and
/// GET /discovery/{screen}/sections/) for every listing_type, but per the
/// per-type table only events and programs ever carry a non-null
/// end_datetime — confirmed live: a class card here has start_datetime but
/// end_datetime: null, and a venue has neither.
void main() {
  Map<String, dynamic> listing({
    required String listingType,
    String? start,
    String? end,
  }) =>
      {
        'id': 'x',
        'title': 't',
        'listing_type': listingType,
        'start_datetime': start,
        'end_datetime': end,
      };

  group('HomepageListing.fromJson — start/end datetime', () {
    test('TC_M_HP_001 — an event card carries both', () {
      final l = HomepageListing.fromJson(listing(
        listingType: 'event',
        start: '2026-06-15T10:30:00Z',
        end: '2026-06-15T16:30:00Z',
      ));
      expect(l.startDatetime, DateTime.parse('2026-06-15T10:30:00Z'));
      expect(l.endDatetime, DateTime.parse('2026-06-15T16:30:00Z'));
    });

    test('TC_M_HP_002 — a program card carries both', () {
      final l = HomepageListing.fromJson(listing(
        listingType: 'program',
        start: '2026-06-11T10:00:00Z',
        end: '2026-09-03T11:00:00Z',
      ));
      expect(l.startDatetime, isNotNull);
      expect(l.endDatetime, isNotNull);
    });

    // Live-verified shape: a class card has start_datetime but end_datetime
    // is explicitly null — by design (no end_date column exists), not a gap.
    test('TC_M_HP_003 — a class card has a start but no end', () {
      final l = HomepageListing.fromJson(listing(
        listingType: 'class',
        start: '2026-06-04T17:30:00Z',
        end: null,
      ));
      expect(l.startDatetime, isNotNull);
      expect(l.endDatetime, isNull);
    });

    test('TC_M_HP_004 — a venue card has neither', () {
      final l = HomepageListing.fromJson(listing(listingType: 'venue'));
      expect(l.startDatetime, isNull);
      expect(l.endDatetime, isNull);
    });
  });
}
