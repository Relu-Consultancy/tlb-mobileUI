import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/user_location.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';

/// The geo parameters are all-or-nothing: a lone or malformed `lat` answers
/// 400 INVALID_COORDS. The services must therefore send both or neither, and
/// every browse screen must pass the user's fix when it has one.
///
/// The services build their requests with no injectable http client (see
/// auth_service_test's note), so the request shape is checked at source.
void main() {
  String read(String path) => File(path).readAsStringSync();

  group('UserLocation', () {
    setUp(() => LocationState().setCity('Mumbai'));

    test('TC_C_UL_001 — nothing to send until the user takes a fix', () {
      expect(UserLocation.isKnown, isFalse);
      expect(UserLocation.lat, isNull);
      expect(UserLocation.lng, isNull);
    });

    test('TC_C_UL_002 — both coordinates once a fix is taken', () {
      LocationState().setCity('Mumbai', latitude: 19.1178, longitude: 72.9079);
      expect(UserLocation.isKnown, isTrue);
      expect(UserLocation.lat, 19.1178);
      expect(UserLocation.lng, 72.9079);
    });

    test('TC_C_UL_003 — picking a city by hand stops sending the old fix', () {
      // Otherwise every distance would be measured from where the user was,
      // not the city they are now browsing.
      LocationState().setCity('Mumbai', latitude: 19.1178, longitude: 72.9079);
      LocationState().setCity('Pune');
      expect(UserLocation.isKnown, isFalse);
      expect(UserLocation.lat, isNull);
    });
  });

  group('Services send lat and lng together', () {
    const services = <String, List<String>>{
      'events_listing_service.dart': ['fetchEvents', 'fetchVenues'],
      'classes_listing_service.dart': ['fetchClasses'],
      'programs_listing_service.dart': ['fetchPrograms'],
      'search_service.dart': ['search'],
    };

    services.forEach((file, methods) {
      test('$file accepts and forwards coordinates', () {
        final src = read('lib/services/$file');
        expect(src, contains('double? lat,'), reason: file);
        expect(src, contains('double? lng,'), reason: file);
        expect(src, contains("'lat': lat.toString()"), reason: file);
        expect(src, contains("'lng': lng.toString()"), reason: file);
      });
    });

    test('TC_SVC_GEO_001 — neither is sent without the other', () {
      // A lone coordinate is a 400, so the pair is guarded as one.
      for (final file in const [
        'events_listing_service.dart',
        'classes_listing_service.dart',
        'search_service.dart',
      ]) {
        final src = read('lib/services/$file');
        expect(src, contains('if (lat != null && lng != null)'), reason: file);
      }
    });

    test('TC_SVC_GEO_002 — an empty geo class result retries without geo', () {
      // Geo-sorting excludes classes with no coordinates stored, and none
      // have them yet — sending the fix would empty the catalogue rather
      // than order it.
      final src = read('lib/services/classes_listing_service.dart');
      expect(src, contains('page1.results.isEmpty && lat != null'));
    });
  });

  group('Browse screens pass the user fix', () {
    const screens = <String>[
      'category_events_screen.dart',
      'category_classes_screen.dart',
      'category_programs_screen.dart',
      'category_venues_screen.dart',
      'format_events_screen.dart',
      'format_programs_screen.dart',
      'pace_classes_screen.dart',
      'search_screen.dart',
    ];

    for (final screen in screens) {
      test('$screen sends coordinates and renders the measured distance', () {
        final src = read('lib/screens/$screen');
        expect(src, contains('lat: UserLocation.lat'), reason: screen);
        expect(src, contains('lng: UserLocation.lng'), reason: screen);
      });
    }

    test('TC_S_GEO_001 — every converter carries distance to the card', () {
      const converters = <String, String>{
        'category_events_screen.dart': 'distanceKm: event.distanceKm',
        'category_classes_screen.dart': 'distanceKm: cls.distanceKm',
        'category_programs_screen.dart': 'distanceKm: prg.distanceKm',
        'format_events_screen.dart': 'distanceKm: e.distanceKm',
        'format_programs_screen.dart': 'distanceKm: p.distanceKm',
        'pace_classes_screen.dart': 'distanceKm: cls.distanceKm',
        'search_screen.dart': 'distanceKm: r.distanceKm',
      };
      converters.forEach((file, expected) {
        expect(read('lib/screens/$file'), contains(expected), reason: file);
      });
    });
  });

  group('Cards hide an unknown distance', () {
    test('TC_W_GEO_001 — no row is drawn without a measurement', () {
      for (final file in const [
        'lib/widgets/listing_meta_rows.dart',
        'lib/widgets/trending_event_card.dart',
        'lib/screens/programs_screen.dart',
      ]) {
        expect(read(file), contains('event.distanceDisplay != null'),
            reason: file);
      }
    });

    test('TC_W_GEO_002 — the fabricated figure is gone for good', () {
      final src = read('lib/models/event_model.dart');
      expect(src, isNot(contains('_mockSeed % 95')));
      expect(src, contains('String? get distanceDisplay'));
    });
  });
}
