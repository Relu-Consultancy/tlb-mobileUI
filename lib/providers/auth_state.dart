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

  /// True when the user has at least filled in their first name.
  static bool get isProfileComplete {
    final profile = userData?['profile'] as Map<String, dynamic>?;
    final firstName = profile?['first_name'] as String? ?? '';
    return firstName.isNotEmpty;
  }

  /// Call after a successful updateProfile API response to sync local state.
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
  static Future<bool> tryRestoreSession() async {
    try {
      final stored = await TokenStorage.loadTokens();
      final refresh = stored['refresh'];
      if (refresh == null || refresh.isEmpty) return false;

      final result = await AuthService.refreshToken(refresh: refresh);
      if (result['success'] != true) {
        await TokenStorage.clearTokens();
        return false;
      }

      final newAccess = result['access'] as String?;
      final newRefresh = result['refresh'] as String? ?? refresh;
      if (newAccess == null) {
        await TokenStorage.clearTokens();
        return false;
      }

      Map<String, dynamic>? user;
      final userJson = stored['user_json'];
      if (userJson != null && userJson.isNotEmpty) {
        try {
          user = jsonDecode(userJson) as Map<String, dynamic>;
        } catch (_) {}
      }

      login(access: newAccess, refresh: newRefresh, user: user);
      return true;
    } catch (_) {
      await TokenStorage.clearTokens();
      return false;
    }
  }
}
