import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_event_model.dart';

/// `end_datetime` was added to the public **list** endpoint on 2026-08-24
/// specifically so a finished event could be identified without fetching its
/// detail (previously only the detail response carried it — see
/// lib/core/listing_schedule.dart). These pin the parsing, and the
/// refactor that made ApiEventDetail inherit `endDatetime` from ApiEvent
/// instead of redeclaring its own separate field of the same name.
void main() {
  group('ApiEvent.fromJson — end_datetime (list endpoint)', () {
    test('TC_M_AE_001 — parses end_datetime alongside start_datetime', () {
      final e = ApiEvent.fromJson({
        'id': '1b98e204-b813-4c1c-87ce-15ccc2667a3a',
        'title': 'Summer Arts Festival',
        'city': 'Mumbai',
        'price_type': 'paid',
        'start_datetime': '2026-08-20T18:00:00Z',
        'end_datetime': '2026-09-21T22:00:00Z',
      });
      expect(e.endDatetime, DateTime.parse('2026-09-21T22:00:00Z'));
    });

    test('TC_M_AE_002 — a card missing end_datetime parses to null, not a crash', () {
      final e = ApiEvent.fromJson({
        'id': 'x',
        'title': 'No end date',
        'city': 'Mumbai',
        'price_type': 'free',
        'start_datetime': '2026-08-20T18:00:00Z',
      });
      expect(e.endDatetime, isNull);
    });
  });

  group('ApiEventDetail — endDatetime is inherited, not redeclared', () {
    // The base class already declares `endDatetime`; ApiEventDetail used to
    // duplicate it as its own field. This confirms the refactor to
    // `super.endDatetime` still threads the parsed value through correctly —
    // a mistake there would silently null out the detail screen's own
    // ended-event handling (ListingSchedule.hasEnded(_detail?.endDatetime)).
    test('TC_M_AE_003 — the detail model still carries end_datetime', () {
      final d = ApiEventDetail.fromJson({
        'id': 'a379ee9f-f44b-450e-b714-8f1e5c66b533',
        'title': 'Monsoon Special Art Festival',
        'category': {'id': 10, 'name': 'Festivals & Celebrations'},
        'format': 'meetup',
        'city': 'Mumbai',
        'price_type': 'paid',
        'start_datetime': '2026-08-20T23:00:00Z',
        'end_datetime': '2026-09-21T10:33:00Z',
        'mode': 'offline',
      });
      expect(d.endDatetime, DateTime.parse('2026-09-21T10:33:00Z'));
      // And it's reachable as the ApiEvent-typed field too — same instance,
      // one declaration.
      final ApiEvent asBase = d;
      expect(asBase.endDatetime, d.endDatetime);
    });
  });
}
