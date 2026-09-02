import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/responsive.dart';

/// The format name engraved near the bottom of a format circle.
///
/// Returns a [Positioned], so it goes straight into the circle's [Stack].
///
/// Two things here are load-bearing, and both were wrong when the labels were
/// written inline at each call site:
///
/// * The text box is **wide**. At the old `diameter * 0.14` inset an eleven
///   character word — "Competition", "MasterClass", "Performance" — was a few
///   pixels too wide to fit, and Flutter breaks a too-long word mid-word
///   rather than not at all, which produced "Competiti / on".
/// * The box is a **fixed two lines, bottom-anchored**. Left to size itself, a
///   one-line label and a two-line one occupied different heights and floated
///   at different points against the artwork. Pinning the height means every
///   label in a row ends on the same line whatever its length.
class FormatCircleLabel extends StatelessWidget {
  final String label;

  /// Diameter of the circle this sits on; every inset is derived from it.
  final double diameter;

  /// Unscaled font size, passed through [Responsive.sp].
  final double fontSize;

  final Color color;

  const FormatCircleLabel({
    super.key,
    required this.label,
    required this.diameter,
    required this.fontSize,
    this.color = Colors.black,
  });

  /// Side inset as a fraction of [diameter]. Wide enough that no single word
  /// in the format vocabulary has to break.
  static const double insetFraction = 0.05;

  /// How far the label sits above the circle's bottom edge.
  static const double bottomFraction = 0.08;

  /// Line spacing, and the multiplier the two-line box is built from.
  static const double lineHeight = 1.15;

  @override
  Widget build(BuildContext context) {
    // Allowed to shrink on a narrow screen, never to grow. The circle it sits
    // in is a fixed diameter, so type that scales up with the screen
    // eventually makes an eleven-character word wider than the box — and
    // Flutter breaks an over-wide word mid-word rather than leaving it long.
    final size = math.min(Responsive.sp(context, fontSize), fontSize);
    return Positioned(
      left: diameter * insetFraction,
      right: diameter * insetFraction,
      bottom: diameter * bottomFraction,
      height: size * lineHeight * 2,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: size,
            fontWeight: FontWeight.w600,
            height: lineHeight,
            color: color,
            // A soft white halo, so the name stays legible wherever it lands
            // on the artwork.
            shadows: const [
              Shadow(color: Colors.white, blurRadius: 4),
              Shadow(color: Colors.white, blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}
