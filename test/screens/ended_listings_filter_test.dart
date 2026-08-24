import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Follows on from ended_events_filter_test.dart (events) — same treatment
/// extended to programs (has a real end_datetime, aggregated across active
/// batches) and classes (no end_datetime by design; is_paused is the
/// equivalent signal). Venues get neither field and are correctly untouched
/// — see ListingSchedule's doc.
///
/// The filtering logic itself is covered where it's actually testable — see
/// api_program_model_test.dart, api_class_model_test.dart and
/// listing_schedule_test.dart. This file guards the wiring: that each
/// consumer still calls the right predicate on the right field, since the
/// services hit http.post/get directly with no injectable client (see
/// auth_service_test.dart), so there's no seam to mock these screens'
/// network calls through.
void main() {
  String read(String path) => File(path).readAsStringSync();

  group('Programs — filtered like events, by end_datetime', () {
    test('TC_S_ELF_001 — category_programs_screen filters _apiPrograms', () {
      final src = read('lib/screens/category_programs_screen.dart');
      expect(src, contains('ListingSchedule.hasEnded(p.endDatetime)'));
    });

    test('TC_S_ELF_002 — search_screen filters program results', () {
      final src = read('lib/screens/search_screen.dart');
      // Scope to the _fetchProgramItems *definition*, not its call site
      // (which appears earlier in the file, in _doSearch) — so this can't
      // accidentally match the events branch's identically-shaped filter.
      final start = src.indexOf('Future<List<_SearchItem>?> _fetchProgramItems');
      expect(start, greaterThan(-1));
      final body = src.substring(start, start + 1200);
      expect(body, contains('ListingSchedule.hasEnded(p.endDatetime)'));
    });

    test('TC_S_ELF_003 — home_feed_state filters the homepage feed', () {
      final src = read('lib/providers/home_feed_state.dart');
      expect(src, contains('ListingSchedule.hasEnded(l.endDatetime)'));
    });
  });

  group('Classes — filtered by is_paused, not a date', () {
    test('TC_S_ELF_004 — category_classes_screen filters _apiClasses', () {
      final src = read('lib/screens/category_classes_screen.dart');
      expect(src, contains('!c.isPaused'));
      // The wrong fix for this bug is reaching for ListingSchedule here —
      // classes have no end_datetime to filter by at all.
      expect(src, isNot(contains('ListingSchedule.hasEnded')));
    });

    test('TC_S_ELF_005 — search_screen filters class results', () {
      final src = read('lib/screens/search_screen.dart');
      final start = src.indexOf('Future<List<_SearchItem>?> _fetchClassItems');
      expect(start, greaterThan(-1));
      final body = src.substring(start, start + 1200);
      expect(body, contains('!c.isPaused'));
    });
  });

  group('Venues — deliberately untouched', () {
    test('TC_S_ELF_006 — no schedule/pause filter exists for venues', () {
      // Neither a date nor a pause flag exists for venues (permanently
      // bookable space; availability is slots, not a run of dates) — nothing
      // to filter, per ListingSchedule's doc. This guards against someone
      // "fixing" venues to match events/programs by mistake.
      final src = read('lib/models/api_venue_model.dart');
      expect(src, isNot(contains('endDatetime')));
      expect(src, isNot(contains('isPaused')));
    });
  });
}
