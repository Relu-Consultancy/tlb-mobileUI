import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api_error_text.dart';
import '../providers/auth_state.dart';
import 'auth_http.dart';

/// "Verify later": confirm a mobile number (WhatsApp OTP) or an email (email
/// OTP) on an account that is already signed in.
///
/// A contact counts as verified only after a successful OTP against that
/// contact. Signing in with an email code verifies the email and leaves the
/// mobile number unverified (e.g. when WhatsApp delivery failed), and the
/// other way round.
///
/// PROPOSED CONTRACT — the backend has no endpoint for this yet (its
/// request-otp / verify-otp are sign-in calls; used here they would create or
/// switch to a different account instead of verifying this one). The paths are
/// constants below so aligning with the real ones is a one-line change.
/// Until they exist the server answers 404, which surfaces as
/// [unavailable] — a plain "not available yet" message, never a crash.
///
///   POST /customer/phone/request-otp/  {phone}        → code on WhatsApp
///   POST /customer/phone/verify/       {phone, otp}   → marks it verified
///   POST /customer/email/request-otp/  {email}        → code by email
///   POST /customer/email/verify/       {email, otp}   → marks it verified
///
/// Every call returns `{success, message?, code?}`; none throws.
class ContactVerificationService {
  ContactVerificationService._();

  static const String _base = 'https://tlb-api.reluconsultancy.in/api/v1';
  static const String phoneRequestPath = '/customer/phone/request-otp/';
  static const String phoneVerifyPath = '/customer/phone/verify/';
  static const String emailRequestPath = '/customer/email/request-otp/';
  static const String emailVerifyPath = '/customer/email/verify/';

  static const Duration _timeout = Duration(seconds: 30);

  /// `code` when the server has no such endpoint yet.
  static const String unavailable = 'VERIFICATION_UNAVAILABLE';

  static const String _unavailableMessage =
      "Verification isn't available yet. Please try again later.";

  /// Sends a WhatsApp OTP to [phone] (E.164).
  static Future<Map<String, dynamic>> requestPhoneOtp(String phone) =>
      _post(phoneRequestPath, {'phone': phone});

  /// Confirms [otp] for [phone]. On success the number is marked verified on
  /// this device too.
  static Future<Map<String, dynamic>> verifyPhone(
    String phone,
    String otp,
  ) async {
    final r = await _post(phoneVerifyPath, {'phone': phone, 'otp': otp});
    if (r['success'] == true) AuthState.markVerified(phone: phone);
    return r;
  }

  /// Sends an email OTP to [email].
  static Future<Map<String, dynamic>> requestEmailOtp(String email) =>
      _post(emailRequestPath, {'email': email});

  /// Confirms [otp] for [email]. On success the email is marked verified.
  static Future<Map<String, dynamic>> verifyEmail(
    String email,
    String otp,
  ) async {
    final r = await _post(emailVerifyPath, {'email': email, 'otp': otp});
    if (r['success'] == true) AuthState.markVerified(email: email);
    return r;
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await AuthHttp.send(
        (token) => http
            .post(
              Uri.parse('$_base$path'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'accept': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(_timeout),
      );
      final decoded = _decode(res.body);
      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          decoded['success'] != false) {
        return {'success': true};
      }
      return {'success': false, ..._failure(res.statusCode, decoded)};
    } on SessionExpiredException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      if (kDebugMode) debugPrint('[ContactVerification] $path failed: $e');
      return {
        'success': false,
        'message':
            'Could not connect. Please check your internet connection and try again.',
      };
    }
  }

  static Map<String, dynamic> _failure(int status, Map<String, dynamic> body) {
    final error = body['error'];
    final code = error is Map ? '${error['code']}' : '';
    if (status == 404 || status == 405 || status == 501) {
      return {'code': unavailable, 'message': _unavailableMessage};
    }
    switch (code) {
      case 'OTP_INVALID':
        return {'code': code, 'message': 'Incorrect OTP. Please try again.'};
      case 'OTP_EXPIRED':
        return {
          'code': code,
          'message': 'OTP has expired. Please request a new one.',
        };
      case 'OTP_LOCKED':
        return {
          'code': code,
          'message': 'Too many incorrect attempts. Please request a new OTP.',
        };
      case 'RATE_LIMIT_EXCEEDED':
        return {
          'code': code,
          'message':
              'Too many requests. Please wait a few minutes and try again.',
        };
      case 'PHONE_IN_USE':
      case 'EMAIL_IN_USE':
        return {
          'code': code,
          'message': code == 'PHONE_IN_USE'
              ? 'This number is already linked to another account.'
              : 'This email is already linked to another account.',
        };
    }
    if (status == 429) {
      return {
        'code': code,
        'message':
            'Too many requests. Please wait a few minutes and try again.',
      };
    }
    final message = error is Map ? error['message'] : body['detail'];
    return {
      'code': code,
      'message': message is String && message.isNotEmpty
          ? ApiErrorText.readable(message)
          : ApiErrorText.fallback,
    };
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      final d = jsonDecode(body);
      return d is Map<String, dynamic> ? d : {};
    } catch (_) {
      return {};
    }
  }
}
