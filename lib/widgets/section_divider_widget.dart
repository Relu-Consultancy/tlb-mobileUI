import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';

/// Section title with short golden accent lines on either side.
///
/// Session-49 redesign: lines are now a fixed short length (not Expanded),
/// the gap between text and lines is tight (8 px), and the title uses a
/// slimmer weight (w500) per the home-screen redesign mocks.
class SectionDividerWidget extends StatelessWidget {
  final String title;

  /// Length of each accent line in logical pixels.
  final double lineLength;

  /// Base font size for the title (passed through `Responsive.sp`).
  final double fontSize;

  /// Font weight for the title.
  final FontWeight fontWeight;

  /// Color of the title text.
  final Color textColor;

  /// Color of the accent lines (defaults to the pale section gold).
  final Color lineColor;

  /// Thickness of the accent lines in logical pixels.
  final double lineThickness;

  /// Optional custom padding above the divider — the gap from the previous
  /// section's cards. Defaults to 30.
  final double topPadding;

  /// Optional custom padding below the divider. Defaults to 16.
  final double bottomPadding;

  /// When true, a small gold 4-point star sits between each accent line and
  /// the title (`— ✦ Title ✦ —`). Used by the Spotlight header.
  final bool showStars;

  /// Colour of the flanking stars (defaults to a warm gold).
  final Color starColor;

  const SectionDividerWidget({
    super.key,
    required this.title,
    this.lineLength = 72,
    this.fontSize = 17, // section titles — match home-screen style
    this.fontWeight = FontWeight.w600, // light bold
    this.textColor = AppColors.textPrimary, // dark navy (#1A1A2E)
    this.lineColor = AppColors.dividerGold,
    this.lineThickness = 1,
    this.topPadding = 30,
    this.bottomPadding = 16,
    this.showStars = false,
    this.starColor = const Color(0xFFE7A11A),
  });

  /// Titles longer than this many characters use the shorter accent line so
  /// the centered row stays within the screen width.
  static const int _kLongTitleThreshold = 16;

  /// Accent-line length applied to long titles (see [_kLongTitleThreshold]).
  /// Kept generous (not stubby) — each line sits in a `Flexible`, so it shrinks
  /// to fit on narrow screens without ever overflowing.
  static const double _kCompactLineLength = 90;

  @override
  Widget build(BuildContext context) {
    // Long titles would push the fixed-length accent lines past the screen
    // edges (RenderFlex overflow). When the title exceeds the threshold the
    // lines shrink to a compact length; shorter titles keep their original
    // length. Each line is also wrapped in a `Flexible` so it can never
    // overflow on narrow devices, without affecting short-title layout.
    final double effectiveLineLength = title.length > _kLongTitleThreshold
        ? (lineLength < _kCompactLineLength ? lineLength : _kCompactLineLength)
        : lineLength;

    final Widget titleText = Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: Responsive.sp(context, fontSize),
        fontWeight: fontWeight,
        color: textColor,
        letterSpacing: 0.2,
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: showStars
            // — ✦ Title ✦ — : a gold star between each line and the title.
            ? [
                _buildLine(isLeft: true, length: effectiveLineLength),
                const SizedBox(width: 8),
                _FourPointStar(size: 9, color: starColor),
                const SizedBox(width: 8),
                titleText,
                const SizedBox(width: 8),
                _FourPointStar(size: 9, color: starColor),
                const SizedBox(width: 8),
                _buildLine(isLeft: false, length: effectiveLineLength),
              ]
            : [
                _buildLine(isLeft: true, length: effectiveLineLength),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: titleText,
                ),
                _buildLine(isLeft: false, length: effectiveLineLength),
              ],
      ),
    );
  }

  Widget _buildLine({required bool isLeft, required double length}) {
    return Flexible(
      child: SizedBox(
        width: length,
        height: lineThickness,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLeft
                  ? [Colors.transparent, lineColor]
                  : [lineColor, Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small solid 4-point star (sparkle ✦) used to flank the Spotlight title.
class _FourPointStar extends StatelessWidget {
  final double size;
  final Color color;

  const _FourPointStar({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _FourPointStarPainter(color),
    );
  }
}

class _FourPointStarPainter extends CustomPainter {
  final Color color;

  _FourPointStarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Offset c = Offset(size.width / 2, size.height / 2);
    final double outer = size.width / 2;
    const double innerRatio = 0.34; // waist between the points
    final Path path = Path();
    for (int i = 0; i < 8; i++) {
      final double radius = i.isEven ? outer : outer * innerRatio;
      // Outer points at top / right / bottom / left.
      final double angle = (math.pi / 4) * i - math.pi / 2;
      final Offset p =
          Offset(c.dx + radius * math.cos(angle), c.dy + radius * math.sin(angle));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FourPointStarPainter oldDelegate) =>
      oldDelegate.color != color;
}
