import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/responsive.dart';

/// The format name, set **below** its circle rather than engraved inside it.
///
/// Engraving the label on the artwork gave it only the width of the disc's
/// middle — around 65px — to work in. Three of the six names ("Competition",
/// "MasterClass", "Performance") are wider than that, and Flutter breaks an
/// over-wide word mid-word rather than leaving it long, so the row showed
/// "Competiti / on" and "MasterCla / ss". Below the disc the label has the
/// whole tile width and no such constraint.
///
/// The box is a fixed two lines and the text is **top**-anchored, so the first
/// line of every label in a row sits on the same baseline whether the name
/// takes one line or two.
class FormatCircleLabel extends StatelessWidget {
  final String label;

  /// Unscaled font size, passed through [Responsive.sp].
  final double fontSize;

  final Color color;

  /// Slightly heavier for the format currently being browsed.
  final bool selected;

  const FormatCircleLabel({
    super.key,
    required this.label,
    required this.fontSize,
    this.color = Colors.white,
    this.selected = false,
  });

  static const double lineHeight = 1.2;

  /// Height of the two-line box, so a caller can size a row that holds both
  /// the disc and its label.
  static double boxHeight(BuildContext context, double fontSize) =>
      Responsive.sp(context, fontSize) * lineHeight * 2;

  @override
  Widget build(BuildContext context) {
    final size = Responsive.sp(context, fontSize);
    return SizedBox(
      height: size * lineHeight * 2,
      width: double.infinity,
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: size,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            height: lineHeight,
            color: color,
          ),
        ),
      ),
    );
  }
}
