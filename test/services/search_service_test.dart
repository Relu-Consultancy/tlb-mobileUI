import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/services/search_service.dart';

/// `GET /listings/search/?q={keyword}[&listing_type=...]` — the unified,
/// relevance-ranked, typo-tolerant search across all four listing types.
///
/// The services here call `http.get` directly with no injectable client (see
/// auth_service_test.dart's note), so the request itself is checked against
/// the literal source. The blank-query short-circuit needs no network and is
/// exercised for real.
void main() {
  String read(String relativePath) => File(relativePath).readAsStringSync();

  group('SearchService.search', () {
    test('TC_SVC_SS_001 — a blank query returns empty without a request', () {
      // The endpoint answers 400 VALIDATION_ERROR to a blank `q`; spending a
      // request to be told so would surface as an error state on screen.
      expectLater(
        SearchService.search('   ').then((p) => p.results),
        completion(isEmpty),
      );
      expectLater(
        SearchService.search('').then((p) => p.count),
        completion(0),
      );
    });
  });

  group('SearchService — request contract', () {
    late String src;

    setUp(() => src = read('lib/services/search_service.dart'));

    test('TC_SVC_SS_002 — calls the unified search path', () {
      expect(src, contains("'\$_base/api/v1/listings/search/'"));
    });

    test('TC_SVC_SS_003 — sends the keyword as q, not as search', () {
      // The per-type browse endpoints take `search`; this one takes `q` and
      // 400s without it.
      expect(src, contains("'q': q"));
      expect(src, isNot(contains("'search':")));
    });

    test('TC_SVC_SS_004 — narrows by listing_type only when asked', () {
      expect(src, contains("if (type != null) 'listing_type'"));
    });

    test('TC_SVC_SS_005 — sends no Authorization header', () {
      // A public browse endpoint; sending a stale token would be pointless
      // and, on expiry, harmful.
      expect(src, isNot(contains('Authorization')));
      expect(src, isNot(contains('Bearer')));
    });

    test('TC_SVC_SS_006 — treats 404 as no matches, not as a failure', () {
      expect(src, contains('res.statusCode == 404'));
    });
  });
}
