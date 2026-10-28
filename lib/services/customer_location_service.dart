import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_http.dart';

/// The customer's saved "last known location".
///
/// All three fields are null when nothing is saved — after a DELETE, or before
/// the user has ever shared a location.
class SavedLocation {
  final double? latitude;
  final double? longitude;
  final DateTime? updatedAt;

  const SavedLocation({this.latitude, this.longitude, this.updatedAt});

  /// True when there is a usable pair to read back.
  bool get isSet => latitude != null && longitude != null;

  /// The API sends the pair as decimal strings (`"19.120000"`); accept a
  /// number too, so a serializer change on either side cannot break parsing.
  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
        latitude: _num(json['latitude']),
        longitude: _num(json['longitude']),
        updatedAt:
            DateTime.tryParse(json['location_updated_at']?.toString() ?? ''),
      );

  static double? _num(Object? v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
}

/// `/api/v1/customer/location/` — GET, PATCH and DELETE, customer-only.
///
/// The server rounds what it stores to roughly 1 km (19.117866 reads back as
/// 19.12) and keeps the latest value only, no history. That is precise enough
/// for a distance badge and nothing finer, so the app keeps using the device's
/// own fix for the session it was taken in, and only falls back to this copy
/// on a later launch.
///
/// Every call goes through [AuthHttp], so an expired access token refreshes
/// once and retries. None of these are worth interrupting the user over: a
/// failure simply means distances are not shown until the next attempt.
class CustomerLocationService {
  CustomerLocationService._();

  static const String _url =
      'https://tlb-api.reluconsultancy.in/api/v1/customer/location/';
  static const _timeout = Duration(seconds: 15);

  /// What is saved, or null when the request failed.
  static Future<SavedLocation?> fetch() => _send(
        (t) => http.get(Uri.parse(_url), headers: _headers(t)).timeout(_timeout),
      );

  /// Saves the user's current location. Call only after the user explicitly
  /// taps "Use current location" — never in the background.
  static Future<SavedLocation?> save(double latitude, double longitude) {
    // Server-side validation rejects these with 400; skip a request that can
    // only fail.
    if (latitude.abs() > 90 || longitude.abs() > 180) {
      return Future.value(null);
    }
    return _send(
      (t) => http
          .patch(
            Uri.parse(_url),
            headers: {..._headers(t), 'Content-Type': 'application/json'},
            body: jsonEncode({
              // Six places is what the API stores anyway; sending the raw
              // double would only add noise it discards.
              'latitude': latitude.toStringAsFixed(6),
              'longitude': longitude.toStringAsFixed(6),
            }),
          )
          .timeout(_timeout),
    );
  }

  /// Clears the saved location. Called when the user picks a city by hand, so
  /// an old fix from somewhere else does not linger.
  static Future<SavedLocation?> clear() => _send(
        (t) =>
            http.delete(Uri.parse(_url), headers: _headers(t)).timeout(_timeout),
      );

  static Map<String, String> _headers(String token) => {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Future<SavedLocation?> _send(
    Future<http.Response> Function(String token) build,
  ) async {
    try {
      final res = await AuthHttp.send(build);
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      final decoded = jsonDecode(res.body);
      final data = decoded is Map<String, dynamic>
          ? (decoded['data'] is Map<String, dynamic>
              ? decoded['data'] as Map<String, dynamic>
              : decoded)
          : null;
      return data == null ? null : SavedLocation.fromJson(data);
    } catch (_) {
      // Offline, timed out, or the session could not be refreshed (AuthHttp
      // has already logged the user out in that last case).
      return null;
    }
  }
}
