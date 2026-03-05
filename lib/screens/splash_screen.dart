import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Phase 1 (0–35%): Logo appears big on white
  late Animation<double> _logoAppear;
  // Phase 2 (35–55%): Logo shrinks, still white bg
  late Animation<double> _logoShrink;
  // Phase 3 (55–78%): Background white → golden yellow
  late Animation<Color?> _bgColor;
  // Phase 3b (65–85%): Reveal full logo - "the little broadway" appears below
  late Animation<double> _subtitleReveal;
  // Phase 4 (88–100%): Everything fades out → navigate
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    // Big logo scales in: 0 → 1.15
    _logoAppear = Tween<double>(begin: 0.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.32, curve: Curves.elasticOut),
      ),
    );

    // Logo shrinks: 1.15 → 0.65
    _logoShrink = Tween<double>(begin: 1.15, end: 0.65).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.52, curve: Curves.easeInOut),
      ),
    );

    // Background white → golden yellow
    _bgColor = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFFFB902),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.52, 0.75, curve: Curves.easeInOut),
      ),
    );

    // Reveal full logo (clip goes from 55% to 100%) - "the little broadway" appears
    _subtitleReveal = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.62, 0.82, curve: Curves.easeOut),
      ),
    );

    // Screen fades out
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.90, 1.0, curve: Curves.easeIn),
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

  double get _logoScale {
    if (_controller.value <= 0.32) return _logoAppear.value;
    return _logoShrink.value;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Initially show only top 55% (tlb), then reveal full logo (tlb + the little broadway)
        final clipFraction = _subtitleReveal.value;

        return FadeTransition(
          opacity: _fadeOut,
          child: Scaffold(
            backgroundColor: _bgColor.value,
            body: Center(
              child: Transform.scale(
                scale: _logoScale,
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: 280 * clipFraction,
                        width: 280,
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          maxWidth: 280,
                          maxHeight: 280,
                          child: Image.asset(
                            'assets/images/tlb_logo.png',
                            width: 280,
                            height: 280,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
