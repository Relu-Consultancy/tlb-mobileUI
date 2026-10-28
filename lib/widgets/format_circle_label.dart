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

  /// How much the disc of the format being browsed grows. Selection is
  /// shown by size, so the row has to leave room for it — see [rowHeight].
  static const double selectedScale = 1.12;

  /// Height of a disc-plus-label tile, including the headroom the grown
  /// disc needs.
  ///
  /// Sizing the row to the *unscaled* disc is what cut a flat edge across
  /// the top of the selected circle: the disc grew inside its tile, the
  /// list's viewport did not, and a horizontal ListView clips at its
  /// viewport. Invisible on the events row, whose artwork has transparent
  /// corners, but obvious on the classes and programs rows, where the disc
  /// is a solid white circle.
  static double rowHeight(
    BuildContext context,
    double discSize,
    double fontSize, {
    double gap = 8,
  }) =>
      discSize * selectedScale + gap + boxHeight(context, fontSize);

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
