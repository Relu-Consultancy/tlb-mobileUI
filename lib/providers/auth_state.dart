import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import '../services/auth_service.dart';

class AuthState {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<String?> avatarUrl = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> userName = ValueNotifier<String?>(null);

  static String? userEmail;
  static String? userPhone;
  static String? accessToken;
  static String? refreshToken;
  static Map<String, dynamic>? userData;

  static void login({
    String? name,
    String? phone,
    String? email,
    String? access,
    String? refresh,
    Map<String, dynamic>? user,
  }) {
    final profile = user?['profile'] as Map<String, dynamic>?;
    userName.value = name ??
        (profile != null
            ? '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim()
            : null) ??
        user?['email'] ??
        'User';
    userEmail = email ?? user?['email'] as String?;
    userPhone = phone ?? user?['phone'] as String?;
    accessToken = access;
    refreshToken = refresh;
    userData = user;
    avatarUrl.value = (user?['profile'] as Map<String, dynamic>?)?['avatar_url'] as String?;
    isLoggedIn.value = true;
    if (access != null && refresh != null) {
      TokenStorage.saveTokens(
              access, refresh, user != null ? jsonEncode(user) : '{}')
          .catchError((_) {});
    }
  }

  /// UUID of the authenticated customer — used to detect review ownership.
  static String? get userId => userData?['id'] as String?;

  /// First word of the stored full name, falling back to "User".
  /// Use this wherever a greeting like "Hi $firstName" is needed.
  static String get firstName {
    final name = userName.value;
    if (name == null || name.trim().isEmpty) return 'User';
    return name.trim().split(' ').first;
  }

  /// True when the profile `is_completed` flag is set, or first_name is non-empty as fallback.
  static bool get isProfileComplete {
    final profile = userData?['profile'] as Map<String, dynamic>?;
    if (profile?['is_completed'] == true) return true;
    return (profile?['first_name'] as String? ?? '').isNotEmpty;
  }

  /// Call after a successful PATCH /customer/profile/ response to sync local state.
  /// Accepts the profile object returned directly by the profile API.
  static void updateProfileData(Map<String, dynamic> profile) {
    userData ??= {};
    userData!['profile'] = profile;
    final first = profile['first_name'] as String? ?? '';
    final last = profile['last_name'] as String? ?? '';
    final fullName = '$first $last'.trim();
    if (fullName.isNotEmpty) userName.value = fullName;
    if (accessToken != null && refreshToken != null) {
      TokenStorage.saveTokens(
        accessToken!, refreshToken!, jsonEncode(userData),
      ).catchError((_) {});
    }
  }

  /// Legacy: call after a successful updateProfile API response to sync local state.
  static void updateUserProfile(Map<String, dynamic> updatedUser) {
    userData = updatedUser;
    final profile = updatedUser['profile'] as Map<String, dynamic>?;
    avatarUrl.value = profile?['avatar_url'] as String?;
    if (profile != null) {
      final first = profile['first_name'] as String? ?? '';
      final last = profile['last_name'] as String? ?? '';
      final fullName = '$first $last'.trim();
      userName.value = fullName.isNotEmpty ? fullName : (updatedUser['email'] as String? ?? 'User');
    }
    if (accessToken != null && refreshToken != null) {
      TokenStorage.saveTokens(
        accessToken!, refreshToken!, jsonEncode(updatedUser),
      ).catchError((_) {});
    }
  }

  static void logout() {
    userName.value = null;
    userEmail = null;
    userPhone = null;
    accessToken = null;
    refreshToken = null;
    userData = null;
    avatarUrl.value = null;
    isLoggedIn.value = false;
    TokenStorage.clearTokens().catchError((_) {});
  }

  /// On app start: exchange stored refresh token for a fresh access token.
  /// Returns true if session was restored, false if re-login is needed.
  /// Falls back to cached tokens when the network is unavailable so the
  /// user isn't forced to re-login every cold start on flaky connections.
  static Future<bool> tryRestoreSession() async {
    try {
      final stored = await TokenStorage.loadTokens();
      final refresh = stored['refresh'];
      final cachedAccess = stored['access'];

      // Nothing stored at all — fresh install or explicit logout.
      if ((refresh == null || refresh.isEmpty) &&
          (cachedAccess == null || cachedAccess.isEmpty)) {
        return false;
      }

      // Parse cached user data once (used in both paths below).
      Map<String, dynamic>? user;
      final userJson = stored['user_json'];
      if (userJson != null && userJson.isNotEmpty) {
        try {
          user = jsonDecode(userJson) as Map<String, dynamic>;
        } catch (_) {}
      }

      // Try to exchange the refresh token for a fresh access token.
      if (refresh != null && refresh.isNotEmpty) {
        try {
          final result = await AuthService.refreshToken(refresh: refresh);
          if (result['success'] == true) {
            final newAccess = result['access'] as String?;
            final newRefresh = result['refresh'] as String? ?? refresh;
            if (newAccess != null) {
              login(access: newAccess, refresh: newRefresh, user: user);
              return true;
            }
          }
          // Server explicitly rejected the token — clear and require re-login.
          // (Don't fall through to cache path for rejected tokens.)
          final message = (result['message'] ?? '').toString().toLowerCase();
          debugPrint('AuthService.refreshToken message: $message');
          if (message.contains('invalid') || message.contains('expired') || message.contains('blacklisted')) {
            debugPrint('Token rejected by server. Clearing tokens.');
            await TokenStorage.clearTokens();
            return false;
          }
        } catch (e) {
          debugPrint('AuthService.refreshToken threw: $e');
          // Network error — fall through to cached restore below.
        }
      }

      // Fallback: restore session from cached tokens so the user stays
      // logged in even when the network is unavailable at startup.
      if (cachedAccess != null && cachedAccess.isNotEmpty) {
        login(
          access: cachedAccess,
          refresh: refresh,
          user: user,
        );
        return true;
      }

      return false;
    } catch (_) {
      // Catastrophic error — don't clear tokens, just skip restore.
      return false;
    }
  }
}
