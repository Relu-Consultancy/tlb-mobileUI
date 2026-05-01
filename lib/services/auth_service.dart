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

  // ── Signup ──────────────────────────────────────────────────────────────────

  /// Returns `{'success': true}` on 201 or `{'success': false, 'message': '...'}`.
  static Future<Map<String, dynamic>> signup({
    required String firstName,
    required String email,
    required String password,
    required String passwordConfirm,
    String? lastName,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/customer/email/signup/'),
            headers: _headers,
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName ?? '',
              'email': email,
              'password': password,
              'password_confirm': passwordConfirm,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? ''};
      }
      return {'success': false, 'message': _extractError(data)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────────

  /// Returns `{'success': true, 'access': ..., 'refresh': ..., 'user': {...}}` on 200.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/customer/email/login/'),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      final data = _decode(res.body);
      if (res.statusCode == 200) {
        return {
          'success': true,
          'access': data['access'],
          'refresh': data['refresh'],
          'user': data['user'],
        };
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
            Uri.parse('$_base/api/v1/auth/token/refresh/'),
            headers: _headers,
            body: jsonEncode({'refresh': refresh}),
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

  // ── Update profile ───────────────────────────────────────────────────────────

  /// PATCH /api/v1/auth/users/me/ — only sends fields that are non-null.
  /// Returns `{'success': true, 'user': {...}}` on 200.
  static Future<Map<String, dynamic>> updateProfile({
    required String accessToken,
    File? avatarFile,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? city,
    String? state,
    String? guardianName,
    String? institutionName,
    String? institutionType,
  }) async {
    try {
      final uri = Uri.parse('$_base/api/v1/auth/users/me/');
      final request = http.MultipartRequest('PATCH', uri);
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.headers['accept'] = 'application/json';

      if (firstName != null) request.fields['first_name'] = firstName;
      if (lastName != null) request.fields['last_name'] = lastName;
      if (dateOfBirth != null) request.fields['date_of_birth'] = dateOfBirth;
      if (city != null) request.fields['city'] = city;
      if (state != null) request.fields['state'] = state;
      if (guardianName != null) request.fields['guardian_name'] = guardianName;
      if (institutionName != null) request.fields['institution_name'] = institutionName;
      if (institutionType != null) request.fields['institution_type'] = institutionType;

      if (avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar', avatarFile.path),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      final data = _decode(res.body);

      if (res.statusCode == 200) {
        return {'success': true, 'user': data};
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
            body: jsonEncode({'refresh': refresh}),
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
