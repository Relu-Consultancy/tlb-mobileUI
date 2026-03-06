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

  late Animation<double> _logoAppear;
  late Animation<double> _logoShrink;
  late Animation<Color?> _bgColor;
  late Animation<double> _subtitleReveal;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    _logoAppear = Tween<double>(begin: 0.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.32, curve: Curves.elasticOut),
      ),
    );

    _logoShrink = Tween<double>(begin: 1.15, end: 0.65).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.52, curve: Curves.easeInOut),
      ),
    );

    _bgColor = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFFFB902),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.52, 0.75, curve: Curves.easeInOut),
      ),
    );

    _subtitleReveal = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.62, 0.82, curve: Curves.easeOut),
      ),
    );

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
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final logoSize = (screenW * 0.55).clamp(120.0, 280.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final clipFraction = _subtitleReveal.value;

        return FadeTransition(
          opacity: _fadeOut,
          child: Scaffold(
            backgroundColor: _bgColor.value,
            body: SizedBox(
              width: screenW,
              height: screenH,
              child: Center(
                child: Transform.scale(
                  scale: _logoScale,
                  child: SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          height: logoSize * clipFraction,
                          width: logoSize,
                          child: OverflowBox(
                            alignment: Alignment.topCenter,
                            maxWidth: logoSize,
                            maxHeight: logoSize,
                            child: Image.asset(
                              'assets/images/tlb_logo.png',
                              width: logoSize,
                              height: logoSize,
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
          ),
        );
      },
    );
  }
}
