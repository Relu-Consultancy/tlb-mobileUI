import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';
import 'package:tlb_mobile_ui/services/customer_location_service.dart';

/// The user's location is now saved to their account
/// (`/api/v1/customer/location/`) so distances show on a later launch without
/// asking the device again. These cover reading it back: when it applies,
/// and every case where it must not override what the user chose.
void main() {
  final state = LocationState();
  late int fetches;
  late int refreshes;

  void stub({SavedLocation? saved, String? city = 'Pune'}) {
    state.fetchSaved = () async {
      fetches++;
      return saved;
    };
    state.resolveCity = (_, __) async => city;
  }

  setUp(() {
    AuthState.isLoggedIn.value = false;
    // Reset with feed refresh silenced: a fix left by the previous test
    // would otherwise count as a refresh in this one.
    state.refreshGeoFeeds = () {};
    state.setCity('Mumbai'); // signed out: no network, clears any fix
    fetches = 0;
    refreshes = 0;
    state.refreshGeoFeeds = () => refreshes++;
    AuthState.isLoggedIn.value = true;
  });

  tearDown(() {
    AuthState.isLoggedIn.value = false;
  });

  const pune = SavedLocation(latitude: 18.52, longitude: 73.86);

  group('restoreSaved', () {
    test('TC_P_LOC_001 — applies the saved fix and names its city', () async {
      stub(saved: pune);
      await state.restoreSaved();

      expect(state.selectedCity.value, 'Pune');
      expect(state.latitude, 18.52);
      expect(state.longitude, 73.86);
      expect(refreshes, 1, reason: 'feeds refetch to pick up distance_km');
    });

    test('TC_P_LOC_002 — signed out, it does not ask', () async {
      AuthState.isLoggedIn.value = false;
      stub(saved: pune);
      await state.restoreSaved();

      expect(fetches, 0);
      expect(state.hasCoordinates, isFalse);
    });

    test('TC_P_LOC_003 — a fix taken this session wins', () async {
      state.latitude = 19.07;
      state.longitude = 72.87;
      stub(saved: pune);
      await state.restoreSaved();

      expect(fetches, 0);
      expect(state.latitude, 19.07);
    });

    test('TC_P_LOC_004 — nothing saved leaves the city alone', () async {
      stub(saved: const SavedLocation());
      await state.restoreSaved();

      expect(state.selectedCity.value, 'Mumbai');
      expect(state.hasCoordinates, isFalse);
      expect(refreshes, 0);
    });

    test('TC_P_LOC_005 — a failed request changes nothing', () async {
      stub(saved: null);
      await state.restoreSaved();

      expect(state.selectedCity.value, 'Mumbai');
      expect(state.hasCoordinates, isFalse);
    });

    test('TC_P_LOC_006 — a city picked while the request was out wins',
        () async {
      final gate = Completer<SavedLocation?>();
      state.fetchSaved = () => gate.future;
      state.resolveCity = (_, __) async => 'Pune';

      final pending = state.restoreSaved();
      // The user picks a city by hand before the response lands.
      AuthState.isLoggedIn.value = false; // keep setCity off the network
      state.setCity('Goa');
      AuthState.isLoggedIn.value = true;
      gate.complete(pune);
      await pending;

      expect(state.selectedCity.value, 'Goa');
      expect(state.hasCoordinates, isFalse);
    });

    test('TC_P_LOC_007 — skipped when the geocoder cannot name a city',
        () async {
      // Coordinates without a matching city would disagree with the screen.
      stub(saved: pune, city: null);
      await state.restoreSaved();

      expect(state.selectedCity.value, 'Mumbai');
      expect(state.hasCoordinates, isFalse);
    });
  });

  group('sign-out', () {
    test('TC_P_LOC_008 — forgets the device-side fix', () {
      state.latitude = 18.52;
      state.longitude = 73.86;
      state.clearCoordinates();

      expect(state.hasCoordinates, isFalse);
    });
  });

  group('setCity', () {
    test('TC_P_LOC_009 — a change of fix refetches the feeds', () {
      AuthState.isLoggedIn.value = false;
      state.setCity('Pune', latitude: 18.52, longitude: 73.86);
      expect(refreshes, 1);

      state.setCity('Goa'); // dropping the fix also changes distance_km
      expect(refreshes, 2);
    });

    test('TC_P_LOC_010 — hand-picking between cities with no fix does not',
        () {
      AuthState.isLoggedIn.value = false;
      state.setCity('Goa');
      state.setCity('Jaipur');
      expect(refreshes, 0);
    });
  });

  group('SavedLocation.fromJson', () {
    test('TC_P_LOC_011 — reads the API\'s decimal strings', () {
      final s = SavedLocation.fromJson({
        'latitude': '19.120000',
        'longitude': '72.880000',
        'location_updated_at': '2026-09-15T10:04:00Z',
      });
      expect(s.isSet, isTrue);
      expect(s.latitude, 19.12);
      expect(s.longitude, 72.88);
      expect(s.updatedAt, DateTime.utc(2026, 9, 15, 10, 4));
    });

    test('TC_P_LOC_012 — all-null after a DELETE reads as nothing saved', () {
      final s = SavedLocation.fromJson({
        'latitude': null,
        'longitude': null,
        'location_updated_at': null,
      });
      expect(s.isSet, isFalse);
    });
  });
}
