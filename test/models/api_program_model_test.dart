import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/api_program_model.dart';

/// start_datetime / end_datetime were added to the programs list and detail
/// endpoints on 2026-08-24, following on from events. Unlike an event's
/// single start/end, a program's end_datetime is the *latest active batch's*
/// end — aggregated server-side, so the client just reads the one field, the
/// same as for an event. A program is over only once every batch is.
void main() {
  group('ApiProgram.fromJson — start/end datetime (list endpoint)', () {
    test('TC_M_AP_001 — parses both fields', () {
      final p = ApiProgram.fromJson({
        'id': '37ca638a-521b-4361-95c0-3c46d1c93ca5',
        'title': 'Coding Program – Powai',
        'average_rating': 0,
        'total_reviews': 0,
        'start_datetime': '2026-09-02T17:00:00Z',
        'end_datetime': '2026-10-28T17:00:00Z',
      });
      expect(p.startDatetime, DateTime.parse('2026-09-02T17:00:00Z'));
      expect(p.endDatetime, DateTime.parse('2026-10-28T17:00:00Z'));
    });

    test('TC_M_AP_002 — a card missing both parses to null, not a crash', () {
      final p = ApiProgram.fromJson({
        'id': 'x',
        'title': 'No dates',
        'average_rating': 0,
        'total_reviews': 0,
      });
      expect(p.startDatetime, isNull);
      expect(p.endDatetime, isNull);
    });
  });

  group('ApiProgramDetail — inherits start/end datetime', () {
    Map<String, dynamic> detailJson({String? start, String? end}) => {
          'id': '37ca638a-521b-4361-95c0-3c46d1c93ca5',
          'title': 'Coding Program – Powai',
          'average_rating': 0,
          'total_reviews': 0,
          'booking_type': 'direct_booking',
          'tags': [],
          'batches': [],
          'faqs': [],
          'media': [],
          'start_datetime': start,
          'end_datetime': end,
        };

    test('TC_M_AP_003 — the detail model carries both dates', () {
      final d = ApiProgramDetail.fromJson(detailJson(
        start: '2026-09-02T17:00:00Z',
        end: '2026-10-28T17:00:00Z',
      ));
      expect(d.startDatetime, DateTime.parse('2026-09-02T17:00:00Z'));
      expect(d.endDatetime, DateTime.parse('2026-10-28T17:00:00Z'));
      // Reachable as the ApiProgram-typed field too — one declaration, not a
      // duplicate shadowing field.
      final ApiProgram asBase = d;
      expect(asBase.endDatetime, d.endDatetime);
    });

    test('TC_M_AP_004 — a program still running (started, not ended)', () {
      // Mirrors the live "Monsoon Special Art Festival" case for events: this
      // must not be treated as ended just because it has begun.
      final d = ApiProgramDetail.fromJson(detailJson(
        start: '2020-01-01T00:00:00Z',
        end: '2099-01-01T00:00:00Z',
      ));
      expect(d.endDatetime!.isAfter(DateTime.now()), isTrue);
    });
  });
}
