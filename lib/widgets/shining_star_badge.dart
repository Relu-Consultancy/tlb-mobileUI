import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The pink→orange gradient star badge (with motion lines) used on the
/// "Where Every Star Shines" cards.
///
/// A glossy highlight continuously sweeps across the badge from the top-left to
/// the bottom-right and loops, giving a "shining" effect. The sweep is drawn
/// with a `ShaderMask` in `BlendMode.srcATop`, so the highlight only appears on
/// the badge's opaque pixels (the circle + star) and never spills outside it —
/// no extra clipping geometry needed.
class ShiningStarBadge extends StatefulWidget {
  /// Box size for the SVG (the visible circle is ~80% of this, the rest is the
  /// SVG's built-in soft drop shadow).
  final double size;

  /// One full loop = sweep + a short pause before the next sweep.
  final Duration period;

  const ShiningStarBadge({
    super.key,
    this.size = 38,
    this.period = const Duration(milliseconds: 2400),
  });

  @override
  State<ShiningStarBadge> createState() => _ShiningStarBadgeState();
}

class _ShiningStarBadgeState extends State<ShiningStarBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = SvgPicture.asset(
      'assets/icons/star_badge.svg',
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );

    // The SVG circle sits in the top ~80% of the viewBox (the rest was the
    // removed drop-shadow margin). Recreate a soft shadow under it natively
    // since flutter_svg can't render the SVG's blur filter.
    final circle = widget.size * 0.80;
    final shadow = Positioned(
      left: widget.size * 0.10,
      top: widget.size * 0.03,
      child: Container(
        width: circle,
        height: circle,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );

    final shimmer = AnimatedBuilder(
        animation: _controller,
        child: badge,
        builder: (context, child) {
          // The highlight sweeps during the first ~45% of the loop, then waits
          // off-screen for the remainder so the shine pulses rather than runs
          // continuously.
          final sweep = (_controller.value / 0.45).clamp(0.0, 1.0);
          final pos = -0.25 + 1.5 * sweep; // band centre: off-left → off-right
          const half = 0.18; // half-width of the bright band

          double clamp01(double v) => v.clamp(0.0, 1.0);
          final s0 = clamp01(pos - half);
          final s1 = clamp01(pos);
          final s2 = clamp01(pos + half);
          // Stops must be strictly non-decreasing; nudge if clamping collided.
          final stops = <double>[s0, s1 <= s0 ? s0 : s1, s2 <= s1 ? s1 : s2];

          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0x00FFFFFF), // transparent white
                Color(0x99FFFFFF), // ~60% white highlight
                Color(0x00FFFFFF),
              ],
              stops: stops,
            ).createShader(rect),
            child: child,
          );
        },
      );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [shadow, shimmer],
      ),
    );
  }
}
