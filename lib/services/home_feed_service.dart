import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/homepage_section_model.dart';

/// Fetches a section → listings mapping. Public, no auth.
///
/// Two feeds share one response shape: the homepage
/// (GET /api/v1/homepage/sections/) and each discovery screen
/// (GET /api/v1/listings/{screen}/sections/).
class HomeFeedService {
  static const String _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  /// The homepage feed.
  static Future<List<HomepageSection>> fetchSections() =>
      _fetch('$_base/api/v1/homepage/sections/');

  /// One discovery screen's feed — [screen] is events, classes, programs
  /// or venues.
  static Future<List<HomepageSection>> fetchScreenSections(String screen) =>
      _fetch('$_base/api/v1/listings/$screen/sections/');

  static Future<List<HomepageSection>> _fetch(String url) async {
    try {
      final res = await http
          .get(
            Uri.parse(url),
            headers: {'accept': 'application/json'},
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
