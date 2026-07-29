import 'dart:math' as math;
import 'dart:ui' show ImageFilter, PointMode;
import 'package:flutter/material.dart';
import '../helpers/walkthrough_keys.dart';
import '../sections/home_header.dart';

/// The shared dark header used on Home, Events, Classes, Programs and Venues:
/// the universal [HomeHeader] in dark mode over a black backdrop, with a warm
/// "light from the top" glow and a faint dither grain.
///
/// The glow is a heavily Gaussian-blurred solid ellipse — NOT a gradient. A dark
/// radial gradient always shows concentric banding on 8-bit displays; a GPU blur
/// produces a smooth, high-precision falloff that cannot band.
class DarkGlowHeader extends StatelessWidget {
  final ShowcaseProfileConfig? profileShowcaseConfig;
  final ShowcaseProfileConfig? locationShowcaseConfig;

  const DarkGlowHeader({
    super.key,
    this.profileShowcaseConfig,
    this.locationShowcaseConfig,
  });

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    // ClipRect keeps the soft glow inside the header; RepaintBoundary caches the
    // blur so it isn't recomputed on every scroll.
    return RepaintBoundary(
      child: ClipRect(
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            children: [
              Positioned(
                top: -155,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: w * 0.52,
                        height: 220,
                        decoration: BoxDecoration(
                          color: const Color(0xFF937024),
                          borderRadius: BorderRadius.circular(220),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Faint grain — extra insurance against any residual banding.
              const Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _GlowGrainPainter()),
                ),
              ),
              HomeHeader(
                onDark: true,
                profileShowcaseConfig: profileShowcaseConfig,
                locationShowcaseConfig: locationShowcaseConfig,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints a very faint, deterministic salt-and-pepper grain across the header.
/// Dithering the warm glow this way hides any residual 8-bit banding without
/// visibly changing the colour. Two `drawPoints` calls (one light, one dark)
/// keep it cheap, and it never repaints (fixed seed → stable grain).
class _GlowGrainPainter extends CustomPainter {
  const _GlowGrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rnd = math.Random(42);
    // ~1 point per 90px² — dense enough to dither, light enough to be cheap.
    final int count = (size.width * size.height / 90).round().clamp(0, 7000);
    final light = <Offset>[];
    final dark = <Offset>[];
    for (int i = 0; i < count; i++) {
      final o = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      (rnd.nextBool() ? light : dark).add(o);
    }
    canvas.drawPoints(
      PointMode.points,
      light,
      Paint()
        ..color = Colors.white.withOpacity(0.025)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPoints(
      PointMode.points,
      dark,
      Paint()
        ..color = Colors.black.withOpacity(0.040)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GlowGrainPainter oldDelegate) => false;
}
