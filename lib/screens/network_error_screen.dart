import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../providers/connectivity_state.dart';
import '../widgets/app_loader.dart';

/// "No internet connection" — shown when the customer pulls to refresh while
/// offline (see `AppRefreshIndicator`).
///
/// Styled like the other dark state screens ("No events or bookings",
/// "Location not selected"): black page, a playful illustration, white title,
/// grey body, one yellow pill button.
///
/// A hard stop: there is no back arrow, and the system back button / back
/// swipe is blocked, so the screens behind it can't be reached until the
/// connection is back. It closes itself (popping `true`, so the caller can
/// re-run its refresh) the moment it is — from "Try Again", a network-change
/// event, a periodic re-check, or the app returning to the foreground.
///
/// Open it with [show], which never stacks a second copy.
class NetworkErrorScreen extends StatefulWidget {
  const NetworkErrorScreen({super.key});

  /// How often reachability is re-checked while the screen is up. Network
  /// events only fire when the interface changes; internet coming back on the
  /// same Wi-Fi (router or captive portal) sends none, and without this the
  /// customer would be stuck until they tapped Try Again.
  static const Duration pollEvery = Duration(seconds: 5);

  static bool _isOpen = false;

  /// Shows the screen unless it is already up, and completes with true once
  /// the connection is back. Two refreshes racing (or a second pull from a
  /// screen still mounted underneath) won't stack a second copy.
  static Future<bool> show(BuildContext context) =>
      showWith(Navigator.of(context));

  /// [show] for callers with no context under the navigator — the app-wide
  /// offline guard opens it through the root navigator's key.
  static Future<bool> showWith(NavigatorState navigator) async {
    if (_isOpen) return false;
    _isOpen = true;
    try {
      final back = await navigator.push<bool>(
        MaterialPageRoute(builder: (_) => const NetworkErrorScreen()),
      );
      return back == true;
    } finally {
      _isOpen = false;
    }
  }

  /// Whether the screen is currently showing.
  static bool get isOpen => _isOpen;

  @visibleForTesting
  static void resetForTest() => _isOpen = false;

  @override
  State<NetworkErrorScreen> createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends State<NetworkErrorScreen>
    with WidgetsBindingObserver {
  bool _checking = false;
  bool _backChecking = false;
  bool _closed = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    ConnectivityState.isOnline.addListener(_onConnectivity);
    WidgetsBinding.instance.addObserver(this);
    _poll = Timer.periodic(
      NetworkErrorScreen.pollEvery,
      (_) => ConnectivityState.refresh(),
    );
    // The connection may have come back between the failed check and this
    // screen mounting — that change would have no listener to hear it.
    if (ConnectivityState.isOnline.value == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close());
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    ConnectivityState.isOnline.removeListener(_onConnectivity);
    super.dispose();
  }

