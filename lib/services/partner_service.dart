import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class PartnerService {
  static const _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  /// POST /api/v1/partner/{partnerId}/follow/
  static Future<void> follow({
    required String token,
    required String partnerId,
  }) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$_base/api/v1/partner/$partnerId/follow/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      if (resp.statusCode == 200 || resp.statusCode == 201) return;
      if (resp.statusCode == 400) return; // already following — treat as success
      throw Exception('Failed to follow partner (${resp.statusCode})');
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
      final resp = await http
          .delete(
            Uri.parse('$_base/api/v1/partner/$partnerId/unfollow/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      if (resp.statusCode == 200) return;
      if (resp.statusCode == 404) return; // not following — treat as success
      throw Exception('Failed to unfollow partner (${resp.statusCode})');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }
}
