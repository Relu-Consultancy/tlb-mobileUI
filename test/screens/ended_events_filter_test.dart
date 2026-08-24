import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/listing_schedule.dart';
import 'package:tlb_mobile_ui/models/api_event_model.dart';

/// Ended events are deliberately still returned by the events list API — the
/// client decides whether to hide, grey out, or badge them (per the backend
/// team's note on the `end_datetime` addition). This app hides them from
/// every browse/search surface, since a finished event has nothing left to
/// book and just leads to a dead end when tapped.
///
/// Filtering happens inline in four places (category_events_screen,
/// format_events_screen, upcoming_events_section, search_screen) rather than
/// in one shared function, because each already has its own `.where`/getter
/// doing other filtering (subcategory, city+format, self-exclusion, search
/// relevance). Two kinds of guard, since the filtering itself isn't behind a
/// single seam that could be unit-tested directly:
///   1. The predicate every site uses, run against realistic fixtures.
///   2. A static check that each site's source still calls it.
void main() {
  ApiEvent event({required String start, String? end}) => ApiEvent.fromJson({
        'id': 'e1',
        'title': 't',
        'city': 'Mumbai',
        'price_type': 'free',
        'start_datetime': start,
        'end_datetime': end,
      });

  group('The filter predicate, against realistic fixtures', () {
    // This exact case is why has_started can't be used: it started 20 Aug,
    // hasn't ended yet, and must survive the filter — a currently-running
    // event is not "ended".
    test('TC_S_EEF_001 — an ongoing event (started, not yet ended) survives',
        () {
      final ongoing = event(
        start: '2026-08-20T23:00:00Z',
        end: '2026-09-21T10:33:00Z',
      );
      expect(ListingSchedule.hasEnded(ongoing.endDatetime), isFalse);
    });

    test('TC_S_EEF_002 — a fully past event is filtered out', () {
      final ended = event(
        start: '2026-06-04T10:00:00Z',
        end: '2026-06-04T12:00:00Z',
      );
      expect(ListingSchedule.hasEnded(ended.endDatetime), isTrue);
    });

    test('TC_S_EEF_003 — a future event survives', () {
      final future = event(
        start: '2027-01-01T10:00:00Z',
        end: '2027-01-01T12:00:00Z',
      );
      expect(ListingSchedule.hasEnded(future.endDatetime), isFalse);
    });

    test('TC_S_EEF_004 — a card with no end date is never filtered out', () {
      final noEnd = event(start: '2020-01-01T10:00:00Z');
      expect(ListingSchedule.hasEnded(noEnd.endDatetime), isFalse);
    });
  });

  group('Each consumer still applies the filter', () {
    String read(String path) => File(path).readAsStringSync();

    test('TC_S_EEF_005 — category_events_screen filters _apiEvents', () {
      final src = read('lib/screens/category_events_screen.dart');
      expect(src, contains('ListingSchedule.hasEnded(e.endDatetime)'));
    });

    test('TC_S_EEF_006 — format_events_screen filters alongside format+city', () {
      final src = read('lib/screens/format_events_screen.dart');
      expect(src, contains('ListingSchedule.hasEnded(e.endDatetime)'));
    });

    // Superseded: this section originally filtered client-side, the same as
    // the other three. That broke it outright — fetching an unfiltered page
    // and stripping ended events afterward could legitimately zero out the
    // whole page (the API's default ordering front-loads old seed data; 10/10
    // events on page 1 were already-ended, hiding 11 genuinely upcoming ones
    // sitting on page 2+). date_preset: 'upcoming' filters server-side
    // instead, so pagination can't hide anything — see
    // upcoming_events_section_test.dart's TC_W_UE_003 for this guard now.
    test('TC_S_EEF_007 — upcoming_events_section filters server-side, not client-side', () {
      final src = read('lib/widgets/upcoming_events_section.dart');
      expect(src, contains("datePreset: 'upcoming'"));
      expect(src, isNot(contains('ListingSchedule.hasEnded')));
    });

    test('TC_S_EEF_008 — search_screen filters event results', () {
      final src = read('lib/screens/search_screen.dart');
      expect(src, contains('ListingSchedule.hasEnded(e.endDatetime)'));
    });

    // The one deliberate exception: on the detail screen — where the
    // customer has already navigated in — an ended event disables the CTA
    // instead of being unreachable. Confirms that treatment wasn't
    // accidentally replaced by hiding.
    test('TC_S_EEF_009 — event_detail_screen disables rather than hides', () {
      final src = read('lib/screens/event_detail_screen.dart');
      expect(src, contains('ListingSchedule.hasEnded(_detail?.endDatetime)'));
    });
  });
}
