import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _glowScale;
  late Animation<double> _dotsFade;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    // Total splash time = 5 s. Intervals below keep the entrance crisp (same
    // absolute timing as before) and add a longer hold before the end fade.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // Logo pops in (elastic) and fades in.
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.27, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.14, curve: Curves.easeOut),
      ),
    );

    // Soft glow expands behind the logo.
    _glowScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.31, curve: Curves.easeOutCubic),
      ),
    );

    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.31, 0.42, curve: Curves.easeOut),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.92, 1.0, curve: Curves.easeIn),
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

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final logoSize = (screenW * 0.62).clamp(150.0, 320.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return FadeTransition(
            opacity: _fadeOut,
            child: Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                // Flat golden ground — the same colour the native splash
                // paints, so the handoff into Flutter is invisible.
                color: AppColors.splashGold,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Soft radial glow behind the logo.
                    Transform.scale(
                      scale: _glowScale.value,
                      child: Container(
                        width: logoSize * 1.9,
                        height: logoSize * 1.9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.45),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Logo.
                    Opacity(
                      opacity: _logoFade.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: SvgPicture.asset(
                          'assets/icons/the_little_broadway_logo.svg',
                          width: logoSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Loading dots near the bottom.
                    Positioned(
                      bottom: 56,
                      child: FadeTransition(
                        opacity: _dotsFade,
                        child: _LoadingDots(controller: _controller),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Three small dots that pulse in sequence — a subtle "loading" cue.
class _LoadingDots extends StatelessWidget {
  final AnimationController controller;
  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        // Staggered pulse driven off the main controller's tail.
        final t = ((controller.value * 3) + i * 0.33) % 1.0;
        final scale = 0.6 + 0.4 * (1 - (2 * t - 1).abs());
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFF3A2A12).withOpacity(0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
