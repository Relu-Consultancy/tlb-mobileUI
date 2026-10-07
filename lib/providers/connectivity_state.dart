import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Whether the device can actually reach TLB right now.
///
/// `connectivity_plus` only says which network interface is up — a phone on a
/// Wi-Fi with no internet, or behind a captive portal, still reports "wifi".
/// So its change events are used as the *trigger*, and the answer comes from
/// opening a real connection to the API host.
class ConnectivityState {
  const ConnectivityState._();

  static const String _host = 'tlb-api.reluconsultancy.in';
  static const Duration _probeTimeout = Duration(seconds: 4);

  /// Null until the first check completes; then true/false. The top toast
  /// reacts to changes of this.
  static final ValueNotifier<bool?> isOnline = ValueNotifier<bool?>(null);

  static StreamSubscription<List<ConnectivityResult>>? _sub;
  static Timer? _debounce;

  /// Test seam: how reachability is decided. Defaults to a TCP connection to
  /// the API host.
  @visibleForTesting
  static Future<bool> Function() probe = _probeApiHost;

  /// Starts listening for network changes. Safe to call more than once.
  static void init() {
    if (_sub != null) return;
    _sub = Connectivity().onConnectivityChanged.listen((_) {
      // Interfaces flap while switching (Wi-Fi → mobile data fires several
      // events); wait for them to settle before probing.
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), refresh);
    });
    refresh();
  }

  /// Re-checks reachability and publishes the result.
  static Future<bool> refresh() async {
    final online = await probe();
    isOnline.value = online;
    return online;
  }

  /// For a pull-to-refresh: a fresh check, not the last known value, since the
  /// customer may have just turned their data back on.
  static Future<bool> checkNow() => refresh();

  static Future<bool> _probeApiHost() async {
    try {
      final socket =
          await Socket.connect(_host, 443, timeout: _probeTimeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  @visibleForTesting
  static void resetForTest() {
    _sub?.cancel();
    _sub = null;
    _debounce?.cancel();
    _debounce = null;
    probe = _probeApiHost;
    isOnline.value = null;
  }
}
