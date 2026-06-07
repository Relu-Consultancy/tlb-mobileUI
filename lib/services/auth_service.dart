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
  ///
  /// [purpose] gates account auto-creation on the backend:
  ///  • `'login'`    — OTP is only sent if the email is already registered.
  ///                   Unregistered emails get a 400 `USER_NOT_FOUND` and NO
  ///                   OTP is delivered (returned here as `code: 'USER_NOT_FOUND'`).
  ///  • `'register'` — OTP is sent to any email and the account is created on
  ///                   verify. Use for the signup flow.
  ///
  /// Returns `{'success': true}` on 200, `{'success': false, 'message': ...,
  /// 'code': ...}` otherwise.
  static Future<Map<String, dynamic>> requestOtp({
    required String identifier,
    String purpose = 'register',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/request-otp/'),
            headers: _headers,
            body: jsonEncode({
              'identifier': identifier,
              'identifier_type': 'email',
              'purpose': purpose,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        final inner = _inner(body);
        return {'success': true, 'message': inner?['message'] ?? 'OTP sent'};
      }
      if (res.statusCode == 429) {
        return {'success': false, 'message': 'Too many requests. Please wait before trying again.'};
      }
      // Login attempt for an email that isn't registered — backend blocks the
      // OTP entirely. Surface a friendly, actionable message + the code so the
      // caller can route the user to signup.
      final code = (body['error'] is Map) ? body['error']['code'] : null;
      if (res.statusCode == 400 && code == 'USER_NOT_FOUND') {
        return {
          'success': false,
          'code': 'USER_NOT_FOUND',
          'message': 'Account not found. Please sign up first.',
        };
      }
      return {'success': false, 'code': code, 'message': _extractError(body)};
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

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        final inner = _inner(body) ?? body;
        return {
          'success': true,
          'access': inner['access_token'] ?? inner['access'],
          'refresh': inner['refresh_token'] ?? inner['refresh'],
          'is_new_user': _detectNewUser(inner),
          'user': inner['user'],
        };
      }
      if (res.statusCode == 400) {
        final inner = _inner(body) ?? body;
        final code = (body['error'] as Map<String, dynamic>?)?['code'] ?? inner['code'] ?? '';
        if (code == 'OTP_INVALID') return {'success': false, 'message': 'Incorrect OTP. Please try again.'};
        if (code == 'OTP_EXPIRED') return {'success': false, 'message': 'OTP has expired. Please request a new one.'};
        if (code == 'USER_ROLE_MISMATCH') return {'success': false, 'message': 'Account type mismatch.'};
      }
      if (res.statusCode == 429) {
        return {'success': false, 'message': 'Too many attempts. Please try again later.'};
      }
      return {'success': false, 'message': _extractError(body)};
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

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'message': _inner(body)?['message'] ?? ''};
      }
      return {'success': false, 'message': _extractError(body)};
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

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'reset_token': _inner(body)?['reset_token'] ?? ''};
      }
      return {'success': false, 'message': _extractError(body)};
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

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'message': _inner(body)?['message'] ?? ''};
      }
      return {'success': false, 'message': _extractError(body)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  // ── Google sign-in ───────────────────────────────────────────────────────────

  /// Exchanges a Google ID token (from Google Sign-In SDK) for TLB JWT tokens.
  static Future<Map<String, dynamic>> googleSignIn({
    required String idToken,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/v1/auth/google-login/'),
            headers: _headers,
            body: jsonEncode({'id_token': idToken}),
          )
          .timeout(const Duration(seconds: 30));

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        final inner = _inner(body) ?? body;
        return {
          'success': true,
          'access': inner['access_token'] ?? inner['access'],
          'refresh': inner['refresh_token'] ?? inner['refresh'],
          'is_new_user': _detectNewUser(inner),
          'user': inner['user'],
        };
      }
      // Surface the three documented error codes with friendly text;
      // anything else falls back to the generic extractor.
      final code = (body['error'] is Map) ? body['error']['code'] : null;
      String msg;
      switch (code) {
        case 'INVALID_GOOGLE_TOKEN':
          msg = 'Your Google sign-in token was rejected. Please try again.';
          break;
        case 'UNVERIFIED_EMAIL':
          msg = 'Your Google account email is not verified. Verify it in your Google account and try again.';
          break;
        case 'USER_ROLE_MISMATCH':
          msg = 'This email is already registered as a partner account. Use the partner app to sign in.';
          break;
        default:
          msg = _extractError(body);
      }
      return {'success': false, 'message': msg, 'code': code};
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

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'message': _inner(body)?['message'] ?? 'Password changed successfully.'};
      }
      return {'success': false, 'message': _extractError(body)};
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

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        final inner = _inner(body) ?? body;
        return {
          'success': true,
          'access': inner['access_token'] ?? inner['access'],
          'refresh': inner['refresh_token'] ?? inner['refresh'],
        };
      }
      return {'success': false, 'message': _extractError(body)};
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

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'profile': _inner(body) ?? body};
      }
      return {'success': false, 'message': _extractError(body)};
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
      final reqBody = <String, dynamic>{};
      if (firstName != null) reqBody['first_name'] = firstName;
      if (lastName != null) reqBody['last_name'] = lastName;
      if (phoneNumber != null) reqBody['phone_number'] = phoneNumber;
      if (gender != null) reqBody['gender'] = gender;
      if (birthdate != null) reqBody['birthdate'] = birthdate;
      if (region != null) reqBody['region'] = region;

      final res = await http
          .patch(
            Uri.parse('$_base/api/v1/customer/profile/'),
            headers: {
              ..._headers,
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(reqBody),
          )
          .timeout(const Duration(seconds: 30));

      final body = _decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'profile': _inner(body) ?? body};
      }
      return {'success': false, 'message': _extractError(body)};
    } catch (e) {
      return {'success': false, 'message': _networkError(e)};
    }
  }

  /// DELETE /api/v1/customer/account/ — soft-deletes the customer account.
  /// Access is revoked immediately on success; the backend keeps profile and
  /// booking history but the user can no longer authenticate.
  /// Returns `{'success': true}` on 200, `{'success': false, 'message': ...}` otherwise.
  static Future<Map<String, dynamic>> deleteAccount({
    required String accessToken,
  }) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$_base/api/v1/customer/account/'),
            headers: {
              ..._headers,
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) return {'success': true};
      if (res.statusCode == 401) {
        return {
          'success': false,
          'message': 'Your session has expired. Please log in again.',
        };
      }
      if (res.statusCode == 403) {
        return {
          'success': false,
          'message':
              'This account type cannot be deleted from the mobile app.',
        };
      }
      final body = _decode(res.body);
      return {'success': false, 'message': _extractError(body)};
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

  /// Best-effort detection of whether verify-OTP / google-login just CREATED
  /// the account (vs. logging in an existing one). The backend is inconsistent
  /// about this flag — it may live under several keys, inside the `user`
  /// object, or be absent entirely. Returns false only when no positive signal
  /// is found; callers MUST treat a freshly-created account that needs signup
  /// as untrusted and additionally verify profile completeness via
  /// [isAccountRegistered], because this flag cannot be relied on alone.
  static bool _detectNewUser(Map<String, dynamic> inner) {
    bool? readFlag(dynamic m) {
      if (m is! Map) return null;
      for (final k in ['is_new_user', 'is_new', 'new_user', 'created']) {
        final v = m[k];
        if (v is bool) return v;
        if (v is String && (v == 'true' || v == 'false')) return v == 'true';
      }
      return null;
    }

    return readFlag(inner) ?? readFlag(inner['user']) ?? false;
  }

  /// Returns true when the authenticated account has actually completed signup
  /// (a real, registered user) — i.e. the backend profile exists and is marked
  /// completed (or at least carries a first name). Used to defend against the
  /// backend auto-creating accounts for unregistered emails during an OTP
  /// LOGIN: such an account authenticates but is NOT a registered user.
  ///
  /// Defaults to `true` on a network/parse failure so we never lock a genuine
  /// returning user out because of a transient profile-fetch error — the
  /// security-critical rejection still hinges on [_detectNewUser] in that case.
  static Future<bool> isAccountRegistered({required String accessToken}) async {
    final res = await getProfile(accessToken: accessToken);
    if (res['success'] != true) return true; // fail open — don't lock out
    final profile = res['profile'];
    if (profile is! Map) return true;
    if (profile['is_completed'] == true) return true;
    final firstName = (profile['first_name'] as String?) ?? '';
    return firstName.trim().isNotEmpty;
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Unwraps the `{"success":..., "data": {...}, "error":...}` envelope.
  /// Returns the inner `data` map, or null if it is absent/not a map.
  static Map<String, dynamic>? _inner(Map<String, dynamic> body) {
    final d = body['data'];
    return d is Map<String, dynamic> ? d : null;
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

  /// Extracts the first human-readable error from a TLB API response body.
  /// Handles flat strings, lists, and DRF-style validation dicts without casting.
  static String _extractError(Map<String, dynamic> body) {
    // TLB envelope: {"error": {"code": "...", "message": "..." | {...} | [...]}}
    final error = body['error'];
    if (error is Map) {
      final msg = error['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is Map && msg.isNotEmpty) return _flattenValidationMap(msg);
      if (msg is List && msg.isNotEmpty) return msg.first.toString();
    }
    // DRF flat formats: 'detail', 'message', 'non_field_errors', or field-keyed dicts
    for (final key in ['detail', 'message', 'non_field_errors']) {
      final v = body[key];
      if (v is String && v.isNotEmpty) return v;
      if (v is List && v.isNotEmpty) return v.first.toString();
    }
    // DRF validation dict at root — e.g. {"phone_number": ["Enter a valid phone number."]}
    for (final entry in body.entries) {
      final v = entry.value;
      if (v is List && v.isNotEmpty) return '${entry.key}: ${v.first}';
      if (v is String && v.isNotEmpty) return '${entry.key}: $v';
    }
    return 'Something went wrong. Please try again.';
  }

  static String _flattenValidationMap(Map map) {
    final entry = map.entries.first;
    final val = entry.value;
    if (val is List && val.isNotEmpty) return '${entry.key}: ${val.first}';
    return '${entry.key}: $val';
  }
}
