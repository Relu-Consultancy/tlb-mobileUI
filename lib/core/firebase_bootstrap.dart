import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Centralised guard for Firebase initialisation.
///
/// `main()` calls [ensureInitialized] at startup. If init fails there (a
/// transient network issue, a config mismatch, etc.) we hold onto the error
/// instead of silently swallowing it. The Google sign-in / sign-up flows
/// then call [ensureInitialized] again before touching `FirebaseAuth` so
/// users get a real retry — and if it still fails, the snackbar can quote
/// the underlying message instead of an opaque "no-app" / "FirebaseException".
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;
  static Object? _lastError;

  /// Initialises the default Firebase app exactly once. Safe to call from
  /// many places — repeat calls are no-ops once init succeeds.
  /// Throws if init fails so callers can surface the real reason.
  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      _initialized = true;
      _lastError = null;
    } catch (e) {
      // Tolerate the "already initialized" case — different platforms throw
      // different exact types here, so match on the message.
      final msg = e.toString().toLowerCase();
      if (msg.contains('already exists') ||
          msg.contains('duplicate-app') ||
          msg.contains('[default]')) {
        _initialized = true;
        _lastError = null;
        return;
      }
      _lastError = e;
      if (kDebugMode) {
        debugPrint('[FirebaseBootstrap] init failed: ${e.runtimeType}: $e');
      }
      rethrow;
    }
  }

  static bool get isInitialized => _initialized;
  static Object? get lastError => _lastError;
}