  /// Back from the background: the network may have changed while no events
  /// were being delivered.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ConnectivityState.refresh();
  }

  void _onConnectivity() {
    if (ConnectivityState.isOnline.value == true) _close();
  }

  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    _poll?.cancel();
    // Navigator.pop is not subject to PopScope, which only gates the system
    // back button and back swipe.
    Navigator.of(context).pop(true);
  }

  /// System back was blocked; re-check rather than ignore it, since the
  /// customer pressing back may have just reconnected.
  Future<void> _onBackBlocked() async {
    // Mashing back shouldn't queue a network check per press.
    if (_checking || _backChecking) return;
    _backChecking = true;
    final online = await ConnectivityState.checkNow();
    _backChecking = false;
    if (online) {
      _close();
    } else if (mounted) {
      AppSnackBar.error(
        context,
        'No internet connection. Reconnect to continue.',
      );
    }
  }

  Future<void> _retry() async {
    if (_checking) return;
    setState(() => _checking = true);
    final online = await ConnectivityState.checkNow();
    if (!mounted) return;
    setState(() => _checking = false);
    if (online) {
      _close();
    } else {
      AppSnackBar.error(context, 'Still offline. Check your connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return PopScope(
      // Blocks the Android back button and the iOS back swipe.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBackBlocked();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.black,
          // No app bar: nothing to go back to until the connection returns.
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    // Sits a little above centre, like the other state screens.
                    padding: const EdgeInsets.only(bottom: 56),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _OfflineArt(width: sw * 0.72),
                        const SizedBox(height: 28),
                        Text(
                          'No internet connection',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 19),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Check your Wi-Fi or mobile data\nand try again.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 13),
                            color: const Color(0xFF8A8FA3),
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _checking ? null : _retry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                disabledBackgroundColor: AppColors.primaryLight,
                                foregroundColor: AppColors.textPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: _checking
                                  ? const AppLoaderInline(
                                      dotSize: 7,
                                      spacing: 4,
                                      color: AppColors.textPrimary,
                                    )
                                  : Text(
                                      'Try Again',
                                      style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 14),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The illustration, drawn in code in the same language as the other state
/// screens' artwork: a glowing pink centrepiece (here a Wi-Fi-off mark with
/// signal rays), dark clouds at its base, and the scattered confetti — cyan,
/// green and pink dots, grey crosses and a yellow star.
class _OfflineArt extends StatelessWidget {
  final double width;

  const _OfflineArt({required this.width});

  static const Color _pink = Color(0xFFFF6B8B);
  static const Color _cloud = Color(0xFF24272F);
  static const Color _cloudBack = Color(0xFF1A1C22);
  static const Color _grey = Color(0xFF4A4F5C);

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = w * 0.78;
    Widget at(double x, double y, Widget child) =>
        Positioned(left: x * w, top: y * h, child: child);
    Widget dot(double size, Color c) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
    Widget ray(double angle) => Transform.rotate(
      angle: angle,
      child: Container(
        width: 5,
        height: w * 0.07,
        decoration: BoxDecoration(
          color: _pink,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );

    return ExcludeSemantics(
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Signal rays above the mark.
            at(0.40, 0.02, ray(-0.5)),
            at(0.49, 0.0, ray(0)),
            at(0.58, 0.02, ray(0.5)),
            // Soft pink glow behind the mark.
            Positioned(
              left: w * 0.27,
              top: h * 0.14,
              child: Container(
                width: w * 0.46,
                height: w * 0.46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _pink.withOpacity(0.28),
                      blurRadius: 60,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            // The mark itself, in a dark disc ringed in pink.
            Positioned(
              left: w * 0.30,
              top: h * 0.17,
              child: Container(
                width: w * 0.40,
                height: w * 0.40,
                decoration: BoxDecoration(
                  color: const Color(0xFF121318),
                  shape: BoxShape.circle,
                  border: Border.all(color: _pink, width: 4),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: _pink,
                  size: w * 0.22,
                ),
              ),
            ),
            // Clouds at the base, back layer first.
            at(
              0.04,
              0.60,
              Icon(Icons.cloud_rounded, color: _cloudBack, size: w * 0.34),
            ),
            at(
              0.60,
              0.58,
              Icon(Icons.cloud_rounded, color: _cloudBack, size: w * 0.36),
            ),
            at(
              -0.02,
              0.66,
              Icon(Icons.cloud_rounded, color: _cloud, size: w * 0.32),
            ),
            at(
              0.64,
              0.64,
              Icon(Icons.cloud_rounded, color: _cloud, size: w * 0.34),
            ),
            // Confetti.
            at(0.12, 0.30, dot(w * 0.035, const Color(0xFF5CE1E6))),
            at(0.78, 0.12, dot(w * 0.045, const Color(0xFF9BE89B))),
            at(0.70, 0.18, dot(w * 0.02, _grey)),
            at(0.86, 0.62, dot(w * 0.03, _pink)),
            at(0.10, 0.58, dot(w * 0.02, _grey)),
            at(
              0.08,
              0.10,
              Icon(Icons.close_rounded, color: _grey, size: w * 0.08),
            ),
            at(
              0.84,
              0.28,
              Icon(Icons.close_rounded, color: _grey, size: w * 0.08),
            ),
            at(
              0.80,
              0.40,
              Icon(
                Icons.star_rounded,
                color: const Color(0xFFFFD54F),
                size: w * 0.10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
