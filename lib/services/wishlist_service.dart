import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class WishlistService {
  static const _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  static Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── Fetch ──────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchWishlist(String accessToken) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/v1/wishlist/'), headers: _headers(accessToken))
          .timeout(_timeout);

      if (res.statusCode == 401) throw Exception('Session expired. Please log in again.');

      if (res.body.isEmpty) return [];
      final body = jsonDecode(res.body);

      // Normalise every shape the API might return into a List, then keep
      // only the map entries (skips any stray nulls — the source of the
      // "Null is not a subtype of Map<String, dynamic>" cast crash).
      List<dynamic> raw = const [];
      if (body is List) {
        raw = body;
      } else if (body is Map) {
        final data = body['data'];
        if (data is List) {
          raw = data;
        } else if (data is Map && data['results'] is List) {
          raw = data['results'] as List;
        } else if (body['results'] is List) {
          raw = body['results'] as List;
        }
      }
      return raw.whereType<Map<String, dynamic>>().toList();
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Add ────────────────────────────────────────────────────────────────────

  /// Returns the created/reactivated wishlist item (200 or 201 both succeed).
  static Future<void> add(String accessToken, String listingId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/wishlist/add/'),
            headers: _headers(accessToken),
            body: jsonEncode({'listing_id': listingId}),
          )
          .timeout(_timeout);

      if (res.statusCode == 401) throw Exception('Session expired. Please log in again.');
      if (res.statusCode == 404) throw Exception('Listing not found.');
      if (res.statusCode == 400) {
        // 400 = already in wishlist (API reactivates removed items, so this means it's already active)
        return; // treat as success — item is in wishlist
      }
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Failed to add to wishlist.');
      }
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Remove ─────────────────────────────────────────────────────────────────

  static Future<void> remove(String accessToken, String listingId) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$_base/api/v1/wishlist/remove/$listingId/'),
            headers: _headers(accessToken),
          )
          .timeout(_timeout);

      if (res.statusCode == 401) throw Exception('Session expired. Please log in again.');
      if (res.statusCode == 404) return; // Already removed — treat as success
      if (res.statusCode != 200) throw Exception('Failed to remove from wishlist.');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }
}
