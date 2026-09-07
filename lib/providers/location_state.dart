import 'package:flutter/foundation.dart';

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
  void setCity(String city, {double? latitude, double? longitude}) {
    if (city.trim().isEmpty) return;
    selectedCity.value = city.trim();
    this.latitude = latitude;
    this.longitude = longitude;
  }

  bool isLocationSupported(String city) {
    return supportedCities.any((c) => c.toLowerCase() == city.toLowerCase());
  }
}
