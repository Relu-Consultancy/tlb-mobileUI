import 'package:flutter/foundation.dart';

import '../core/city_resolver.dart';
import '../services/customer_location_service.dart';
import 'auth_state.dart';
import 'discovery_feed_state.dart';
import 'home_feed_state.dart';

class LocationState {
  static final LocationState _instance = LocationState._internal();
  factory LocationState() => _instance;
  LocationState._internal();

  // The globally selected city. Defaults to a supported city so the home
  // screen shows real content on first launch instead of the empty-location
  // state. The user can still change this via the city picker; the empty
  // state remains for unsupported cities they pick manually.
  final ValueNotifier<String> selectedCity = ValueNotifier<String>('Mumbai');

  /// The GPS fix behind [selectedCity], when the city came from "use my
  /// current location". Null whenever the city was typed or picked from the
  /// list, because coordinates from an earlier, different place would put the
  /// user in the wrong spot.
  ///
  /// Kept because the listing endpoints' geo-distance sorting takes lat & lng,
  /// and the app used to reverse-geocode the fix to a city name and throw the
  /// numbers away — asking for location permission and then discarding what
  /// it got.
  double? latitude;
  double? longitude;

  /// True when a distance-based query has coordinates to work from.
  bool get hasCoordinates => latitude != null && longitude != null;

  // List of cities that currently have "events" in our dummy data.
  // Any city not in this list will trigger the Empty Location State on the home screen.
  final List<String> supportedCities = [
    'Mumbai',
    'New Delhi',
    'Bengaluru',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Goa',
    'Kochi',
    'Lucknow',
    'Sonipat',
    'The Palm Springs, DLF',
  ];

  /// Sets the city. Pass [latitude]/[longitude] only when the city was
  /// derived from a real fix; omitting them clears any stale pair, so the
  /// coordinates never disagree with the city on screen.
  ///
  /// This is the user's own choice, so it is also mirrored to their account
  /// (`/customer/location/`): a fix from "Use current location" is saved,
  /// and a city picked by hand clears whatever was saved before. Signed-out
  /// users keep it on the device only.
  void setCity(String city, {double? latitude, double? longitude}) {
    if (city.trim().isEmpty) return;
    final hadCoordinates = hasCoordinates;
    _apply(city, latitude, longitude);
    if (AuthState.isLoggedIn.value) {
      if (latitude != null && longitude != null) {
        CustomerLocationService.save(latitude, longitude);
      } else {
        CustomerLocationService.clear();
      }
    }
    // The section feeds only carry distance_km when the request had
    // coordinates, so a change in either direction needs a fresh fetch.
    if (hasCoordinates || hadCoordinates) _refreshGeoFeeds();
  }

  void _apply(String city, double? latitude, double? longitude) {
    selectedCity.value = city.trim();
    this.latitude = latitude;
    this.longitude = longitude;
  }

  /// Test seam and fallback for [restoreSaved]; the platform geocoder by
  /// default.
  @visibleForTesting
  Future<String?> Function(double latitude, double longitude) resolveCity =
      CityResolver.fromCoordinates;

  /// Test seam for [restoreSaved]; the real endpoint by default.
  @visibleForTesting
  Future<SavedLocation?> Function() fetchSaved =
      CustomerLocationService.fetch;

  /// Test seam for the feed refresh a coordinate change triggers.
  @visibleForTesting
  void Function() refreshGeoFeeds = _refreshLoadedFeeds;

  void _refreshGeoFeeds() => refreshGeoFeeds();

  /// Picks up the location saved to the account on an earlier launch, so
  /// distances show without asking the device again.
  ///
  /// Runs once per sign-in. It never overrides anything the user chose in
  /// this session: if the device already has a fix, or the city changes while
  /// the request is out, the saved copy is ignored. Nothing is written back —
  /// this only reads.
  ///
  /// The city is re-derived from the coordinates rather than left at its
  /// default, so the pair never disagrees with the city on screen. When the
  /// geocoder cannot name one the restore is skipped for the same reason.
  Future<void> restoreSaved() async {
    if (!AuthState.isLoggedIn.value || hasCoordinates) return;
    final cityAtStart = selectedCity.value;
    final saved = await fetchSaved();
    if (saved == null || !saved.isSet) return;
    if (hasCoordinates || selectedCity.value != cityAtStart) return;
    final city = await resolveCity(saved.latitude!, saved.longitude!);
    if (city == null || city.trim().isEmpty) return;
    // Re-check: the user may have picked a city while the geocoder ran.
    if (hasCoordinates || selectedCity.value != cityAtStart) return;
    if (!AuthState.isLoggedIn.value) return;
    _apply(city, saved.latitude, saved.longitude);
    _refreshGeoFeeds();
  }

  /// Forgets the device-side fix. Called on sign-out: the saved location
  /// belongs to that account, and the next person to sign in on this phone
  /// should not see distances measured from where the last one was. The
  /// account's server copy is left alone for their next sign-in.
  void clearCoordinates() {
    latitude = null;
    longitude = null;
  }

  /// Reload whichever section feeds are already on screen so their cards
  /// pick up (or drop) distance_km. Feeds for screens never opened are left
  /// alone; they fetch with the new coordinates when they are.
  static void _refreshLoadedFeeds() {
    if (HomeFeedState.isLoaded) HomeFeedState.load(force: true);
    for (final feed in [
      DiscoveryFeedState.events,
      DiscoveryFeedState.classes,
      DiscoveryFeedState.programs,
      DiscoveryFeedState.venues,
    ]) {
      if (feed.isLoaded) feed.load(force: true);
    }
  }

  bool isLocationSupported(String city) {
    return supportedCities.any((c) => c.toLowerCase() == city.toLowerCase());
  }
}
