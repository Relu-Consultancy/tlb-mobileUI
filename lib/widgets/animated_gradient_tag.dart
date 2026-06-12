import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

/// A pill tag (e.g. "TLB Originals") with a very slim white border and a
/// background gradient whose colours continuously cycle through the spectrum in
/// an endless loop — the gradient never stops changing.
///
/// The colour cycle is driven by rotating the HSV hue over time, so it stays
/// vivid at every frame. Three hue-offset stops give a flowing multi-colour
/// gradient that sweeps as the hue rotates.
class AnimatedGradientTag extends StatefulWidget {
  final String text;
  final double fontSize;

  /// Duration of one full hue rotation (one colour loop).
  final Duration period;

  const AnimatedGradientTag({
    super.key,
    required this.text,
    this.fontSize = 13,
    this.period = const Duration(seconds: 8),
  });

  @override
  State<AnimatedGradientTag> createState() => _AnimatedGradientTagState();
}

class _AnimatedGradientTagState extends State<AnimatedGradientTag>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final base = _controller.value * 360.0; // current hue, 0→360 looping

        // Keep colours deep/saturated (low value) so the white text always has
        // strong contrast — no light/pale gradients.
        Color hue(double offset, {double sat = 0.9, double val = 0.6}) =>
            HSVColor.fromAHSV(1.0, (base + offset) % 360.0, sat, val).toColor();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [hue(0), hue(80), hue(160)],
            ),
            // Very slim white border (matches the reference tag outline).
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.text,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, widget.fontSize),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
