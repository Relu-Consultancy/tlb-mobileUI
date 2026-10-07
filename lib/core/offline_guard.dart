import 'dart:async';

import 'package:flutter/widgets.dart';

import '../providers/connectivity_state.dart';
import '../screens/network_error_screen.dart';
import '../screens/splash_screen.dart';

/// Puts the No-internet screen over whatever is showing the moment the
/// connection drops — not only when the customer pulls to refresh — and lets
/// it close itself when the connection returns.
///
/// Started once from `main()` with the root navigator's key. Listens to
/// [ConnectivityState.isOnline] and to the splash hand-off; holds no widget.
class OfflineGuard {
  const OfflineGuard._();

  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _started = false;
  static bool _busy = false;

  /// How long a drop must last before the screen is shown. One failed probe
  /// on a slow or momentarily congested network shouldn't throw up a screen
  /// the customer can't leave, so the drop is confirmed with a second check.
  @visibleForTesting
  static Duration confirmAfter = const Duration(milliseconds: 1500);

  static void start(GlobalKey<NavigatorState> navigatorKey) {
    if (_started) return;
    _started = true;
    _navigatorKey = navigatorKey;
    ConnectivityState.isOnline.addListener(_check);
    SplashScreen.handedOff.addListener(_check);
  }

  static Future<void> _check() async {
    if (ConnectivityState.isOnline.value != false) return;
    // Opened offline: wait for the splash to hand over — this runs again then.
    if (!SplashScreen.handedOff.value) return;
    if (_busy || NetworkErrorScreen.isOpen) return;
    _busy = true;
    try {
      await Future<void>.delayed(confirmAfter);
      if (ConnectivityState.isOnline.value != false) return;
      if (await ConnectivityState.refresh()) return;
      final navigator = _navigatorKey?.currentState;
      if (navigator == null) return;
      // Completes once the connection is back and the screen has closed.
      await NetworkErrorScreen.showWith(navigator);
    } finally {
      _busy = false;
    }
    // A flicker — back online, then straight off again — delivers its second
    // drop while this call is still finishing, and _busy swallows it. Re-check
    // so the customer isn't left on a live screen while offline.
    if (ConnectivityState.isOnline.value == false) unawaited(_check());
  }

  @visibleForTesting
  static void resetForTest() {
    ConnectivityState.isOnline.removeListener(_check);
    SplashScreen.handedOff.removeListener(_check);
    _started = false;
    _busy = false;
    _navigatorKey = null;
    confirmAfter = const Duration(milliseconds: 1500);
  }
}
