import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

class WalkthroughIntroOverlay extends StatefulWidget {
  final VoidCallback onNext;

  const WalkthroughIntroOverlay({super.key, required this.onNext});

  @override
  State<WalkthroughIntroOverlay> createState() =>
      _WalkthroughIntroOverlayState();
}

class _WalkthroughIntroOverlayState extends State<WalkthroughIntroOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          color: Colors.black.withOpacity(0.82),
          child: SafeArea(
            child: Center(
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 28, min: 20),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    Responsive.w(context, 28, min: 20),
                    Responsive.h(context, 36, min: 28),
                    Responsive.w(context, 28, min: 20),
                    Responsive.h(context, 24, min: 18),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.45),
                        blurRadius: 48,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFCC00).withOpacity(0.08),
                        blurRadius: 60,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _IconBadge(),
                      const SizedBox(height: 26),
                      Text(
                        'Welcome to\nThe Little Broadway',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 22),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'This is your platform to discover and connect — '
                        'explore events, join classes, participate in programs, '
                        'and find amazing venues around you.',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13.5),
                          color: Colors.white.withOpacity(0.72),
                          height: 1.65,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _dismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCC00),
                            foregroundColor: const Color(0xFF1A1A2E),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Let's Go  →",
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 15),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E),
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
    );
  }
}

class _IconBadge extends StatefulWidget {
  @override
  State<_IconBadge> createState() => _IconBadgeState();
}

class _IconBadgeState extends State<_IconBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.65).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFCC00).withOpacity(0.12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFCC00).withOpacity(_glow.value),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.explore_rounded,
          color: Color(0xFFFFCC00),
          size: 38,
        ),
      ),
    );
  }
}
