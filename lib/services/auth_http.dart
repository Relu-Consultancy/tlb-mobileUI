import 'dart:async';
import 'package:http/http.dart' as http;
import '../providers/auth_state.dart';
import 'auth_service.dart';

/// Thrown when an authenticated request fails with 401 and the session could
/// not be refreshed. By the time this is thrown the user has been logged out,
/// so callers should route to the login screen.
class SessionExpiredException implements Exception {
  final String message;
  const SessionExpiredException(
      [this.message = 'Your session has expired. Please log in again.']);
  @override
  String toString() => message;
}

/// Centralized authenticated-request wrapper.
///
/// Wrap any protected request in [AuthHttp.send]. The wrapper attaches the
/// current access token, and on a 401 it transparently refreshes the session
/// once (coalescing concurrent refreshes), retries the request with the new
/// token, and — if the refresh fails or the retry still 401s — logs the user
/// out and throws [SessionExpiredException].
///
/// [build] must construct AND send the request (so it can be replayed with a
/// fresh token) and apply its own `.timeout(...)`. It receives the token to
/// embed in the `Authorization` header.
class AuthHttp {
  AuthHttp._();

  // A single in-flight refresh shared by every 401 that lands while it runs,
  // so a burst of concurrent 401s triggers exactly one refresh call.
  static Future<bool>? _refreshing;

  static Future<http.Response> send(
    Future<http.Response> Function(String token) build,
  ) async {
    final resp = await build(AuthState.accessToken ?? '');
    if (resp.statusCode != 401) return resp;

    final refreshed = await _refreshSession();
    if (!refreshed) {
      AuthState.logout();
      throw const SessionExpiredException();
    }

    final retry = await build(AuthState.accessToken ?? '');
    if (retry.statusCode == 401) {
      AuthState.logout();
      throw const SessionExpiredException();
    }
    return retry;
  }

  static Future<bool> _refreshSession() =>
      _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  static Future<bool> _doRefresh() async {
    final refresh = AuthState.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final result = await AuthService.refreshToken(refresh: refresh);
      if (result['success'] == true) {
        final newAccess = result['access'] as String?;
        final newRefresh = result['refresh'] as String? ?? refresh;
        if (newAccess != null && newAccess.isNotEmpty) {
          AuthState.updateTokens(access: newAccess, refresh: newRefresh);
          return true;
        }
      }
    } catch (_) {
      // Network/parse failure during refresh — treat as un-refreshed.
    }
    return false;
  }
}
