import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tlb_mobile_ui/core/city_resolver.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';
import 'package:tlb_mobile_ui/sections/home_header.dart';

import '../helpers/test_setup.dart';

void main() {
  group('CityResolver.shortLabel', () {
    test('TC_C_PL_001 — street, area, city', () {
      const p = Placemark(
        thoroughfare: 'MG Road',
        subLocality: 'Civil Lines',
        subAdministrativeArea: 'Prayagraj',
        locality: 'Prayagraj',
      );
      expect(CityResolver.shortLabel(p, 'Prayagraj'),
          'MG Road, Civil Lines, Prayagraj');
    });

    test('TC_C_PL_002 — district used when there is no road', () {
      const p = Placemark(subLocality: 'Andheri East',
          subAdministrativeArea: 'Thane', locality: 'Mumbai');
      expect(CityResolver.shortLabel(p, 'Mumbai'), 'Andheri East, Thane, Mumbai');
    });

    test('TC_C_PL_003 — at most two parts before the city', () {
      const p = Placemark(
        thoroughfare: 'Link Road',
        subLocality: 'Malad West',
        subAdministrativeArea: 'Thane',
      );
      expect(CityResolver.shortLabel(p, 'Mumbai'), 'Link Road, Malad West, Mumbai');
    });

    test('TC_C_PL_004 — drops repeats of the city and duplicates', () {
      const p = Placemark(
        subLocality: 'Bandra',
        subAdministrativeArea: 'Mumbai Suburban',
      );
      expect(CityResolver.shortLabel(p, 'Mumbai'), 'Bandra, Mumbai');
    });

    test('TC_C_PL_005 — drops plus codes and bare numbers', () {
      const p = Placemark(thoroughfare: '7JFJ+Q2', subLocality: '12/4');
      expect(CityResolver.shortLabel(p, 'Pune'), isNull);
    });

    test('TC_C_PL_006 — null when nothing beyond the city is known', () {
      const p = Placemark(locality: 'Goa');
      expect(CityResolver.shortLabel(p, 'Goa'), isNull);
    });
  });

  group('LocationState.placeLabel', () {
    final state = LocationState();

    setUp(() {
      AuthState.isLoggedIn.value = false; // keep setCity off the network
      state.refreshGeoFeeds = () {};
    });
    tearDown(() => state.setCity('Mumbai'));

    test('TC_C_PL_007 — kept with a GPS fix', () {
      state.setCity('Pune',
          latitude: 18.5, longitude: 73.8, label: 'FC Road, Shivajinagar, Pune');
      expect(state.placeLabel.value, 'FC Road, Shivajinagar, Pune');
    });

    test('TC_C_PL_008 — cleared when a city is picked by hand', () {
      state.setCity('Pune', latitude: 18.5, longitude: 73.8, label: 'FC Road, Pune');
      state.setCity('Goa');
      expect(state.placeLabel.value, isNull);
    });

    test('TC_C_PL_009 — ignored without coordinates', () {
      state.setCity('Goa', label: 'Somewhere, Goa');
      expect(state.placeLabel.value, isNull);
    });

    test('TC_C_PL_010 — cleared on sign-out with the fix', () {
      state.setCity('Pune', latitude: 18.5, longitude: 73.8, label: 'FC Road, Pune');
      state.clearCoordinates();
      expect(state.placeLabel.value, isNull);
    });
  });

  group('Header location chip', () {
    final state = LocationState();

    setUp(() {
      AuthState.isLoggedIn.value = false;
      state.refreshGeoFeeds = () {};
    });
    tearDown(() => state.setCity('Mumbai'));

    testWidgets('TC_W_PL_011 — shows the short address after a GPS fix',
        (tester) async {
      state.setCity('Prayagraj',
          latitude: 25.4, longitude: 81.8, label: 'MG Road, Civil Lines, Prayagraj');
      await pumpTLBApp(
          tester, const Scaffold(body: HomeHeader(onDark: true)));
      await tester.pump();
      expect(find.text('MG Road, Civil Lines, Prayagraj'), findsOneWidget);
    });

    testWidgets('TC_W_PL_012 — shows just the city when picked by hand',
        (tester) async {
      state.setCity('Pune');
      await pumpTLBApp(
          tester, const Scaffold(body: HomeHeader(onDark: true)));
      await tester.pump();
      expect(find.text('Pune'), findsOneWidget);
    });
  });
}
