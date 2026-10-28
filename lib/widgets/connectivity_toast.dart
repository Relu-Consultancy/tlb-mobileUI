import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../providers/connectivity_state.dart';

/// A small pill that drops in at the top of every screen when the connection
/// goes away ("You're offline") or comes back ("Back online").
///
/// Mounted once, above the navigator, from `MaterialApp.builder`, so it shows
/// on whatever screen is open. It never takes taps while hidden.
class ConnectivityToast extends StatefulWidget {
  const ConnectivityToast({super.key});

  /// How long each message stays up.
  static const Duration offlineFor = Duration(seconds: 4);
  static const Duration onlineFor = Duration(milliseconds: 2500);

  @override
  State<ConnectivityToast> createState() => _ConnectivityToastState();
}

class _ConnectivityToastState extends State<ConnectivityToast> {
  bool? _last;
  bool _visible = false;
  bool _showingOnline = false;
  Timer? _hide;

  @override
  void initState() {
    super.initState();
    _last = ConnectivityState.isOnline.value;
    ConnectivityState.isOnline.addListener(_onChange);
  }

  @override
  void dispose() {
    ConnectivityState.isOnline.removeListener(_onChange);
    _hide?.cancel();
    super.dispose();
  }

  void _onChange() {
    final now = ConnectivityState.isOnline.value;
    final before = _last;
    _last = now;
    if (now == null || now == before) return;
    // Lost it (including opening the app already offline), or got it back
    // after having lost it. Coming online at launch is not news.
    if (now == false) {
      _show(online: false);
    } else if (before == false) {
      _show(online: true);
    }
  }

  void _show({required bool online}) {
    _hide?.cancel();
    setState(() {
      _showingOnline = online;
      _visible = true;
    });
    _hide = Timer(
      online ? ConnectivityToast.onlineFor : ConnectivityToast.offlineFor,
      () {
        if (mounted) setState(() => _visible = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 8;
    final online = _showingOnline;

    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: IgnorePointer(
        ignoring: !_visible,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          offset: _visible ? Offset.zero : const Offset(0, -1.6),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _visible ? 1 : 0,
            child: Center(
              child: Semantics(
                liveRegion: true,
                label: online ? 'Back online' : "You're offline",
                excludeSemantics: true,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: (online
                                ? AppColors.successGreen
                                : AppColors.categoryRed)
                            .withOpacity(0.55),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                          size: 18,
                          color: online
                              ? AppColors.successGreen
                              : AppColors.categoryRed,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          online ? 'Back online' : "You're offline",
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 12.5),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
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
