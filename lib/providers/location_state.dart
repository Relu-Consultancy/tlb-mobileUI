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

  /// The globally selected city; empty until the customer has one.
  ///
  /// It used to default to Mumbai, which put every first launch in a city
  /// nobody had chosen. It now starts unset: the app asks for location
  /// permission on launch and fills it from the device fix (see
  /// `LaunchLocation`), and a customer who declines picks a city by hand. Until
  /// then Home shows the "Location not selected" screen. A city that is set but
  /// not in [supportedCities] still gets the "not serving this location" state.
  final ValueNotifier<String> selectedCity = ValueNotifier<String>('');

  /// True while the launch-time permission prompt / GPS fix is in flight, so
  /// the "Location not selected" screen doesn't flash up for the second or two
  /// before the city is known.
  final ValueNotifier<bool> resolvingLocation = ValueNotifier<bool>(false);

  /// A short "street, area, city" label for the header when the city came
  /// from a GPS fix (see `CityResolver.shortLabel`); null otherwise, and the
  /// header shows the bare city. Display only — filtering and every request
  /// still use [selectedCity].
  final ValueNotifier<String?> placeLabel = ValueNotifier<String?>(null);

  /// True when the current city was picked from the list by hand (no GPS
  /// fix behind it). A fresh device fix must not override that choice; it may
  /// replace a city detected on launch or restored from the account.
  bool get cityPickedByHand => _pickedByHand;
  bool _pickedByHand = false;

  /// Back to a fresh launch: no city, no fix, no label, nothing picked.
  @visibleForTesting
  void resetForTest() {
    _pickedByHand = false;
    latitude = null;
    longitude = null;
    placeLabel.value = null;
    resolvingLocation.value = false;
    selectedCity.value = '';
  }

  /// Whether a city has been chosen or detected.
  bool get hasCity => selectedCity.value.trim().isNotEmpty;

  /// The city for a listing request: null when none is set, so callers omit
  /// the `city` filter rather than sending an empty one that matches nothing.
  String? get cityOrNull => hasCity ? selectedCity.value : null;

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
    'Prayagraj',
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
  ///
  /// [label] is the short address for the header; it is kept only alongside
  /// coordinates, so a city picked by hand never shows an old street.
  void setCity(String city,
      {double? latitude, double? longitude, String? label}) {
    if (city.trim().isEmpty) return;
    final hadCoordinates = hasCoordinates;
    _pickedByHand = latitude == null || longitude == null;
    _apply(city, latitude, longitude, label: label);
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

  void _apply(String city, double? latitude, double? longitude,
      {String? label}) {
    // Label first, so anything listening to the city already sees it.
    final hasFix = latitude != null && longitude != null;
    final l = label?.trim();
    placeLabel.value = hasFix && l != null && l.isNotEmpty ? l : null;
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
    placeLabel.value = null; // the street belonged to that fix
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
