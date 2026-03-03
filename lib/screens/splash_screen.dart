import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Phase 1 (0–35%): "tlb" appears big on white
  late Animation<double> _logoAppear;
  // Phase 2 (35–55%): "tlb" shrinks to smaller size, still white bg
  late Animation<double> _logoShrink;
  // Phase 3 (55–78%): Background white → golden yellow
  late Animation<Color?> _bgColor;
  // Phase 3b (60–80%): "the little broadway" fades in
  late Animation<double> _subtitleFade;
  // Phase 4 (88–100%): Everything fades out → navigate
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    // Big logo scales in: 0 → 1.0
    _logoAppear = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );

    // Logo shrinks: fontSize 120 → 72 (driven by 1.0 → 0.6 multiplier)
    _logoShrink = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.55, curve: Curves.easeInOut),
      ),
    );

    // Background white → golden yellow
    _bgColor = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFFFB902),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.78, curve: Curves.easeInOut),
      ),
    );

    // Subtitle fades in
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.82, curve: Curves.easeIn),
      ),
    );

    // Screen fades out
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.88, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => widget.nextScreen,
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _sizeMultiplier {
    if (_controller.value <= 0.35) return _logoAppear.value;
    return _logoShrink.value;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final fontSize = 120.0 * _sizeMultiplier;

        return FadeTransition(
          opacity: _fadeOut,
          child: Scaffold(
            backgroundColor: _bgColor.value,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "tlb" bold text
                  Text(
                    'tlb',
                    style: GoogleFonts.poppins(
                      fontSize: fontSize.clamp(0.0, 200.0),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A2E),
                      height: 1.0,
                    ),
                  ),
                  // "the little broadway" subtitle
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'the little broadway',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
