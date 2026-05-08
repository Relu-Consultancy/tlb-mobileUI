import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Thin wrapper around the TLB Auth API.
class AuthService {
  static const String _base = 'https://tlb-api.reluconsultancy.in';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
  };

  // ── OTP Login / Signup ───────────────────────────────────────────────────────

  /// Step 1: Sends a 6-digit OTP to [identifier] (email).
  /// Returns `{'success': true}` on 200, `{'success': false, 'message': ...}` otherwise.
  static Future<Map<String, dynamic>> requestOtp({
    required String identifier,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/request-otp/'),
            headers: _headers,
            body: jsonEncode({
              'identifier': identifier,
              'identifier_type': 'email',
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'OTP sent'};
      }
      if (res.statusCode == 429) {
        return {'success': false, 'message': 'Too many requests. Please wait before trying again.'};
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  /// Step 2: Verifies OTP. Creates account automatically if email is not registered.
  /// Returns `{'success': true, 'access': ..., 'refresh': ..., 'is_new_user': bool, 'user': {...}}` on 200.
  static Future<Map<String, dynamic>> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/verify-otp/'),
            headers: _headers,
            body: jsonEncode({
              'identifier': identifier,
              'otp': otp,
              'role': 'customer',
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {
          'success': true,
          'access': data['access'],
          'refresh': data['refresh'],
          'is_new_user': data['is_new_user'] ?? false,
          'user': data['user'],
        };
      }
      if (res.statusCode == 400) {
        final code = data['code'] ?? '';
        if (code == 'OTP_INVALID') return {'success': false, 'message': 'Incorrect OTP. Please try again.'};
        if (code == 'OTP_EXPIRED') return {'success': false, 'message': 'OTP has expired. Please request a new one.'};
        if (code == 'USER_ROLE_MISMATCH') return {'success': false, 'message': 'Account type mismatch.'};
      }
      if (res.statusCode == 429) {
        return {'success': false, 'message': 'Too many attempts. Please try again later.'};
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Forgot password — 3-step OTP flow ───────────────────────────────────────

  /// Step 1: Sends OTP to [email]. Returns `{'success': true}` on 200.
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/customer/password/reset/request/'),
            headers: _headers,
            body: jsonEncode({'identifier': email}),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? ''};
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  /// Step 2: Verifies OTP. Returns `{'success': true, 'reset_token': '...'}` on 200.
  static Future<Map<String, dynamic>> verifyResetOtp({
    required String identifier,
    required String code,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/customer/password/reset/verify-otp/'),
            headers: _headers,
            body: jsonEncode({'identifier': identifier, 'code': code}),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'reset_token': data['reset_token'] ?? ''};
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  /// Step 3: Sets new password using reset_token. Returns `{'success': true}` on 200.
  static Future<Map<String, dynamic>> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/customer/password/reset/confirm/'),
            headers: _headers,
            body: jsonEncode({
              'reset_token': resetToken,
              'new_password': newPassword,
              'new_password_confirm': newPasswordConfirm,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? ''};
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Google sign-in ───────────────────────────────────────────────────────────

  /// Exchanges a Firebase ID token for TLB JWT tokens.
  static Future<Map<String, dynamic>> googleSignIn({
    required String firebaseIdToken,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/customer/google/'),
            headers: _headers,
            body: jsonEncode({'firebase_id_token': firebaseIdToken}),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {
          'success': true,
          'access': data['access'],
          'refresh': data['refresh'],
          'is_new_user': data['is_new_user'] ?? false,
          'user': data['user'],
        };
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Change password ──────────────────────────────────────────────────────────

  /// Requires a valid access token. Returns `{'success': true}` on 200.
  static Future<Map<String, dynamic>> changePassword({
    required String accessToken,
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/password/change/'),
            headers: {
              ..._headers,
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'old_password': oldPassword,
              'new_password': newPassword,
              'new_password_confirm': newPasswordConfirm,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Password changed successfully.'};
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Refresh token ─────────────────────────────────────────────────────────────

  /// Returns new `{'access': ..., 'refresh': ...}` or `{'success': false, 'message': ...}`.
  static Future<Map<String, dynamic>> refreshToken({
    required String refresh,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/refresh-token/'),
            headers: _headers,
            body: jsonEncode({'refresh_token': refresh}),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'access': data['access'], 'refresh': data['refresh']};
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Customer Profile ─────────────────────────────────────────────────────────

  /// GET /api/v1/customer/profile/ — returns profile with `is_completed` flag.
  static Future<Map<String, dynamic>> getProfile({
    required String accessToken,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse('$_base/api/v1/customer/profile/'),
            headers: {
              ..._headers,
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'profile': data};
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  /// PATCH /api/v1/customer/profile/ — partial update, only sends non-null fields.
  /// Returns `{'success': true, 'profile': {...}}` on 200.
  static Future<Map<String, dynamic>> updateProfile({
    required String accessToken,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? gender,
    String? birthdate,
    String? region,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;
      if (gender != null) body['gender'] = gender;
      if (birthdate != null) body['birthdate'] = birthdate;
      if (region != null) body['region'] = region;

      final res = await http
          .patch(
            Uri.parse('$_base/api/v1/customer/profile/'),
            headers: {
              ..._headers,
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'profile': data};
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  /// Blacklists the refresh token. Returns true on success.
  static Future<bool> logout({required String refresh}) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/logout/'),
            headers: _headers,
            body: jsonEncode({'refresh_token': refresh}),
          )
          .timeout(const Duration(seconds: 30));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _decode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Converts a caught exception into a user-readable message.
  static String _networkError(Object e) {
    if (e is SocketException) {
      return 'Cannot reach server. Check your internet connection. (${e.message})';
    }
    if (e is TimeoutException) {
      return 'Request timed out. Server may be slow — try again.';
    }
    if (e is HandshakeException) {
      return 'SSL error connecting to server. (${e.message})';
    }
    return 'Network error: ${e.runtimeType}: $e';
  }

  /// Extracts the first human-readable error from a DRF response body.
  static String _extractError(Map<String, dynamic> data) {
    for (final key in ['message', 'detail', 'non_field_errors']) {
      final v = data[key];
      if (v is String && v.isNotEmpty) return v;
      if (v is List && v.isNotEmpty) return v.first.toString();
    }
    for (final v in data.values) {
      if (v is String && v.isNotEmpty) return v;
      if (v is List && v.isNotEmpty) return v.first.toString();
    }
    return 'Something went wrong. Please try again.';
  }
}
