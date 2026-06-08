import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_coupon_model.dart';

/// Customer-side coupon endpoints (`/api/v1/coupons/...`).
class CouponService {
  static const String _base = 'https://tlb-api.reluconsultancy.in';
  static const _timeout = Duration(seconds: 30);

  /// POST /api/v1/coupons/validate/
  ///
  /// Previews a coupon's discount for [listingId] against [originalAmount]
  /// before booking. Requires a customer JWT with a completed profile.
  ///
  /// Always resolves to a [CouponValidationResult] — backend "invalid coupon"
  /// responses come back with `isValid: false` + an `errorMessage`; network /
  /// parse failures map to [CouponValidationResult.failure].
  static Future<CouponValidationResult> validate({
    required String token,
    required String couponCode,
    required String listingId,
    required double originalAmount,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/coupons/validate/'),
            headers: {
              'Content-Type': 'application/json',
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'coupon_code': couponCode,
              'listing_id': listingId,
              'original_amount': originalAmount.toStringAsFixed(2),
            }),
          )
          .timeout(_timeout);

      final body = _decode(res.body);
      // The validation payload may be flat or wrapped in {success, data}.
      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;

      if (res.statusCode == 200) {
        return CouponValidationResult.fromJson(data);
      }
      if (res.statusCode == 403) {
        return CouponValidationResult.failure(
          'Complete your profile to use coupons.',
          fallbackAmount: originalAmount,
        );
      }
      // 400 etc. — surface the backend message if it carried one.
      final msg = data['error_message'] as String? ??
          _envelopeError(body) ??
          'This coupon could not be applied.';
      return CouponValidationResult.failure(msg, fallbackAmount: originalAmount);
    } on SocketException {
      return CouponValidationResult.failure(
        'Cannot reach server. Check your connection.',
        fallbackAmount: originalAmount,
      );
    } on TimeoutException {
      return CouponValidationResult.failure(
        'Request timed out. Please try again.',
        fallbackAmount: originalAmount,
      );
    } catch (_) {
      return CouponValidationResult.failure(
        'Could not validate coupon. Please try again.',
        fallbackAmount: originalAmount,
      );
    }
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      final v = jsonDecode(body);
      return v is Map<String, dynamic> ? v : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static String? _envelopeError(Map<String, dynamic> body) {
    final err = body['error'];
    if (err is Map) {
      final msg = err['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    final m = body['detail'] ?? body['message'];
    return m is String && m.isNotEmpty ? m : null;
  }
}
