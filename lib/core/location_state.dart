import 'package:flutter/foundation.dart';

class LocationState {
  static final LocationState _instance = LocationState._internal();
  factory LocationState() => _instance;
  LocationState._internal();

  // The globally selected city. Defaults to a dummy "unsupported" city for testing the empty state quickly,
  // but could default to a supported city like 'New Delhi' in production.
  final ValueNotifier<String> selectedCity = ValueNotifier<String>('Bhopal City');

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
