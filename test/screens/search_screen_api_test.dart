import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The header's search box opens SearchScreen, which now asks the unified
/// `/listings/search/` endpoint instead of fanning out to the four per-type
/// browse endpoints.
///
/// SearchScreen builds its own service calls with no injectable client, so
/// this guards the wiring at source level — the same approach the enquiry
/// endpoint guards use.
void main() {
  final src = File('lib/screens/search_screen.dart').readAsStringSync();

  group('SearchScreen — unified search wiring', () {
    test('TC_S_SS_001 — a plain keyword goes to the unified endpoint', () {
      expect(src, contains('SearchService.search('));
      expect(src, contains('_usesUnifiedSearch'));
    });

    test('TC_S_SS_002 — the type chip is sent as a query parameter', () {
      expect(src, contains('type: _selectedKind'));
    });

    test('TC_S_SS_003 — unified results are not re-filtered by keyword', () {
      // The endpoint is typo-tolerant: "robtics" ranks "Weekend Robotics
      // Camp" first, and that row does not contain the typed word. The
      // token-contains guard the per-type path uses would discard exactly
      // those matches, so it must not run on this path.
      final start = src.indexOf('Future<void> _runUnifiedSearch(');
      expect(start, isNot(-1));
      final end = src.indexOf('_SearchItem _itemFromSearchResult(', start);
      expect(end, greaterThan(start));
      final body = src.substring(start, end);

      expect(body, isNot(contains('tokens')));
      expect(body, isNot(contains('haystack')));
      expect(body, isNot(contains('.contains')));
    });

    test('TC_S_SS_004 — a category filter still goes type-by-type', () {
      // The unified endpoint takes no category parameter, so dropping the
      // per-type path would silently lose category filtering.
      expect(src, contains('bool get _usesUnifiedSearch => !_hasServerFilter;'));
      expect(src, contains('EventsListingService.fetchEvents('));
      expect(src, contains('ClassesListingService.fetchClasses('));
      expect(src, contains('ProgramsListingService.fetchPrograms('));
      expect(src, contains('EventsListingService.fetchVenues('));
    });
  });
}
