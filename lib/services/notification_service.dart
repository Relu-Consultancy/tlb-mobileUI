import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_notification_model.dart';
import 'auth_http.dart';

/// REST wrapper for the customer-side in-app notification endpoints
/// (`/api/v1/notifications/...`). All calls use the customer's own JWT.
class NotificationService {
  static const String _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── List ────────────────────────────────────────────────────────────────────

  /// GET /api/v1/notifications/in-app/?unread=&page=&page_size=
  static Future<ApiNotificationPage> listInApp({
    required String token,
    bool unreadOnly = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (unreadOnly) 'unread': 'true',
      };
      final uri = Uri.parse('$_base/api/v1/notifications/in-app/')
          .replace(queryParameters: params);
      final res = await AuthHttp.send(
          (t) => http.get(uri, headers: _headers(t)).timeout(_timeout));

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        // The list endpoint returns a bare paginated object; some gateways
        // wrap it in the {success, data} envelope — handle both.
        final root = body['results'] != null
            ? body
            : (body['data'] is Map<String, dynamic>
                ? body['data'] as Map<String, dynamic>
                : body);
        final list = root['results'] as List<dynamic>? ?? [];
        return ApiNotificationPage(
          count: (root['count'] as num?)?.toInt() ?? list.length,
          hasNext: root['next'] != null,
          results: list
              .whereType<Map<String, dynamic>>()
              .map(ApiNotification.fromJson)
              .toList(),
        );
      }
      throw Exception(_extractError(body, res.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Unread count (drives the bell badge) ──────────────────────────────────────

  /// GET /api/v1/notifications/in-app/unread-count/
  /// Returns the unread count, or null on any failure (caller keeps prior value).
  static Future<int?> unreadCount({required String token}) async {
    try {
      final res = await AuthHttp.send((t) => http
          .get(
            Uri.parse('$_base/api/v1/notifications/in-app/unread-count/'),
            headers: _headers(t),
          )
          .timeout(_timeout));
      if (res.statusCode != 200) return null;
      final body = _decode(res.body);
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return (data['count'] as num?)?.toInt();
      }
      return (body['count'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }

  // ── Mark one as read ──────────────────────────────────────────────────────────

  /// POST /api/v1/notifications/in-app/{id}/read/
  static Future<bool> markRead({
    required String token,
    required String id,
  }) async {
    try {
      final res = await AuthHttp.send((t) => http
          .post(
            Uri.parse('$_base/api/v1/notifications/in-app/$id/read/'),
            headers: _headers(t),
          )
          .timeout(_timeout));
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // ── Mark all as read ──────────────────────────────────────────────────────────

  /// POST /api/v1/notifications/in-app/read-all/
  /// Returns the number marked read, or null on failure.
  static Future<int?> markAllRead({required String token}) async {
    try {
      final res = await AuthHttp.send((t) => http
          .post(
            Uri.parse('$_base/api/v1/notifications/in-app/read-all/'),
            headers: _headers(t),
          )
          .timeout(_timeout));
      if (res.statusCode != 200) return null;
      final body = _decode(res.body);
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return (data['marked_read'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (_) {
      return null;
    }
  }

  // ── Device token registration (for FCM push) ──────────────────────────────────

  /// POST /api/v1/notifications/devices/ — registers this device's FCM token so
  /// the backend can target it with push notifications.
  ///
  /// NOTE: the exact path + field names must be confirmed with the backend.
  /// This sends `{registration_id, type, active}` (the django-push-notifications
  /// convention). It fails silently — push is best-effort and must never block
  /// the UI. Returns true on a 2xx response.
  static Future<bool> registerDeviceToken({
    required String token,
    required String fcmToken,
    required String platform, // 'android' | 'ios'
  }) async {
    try {
      final res = await AuthHttp.send((t) => http
          .post(
            Uri.parse('$_base/api/v1/notifications/devices/'),
            headers: _headers(t),
            body: jsonEncode({
              'registration_id': fcmToken,
              'type': platform,
              'active': true,
            }),
          )
          .timeout(_timeout));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _decode(String body) {
    try {
      final v = jsonDecode(body);
      return v is Map<String, dynamic> ? v : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static String _extractError(Map<String, dynamic> body, int statusCode) {
    if (statusCode == 401) return 'Your session has expired. Please log in again.';
    final err = body['error'];
    if (err is Map) {
      final msg = err['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    final msg = body['detail'] ?? body['message'];
    if (msg is String && msg.isNotEmpty) return msg;
    return 'Could not load notifications ($statusCode).';
  }
}
