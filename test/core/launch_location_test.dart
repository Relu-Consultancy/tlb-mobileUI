import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/launch_location.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';

void main() {
  // detect() registers an app-lifecycle listener, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();
  final state = LocationState();

  setUp(() {
    AuthState.isLoggedIn.value = false; // keep setCity off the network
    state.refreshGeoFeeds = () {};
    // The app starts with no city: put the singleton back there.
    state.resetForTest();
    LaunchLocation.resetForTest();
  });

  tearDown(() {
    LaunchLocation.resetForTest();
    state.resolvingLocation.value = false;
    state.setCity('Mumbai');
  });

  group('no default city', () {
    test('TC_C_LL_001 — a fresh app has no city and sends no city filter', () {
      expect(state.hasCity, isFalse);
      expect(state.cityOrNull, isNull);
    });

    test('TC_C_LL_002 — a set city is passed through to the filters', () {
      state.setCity('Pune');
      expect(state.hasCity, isTrue);
      expect(state.cityOrNull, 'Pune');
    });
  });

  group('LaunchLocation.detect', () {
    test('TC_C_LL_003 — a granted fix sets the city and keeps the coordinates',
        () async {
      LaunchLocation.acquireFix = () async => (lat: 18.52, lng: 73.86);
      LaunchLocation.resolvePlace =
          (_, __) async => (city: 'Pune', label: 'FC Road, Shivajinagar, Pune');

      await LaunchLocation.detect();

      expect(state.selectedCity.value, 'Pune');
      expect(state.latitude, 18.52);
      expect(state.longitude, 73.86);
      expect(state.resolvingLocation.value, isFalse);
    });

    test('TC_C_LL_004 — declined permission leaves the city unset', () async {
      LaunchLocation.acquireFix = () async => null;

      await LaunchLocation.detect();

      expect(state.hasCity, isFalse);
      expect(state.hasCoordinates, isFalse);
      expect(state.resolvingLocation.value, isFalse);
    });

    test('TC_C_LL_005 — a fix the geocoder cannot name leaves it unset',
        () async {
      LaunchLocation.acquireFix = () async => (lat: 0.0, lng: 0.0);
      LaunchLocation.resolvePlace = (_, __) async => null;

      await LaunchLocation.detect();

      expect(state.hasCity, isFalse);
      expect(state.hasCoordinates, isFalse);
    });

    test('TC_C_LL_006 — a timeout or platform error leaves it unset', () async {
      LaunchLocation.acquireFix = () async => throw TimeoutException('gps');

      await LaunchLocation.detect();

      expect(state.hasCity, isFalse);
      expect(state.resolvingLocation.value, isFalse);
    });

    test('TC_C_LL_007 — shows as resolving while the fix is in flight',
        () async {
      final gate = Completer<({double lat, double lng})?>();
      LaunchLocation.acquireFix = () => gate.future;

      final pending = LaunchLocation.detect();
      // Set before the first await, so Home never paints "not selected" first.
      expect(state.resolvingLocation.value, isTrue);

      gate.complete(null);
      await pending;
      expect(state.resolvingLocation.value, isFalse);
    });

    test('TC_C_LL_008 — a city picked meanwhile is not overridden', () async {
      final gate = Completer<({double lat, double lng})?>();
      LaunchLocation.acquireFix = () => gate.future;
      LaunchLocation.resolvePlace =
          (_, __) async => (city: 'Pune', label: 'FC Road, Shivajinagar, Pune');

      final pending = LaunchLocation.detect();
      state.setCity('Goa'); // the customer chose by hand
      gate.complete((lat: 18.52, lng: 73.86));
      await pending;

      expect(state.selectedCity.value, 'Goa');
      expect(state.hasCoordinates, isFalse);
    });

    test('TC_C_LL_009 — an existing city is left alone without asking',
        () async {
      var asked = 0;
      LaunchLocation.acquireFix = () async {
        asked++;
        return (lat: 18.52, lng: 73.86);
      };
      state.setCity('Goa');

      await LaunchLocation.detect();

      expect(asked, 0);
      expect(state.selectedCity.value, 'Goa');
    });

    test('TC_C_LL_010 — a declined prompt is not repeated in the same run',
        () async {
      var asked = 0;
      LaunchLocation.acquireFix = () async {
        asked++;
        return null;
      };

      await LaunchLocation.detect();
      await LaunchLocation.detect(); // e.g. Home rebuilt after signing in

      expect(asked, 1);
    });

    test('TC_C_LL_011 — a fresh fix replaces a city restored from the account',
        () async {
      // Signed-in launch: the account's saved location lands first, carrying
      // only a city — the header used to stay on that bare city.
      state.setCity('Mumbai', latitude: 19.07, longitude: 72.87);
      LaunchLocation.acquireFix = () async => (lat: 18.52, lng: 73.86);
      LaunchLocation.resolvePlace =
          (_, __) async => (city: 'Pune', label: 'FC Road, Shivajinagar, Pune');

      await LaunchLocation.detect();

      expect(state.selectedCity.value, 'Pune');
      expect(state.placeLabel.value, 'FC Road, Shivajinagar, Pune');
    });
  });

  group('LaunchLocation.refreshOnResume', () {
    var silentFixes = 0;
    var promptingFixes = 0;

    setUp(() {
      silentFixes = 0;
      promptingFixes = 0;
      LaunchLocation.acquireFix = () async {
        promptingFixes++;
        return (lat: 18.52, lng: 73.86);
      };
      LaunchLocation.acquireFixSilently = () async {
        silentFixes++;
        return (lat: 18.53, lng: 73.85);
      };
      LaunchLocation.resolvePlace =
          (_, __) async => (city: 'Pune', label: 'JM Road, Deccan, Pune');
    });

    test('TC_C_LL_012 — refreshes silently, never prompting', () async {
      await LaunchLocation.refreshOnResume();

      expect(silentFixes, 1);
      expect(promptingFixes, 0);
      expect(state.placeLabel.value, 'JM Road, Deccan, Pune');
    });

    test('TC_C_LL_013 — a recent fix is not refreshed again', () async {
      await LaunchLocation.detect(); // fix taken just now
      await LaunchLocation.refreshOnResume();

      expect(silentFixes, 0);
    });

    test('TC_C_LL_014 — a city picked by hand is left alone', () async {
      state.setCity('Goa');
      await LaunchLocation.refreshOnResume();

      expect(silentFixes, 0);
      expect(state.selectedCity.value, 'Goa');
    });

    test('TC_C_LL_015 — no permission (no silent fix) changes nothing',
        () async {
      LaunchLocation.acquireFixSilently = () async => null;
      state.setCity('Mumbai', latitude: 19.07, longitude: 72.87);
      await LaunchLocation.refreshOnResume();

      expect(state.selectedCity.value, 'Mumbai');
    });
  });
}
