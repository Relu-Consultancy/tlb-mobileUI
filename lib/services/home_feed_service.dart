import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/homepage_section_model.dart';

/// Fetches the homepage section → listings mapping
/// (GET /api/v1/homepage/sections/). Public, no auth.
class HomeFeedService {
  static const String _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  static Future<List<HomepageSection>> fetchSections() async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/homepage/sections/'),
            headers: {'accept': 'application/json'},
          )
          .timeout(_timeout);

      if (res.statusCode != 200) {
        throw Exception('Failed to load homepage (${res.statusCode})');
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
