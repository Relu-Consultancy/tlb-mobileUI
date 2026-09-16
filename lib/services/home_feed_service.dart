import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/homepage_section_model.dart';

/// Fetches a section → listings mapping.
///
/// Two feeds share one response shape: the homepage
/// (GET /api/v1/homepage/sections/) and each discovery screen
/// (GET /api/v1/listings/{screen}/sections/).
///
/// Auth is optional on both. Pass a customer bearer [token] whenever the
/// caller has one: `is_wishlisted` is false for every card without it. On
/// the homepage endpoint this was a bug (fixed 9 Sep 2026) — the discovery
/// endpoints already handled the optional token correctly.
///
/// Geo params are optional. Pass [lat] and [lng] together to receive a
/// `distance_km` value on each card; omitting either sends no coordinates.
/// Passing only one of the pair returns 400 INVALID_COORDS from the API,
/// which is why [_fetch] guards the pair as all-or-nothing.
class HomeFeedService {
  static const String _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  /// The homepage feed.
  ///
  /// Pass [token] (customer bearer) so `is_wishlisted` reflects the caller's
  /// actual wishlist. Pass [lat] + [lng] together for `distance_km` on cards.
  static Future<List<HomepageSection>> fetchSections({
    String? token,
    double? lat,
    double? lng,
  }) =>
      _fetch(
        '$_base/api/v1/homepage/sections/',
        token: token,
        lat: lat,
        lng: lng,
      );

  /// One discovery screen's feed — [screen] is events, classes, programs
  /// or venues.
  ///
  /// Pass [lat] + [lng] together for `distance_km` on cards. Auth is not
  /// required here but pass a token if available so `is_wishlisted` is live.
  static Future<List<HomepageSection>> fetchScreenSections(
    String screen, {
    String? token,
    double? lat,
    double? lng,
  }) =>
      _fetch(
        '$_base/api/v1/listings/$screen/sections/',
        token: token,
        lat: lat,
        lng: lng,
      );

  static Future<List<HomepageSection>> _fetch(
    String url, {
    String? token,
    double? lat,
    double? lng,
  }) async {
    try {
      // Build query parameters — geo requires both or neither.
      final params = <String, String>{
        if (lat != null && lng != null) ...{
          'lat': lat.toString(),
          'lng': lng.toString(),
        },
      };
      final uri = params.isEmpty
          ? Uri.parse(url)
          : Uri.parse(url).replace(queryParameters: params);

      final res = await http
          .get(
            uri,
            headers: {
              'accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (res.statusCode != 200) {
        throw Exception('Failed to load sections (${res.statusCode})');
      }
      final decoded = jsonDecode(res.body);
      // Supports both the {success, data:[...]} envelope and a bare array.
      final List list = decoded is Map<String, dynamic>
          ? (decoded['data'] as List? ?? [])
          : (decoded is List ? decoded : []);
      return list
          .whereType<Map<String, dynamic>>()
          .map(HomepageSection.fromJson)
          .toList();
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }
}
