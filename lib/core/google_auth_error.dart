import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/services.dart' show PlatformException;

/// Maps any exception thrown during the Google sign-in / signup flow to a
/// human-readable snackbar message. Designed to surface enough detail so a
/// user can tell us *what* went wrong without exposing raw stack traces.
String googleAuthErrorMessage(Object e) {
  if (e is SocketException) {
    return 'No internet connection. Please check and try again.';
  }
  if (e is TimeoutException) {
    return 'Connection timed out. Please try again.';
  }
  if (e is HandshakeException) {
    return 'Secure connection failed. Please try again.';
  }

  if (e is fb.FirebaseAuthException) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-credential':
        return 'Sign-in credentials are invalid or expired. Try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled for this app. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a minute and try again.';
      default:
        final msg = e.message?.isNotEmpty == true ? e.message : e.code;
        return 'Firebase error: $msg';
    }
  }

  if (e is PlatformException) {
    final code = e.code.toLowerCase();
    if (code.contains('cancel')) return 'Sign-in was cancelled.';
    if (code == 'network_error') {
      return 'Network error. Please check your connection.';
    }
    if (code == 'sign_in_failed') {
      // Common on Android when SHA-1 / Google services not configured.
      final extra = e.message?.isNotEmpty == true ? '\n${e.message}' : '';
      return 'Google sign-in failed (${e.code}).$extra';
    }
    return 'Sign-in failed: ${e.message ?? e.code}';
  }

  final raw = e.toString();
  if (raw.toLowerCase().contains('cancel')) {
    return 'Sign-in was cancelled.';
  }
  // Last-resort: show runtime type so we can identify unknown failure modes.
  return 'Sign-in failed (${e.runtimeType}). Please try again.';
}
