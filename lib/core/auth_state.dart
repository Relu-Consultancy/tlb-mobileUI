import 'package:flutter/material.dart';

/// Global auth state. Tokens live in memory for this session.
class AuthState {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

  static String? userName;
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
    userName = name ??
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
    isLoggedIn.value = true;
  }

  static void logout() {
    userName = null;
    userEmail = null;
    userPhone = null;
    accessToken = null;
    refreshToken = null;
    userData = null;
    isLoggedIn.value = false;
  }
}
