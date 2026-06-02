import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/help_ticket_model.dart';

/// REST wrapper for the Help / Support ticketing endpoints.
///
/// All methods return a result map with at least `success: bool` and either
/// the typed payload or a user-facing `message` — matches the shape used by
/// [AuthService] so screens can stay uniform.
class HelpService {
  static const String _base = 'https://tlb-api.reluconsultancy.in';

  static Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── Create ──────────────────────────────────────────────────────────────────

  /// POST /api/v1/help/tickets/
  static Future<Map<String, dynamic>> createTicket({
    required String accessToken,
    required String subject,
    required String category,
    required String body,
    String? bookingId,
  }) async {
    try {
      final reqBody = <String, dynamic>{
        'subject': subject,
        'category': category,
        'body': body,
      };
      if (bookingId != null && bookingId.isNotEmpty) {
        reqBody['booking_id'] = bookingId;
      }
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/help/tickets/'),
            headers: _authHeaders(accessToken),
            body: jsonEncode(reqBody),
          )
          .timeout(const Duration(seconds: 30));

      final decoded = _decode(res.body);
      if (res.statusCode == 201 || res.statusCode == 200) {
        final inner = _inner(decoded) ?? decoded;
        return {'success': true, 'ticket': HelpTicket.fromJson(inner)};
      }
      return {'success': false, 'message': _extractError(decoded, res.statusCode)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── List mine ───────────────────────────────────────────────────────────────

  /// GET /api/v1/help/tickets/list/
  static Future<Map<String, dynamic>> listTickets({
    required String accessToken,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/help/tickets/list/'),
            headers: _authHeaders(accessToken),
          )
          .timeout(const Duration(seconds: 30));

      final decoded = _decodeAny(res.body);
      if (res.statusCode == 200) {
        final list = _unwrapList(decoded);
        final tickets = list
            .whereType<Map<String, dynamic>>()
            .map(HelpTicket.fromJson)
            .toList();
        return {'success': true, 'tickets': tickets};
      }
      return {
        'success': false,
        'message': _extractError(
          decoded is Map<String, dynamic> ? decoded : {},
          res.statusCode,
        ),
      };
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Detail ──────────────────────────────────────────────────────────────────

  /// GET /api/v1/help/tickets/{id}/
  static Future<Map<String, dynamic>> getTicket({
    required String accessToken,
    required String ticketId,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/help/tickets/$ticketId/'),
            headers: _authHeaders(accessToken),
          )
          .timeout(const Duration(seconds: 30));

      final decoded = _decode(res.body);
      if (res.statusCode == 200) {
        final inner = _inner(decoded) ?? decoded;
        return {'success': true, 'ticket': HelpTicket.fromJson(inner)};
      }
      return {'success': false, 'message': _extractError(decoded, res.statusCode)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Messages — poll ─────────────────────────────────────────────────────────

  /// GET /api/v1/help/tickets/{id}/messages/?since=ISO_8601
  /// [since] is optional. When supplied, only messages with `created_at > since`
  /// are returned — used by the chat poller to fetch incrementals only.
  static Future<Map<String, dynamic>> getMessages({
    required String accessToken,
    required String ticketId,
    DateTime? since,
  }) async {
    try {
      final params = <String, String>{};
      if (since != null) params['since'] = since.toUtc().toIso8601String();
      final uri = Uri.parse('$_base/api/v1/help/tickets/$ticketId/messages/')
          .replace(queryParameters: params.isEmpty ? null : params);

      final res = await http
          .get(uri, headers: _authHeaders(accessToken))
          .timeout(const Duration(seconds: 30));

      final decoded = _decodeAny(res.body);
      if (res.statusCode == 200) {
        final list = _unwrapList(decoded);
        final messages = list
            .whereType<Map<String, dynamic>>()
            .map(HelpTicketMessage.fromJson)
            .toList();
        return {'success': true, 'messages': messages};
      }
      return {
        'success': false,
        'message': _extractError(
          decoded is Map<String, dynamic> ? decoded : {},
          res.statusCode,
        ),
      };
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Send message ────────────────────────────────────────────────────────────

  /// POST /api/v1/help/tickets/{id}/messages/send/
  static Future<Map<String, dynamic>> sendMessage({
    required String accessToken,
    required String ticketId,
    required String body,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/help/tickets/$ticketId/messages/send/'),
            headers: _authHeaders(accessToken),
            body: jsonEncode({'body': body}),
          )
          .timeout(const Duration(seconds: 30));

      final decoded = _decode(res.body);
      if (res.statusCode == 201 || res.statusCode == 200) {
        final inner = _inner(decoded) ?? decoded;
        return {
          'success': true,
          'message_obj': HelpTicketMessage.fromJson(inner),
        };
      }
      return {'success': false, 'message': _extractError(decoded, res.statusCode)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _decode(String body) {
    try {
      final v = jsonDecode(body);
      return v is Map<String, dynamic> ? v : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// Some list endpoints return a bare JSON array, others return the TLB
  /// `{success, data: [...]}` envelope. This decodes whichever it is.
  static dynamic _decodeAny(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  static List<dynamic> _unwrapList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final inner = decoded['data'];
      if (inner is List) return inner;
      if (inner is Map<String, dynamic> && inner['results'] is List) {
        return inner['results'] as List;
      }
      if (decoded['results'] is List) return decoded['results'] as List;
    }
    return const [];
  }

  static Map<String, dynamic>? _inner(Map<String, dynamic> body) {
    final d = body['data'];
    return d is Map<String, dynamic> ? d : null;
  }

  static String _extractError(Map<String, dynamic> body, int statusCode) {
    if (statusCode == 401) {
      return 'Your session has expired. Please log in again.';
    }
    if (statusCode == 403) {
      return "You don't have permission for this action.";
    }
    if (statusCode == 404) return 'Ticket not found.';
    if (statusCode == 429) {
      return 'Too many requests. Please wait a moment and try again.';
    }

    final error = body['error'];
    if (error is Map) {
      final msg = error['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is Map && msg.isNotEmpty) {
        final entry = msg.entries.first;
        final val = entry.value;
        if (val is List && val.isNotEmpty) return '${entry.key}: ${val.first}';
        return '${entry.key}: $val';
      }
      if (msg is List && msg.isNotEmpty) return msg.first.toString();
    }
    for (final key in ['detail', 'message', 'non_field_errors']) {
      final v = body[key];
      if (v is String && v.isNotEmpty) return v;
      if (v is List && v.isNotEmpty) return v.first.toString();
    }
    for (final entry in body.entries) {
      final v = entry.value;
      if (v is List && v.isNotEmpty) return '${entry.key}: ${v.first}';
      if (v is String && v.isNotEmpty) return '${entry.key}: $v';
    }
    return 'Something went wrong. Please try again.';
  }

  static String _networkError(Object e) {
    if (e is SocketException) {
      return 'Cannot reach server. Check your internet connection.';
    }
    if (e is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    if (e is HandshakeException) {
      return 'SSL error connecting to server.';
    }
    return 'Network error: ${e.runtimeType}';
  }
}
