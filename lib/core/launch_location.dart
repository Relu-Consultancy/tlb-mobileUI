import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../providers/location_state.dart';
import 'city_resolver.dart';

/// Asks for location permission when the app opens and, if it is granted,
/// sets the city from the device's fix.
///
/// The city used to be hard-coded to Mumbai on every launch. It now starts
/// unset, so this is what fills it in. A customer who declines — or whose GPS
/// is off, or whose place can't be named — is simply left with no city, and
/// Home shows "Location not selected" with a route to the picker.
///
/// Runs at most once per app run, so a declined prompt isn't repeated every
/// time Home is rebuilt (for instance after signing in). It never overrides a
/// city already chosen by hand.
class LaunchLocation {
  const LaunchLocation._();

  static bool _attempted = false;

  /// Test seam: how the device fix is obtained. Null means "no fix" (denied,
  /// location services off, or timed out).
  @visibleForTesting
  static Future<({double lat, double lng})?> Function() acquireFix = _acquireFix;

  /// Test seam: how a fix is named. The platform geocoder by default.
  @visibleForTesting
  static Future<String?> Function(double lat, double lng) resolveCity =
      CityResolver.fromCoordinates;

  @visibleForTesting
  static void resetForTest() {
    _attempted = false;
    acquireFix = _acquireFix;
    resolveCity = CityResolver.fromCoordinates;
  }

  /// Prompts for permission and applies the detected city. Safe to call from
  /// `initState`: the part before the first `await` marks the lookup as in
  /// flight, so Home never paints "Location not selected" for the moment
  /// before the answer is in.
  static Future<void> detect() async {
    final state = LocationState();
    if (_attempted || state.hasCity) return;
    _attempted = true;
    state.resolvingLocation.value = true;
    try {
      final fix = await acquireFix();
      if (fix == null) return;
      final city = await resolveCity(fix.lat, fix.lng);
      if (city == null || city.trim().isEmpty) return;
      // The customer may have picked a city while the fix was being taken.
      if (state.hasCity) return;
      state.setCity(city, latitude: fix.lat, longitude: fix.lng);
    } catch (_) {
      // Timed out or the platform refused: stay unset and let the customer
      // pick a city themselves.
    } finally {
      state.resolvingLocation.value = false;
    }
  }

  static Future<({double lat, double lng})?> _acquireFix() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Shows the OS prompt.
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return null;
    }
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    ).timeout(const Duration(seconds: 15));
    return (lat: position.latitude, lng: position.longitude);
  }
}
