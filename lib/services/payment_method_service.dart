import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_payment_method_model.dart';

class PaymentMethodService {
  static const _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  /// GET /api/v1/customer/payment-methods/
  static Future<List<ApiPaymentMethod>> listPaymentMethods({
    required String token,
  }) async {
    try {
      final resp = await http
          .get(
            Uri.parse('$_base/api/v1/customer/payment-methods/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      Map<String, dynamic> json;
      try {
        json = jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Server returned invalid response (Status ${resp.statusCode})');
      }

      if (resp.statusCode == 200 && (json['success'] == true || json['success'] == null)) {
        final data = json['data'] as List<dynamic>? ?? [];
        return data.map((e) => ApiPaymentMethod.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception(_extractError(json, resp.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  /// DELETE /api/v1/customer/payment-methods/{id}/
  static Future<void> deletePaymentMethod({
    required String token,
    required int id,
  }) async {
    try {
      final resp = await http
          .delete(
            Uri.parse('$_base/api/v1/customer/payment-methods/$id/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(_timeout);

      if (resp.statusCode == 204 || resp.statusCode == 200) {
        return;
      }
      
      Map<String, dynamic> json;
      try {
        json = jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Server returned invalid response (Status ${resp.statusCode})');
      }
      
      throw Exception(_extractError(json, resp.statusCode));
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  static String _extractError(Map<String, dynamic> body, int statusCode) {
    final err = body['error'];
    if (err is Map) {
      final msg = err['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    final msg = body['message'] ?? body['detail'];
    if (msg is String && msg.isNotEmpty) return msg;
    return 'Request failed ($statusCode). Please try again.';
  }
}
