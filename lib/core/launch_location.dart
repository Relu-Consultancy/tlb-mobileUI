import 'package:flutter/widgets.dart';
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
/// Every launch takes a fresh fix, so the header shows where the customer is
/// now ("MG Road, Civil Lines, Prayagraj"), not a city remembered from before
/// — including over the location restored from their account, which only
/// carries a city. Back in the foreground after [refreshAfter], it refreshes
/// again, silently: only when permission is already granted, never prompting.
///
/// The prompt runs at most once per app run, so a declined one isn't repeated
/// every time Home is rebuilt (for instance after signing in). A city the
/// customer picked from the list by hand is never overridden.
class LaunchLocation {
  const LaunchLocation._();

  static bool _attempted = false;
  static DateTime? _lastFixAt;
  static AppLifecycleListener? _lifecycle;

  /// How stale a fix may get before returning to the app refreshes it.
  static const Duration refreshAfter = Duration(minutes: 10);

  /// Test seam: how the device fix is obtained. Null means "no fix" (denied,
  /// location services off, or timed out).
  @visibleForTesting
  static Future<({double lat, double lng})?> Function() acquireFix = _acquireFix;

  /// Test seam: a fix without ever prompting — null unless permission is
  /// already granted. Used by the foreground refresh.
  @visibleForTesting
  static Future<({double lat, double lng})?> Function() acquireFixSilently =
      () => _acquireFix(prompt: false);

  /// Test seam: how a fix is named — city plus the header's short address.
  /// The platform geocoder by default.
  @visibleForTesting
  static Future<({String city, String? label})?> Function(
      double lat, double lng) resolvePlace = CityResolver.placeFromCoordinates;

  @visibleForTesting
  static void resetForTest() {
    _attempted = false;
    _lastFixAt = null;
    _lifecycle?.dispose();
    _lifecycle = null;
    acquireFix = _acquireFix;
    acquireFixSilently = () => _acquireFix(prompt: false);
    resolvePlace = CityResolver.placeFromCoordinates;
  }

  /// Prompts for permission and applies the detected city. Safe to call from
  /// `initState`: the part before the first `await` marks the lookup as in
  /// flight, so Home never paints "Location not selected" for the moment
  /// before the answer is in.
  static Future<void> detect() async {
    final state = LocationState();
    _listenForResume();
    // A restored or detected city doesn't stop a fresh fix; one picked by
    // hand does.
    if (_attempted || state.cityPickedByHand) return;
    _attempted = true;
    state.resolvingLocation.value = true;
    try {
      await _applyFix(await acquireFix());
    } catch (_) {
      // Timed out or the platform refused: keep whatever city there is (or
      // none) and let the customer pick one themselves.
    } finally {
      state.resolvingLocation.value = false;
    }
  }

  /// Back in the foreground: refresh a stale fix, but only if permission is
  /// already granted — this never prompts — and the customer hasn't picked a
  /// city by hand.
  @visibleForTesting
  static Future<void> refreshOnResume() async {
    if (LocationState().cityPickedByHand) return;
    final last = _lastFixAt;
    if (last != null && DateTime.now().difference(last) < refreshAfter) return;
    try {
      await _applyFix(await acquireFixSilently());
    } catch (_) {
      // Keep the current location; the next resume tries again.
    }
  }

  static void _listenForResume() {
    _lifecycle ??= AppLifecycleListener(onResume: () => refreshOnResume());
  }

  static Future<void> _applyFix(({double lat, double lng})? fix) async {
    if (fix == null) return;
    final place = await resolvePlace(fix.lat, fix.lng);
    if (place == null || place.city.trim().isEmpty) return;
    // The customer may have picked a city by hand while the fix was taken.
    final state = LocationState();
    if (state.cityPickedByHand) return;
    _lastFixAt = DateTime.now();
    state.setCity(place.city,
        latitude: fix.lat, longitude: fix.lng, label: place.label);
  }

  static Future<({double lat, double lng})?> _acquireFix(
      {bool prompt = true}) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && prompt) {
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
