import 'dart:async';

import 'package:geocoding/geocoding.dart';

/// Turns coordinates into one of the app's city names.
///
/// Shared by the location screen's "Use current location" button and by
/// the launch-time restore of a saved location, so both land on the same
/// city for the same place. Before this lived in the screen, a restored
/// fix would have had no way to name its city.
class CityResolver {
  CityResolver._();

  /// Cities the picker lists, and the names a geocoded place is matched to.
  static const List<String> allCities = [
    'Agra',
    'Ahmedabad',
    'Ajmer',
    'Aligarh',
    'Amritsar',
    'Bengaluru',
    'Bhopal',
    'Chandigarh',
    'Chennai',
    'Coimbatore',
    'Delhi NCR',
    'Goa',
    'Guwahati',
    'Hyderabad',
    'Indore',
    'Jaipur',
    'Kanpur',
    'Kochi',
    'Kolkata',
    'Lucknow',
    'Mumbai',
    'Nagpur',
    'Patna',
    'Pune',
    'Surat',
    'Vadodara',
    'Visakhapatnam',
  ];

  /// The city for a coordinate pair, or null when the platform geocoder
  /// cannot name one (offline, timed out, or open sea).
  static Future<String?> fromCoordinates(double latitude, double longitude) async =>
      (await placeFromCoordinates(latitude, longitude))?.city;

  /// The city plus a short address label for the header (see [shortLabel]),
  /// or null when the geocoder cannot name a city.
  static Future<({String city, String? label})?> placeFromCoordinates(
      double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude)
          .timeout(const Duration(seconds: 10));
      if (placemarks.isEmpty) return null;
      final city = cityOf(placemarks.first);
      if (city == null) return null;
      return (city: city, label: shortLabel(placemarks.first, city));
    } catch (_) {
      return null;
    }
  }

  /// The app's city name for a placemark, or null when it names none.
  static String? cityOf(Placemark p) {
    final raw = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '';
    if (raw.trim().isEmpty) return null;
    return matchKnown(raw) ?? raw.trim();
  }

  /// A short "street, area, city" label for a GPS fix — what the header shows
  /// instead of the bare city, e.g. "MG Road, Civil Lines, Prayagraj".
  ///
  /// Most specific first: the road, then the neighbourhood, then the district,
  /// keeping at most two of those before the city. Repeats are dropped (in
  /// India the district is often the city itself), as are Google plus codes
  /// ("7JFJ+Q2") and bare house numbers, which mean nothing to a reader.
  /// Null when there is nothing beyond the city to add.
  static String? shortLabel(Placemark p, String city) {
    final plusCode = RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}', caseSensitive: false);
    bool usable(String? v) {
      final t = (v ?? '').trim();
      return t.isNotEmpty &&
          !plusCode.hasMatch(t) &&
          !RegExp(r'^[\d\s/,-]+$').hasMatch(t);
    }

    final cityLower = city.toLowerCase();
    final parts = <String>[];
    for (final candidate in [
      p.thoroughfare,
      p.subLocality,
      p.subAdministrativeArea,
    ]) {
      if (parts.length == 2) break;
      if (!usable(candidate)) continue;
      final t = candidate!.trim();
      final lower = t.toLowerCase();
      // Skip anything that repeats the city ("Mumbai Suburban" for Mumbai)
      // or a part already taken.
      if (lower.contains(cityLower) || cityLower.contains(lower)) continue;
      if (parts.any((x) => x.toLowerCase() == lower)) continue;
      parts.add(t);
    }
    if (parts.isEmpty) return null;
    return [...parts, city].join(', ');
  }

  /// Tries to map a raw geocoded city name to a known city in the app's list.
  static String? matchKnown(String raw) {
    final lower = raw.toLowerCase().trim();
    if (lower.isEmpty) return null;

    // Delhi region special case
    if (['delhi', 'new delhi', 'gurugram', 'gurgaon', 'noida', 'faridabad', 'ghaziabad']
        .any((k) => lower.contains(k))) {
      return 'Delhi NCR';
    }

    // Exact match (case-insensitive)
    for (final city in allCities) {
      if (city.toLowerCase() == lower) return city;
    }

    // Whole-word match — handles geocoded names that carry a suffix
    // ("Bengaluru Urban", "Mumbai Suburban") while AVOIDING false positives
    // from a bare substring search: "Prayagraj" used to resolve to "Agra"
    // because the letters "agra" sit inside "pray·AGRA·j". Requiring a word
    // boundary on both sides means a known city must appear as its own word.
    for (final city in allCities) {
      final c = city.toLowerCase();
      if (RegExp('\\b${RegExp.escape(c)}\\b').hasMatch(lower)) {
        return city;
      }
    }

    return null;
  }
}
