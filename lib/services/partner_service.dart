import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_followed_partner_model.dart';
import 'auth_http.dart';

class PartnerService {
  static const _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  /// POST /api/v1/partner/{partnerId}/follow/
  static Future<void> follow({
    required String token,
    required String partnerId,
  }) async {
    try {
      final resp = await AuthHttp.send((t) => http
          .post(
            Uri.parse('$_base/api/v1/partner/$partnerId/follow/'),
            headers: {
              'Authorization': 'Bearer $t',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout));

      if (resp.statusCode == 200 || resp.statusCode == 201) return;
      if (resp.statusCode == 400) {
        // 400 usually means already following — treat as success
        return;
      }
      final errBody = resp.body.length > 200 ? resp.body.substring(0, 200) : resp.body;
      throw Exception('Failed to follow partner (${resp.statusCode}): $errBody');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// DELETE /api/v1/partner/{partnerId}/unfollow/
  static Future<void> unfollow({
    required String token,
    required String partnerId,
  }) async {
    try {
      final resp = await AuthHttp.send((t) => http
          .delete(
            Uri.parse('$_base/api/v1/partner/$partnerId/unfollow/'),
            headers: {'Authorization': 'Bearer $t'},
          )
          .timeout(_timeout));

      if (resp.statusCode == 200) return;
      if (resp.statusCode == 404) return; // not following — treat as success
      throw Exception('Failed to unfollow partner (${resp.statusCode})');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// GET /api/v1/partner/followed/
  /// Returns the paginated list of partners the authenticated customer follows.
  static Future<List<ApiFollowedPartner>> fetchFollowed({
    required String token,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final uri = Uri.parse('$_base/api/v1/partner/followed/').replace(
        queryParameters: {
          'page': '$page',
          'page_size': '$pageSize',
        },
      );
      final resp = await AuthHttp.send((t) => http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $t',
          'Accept': 'application/json',
        },
      ).timeout(_timeout));

      if (resp.statusCode != 200) throw Exception('Failed to load followed partners (${resp.statusCode})');

      final decoded = jsonDecode(resp.body);
      final data = (decoded is Map ? (decoded['data'] ?? decoded) : null);
      if (data is! Map<String, dynamic>) return [];
      final results = (data['results'] as List<dynamic>? ?? []);
      return results
          .map((e) => ApiFollowedPartner.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      throw Exception('Failed to load followed partners: $e');
    }
  }
}
