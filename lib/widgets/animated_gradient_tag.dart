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

  /// Duration of one full loop (hue rotation, or one gradient slide).
  final Duration period;

  /// When provided, the tag uses a FIXED palette (e.g. red → purple) that
  /// slowly and continuously slides inside the pill (seamless loop), instead
  /// of the full-spectrum hue cycle. Use colours that start and end the same
  /// (e.g. `[red, purple, red]`) so the slide loops without a seam.
  final List<Color>? gradientColors;

  /// Custom pill shape. Defaults to a fully-rounded pill.
  final BorderRadius? borderRadius;

  /// Inner padding around the text.
  final EdgeInsets padding;

  /// White border + drop shadow (the TLB-Signature look). Set false for a flat
  /// tag that keeps only its gradient.
  final bool showChrome;

  const AnimatedGradientTag({
    super.key,
    required this.text,
    this.fontSize = 13,
    this.period = const Duration(seconds: 8),
    this.gradientColors,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    this.showChrome = true,
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
        final LinearGradient gradient;
        if (widget.gradientColors != null) {
          // Fixed palette sliding continuously left→right. begin/end span 2
          // alignment units and translate by exactly one span over the period,
          // so with TileMode.repeated the motion loops seamlessly.
          final t = _controller.value;
          gradient = LinearGradient(
            begin: Alignment(-1.0 + 2 * t, 0.0),
            end: Alignment(1.0 + 2 * t, 0.0),
            colors: widget.gradientColors!,
            tileMode: TileMode.repeated,
          );
        } else {
          final base = _controller.value * 360.0; // current hue, 0→360 looping
          // Keep colours deep/saturated so the white text always has strong
          // contrast — no light/pale gradients.
          Color hue(double offset, {double sat = 0.9, double val = 0.6}) =>
              HSVColor.fromAHSV(1.0, (base + offset) % 360.0, sat, val).toColor();
          gradient = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [hue(0), hue(80), hue(160)],
          );
        }

        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
            gradient: gradient,
            // Very slim white border (matches the reference tag outline).
            border: widget.showChrome
                ? Border.all(color: Colors.white, width: 1)
                : null,
            boxShadow: widget.showChrome
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
