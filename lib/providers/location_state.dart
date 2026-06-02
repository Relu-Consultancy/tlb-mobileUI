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

  void setCity(String city) {
    if (city.trim().isNotEmpty) {
      selectedCity.value = city.trim();
    }
  }

  bool isLocationSupported(String city) {
    return supportedCities.any((c) => c.toLowerCase() == city.toLowerCase());
  }
}
