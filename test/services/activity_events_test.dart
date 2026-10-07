import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/services/activity_service.dart';

/// The FE-only activity events beyond listing views: search, apply_filters
/// and share — plus the endpoint's rules (signed-in only, 60/min, metadata
/// caps, fire-and-forget).
const _uuid = '550e8400-e29b-41d4-a716-446655440000';

void main() {
  late List<Map<String, dynamic>> sent;
  late DateTime clock;

  setUp(() {
    sent = [];
    clock = DateTime(2026, 10, 7, 12);
    ActivityService.resetForTest();
    ActivityService.send = (body) async => sent.add(body);
    ActivityService.now = () => clock;
    AuthState.isLoggedIn.value = true;
  });

  tearDown(() {
    ActivityService.resetForTest();
    AuthState.isLoggedIn.value = false;
  });

  group('search', () {
    test('TC_A_EV_001 — a committed search sends the term and filters', () {
      ActivityService.trackSearch('pottery',
          scope: 'Classes', filters: {'mode': 'Online', 'age': ['3-5']});

      expect(sent.single, {
        'event_type': 'search',
        'platform': 'app',
        'metadata': {
          'term': 'pottery',
          'scope': 'Classes',
          'mode': 'Online',
          'age': '3-5',
        },
      });
    });

    test('TC_A_EV_002 — submit then opening a result counts once', () {
      ActivityService.trackSearch('pottery');
      ActivityService.trackSearch('Pottery '); // result tap, same term
      expect(sent, hasLength(1));
    });

    test('TC_A_EV_003 — a new term, or the same one later, counts again', () {
      ActivityService.trackSearch('pottery');
      ActivityService.trackSearch('dance');
      clock = clock.add(const Duration(minutes: 2));
      ActivityService.trackSearch('dance');
      expect(sent.map((e) => e['metadata']['term']),
          ['pottery', 'dance', 'dance']);
    });

    test('TC_A_EV_004 — an empty box is not a search', () {
      ActivityService.trackSearch('   ');
      expect(sent, isEmpty);
    });
  });

  group('apply_filters', () {
    test('TC_A_EV_005 — one event per applied set, per screen', () {
      ActivityService.trackFilters('category_events',
          {'category': 'Arts & Crafts', 'sort': 'Price- Low to High'});
      // Sheet closed again without changes — same set.
      ActivityService.trackFilters('category_events',
          {'sort': 'Price- Low to High', 'category': 'Arts & Crafts'});
      expect(sent, hasLength(1));
      expect(sent.single['metadata'], {
        'screen': 'category_events',
        'category': 'Arts & Crafts',
        'sort': 'Price- Low to High',
      });

      ActivityService.trackFilters('category_events',
          {'category': 'Arts & Crafts', 'sort': 'Distance- Near to Far'});
      expect(sent, hasLength(2));
    });

    test('TC_A_EV_006 — clearing filters is reported once; never-set is not',
        () {
      ActivityService.trackFilters('search', {'type': null, 'age': <String>[]});
      expect(sent, isEmpty, reason: 'nothing was ever applied');

      ActivityService.trackFilters('search', {'mode': 'Online'});
      ActivityService.trackFilters('search', {'mode': null});
      ActivityService.trackFilters('search', {});
      expect(sent.map((e) => e['metadata']),
          [{'screen': 'search', 'mode': 'Online'}, {'screen': 'search'}]);
    });
  });

  group('share', () {
    test('TC_A_EV_007 — a listing share carries its id', () {
      ActivityService.trackShare(type: 'event', id: _uuid);
      expect(sent.single, {
        'event_type': 'share',
        'listing_id': _uuid,
        'platform': 'app',
        'metadata': {'listing_type': 'event'},
      });
    });

    test('TC_A_EV_008 — a partner share is not passed off as a listing', () {
      ActivityService.trackShare(type: 'partner', id: _uuid);
      expect(sent.single.containsKey('listing_id'), isFalse);
      expect(sent.single['metadata'],
          {'listing_type': 'partner', 'partner_id': _uuid});
    });

    test('TC_A_EV_009 — every share in the app goes through the tracked helper',
        () {
      final helper = File('lib/core/share_helper.dart').readAsStringSync();
      expect(helper, contains('ActivityService.trackShare('));
      // No screen opens the share sheet around the helper.
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        if (f.path.replaceAll('\\', '/').endsWith('core/share_helper.dart')) {
          continue;
        }
        expect(f.readAsStringSync(), isNot(contains('Share.share(')),
            reason: '${f.path} shares without reporting it');
      }
    });
  });

  group('endpoint rules', () {
    test('TC_A_EV_010 — signed-out customers are not tracked', () {
      AuthState.isLoggedIn.value = false;
      ActivityService.trackSearch('pottery');
      ActivityService.trackFilters('search', {'mode': 'Online'});
      ActivityService.trackShare(type: 'event', id: _uuid);
      expect(sent, isEmpty);
    });

    test('TC_A_EV_011 — stays under 60 a minute, then resumes', () {
      for (var i = 0; i < 80; i++) {
        ActivityService.trackSearch('term $i');
      }
      expect(sent.length, lessThan(60));
      final capped = sent.length;

      clock = clock.add(const Duration(minutes: 1, seconds: 1));
      ActivityService.trackSearch('after the window');
      expect(sent.length, capped + 1);
    });

    test('TC_A_EV_012 — metadata is held to 20 keys and 200 characters', () {
      ActivityService.trackSearch('x' * 500, filters: {
        for (var i = 0; i < 40; i++) 'k$i': 'v',
      });
      final meta = sent.single['metadata'] as Map;
      expect(meta.length, 20);
      expect((meta['term'] as String).length, 200);
    });

    test('TC_A_EV_013 — only the four accepted event types are ever sent', () {
      final src =
          File('lib/services/activity_service.dart').readAsStringSync();
      final types = RegExp(r"'event_type': '(\w+)'")
          .allMatches(src)
          .map((m) => m.group(1))
          .toSet();
      expect(types, {'view_listing', 'search', 'apply_filters', 'share'});
    });

    test('TC_A_EV_014 — a failed send never surfaces', () async {
      ActivityService.send = (_) async => throw Exception('429');
      expect(() => ActivityService.trackSearch('pottery'), returnsNormally);
      await Future<void>.delayed(Duration.zero);
    });
  });
}
